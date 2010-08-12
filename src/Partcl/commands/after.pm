our sub after(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "after option ?arg arg ...?"')
    }
    pir::sleep__vN(+@args[0] / 1000);
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
