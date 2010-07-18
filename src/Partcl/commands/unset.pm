our sub unset(*@args) {
    my $lexpad := pir::find_dynamic_lex('%LEXPAD');
    my $quiet  := 0;
    if +@args && @args[0] eq '-nocomplain' {
        $quiet := 1;
        @args.shift();
    }
    for @args -> $varname {
        my $var := $lexpad{$varname};
        if !pir::defined($var) {
            error("can't unset \"$varname\": no such variable")
                unless $quiet;
        }  else {
            Q:PIR {
                $P1 = find_lex '$lexpad'
                $P2 = find_lex '$varname'
                delete $P1[$P2]
            }
        }
    }
    '';
}
