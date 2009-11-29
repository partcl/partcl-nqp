
our sub append($var, *@args) {
    my $lexpad := pir::find_dynamic_lex__Ps('%LEXPAD');

    my $result := $lexpad{$var};
    while @args {
        $result := $result ~ @args.shift;
    }

    set($var, $result);
}

##  "break" is special -- see "return"
INIT {
    GLOBAL::break := -> $message = '' {
        my $exception := pir::new__ps('Exception');
        $exception<type> := 60; # TCL_BREAK
        pir::throw($exception);
    }
}


our sub catch($code, $varname?) {
    my $retval := 0; # TCL_OK
    my $result;
    try { 
        $result := PmTcl::Compiler.eval($code);
        CONTROL {
            my $parrot_type := $!<type>;

            # XXX using numeric type ids is potentially fragile.
            if $parrot_type == 58 {
                $retval := 2; # TCL_RETURN
            } elsif $parrot_type == 60 {
                $retval := 3; # TCL_BREAK
            } elsif $parrot_type == 61 {
                $retval := 4; # TCL_CONTINUE
            } elsif $parrot_type == 62 {
                $retval := 1; # TCL_ERROR
            } else {
                # This isn't a standard tcl control type. Give up.
                pir::rethrow($!);
            }
            $result := $!<message>;
        }
    };
    if $varname {
        my $lexpad := pir::find_dynamic_lex__Ps('%LEXPAD');
        $lexpad{$varname} := $result;
    }
    return $retval;
}


our sub concat(*@args) {
    my $result := @args ?? string_trim(@args.shift) !! '';
    while @args {
        $result := $result ~ ' ' ~ string_trim(@args.shift);
    }
    $result;
}

##  "continue" is special -- see "return"
INIT {
    GLOBAL::continue := -> $message = '' {
        my $exception := pir::new__ps('Exception');
        $exception<type> := 61; # CONTROL_CONTINUE
        pir::throw($exception);
    }
}


##  "error" is special -- see "return"
INIT {
    GLOBAL::error := -> $message = '' {
        my $exception := pir::new__ps('Exception');
        $exception<type> := 62; # CONTROL_ERROR
        $exception<message> := $message;
        pir::throw($exception);
    }
}


our sub eval(*@args) {
    my $code := concat(|@args);
    our %EVALCACHE;
    my &sub := %EVALCACHE{$code};
    unless pir::defined__IP(&sub) {
        &sub := PmTcl::Compiler.compile($code);
        %EVALCACHE{$code} := &sub;
    }
    &sub();
}

our sub expr(*@args) { 
    my $code := pir::join(' ', @args);
    our %EXPRCACHE;
    my &sub := %EXPRCACHE{$code};
    unless pir::defined__IP(&sub) {
        my $parse := 
            PmTcl::Grammar.parse(
                $code,
                :rule('TOP_expr'),
                :actions(PmTcl::Actions) 
            );
        &sub := PAST::Compiler.compile($parse.ast);
        %EXPRCACHE{$code} := &sub;
    }
    &sub();
}

our sub for  ($init,$cond,$incr,$body) {
    eval($init);
    while expr($cond) {
        eval($body);
        eval($incr);
    }
    '';
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

our sub incr (*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "incr varName ?increment?"');
    }

    my $lexpad := pir::find_dynamic_lex__Ps('%LEXPAD');
    my $var := @args[0];
    my $val := @args[1];
    return set($var, pir::add__Nnn($lexpad{$var}, $val // 1));
}

our sub join(*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "join list ?joinString?"');
    }

    my $list := @args[0];
    my $joinString := @args[1];

    my @list :=
        PmTcl::Grammar.parse($list, :rule<list>, :actions(PmTcl::Actions) ).ast // pir::new__Ps('TclList');

    $joinString := " " unless pir::defined($joinString);

    pir::join($joinString, @list);
}

our sub global (*@args) {
    our %GLOBALS;

    ##  my %CUR_LEXPAD := DYNAMIC::<%LEXPAD>
    my %CUR_LEXPAD := pir::find_dynamic_lex__Ps('%LEXPAD');

    for @args {
        %CUR_LEXPAD{$_} := %GLOBALS{$_};     
    } 
    '';
}

our sub list(*@args) {
    return @args;
}

our sub lindex($list, $pos) {
    my @list :=
        PmTcl::Grammar.parse($list, :rule<list>, :actions(PmTcl::Actions) ).ast;

    return @list[$pos];
}

our sub llength(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "llength list"')
    }
    my @list :=
        PmTcl::Grammar.parse(@args[0], :rule<list>, :actions(PmTcl::Actions) ).ast;

    return +@list;
}

our sub proc($name, $args, $body) {
    my $parse := 
        PmTcl::Grammar.parse( $body, :rule<TOP_proc>, :actions(PmTcl::Actions) );
    my $block := $parse.ast;
    my @args  :=
        PmTcl::Grammar.parse($args, :rule<list>, :actions(PmTcl::Actions) ).ast;

    for @args {
        my @argument :=
            PmTcl::Grammar.parse($_, :rule<list>, :actions(PmTcl::Actions) ).ast;

        if +@argument == 1 { 
            $block[0].push(
                PAST::Op.new( :pasttype<bind>,
                    PAST::Var.new( :scope<keyed>,
                        PAST::Var.new( :name('lexpad'), :scope<register> ),
                        $_
                    ),
                    PAST::Var.new( :scope<parameter> )
                )
            );
        } elsif +@argument == 2 {
            $block[0].push(
                PAST::Op.new( :pasttype<bind>,
                    PAST::Var.new( :scope<keyed>,
                        PAST::Var.new( :name('lexpad'), :scope<register> ),
                        @argument[0]
                    ),
                    PAST::Var.new(
                        :scope<parameter>,
                        :viviself(PAST::Val.new( :value(@argument[1]) ))
                    )
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

our sub set($varname, $value?) {
    my $var :=
        Q:PIR {
            .local pmc varname, lexpad
            varname = find_lex '$varname'
            lexpad = find_dynamic_lex '%LEXPAD'
            %r = vivify lexpad, varname, ['Undef']
        };
    pir::copy__0PP($var, $value) if pir::defined($value);
    $var;
}

our sub source($filename) {
    PmTcl::Compiler.evalfiles($filename);
}

our sub split(*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "split string ?splitChars?"')
    }
 
    my $string     := @args[0];
    my $splitChars := @args[1] // " \r\n\t";

    if $string eq '' {
        return '';
    }

    if $splitChars eq '' {
        return pir::split__Pss('',$string);
    }

    my @result;
    my $element := '';
    for $string -> $char {
        my $active := 1;
        for $splitChars -> $sc {
            if $active {
                if $char eq $sc {
                    @result.push($element);
                    $element := '';
                    $active := 0;
                }
            }
        }
        if $active {
            $element := $element ~ $char;
        }
    };
    @result.push($element);

    @result := list(|@result); # convert to a TclList
    return @result;
}

our sub string($cmd, *@args) {
    if $cmd eq 'toupper' {
        return pir::upcase(@args[0]); 
    } elsif $cmd eq 'compare' {
        @args.shift; # assuming -nocase here.
        my $s1 := pir::upcase(@args[0]);
        my $s2 := pir::upcase(@args[1]);
        if ($s1 eq $s2) {
            return 0;
        } elsif ($s1 lt $s2) {
            return -1;
        } else {
            return 1;
        } 
    }
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


our sub switch ($string, *@args) {
    unless @args {
        pir::printerr("wrong # args: should be ``switch ?switches? string pattern body ... ?default body?''");
        return;
    }
    if +@args % 2 == 1 {
        pir::printerr("extra switch pattern with no body");
        return;
    }
    while @args {
        my $pat := @args.shift;
        my $body := @args.shift;
        if $string eq $pat || (+@args == 0 && $pat eq 'default') {
            eval($body);
            last;
        }
    }
}

our sub unset($varname) {
    Q:PIR {
        $P1 = find_lex '$varname'
        $P2 = find_dynamic_lex '%LEXPAD'
        delete $P2[$P1]
    }
}

our sub uplevel($level, *@args) {
    ##  my %LEXPAD := DYNAMIC::<%LEXPAD>
    my %LEXPAD := pir::find_dynamic_lex__Ps('%LEXPAD');

    ##  0x23 == '#'
    if pir::ord($level) == 0x23 {
        $level := %LEXPAD.depth - pir::substr($level, 1);
    }

    ##  walk up the chain of outer contexts
    while $level > 0 {
        %LEXPAD := %LEXPAD.outer;
        $level := $level - 1;
    }

    ##  now evaluate @args in the current context
    my $code := concat(|@args);
    PmTcl::Compiler.eval($code);
}


our sub while (*@args) {
    if +@args != 2 {
        error('wrong # args: should be "while test command"');
    }
    my $cond := @args[0];
    my $body := @args[1];
    while expr($cond) {
        eval($body);
    }
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
