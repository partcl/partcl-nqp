method format(*@args) {
    unless +@args {
        self.error('wrong # args: should be "format formatString ?arg arg ...?"');
    }

    nqp::sprintf(@args.shift(), @args)
}

# vim: expandtab shiftwidth=4 ft=perl6:
