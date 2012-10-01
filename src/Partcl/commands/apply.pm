method apply(*@args) {
    if +@args == 0 {
        self.error('wrong # args: should be "apply lambdaExpr ?arg1 arg2 ...?"');
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
