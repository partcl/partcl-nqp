our sub string(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "string subcommand ?argument ...?"');
    }

    my @opts := <bytelength compare equal first index is last length map match range repeat replace reverse tolower totitle toupper trim trimleft trimright wordend wordstart>;
    my $cmd := _tcl::select_option(@opts, @args.shift(), 'subcommand');

    if $cmd eq 'bytelength' {
        if +@args != 1 {
            error('wrong # args: should be "string bytelength string"');
        }

        return pir::bytelength__is(~@args[0]);
    } elsif $cmd eq 'compare' {
        if +@args == 3 {
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
            return '';
        }
    } elsif $cmd eq 'equal' {
        return '';
    } elsif $cmd eq 'first' {
        if +@args < 2 || +@args > 3 {
            error('wrong # args: should be "string first needleString haystackString ?startIndex?"');
        }

        my $needle   := @args[0];
        my $haystack := @args[1];
        my $index    := $haystack.getIndex(@args[2] // 0);
        if $index < 0 { $index := 0 }

        return pir::index__issi($haystack, $needle, $index);
    } elsif $cmd eq 'index' {
        if +@args != 2 {
            error('wrong # args: should be "string index string charIndex"');
        } 
        my $haystack := @args[0];
        my $index    := $haystack.getIndex(@args[1]);
        if $index < 0 || $index > pir::length__is($haystack) {
            return '';
        }
        return pir::substr__ssii($haystack, $index, 1);
    } elsif $cmd eq 'is' {
        return '';
    } elsif $cmd eq 'last' {
        if +@args > 3 || +@args < 2 {
            error('wrong # args: should be "string last needleString haystackString ?startIndex?"');
        }
        my $needle    := @args[0];
        my $haystack  := @args[1];
        my $start_pos := pir::length__is($haystack);
        if +@args == 3 {
            my $index := $haystack.getIndex(@args[2]);
            if $index < $start_pos {
                $start_pos := $index;
            }
        }

        # XXX This algorithm loops through from string start -
        # Does parrot provide a more natural way to do this?
        my $cur_pos := pir::index__issi($haystack, $needle, 0);
        if $cur_pos > $start_pos || $cur_pos < 0 {
            return -1;
        }

        my $test_pos;
        while $cur_pos >= 0 && $cur_pos <= $start_pos {
            $test_pos := $cur_pos;
            $cur_pos := pir::index__issi($haystack, $needle, ($cur_pos+1));
        }
        return($test_pos);
    } elsif $cmd eq 'length' {
        if +@args != 1 {
            error('wrong # args: should be "string length string"');
        }

        return pir::bytelength__is(~@args[0]);
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

# vim: filetype=perl6:
