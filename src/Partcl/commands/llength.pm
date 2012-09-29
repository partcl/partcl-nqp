sub llength(*@args) is export {
    if +@args != 1 {
        error('wrong # args: should be "llength list"')
    }

    +@args[0].getList();
}

# vim: expandtab shiftwidth=4 ft=perl6:
