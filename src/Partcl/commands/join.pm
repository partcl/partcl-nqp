method join(*@args) {
    if +@args < 1 || +@args > 2 {
        self.error('wrong # args: should be "join list ?joinString?"');
    }

    nqp::join(@args[1] // " ", Internals.getList(@args[0]));
}

# vim: expandtab shiftwidth=4 ft=perl6:
