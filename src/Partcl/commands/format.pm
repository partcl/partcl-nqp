our sub format(*@args) {
    unless +@args {
        error('wrong # args: should be "format formatString ?arg arg ...?"');
    }

    pir::sprintf__ssp(@args.shift(), @args)
}
