our sub puts($x) { pir::say($x); ''; }

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
            :rule('EXPR'),
            :actions(PmTcl::Actions) 
        );
    PAST::Compiler.eval(PAST::Block.new($parse.ast));
}

our sub if(*@args) {
    if @args[0] { return eval(@args[1]); }
}

our sub proc($name, $args, $body) {
    my $parse := 
        PmTcl::Grammar.parse( $body, :rule<PROC>, :actions(PmTcl::Actions) );
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
    PAST::Compiler.compile($block);
}

our sub set($varname, $value) {
    my $lexpad := pir::find_dynamic_lex__Ps('%VARS');
    $lexpad{$varname} := $value;
    $value;
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
