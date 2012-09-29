sub vwait(*@args) is export {
    if +@args != 1 {
        error('wrong # args: should be "vwait name"');
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
