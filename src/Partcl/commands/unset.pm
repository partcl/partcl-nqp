method unset(*@args) {
    my $lexpad := pir::find_dynamic_lex__PS('%LEXPAD');
    my $quiet  := 0;
    if +@args && @args[0] eq '-nocomplain' {
        $quiet := 1;
        @args.shift();
    }
    for @args -> $varname {
        my $var := $lexpad{$varname};
        if !nqp::defined($var) {
            self.error("can't unset \"$varname\": no such variable")
                unless $quiet;
        }  else {
            nqp::deletekey(
                pir::find_lex__PS("$lexpad"), 
                pir::find_lex__PS("$varname")
            );
        }
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
