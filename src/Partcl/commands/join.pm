sub join(*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "join list ?joinString?"');
    }

    pir::join(@args[1] // " ", @args[0].getList());
}

# vim: expandtab shiftwidth=4 ft=perl6:
