our sub while (*@args) {
    if +@args != 2 {
        error('wrong # args: should be "while test command"');
    }
    my $cond := @args[0];
    my $body := @args[1];
    while expr($cond) {
        eval($body);
    }
}
