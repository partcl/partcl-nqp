our sub lreverse(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "lreverse list"');
    }
    return @args[0].getList().reverse();
}

# vim: filetype=perl6:
