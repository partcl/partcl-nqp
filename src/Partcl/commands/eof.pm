our sub eof(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "eof channelId"')
    }
    my $chan := _getChannel(@args[0]);
    0;
}
