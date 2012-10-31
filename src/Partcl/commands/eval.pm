method eval(*@args) {
    if +@args < 1 {
        self.error('wrong # args: should be "eval arg ?arg ...?"');
    }
    my $code := Builtins.new.concat(|@args);
    my $tcl := pir::compreg__PS('Partcl');
    my $sub := $tcl.compile($code);
    $sub();
}

# vim: expandtab shiftwidth=4 ft=perl6:
