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

        my $nocase   := 0; 
        my $len      := -1;
        my $bad_args := 0;

        $bad_args :=1 if +@args < 2;

        while +@args > 2 {
            my $flag := @args.shift;
            if $flag eq '-length' {
                $len := @args.shift;
            } elsif $flag eq '-nocase' {
                $nocase := 1;
            } else {
                $bad_args := 1;
                last;
            }
        }
        # flags_done:
        if $bad_args { 
            error('wrong # args: should be "string equal ?-nocase? ?-length int? string1 string2"');
        }

        my $a := @args[0];
        my $b := @args[1];

        if $nocase {
            $a := pir::downcase__ss($a);
            $b := pir::downcase__ss($b);
        }
        if $len != -1 {
            $a := pir::substr__ssii($a,0,$len);
            $b := pir::substr__ssii($b,0,$len);
        }

        return $a eq $b;
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

        return pir::length__is(@args[0]);
    } elsif $cmd eq 'map' {
        return '';
    } elsif $cmd eq 'match' {
        if +@args < 2 || +@args > 3 {
           error('wrong # args: should be "string match ?-nocase? pattern string"');
        }

        my $nocase := 0;
        if +@args == 3 {
            my $option := @args.shift();
            if $option ne '-nocase' {
                error('bad option "$option": must be -nocase');
            }
            $nocase := 1; 
        }
        my $pattern := @args[0];
        my $string  := @args[1];
        if $nocase {
            $pattern := pir::downcase__ss($pattern);
            $string  := pir::downcase__ss($string);
        }

        ## my &dumper := Q:PIR { %r = get_root_global ['parrot'], '_dumper' };
        ## &dumper(StringGlob::Compiler.compile($pattern, :target<parse>));
        my $globber := StringGlob::Compiler.compile($pattern);
        ?Regex::Cursor.parse($string, :rule($globber), :c(0));
    } elsif $cmd eq 'range' {
        if +@args != 3 {
            error('wrong # args: should be "string range string first last"')
        }

        my $string := @args[0];
        my $first  := $string.getIndex(@args[1]);
        my $last   := $string.getIndex(@args[2]);

        return '' if $first > $last;
        $first := 0 if $first < 0;

        my $last_index := pir::length__is($string) - 1;
        $last := $last_index if $last > $last_index;

        return pir::substr__ssii($string, $first, $last-$first+1)
    } elsif $cmd eq 'repeat' {
        if +@args != 2 {
            error('wrong # args: should be "string repeat string count"');
        }
        my $string := @args[0];
        my $repeat := +@args[1];

        if $repeat < 0 { return '' }

        return pir::repeat__ssi($string, $repeat);
    } elsif $cmd eq 'replace' {
        if +@args <3 || +@args >4 {
            error('wrong # args: should be "string replace string first last ?string?"');
        }

        my $string := @args[0];
        my $string_len := pir::length__is($string);
        my $replacement := @args[3] // '';

        my $low := $string.getIndex(@args[1]);
        
        return $string if $low >= $string_len;

        my $high := $string.getIndex(@args[2]);

        return $string if $high < $low;

        $low := 0 if $low < 0;
   
        $high := $string_len if $high > $string_len; 
 
        my $chunk_len := $high - $low + 1; 
        return Q:PIR {
            $P0 = find_lex '$string'
            $S0 = $P0
            $P0 = find_lex '$low'
            $I0 = $P0
            $P0 = find_lex '$chunk_len'
            $I1 = $P0
            $P0 = find_lex '$replacement'
            $S1 = $P0
            substr $S0, $I0, $I1, $S1
            $P0 = box $S0
            %r = $P0
        }
    } elsif $cmd eq 'reverse' {
        return '';
    } elsif $cmd eq 'tolower' {
        if +@args <1 || +@args >3 {
            error('wrong # args: should be "string tolower string ?first? ?last?"')
        }

        my $orig_str := @args[0];
        my $orig_len := pir::length__is($orig_str);
        # If no range is specified, do to all the string

        my $first; my $last;

        if pir::defined(@args[1]) {
            $first := $orig_str.getIndex(@args[1]);
            if pir::defined(@args[2]) {
                $last := $orig_str.getIndex(@args[2]);
            } else {
                $last := $first;
            }
        } else {
            $first := 0;
            $last  := $orig_len;
        }

        return $orig_str if $first > $orig_len;

        $last := $orig_len if $last > $orig_len;

        my $chunk_len := $last - $first + 1;

        return Q:PIR {
            $P0 = find_lex '$orig_str'
            $S0 = $P0
            $P0 = find_lex '$first'
            $I0 = $P0
            $P0 = find_lex '$chunk_len'
            $I1 = $P0
            $S1 = substr $S0, $I0, $I1
            downcase $S1
            substr $S0, $I0, $I1, $S1
            $P0 = box $S0
            %r = $P0
        }
    } elsif $cmd eq 'totitle' {
        if +@args <1 || +@args >3 {
            error('wrong # args: should be "string totitle string ?first? ?last?"')
        }

        my $orig_str := @args[0];
        my $orig_len := pir::length__is($orig_str);
        # If no range is specified, do to all the string

        my $first; my $last;

        if pir::defined(@args[1]) {
            $first := $orig_str.getIndex(@args[1]);
            if pir::defined(@args[2]) {
                $last := $orig_str.getIndex(@args[2]);
            } else {
                $last := $first;
            }
        } else {
            $first := 0;
            $last  := $orig_len;
        }

        return $orig_str if $first > $orig_len;

        $last := $orig_len if $last > $orig_len;

        my $chunk_len := $last - $first + 1;

        return Q:PIR {
            $P0 = find_lex '$orig_str'
            $S0 = $P0
            $P0 = find_lex '$first'
            $I0 = $P0
            $P0 = find_lex '$chunk_len'
            $I1 = $P0
            $S1 = substr $S0, $I0, $I1
            titlecase $S1
            substr $S0, $I0, $I1, $S1
            $P0 = box $S0
            %r = $P0
        }
    } elsif $cmd eq 'toupper' {
        if +@args <1 || +@args >3 {
            error('wrong # args: should be "string toupper string ?first? ?last?"')
        }

        my $orig_str := @args[0];
        my $orig_len := pir::length__is($orig_str);
        # If no range is specified, do to all the string

        my $first; my $last;

        if pir::defined(@args[1]) {
            $first := $orig_str.getIndex(@args[1]);
            if pir::defined(@args[2]) {
                $last := $orig_str.getIndex(@args[2]);
            } else {
                $last := $first;
            }
        } else {
            $first := 0;
            $last  := $orig_len;
        }

        return $orig_str if $first > $orig_len;

        $last := $orig_len if $last > $orig_len;

        my $chunk_len := $last - $first + 1;

        return Q:PIR {
            $P0 = find_lex '$orig_str'
            $S0 = $P0
            $P0 = find_lex '$first'
            $I0 = $P0
            $P0 = find_lex '$chunk_len'
            $I1 = $P0
            $S1 = substr $S0, $I0, $I1
            upcase $S1
            substr $S0, $I0, $I1, $S1
            $P0 = box $S0
            %r = $P0
        }
    } elsif $cmd eq 'trim' {
        return '';
    } elsif $cmd eq 'trimleft' {
        if +@args <1 || +@args >2 {
            error('wrong # args: should be "string trimleft string ?chars?"');
        }

        my $string := @args[0];
        my $chars  := @args[1] // " \t\r\n";

        my $pos       := 0;
        my $found_pos := 0;
        my $string_len := pir::length__is($string);
        while ($pos < $string_len) && ($found_pos >= 0) {
            my $char      := pir::chr__si(pir::ord__isi($string, $pos));
            $found_pos := pir::index__iss($chars, $char);
            $pos++;
        }
        $pos-- if $pos != 0;
        return Q:PIR {
            $P0 = find_lex '$string'
            $S0 = $P0
            $P0 = find_lex '$pos'
            $I0 = $P0
            substr $S0, 0, $I0, ''
            $P0 = box $S0
            %r = $P0
        }
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
