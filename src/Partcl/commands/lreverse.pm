sub lreverse(*@args) is export {
    if +@args != 1 {
        error('wrong # args: should be "lreverse list"');
    }
    return @args[0].getList().reverse();
}

# vim: expandtab shiftwidth=4 ft=perl6:
