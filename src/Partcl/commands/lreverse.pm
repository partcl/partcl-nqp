method lreverse(*@args) {
    if +@args != 1 {
        self.error('wrong # args: should be "lreverse list"');
    }
    return @args[0].getList().reverse();
}

# vim: expandtab shiftwidth=4 ft=perl6:
