our sub proc(*@args) {
    if +@args != 3 {
        error('wrong # args: should be "proc name args body"');
    }

    my $name := @args[0];
    my $args := @args[1];
    my $body := @args[2];

    my $parse :=
        Partcl::Grammar.parse( $body, :rule<TOP_proc>, :actions(Partcl::Actions) );
    my $block    := $parse.ast;
    my @params   := $args.getList();
    my @argsInfo := pir::new('TclList');
    my %defaults := pir::new('TclArray');

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
            %defaults{$_} := pir::new('Undef');
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
            error("too many fields in argument specifier \"$_\"");
        }


    }
    $block.name($name);
    $block.control('return_pir');
    PAST::Compiler.compile($block);
    my $thing := pir::get_hll_global__PS($name);
    pir::setprop($thing, 'args', @argsInfo);
    pir::setprop($thing, 'defaults', %defaults);
    pir::setprop($thing, 'body', $body);
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
