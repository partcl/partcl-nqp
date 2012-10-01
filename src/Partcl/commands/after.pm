method after(*@args) {
    if +@args < 1 {
        self.error('wrong # args: should be "after option ?arg arg ...?"')
    }
    nqp::sleep(+@args[0] / 1000);
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
