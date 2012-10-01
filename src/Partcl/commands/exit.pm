method exit(*@args) {
    if +@args > 1 {
        self.error('wrong # args: should be "exit ?returnCode?"');
    }
    my $code := @args[0] // 0;
    nqp::exit($code);
}

# vim: expandtab shiftwidth=4 ft=perl6:
