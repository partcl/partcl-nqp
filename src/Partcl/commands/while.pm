method while(*@args) {
    if +@args != 2 {
        self.error('wrong # args: should be "while test command"');
    }
    my $cond := @args[0];
    my $body := @args[1];
    while expr($cond) {
        eval($body);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
