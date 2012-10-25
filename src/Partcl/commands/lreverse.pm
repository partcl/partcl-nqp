method lreverse(*@args) {
    if +@args != 1 {
        self.error('wrong # args: should be "lreverse list"');
    }
    return Internals.getList(@args[0]).reverse();
}

# vim: expandtab shiftwidth=4 ft=perl6:
