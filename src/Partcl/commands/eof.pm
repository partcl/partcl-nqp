method eof(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "eof channelId"')
    }
    my $chan := _getChannel(@args[0]);
    0;
}

# vim: expandtab shiftwidth=4 ft=perl6:
