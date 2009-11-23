
our sub concat(*@args) {
    my $result := @args ?? string_trim(@args.shift) !! '';
    while @args {
        $result := $result ~ ' ' ~ string_trim(@args.shift);
    }
    $result;
}

our sub eval(*@args) {
    my $code := concat(|@args);
    PmTcl::Compiler.eval($code);
}

our sub expr(*@args) { 
    my $parse := 
        PmTcl::Grammar.parse(
            pir::join(' ', @args), 
            :rule('TOP_expr'),
            :actions(PmTcl::Actions) 
        );
    PAST::Compiler.eval($parse.ast);
}

our sub for  ($init,$cond,$incr,$body) {
    eval($init);
    while expr($cond) {
        eval($body);
        eval($incr);
    }
}

our sub if(*@args) {
    while @args {
        my $expr := @args.shift;
        my $body := @args.shift;
        $body := @args.shift if $body eq 'then';
        if expr($expr) { return eval($body); }
        if @args {
            my $else := @args.shift;
            if $else ne 'elseif' {
                $else := @args.shift if $else eq 'else';
                return eval($else);
            }
        }
    }
    '';
}

our sub incr ($var,$val?) {
    my $lexpad := pir::find_dynamic_lex__Ps('%LEXPAD');
    $val := 1 unless $val;
    $lexpad{$var} := $lexpad{$var} + $val;
    $lexpad{$var};
}

our sub global () {
}

our sub proc($name, $args, $body) {
    my $parse := 
        PmTcl::Grammar.parse( $body, :rule<TOP_proc>, :actions(PmTcl::Actions) );
    my $block := $parse.ast;
    my @args  := pir::split(' ', $args);
    for @args {
        if $_ gt '' {
            $block[0].push(
                PAST::Op.new( :pasttype<bind>,
                    PAST::Var.new( :scope<keyed>,
                        PAST::Var.new( :name('lexpad'), :scope<register> ),
                        $_
                    ),
                    PAST::Var.new( :scope<parameter> )
                )
            );
        }
    }
    $block.name($name);
    $block.control('return_pir');
    PAST::Compiler.compile($block);
}

our sub puts(*@args) {
    my $nl := 1;
    if @args[0] eq '-nonewline' {
        @args.shift; $nl := 0;
    }
    if @args[0] eq 'stdout' { @args.shift }
    if @args[0] eq 'stderr' {
        @args.shift;
        pir::printerr(@args[0]);
        pir::printerr("\n") if $nl;
    } else {
        pir::print(@args[0]);
        pir::print("\n") if $nl;
    }
    '';
}

##  "return" is special -- we want to be able to throw a
##  CONTROL_RETURN exception without the sub itself catching
##  it.  So we create a bare block for the return (bare blocks
##  don't catch return exceptions) and bind it manually into 
##  the (global) namespace when loaded.
INIT {
    GLOBAL::return := -> $result = '' { return $result; }
}

our sub set($varname, $value) {
    my $lexpad := pir::find_dynamic_lex__Ps('%LEXPAD');
    $lexpad{$varname} := $value;
    $value;
}

our sub source($filename) {
    PmTcl::Compiler.evalfiles($filename);
}

our sub string_trim($string) {
    Q:PIR {
        .include 'cclass.pasm'
        .local string str
        $P0 = find_lex '$string'
        str = $P0
        .local int lpos, rpos
        rpos = length str
        lpos = find_not_cclass .CCLASS_WHITESPACE, str, 0, rpos
      rtrim_loop:
        unless rpos > lpos goto rtrim_done
        dec rpos
        $I0 = is_cclass .CCLASS_WHITESPACE, str, rpos
        if $I0 goto rtrim_loop
      rtrim_done:
        inc rpos
        $I0 = rpos - lpos
        $S0 = substr str, lpos, $I0
        %r = box $S0
    };
}


our sub uplevel($level, *@args) {
    ##  my %LEXPAD := DYNAMIC::<%LEXPAD>
    my %LEXPAD := pir::find_dynamic_lex__Ps('%LEXPAD');

    ##  walk up the chain of outer contexts
    while $level > 0 {
        %LEXPAD := %LEXPAD.outer;
        $level := $level - 1;
    }

    ##  now evaluate @args in the current context
    my $code := concat(|@args);
    PmTcl::Compiler.eval($code);
}


##  EXPAND is a helper sub for {*} argument expansion; it probably
##  doesn't belong in the global namespace but this is a convenient
##  place to test it for now.  It takes a string and splits it up
##  into a list of elements, honoring braces and backslash
##  expansion (similar to the Tcl_SplitList function).  The actual
##  parsing and expansion is handled by the <list> token in
##  PmTcl::Grammar .
our sub EXPAND($args) {
    PmTcl::Grammar.parse($args, :rule<list>, :actions(PmTcl::Actions) ).ast;
}
