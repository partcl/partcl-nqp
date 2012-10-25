method llength(*@args) {
    if +@args != 1 {
        self.error('wrong # args: should be "llength list"')
    }

    +Internals.getList(@args[0]);
}

# vim: expandtab shiftwidth=4 ft=perl6:
