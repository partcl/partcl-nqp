module StringHelper {

our    %Arg_limits;
our    %CCLASS;
our    %Command_options;
our    %String_cclass;
our    %String_funcs;
our    %String_token;

INIT {
    %CCLASS<ANY>          := 0xFFFF;
    %CCLASS<NONE>         := 0x0000;
    %CCLASS<UPPERCASE>    := 0x0001;
    %CCLASS<LOWERCASE>    := 0x0002;
    %CCLASS<ALPHABETIC>   := 0x0004;
    %CCLASS<NUMERIC>      := 0x0008;
    %CCLASS<HEXADECIMAL>  := 0x0010;
    %CCLASS<WHITESPACE>   := 0x0020;
    %CCLASS<PRINTING>     := 0x0040;
    %CCLASS<GRAPHICAL>    := 0x0080;
    %CCLASS<BLANK>        := 0x0100;
    %CCLASS<CONTROL>      := 0x0200;
    %CCLASS<PUNCTUATION>  := 0x0400;
    %CCLASS<ALPHANUMERIC> := 0x0800;
    %CCLASS<NEWLINE>      := 0x1000;
    %CCLASS<WORD>         := 0x2000;

    %String_cclass<alnum>      := <ALPHANUMERIC>;
    %String_cclass<alpha>      := <ALPHABETIC>;
    #%String_cclass<BLANK>      := <BLANK>;
    %String_cclass<control>    := <CONTROL>;
    %String_cclass<graph>      := <GRAPHICAL>;
    %String_cclass<xdigit>     := <HEXADECIMAL>;
    %String_cclass<lower>      := <LOWERCASE>;
    #%String_cclass<NEWLINE>    := <NEWLINE>;
    %String_cclass<digit>      := <NUMERIC>;
    %String_cclass<print>      := <PRINTING>;
    %String_cclass<punct>      := <PUNCTUATION>;
    %String_cclass<upper>      := <UPPERCASE>;
    %String_cclass<space>      := <WHITESPACE>;
    %String_cclass<wordchar>   := <WORD>;

    %String_funcs<bytelength> := StringHelper::bytelength;
    %Arg_limits<bytelength> := [ 1, 1, "string" ];

    %String_funcs<compare> := StringHelper::compare;
    %Arg_limits<compare> := [ 2, 5, "?-nocase? ?-length int? string1 string2" ];
    ##%Command_options<compare><-nocase> := 2;
    ##%Command_options<compare><-length> := 2;
    ##%Command_options<compare><ERROR> := '-nocase or -length';

    %String_funcs<equal> := StringHelper::equal;
    %Arg_limits<equal> := [ 2, 5, "?-nocase? ?-length int? string1 string2" ];
    ##%Command_options<equal><-nocase> := 1;
    ##%Command_options<equal><-length> := 2;
    ##%Command_options<equal><ERROR> := '-nocase or -length';

    %String_funcs<first> := StringHelper::first;
    %Arg_limits<first> := [ 2, 3, "needleString haystackString ?startIndex?" ];

    %String_funcs<index> := StringHelper::index;
    %Arg_limits<index> := [ 2, 2, "string charIndex" ];


    %String_funcs<is> := StringHelper::is;
    %Arg_limits<is> := [ 2, 5, "class ?-strict? ?-failindex varname? string" ];
    ##%Command_options<is><offset> := 1;
    ##%Command_options<is><-strict> := 1;
    ##%Command_options<is><-failindex> := 2;
    ##%Command_options<is><ERROR> := '-strict or -failindex';

    %String_funcs<is_alnum>       := StringHelper::is_cclass;
    %String_funcs<is_alpha>       := StringHelper::is_cclass;
    %String_funcs<is_ascii>       := StringHelper::is_ascii;
    %String_funcs<is_boolean>     := StringHelper::is_boolean;
    %String_funcs<is_control>     := StringHelper::is_cclass;
    %String_funcs<is_digit>       := StringHelper::is_cclass;
    %String_funcs<is_double>      := StringHelper::is_double;
    %String_funcs<is_false>       := StringHelper::is_token;
    %String_funcs<is_graph>       := StringHelper::is_cclass;
    %String_funcs<is_integer>     := StringHelper::is_token;
    %String_funcs<is_list>        := StringHelper::is_token;
    %String_funcs<is_lower>       := StringHelper::is_cclass;
    %String_funcs<is_print>       := StringHelper::is_cclass;
    %String_funcs<is_punct>       := StringHelper::is_cclass;
    %String_funcs<is_space>       := StringHelper::is_cclass;
    %String_funcs<is_true>        := StringHelper::is_token;
    %String_funcs<is_upper>       := StringHelper::is_cclass;
    %String_funcs<is_wideinteger> := StringHelper::is_token;
    %String_funcs<is_wordchar>    := StringHelper::is_cclass;
    %String_funcs<is_xdigit>      := StringHelper::is_cclass;

    %String_funcs<last> := StringHelper::last;
    %Arg_limits<last> := [ 2, 3, "needleString haystackString ?startIndex?" ];

    %String_funcs<length> := StringHelper::length;
    %Arg_limits<length> := [ 1, 1, "string" ];

    %String_funcs<map> := StringHelper::map;
    %Arg_limits<map> := [ 2, 3, "?-nocase? mapping string" ];
    ##%Command_options<map><-nocase> := 1;
    ##%Command_options<map><ERROR> := '-nocase';

    %String_funcs<match> := StringHelper::match;
    %Arg_limits<match> := [ 2, 3, "?-nocase? pattern string" ];
    ##%Command_options<match><-nocase> := 1;
    ##%Command_options<match><ERROR> := '-nocase';

    %String_funcs<range> := StringHelper::range;
    %Arg_limits<range> := [ 3, 3, "string first last" ];

    %String_funcs<repeat> := StringHelper::repeat;
    %Arg_limits<repeat> := [ 2, 2, "string count" ];

    %String_funcs<replace> := StringHelper::replace;
    %Arg_limits<replace> := [ 3, 4, "string first last ?string?" ];

    %String_funcs<reverse> := StringHelper::reverse;
    %Arg_limits<reverse> := [ 1, 1, "string" ];

    %String_funcs<tolower> := StringHelper::tolower;
    %Arg_limits<tolower> := [ 1, 3, "string ?first? ?last?" ];

    %String_funcs<totitle> := StringHelper::totitle;
    %Arg_limits<totitle> := [ 1, 3, "string ?first? ?last?" ];

    %String_funcs<toupper> := StringHelper::toupper;
    %Arg_limits<toupper> := [ 1, 3, "string ?first? ?last?" ];

    %String_funcs<trim> := StringHelper::trim;
    %Arg_limits<trim> := [ 1, 2, "string ?chars?" ];

    %String_funcs<trimleft> := StringHelper::trimleft;
    %Arg_limits<trimleft> := [ 1, 2, "string ?chars?" ];

    %String_funcs<trimright> := StringHelper::trimright;
    %Arg_limits<trimright> := [ 1, 2, "string ?chars?" ];

    %String_funcs<wordend> := StringHelper::wordend;
    %Arg_limits<wordend> := [ 2, 2, "string index" ];

    %String_funcs<wordstart> := StringHelper::wordstart;
    %Arg_limits<wordstart> := [ 2, 2, "string index" ];

    %String_token<double>      := 'dec_number';
    %String_token<false>       := 'term:sym<false>';
    %String_token<integer>     := 'integer';
    %String_token<list>        := 'list';
    %String_token<true>        := 'term:sym<true>';
    %String_token<wideinteger> := 'integer';
}


# Parses optional -args, and generates "wrong#args" errors and "bad option -foo" errors.
# Dispatches to fairly normal NQP subs for the detailed work.
our sub dispatch_command(*@args) {
    my $num_args := +@args;

    if $num_args-- < 1 {
        self.error('wrong # args: should be "string subcommand ?argument ...?"');
    }

    my @opts := <bytelength compare equal first index is last length map match range repeat replace reverse tolower totitle toupper trim trimleft trimright wordend wordstart>;
    my $cmd := _tcl::select_option(@opts, @args.shift, 'subcommand');

    my @limits := %Arg_limits{$cmd};

    self.error("wrong # args: should be \"string $cmd {@limits[2]}\"")
        if $num_args > @limits[1];

    my %options;
    my %opts_allowed := %Command_options{$cmd};

    if %opts_allowed {
        my $arg;
        my $shift;
        my $opt_offset := 0 + %opts_allowed<offset>;

        while $num_args > @limits[0]
            && ($arg := @args[$opt_offset])[0] eq '-' {

            $shift := %opts_allowed{$arg};

            if $shift == 2 {
                $arg := nqp::substr($arg, 1);
                %options{$arg} := @args[1 + $opt_offset];
                nqp::splice(@args, [], $opt_offset, $shift);
            }
            elsif $shift == 1 {
                $arg := nqp::substr($arg, 1);
                %options{$arg} := 1;
                nqp::splice(@args, [], $opt_offset, $shift);
            }
            else {
                self.error("bad option \"$arg\": must be {%opts_allowed<ERROR>}");
            }

            $num_args := $num_args - $shift;
        }
    }


    self.error("wrong # args: should be \"string $cmd {@limits[2]}\"")
        if $num_args < @limits[0];

    my &subcommand := %String_funcs{$cmd};
    &subcommand(|@args, |%options);
}


our sub bytelength($string) {
    ## XXX ?
    nqp::chars(~$string);
}

our sub compare($s1, $s2, :$length, :$nocase = 0) {

    if nqp::defined($length) {
        unless $length < 0 {
            $s1 := nqp::substr($s1, 0, $length);
            $s2 := nqp::substr($s2, 0, $length);
        }
    }

    if $nocase {
        $s1 := nqp::uc($s1);
        $s2 := nqp::uc($s2);
    }

    nqp::cmp_s($s1, $s2);
}

our sub equal(*@args, *%options) {
    compare(|@args, |%options) == 0;
}

our sub first($needle, $haystack, $index = 0) {
    $index := $haystack.getIndex($index);

    if $index < 0 { $index := 0 }

    nqp::index($haystack, $needle, $index);
}

our sub index($string, $charIndex) {
    my $index := $string.getIndex($charIndex);

    if $index < 0 || $index > nqp::chars($string) {
        '';
    }
    else {
        nqp::substr($string, $index, 1);
    }
}

our sub is($class, $string, :$failindex, :$strict = 0) {
    my $*length := nqp::chars($string);

    if $*length == 0 {
        ! $strict;
    }
    else {
        my $*failindex := -1;
        my $*class := $class;

        my &subcommand := %String_funcs{"is_$class"};
        my $result := &subcommand($string);

        unless $result {
            # FIXME: Store $*failindex into variable named by $failindex
        }

        $result;
    }
}

our sub is_ascii($string) {
    my $index := 0;
    my $result := 1;

    while $index < $*length {
        if nqp::ord($string, $index) > 0x7F {
            $*failindex := $index;
            $index := $*length;
            $result := 0;
        }

        $index++;
    }

    $result;
}

our sub is_boolean($string) {
    is_token($string, :rule('term:sym<true>')) || is_token($string, :rule('term:sym<false>'));
}

our sub is_cclass($string) {
    my $cclass := %CCLASS{%String_cclass{$*class}};
    $*failindex := nqp::findnotcclass($cclass, $string, 0, $*length);
    $*failindex >= $*length;
}

our sub is_double($string) {
    is_token($string, :rule<dec_number>) || is_token($string, :rule<integer>);
}

our sub is_token($string, :$rule = %String_token{$*class}) {
    my $compiler := Partcl::Compiler.new();

    # TODO: Currently just recognizes - does not attempt to detect under/overflow,
    # as specified for double, e.g. Need $compiler.parse(:rule) to work, for that.
    my $result := $compiler.parsegrammar.parse($string, :rule($rule));

    nqp::chars(~ $result) == nqp::chars(trim($string));
}

our sub last($needle, $haystack, $startIndex = 0 + nqp::chars($haystack)) {

    $startIndex := $haystack.getIndex($startIndex);
    my $len := nqp::chars($haystack) - 1;

    $startIndex := $len
        if $len <  $startIndex;

    my $result := $haystack.reverse_index($needle, $startIndex);
}

our sub length($string) {
    nqp::chars($string);
}

our sub map($mapping, $string, :$nocase = 0) {

    self.error("Bogus charMap - must have an even # of entries")
        if nqp::elems($mapping) % 2 == 1;
    
    my $result := nqp::clone($string);
    my $search := $nocase ?? $string !! nqp::lc($string);
    $mapping := Internals.getList($mapping);
    
    my $idx := 0; # location in $search
    my $dst := 0; # distance of location in $result from $idx
    my $len := length($search);
    while $idx < $len {
        for $mapping -> $from, $to {
            # skip this key if there's not enough of $search left
            next if $idx + length($from) > $len;
            
            $from := nqp::lc($from) if $nocase;
            if nqp::substr($search, $idx, length($from)) eq $from {
                # the actual substitution
                # XXX nqp op for this?
                #$result := pir::replace__SSIIS($result, $idx + $dst, length($from), $to);
                $result := "FIX THIS";
                $idx := $idx + length($from) - 1;
                $dst := $dst + (length($to) - length($from));
                last;
            }
        }
        $idx++;
    }

    $result;
}

our sub match($pattern, $string, :$nocase = 0) {

    if $nocase {
        $pattern := nqp::lc($pattern);
        $string  := nqp::lc($string);
    }

    my $globber := StringGlob::Compiler.compile($pattern);
    ?Regex::Cursor.parse($string, :rule($globber), :c(0));
}

our sub range($string, $first, $last) {
    $first := $string.getIndex($first);
    $first := 0 if $first < 0;

    $last := $string.getIndex($last);
    my $last_index := nqp::chars($string) - 1;
    $last := $last_index if $last > $last_index;

    if $first > $last {
        '';
    }
    else {
        nqp::substr($string, $first, $last-$first+1);
    }
}

our sub repeat($string, $count) {
    if $count < 0 {
        '';
    }
    else {
        nqp::x($string, $count);
    }
}

our sub replace($string, $first, $last, $replacement = '') {

    my $string_len := nqp::chars($string);

    $first := $string.getIndex($first);
    $first := 0 if $first < 0;

    $last := $string.getIndex($last);
    $last := $string_len if $last > $string_len;

    if $first >= $string_len || $last < $first {
        $string;
    }
    else {
        replace_internal($string, $first, $last, $replacement);
    }
}

our sub replace_internal($string, $first, $last, $replacement) {
    # NB: Can't be fixed - the pir:: format only gives access to ops with a result,
    # and the 5-arg version of substr returns the *replaced* substring.

=begin XXX

    Q:PIR {
        $P0 = find_lex '$string'
        $S0 = $P0
        $P0 = find_lex '$first'
        $I0 = $P0
        $P0 = find_lex '$last'
        $I1 = $P0
        $I1 = $I1 - $I0
        inc $I1
        $P0 = find_lex '$replacement'
        $S1 = $P0
        $S0 = replace $S0, $I0, $I1, $S1
        %r = box $S0
    };

=end XXX

}

our sub reverse($string) {
    my $src := nqp::chars($string);
    my $dst := 0;
    my $result := '';

    while $src-- > 0 {
        $result[$dst++] := $string[$src];
    }

    $result;
}

our sub to_case($string, $first, $last, &convert) {

    unless nqp::defined($first) {
        $first := 0;
        $last := 'end';
    }

    $first := $string.getIndex($first);
    $first := 0 if $first < 0;

    $last := $string.getIndex($last);
    my $string_len := nqp::chars($string);
    $last := $string_len - 1 if $last >= $string_len;

    if $first >= $string_len {
        $string;
    }
    else {
        my $chunk_len := $last - $first + 1;
        my $replacement := nqp::substr($string, $first, $chunk_len);
        $replacement := &convert($replacement);

        replace_internal($string, $first, $last, $replacement);
    }
}

our sub tolower($string, $first?, $last = $first) {
    to_case($string, $first, $last, -> $str { nqp::lc($str) });
}

our sub totitle($string, $first?, $last = $first) {
    # XXX need to make this work in nqp
    #to_case($string, $first, $last, -> $str { pir::titlecase__SS($str) });
    "FIX THIS";
}

our sub toupper($string, $first?, $last = $first) {
    to_case($string, $first, $last, -> $str { nqp::uc($str) });
}

our sub trim($string, $chars = " \t\r\n") {
    trimright(trimleft($string, $chars), $chars);
}

our sub trimleft($string, $chars = " \t\r\n") {

    my $pos := 0;
    my $string_len := nqp::chars($string);

    while ($pos < $string_len) {
        if nqp::index($chars, $string[$pos]) < 0 {
            $string := nqp::substr($string, $pos);
            $pos := $string_len;
        }

        ++$pos;
    }

    $string;
}

our sub trimright($string, $chars = " \t\r\n") {

    my $pos := nqp::chars($string);

    while ($pos--) {
        if nqp::index($chars, $string[$pos]) < 0 {
            $string := nqp::substr($string, 0, $pos + 1);
            $pos := 0;
        }
    }

    $string;
}

our sub wordend($string, $index) {
    $index := $string.getIndex( $index );
    my $up_to := nqp::chars( $string ) - $index;

    if nqp::iscclass(%CCLASS<WORD>, $string, $index) {
        $index := nqp::findnotcclass( %CCLASS<WORD>, $string, $index, $up_to);
    }
    else {
        $index := nqp::findcclass( %CCLASS<WORD>, $string, $index, $up_to);
    }
}

our sub wordstart($string, $index) {
    $index := $string.getIndex( $index );
    my $is_word := nqp::iscclass(%CCLASS<WORD>, $string, $index);
    --$index;

    while $index >= 0 && nqp::iscclass(%CCLASS<WORD>, $string, $index) {
        --$index;
    }

    ++$index;
}

}

# vim: expandtab shiftwidth=4 ft=perl6:
