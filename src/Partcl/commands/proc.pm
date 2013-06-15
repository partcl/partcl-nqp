method proc(*@args) {
    if +@args != 3 {
        self.error('wrong # args: should be "proc name args body"');
    }

    my $name := @args[0];
    my $args := @args[1];
    my $body := @args[2];

    my $parse := Partcl::Compiler.parse(
        $body,
        :rule<TOP_proc>,
        :actions(Partcl::Actions)
    );

    my $block    := $parse.ast;
    my @params   := Internals.getList($args);
    my @argsInfo := TclList.new();
    my %defaults := TclArray.new();

    for @params {
        my @argument := Internals.getList($_);

        if +@argument == 1 {
            # TODO: Add an argument declaration for this parameter.
            # default to an undef if no value passed.
        } elsif +@argument == 2 {
            # TODO: Add an argument declaration for this parameter.
            # default to the second value
        } else {
            self.error("too many fields in argument specifier \"$_\"");
        }
    }
    $block.name($name);
    $block.control('return_pir');

    ## compile() returns an Eval. extract out the first sub, which is our proc.
    my $thing := PAST::Compiler.compile($block)[0];

    pir::setprop__vPSP($thing, 'args', @argsInfo);
    pir::setprop__vPSP($thing, 'defaults', %defaults);
    pir::setprop__vPSP($thing, 'body', $body);

    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
