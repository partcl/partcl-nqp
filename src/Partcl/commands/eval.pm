method eval(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "eval arg ?arg ...?"');
    }
    my $code := concat(|@args);
    my &sub := Partcl::Compiler.compile($code);
    &sub();
}

# vim: expandtab shiftwidth=4 ft=perl6:
