method vwait(*@args) {
    if +@args != 1 {
        self.error('wrong # args: should be "vwait name"');
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
