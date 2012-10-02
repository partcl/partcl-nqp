method list(*@args) {
    my @a := TclList.new;
    for @args -> $elem {
        nqp::push(@a, $elem);
    }
    @a;
}

# vim: expandtab shiftwidth=4 ft=perl6:
