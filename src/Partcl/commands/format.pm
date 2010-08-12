our sub format(*@args) {
    unless +@args {
        error('wrong # args: should be "format formatString ?arg arg ...?"');
    }

    pir::sprintf__ssp(@args.shift(), @args)
}

# vim: expandtab shiftwidth=4 ft=perl6:
