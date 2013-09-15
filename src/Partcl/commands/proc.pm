method proc(*@args) {
    if +@args != 3 {
        self.error('wrong # args: should be "proc name args body"');
    }

    my $name := @args[0];
    my $args := @args[1];
    my $body := @args[2];

    my $parse := nqp::getcomp('Partcl').parse(
        $body,
        :rule<TOP_eval>,
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

    my &sub := nqp::getcomp('Partcl').compile($parse.ast, :from("ast"));
    Builtins.HOW.add_method(Builtins, $name, &sub);

    # manually insert this where we can find it later.
    # XXX how to do this without parrot?
    #pir::setprop__vPSP(&sub, 'args',     @argsInfo);
    #pir::setprop__vPSP(&sub, 'defaults', %defaults);
    #pir::setprop__vPSP(&sub, 'body',     $body);

    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
