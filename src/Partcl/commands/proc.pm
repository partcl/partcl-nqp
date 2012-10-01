method proc(*@args) {
    if +@args != 3 {
        self.error('wrong # args: should be "proc name args body"');
    }

    my $name := @args[0];
    my $args := @args[1];
    my $body := @args[2];

    my $parse :=
        Partcl::Grammar.parse( $body, :rule<TOP_proc>, :actions(Partcl::Actions) );
    my $block    := $parse.ast;
    my @params   := $args.getList();
    my @argsInfo := pir::new__PS('TclList');
    my %defaults := pir::new__PS('TclArray');

    for @params {
        my @argument := $_.getList();

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
            @argsInfo.push($_);
            %defaults{$_} := pir::new__PS('Undef');
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
            @argsInfo.push(@argument[0]);
            %defaults{@argument[0]} := @argument[1];
        } else {
            self.error("too many fields in argument specifier \"$_\"");
        }
    }
    $block.name($name);
    $block.control('return_pir');

    if ! nqp::isnull(pir::find_dynamic_lex__PS('@*PARTCL_COMPILER_NAMESPACE')) {
        $block.namespace(@*PARTCL_COMPILER_NAMESPACE);
    }

    ## compile() returns an Eval. extract out the first sub, which is our proc.
    my $thing := PAST::Compiler.compile($block)[0];

    pir::setprop__vPSP($thing, 'args', @argsInfo);
    pir::setprop__vPSP($thing, 'defaults', %defaults);
    pir::setprop__vPSP($thing, 'body', $body);

    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
