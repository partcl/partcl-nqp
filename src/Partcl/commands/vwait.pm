our sub vwait(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "vwait name"');
    }
    '';
}
