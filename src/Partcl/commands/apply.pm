our sub apply(*@args) {
    if +@args == 0 {
        error('wrong # args: should be "apply lambdaExpr ?arg1 arg2 ...?"');
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
