our sub string(*@args) {
    if +@args <1 {
        error('wrong # args: should be "string subcommand ?argument ...?"');
    }
    my $cmd := @args.shift();

    if $cmd eq 'toupper' {
        return pir::upcase(@args[0]); 
    } elsif $cmd eq 'compare' {
        @args.shift; # assuming -nocase here.
        my $s1 := pir::upcase(@args[0]);
        my $s2 := pir::upcase(@args[1]);
        if ($s1 eq $s2) {
            return 0;
        } elsif ($s1 lt $s2) {
            return -1;
        } else {
            return 1;
        } 
    } else {
        return 'XXX';
    }
}

module _tcl {
    our sub string_trim($string) {
        Q:PIR {
            .include 'cclass.pasm'
            .local string str
            $P0 = find_lex '$string'
            str = $P0
            .local int lpos, rpos
            rpos = length str
            lpos = find_not_cclass .CCLASS_WHITESPACE, str, 0, rpos
          rtrim_loop:
            unless rpos > lpos goto rtrim_done
            dec rpos
            $I0 = is_cclass .CCLASS_WHITESPACE, str, rpos
            if $I0 goto rtrim_loop
          rtrim_done:
            inc rpos
            $I0 = rpos - lpos
            $S0 = substr str, lpos, $I0
            %r = box $S0
        };
    }
}
