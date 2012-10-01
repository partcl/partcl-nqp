method format(*@args) {
    unless +@args {
        error('wrong # args: should be "format formatString ?arg arg ...?"');
    }

    pir::sprintf__SSP(@args.shift(), @args)
}

# vim: expandtab shiftwidth=4 ft=perl6:
