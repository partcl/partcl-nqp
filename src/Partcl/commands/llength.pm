our sub llength(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "llength list"')
    }

    +@args[0].getList();
}

# vim: filetype=perl6:
