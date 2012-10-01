method llength(*@args) {
    if +@args != 1 {
        self.error('wrong # args: should be "llength list"')
    }

    +@args[0].getList();
}

# vim: expandtab shiftwidth=4 ft=perl6:
