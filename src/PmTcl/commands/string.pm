our sub string(*@args) {
    if +@args <1 {
        error('wrong # args: should be "string subcommand ?argument ...?"');
    }
    my $cmd := @args.shift();

    if $cmd eq 'bytelength' {
        if +@args != 1 {
            error('wrong # args: should be "string bytelength string"');
        }

        return pir::bytelength__is(~@args[0]);
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
    } elsif $cmd eq 'equal' {
        return '';
    } elsif $cmd eq 'first' {
        if +@args < 2 || +@args > 3 {
            error('wrong # args: should be "string first needleString haystackString ?startIndex?"');
        }

        my $needle   := @args[0];
        my $haystack := @args[1];
        # XXX getIndex
        my $index    := @args[2]; # defaults to 0
        if $index < 0 { $index := 0};

        return pir::index__issi($haystack, $needle, $index);
    } elsif $cmd eq 'index' {
        return '';
    } elsif $cmd eq 'is' {
        return '';
    } elsif $cmd eq 'last' {
        return '';
    } elsif $cmd eq 'length' {
        return '';
    } elsif $cmd eq 'map' {
        return '';
    } elsif $cmd eq 'match' {
        return '';
    } elsif $cmd eq 'range' {
        return '';
    } elsif $cmd eq 'repeat' {
        return '';
    } elsif $cmd eq 'replace' {
        return '';
    } elsif $cmd eq 'reverse' {
        return '';
    } elsif $cmd eq 'tolower' {
        return '';
    } elsif $cmd eq 'totitle' {
        return '';
    } elsif $cmd eq 'toupper' {
        return pir::upcase(@args[0]); 
    } elsif $cmd eq 'trim' {
        return '';
    } elsif $cmd eq 'trimleft' {
        return '';
    } elsif $cmd eq 'trimright' {
        return '';
    } elsif $cmd eq 'wordend' {
        return '';
    } elsif $cmd eq 'wordstart' {
        return '';
    }

    # invalid subcommand.
    error("unknown or ambiguous subcommand \"$cmd\": must be bytelength, compare, equal, first, index, is, last, length, map, match, range, repeat, replace, reverse, tolower, totitle, toupper, trim, trimleft, trimright, wordend, or wordstart");
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
