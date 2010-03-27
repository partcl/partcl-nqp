our sub string(*@args) {
	String::dispatch_command(|@args);
}

module String;

our	%Arg_limits;
our	%CCLASS;
our	%Command_options;
our	%String_cclass;
our	%String_funcs;
our	%String_token;

INIT {
	%CCLASS<ANY>			:= 0xFFFF;
	%CCLASS<NONE>		:= 0x0000;
	%CCLASS<UPPERCASE>	:= 0x0001;
	%CCLASS<LOWERCASE>	:= 0x0002;
	%CCLASS<ALPHABETIC>	:= 0x0004;
	%CCLASS<NUMERIC>		:= 0x0008;
	%CCLASS<HEXADECIMAL>	:= 0x0010;
	%CCLASS<WHITESPACE>	:= 0x0020;
	%CCLASS<PRINTING>		:= 0x0040;
	%CCLASS<GRAPHICAL>	:= 0x0080;
	%CCLASS<BLANK>		:= 0x0100;
	%CCLASS<CONTROL>		:= 0x0200;
	%CCLASS<PUNCTUATION>	:= 0x0400;
	%CCLASS<ALPHANUMERIC>	:= 0x0800;
	%CCLASS<NEWLINE>		:= 0x1000;
	%CCLASS<WORD>		:= 0x2000;

	%String_cclass<alnum>		:= <ALPHANUMERIC>;
	%String_cclass<alpha>		:= <ALPHABETIC>;
	#%String_cclass<BLANK>		:= <BLANK>;
	%String_cclass<control>	:= <CONTROL>;
	%String_cclass<graph>		:= <GRAPHICAL>;
	%String_cclass<xdigit>		:= <HEXADECIMAL>;
	%String_cclass<lower>		:= <LOWERCASE>;
	#%String_cclass<NEWLINE>		:= <NEWLINE>;
	%String_cclass<digit>		:= <NUMERIC>;
	%String_cclass<print>		:= <PRINTING>;
	%String_cclass<punct>		:= <PUNCTUATION>;
	%String_cclass<upper>		:= <UPPERCASE>;
	%String_cclass<space>		:= <WHITESPACE>;
	%String_cclass<wordchar>	:= <WORD>;
	
	%String_funcs<bytelength> := String::bytelength;
	%Arg_limits<bytelength> := [ 1, 1, "string" ];

	%String_funcs<compare> := String::compare;
	%Arg_limits<compare> := [ 2, 5, "?-nocase? ?-length int? string1 string2" ];
	%Command_options<compare><-nocase> := 1;
	%Command_options<compare><-length> := 2;
	%Command_options<compare><ERROR> := '-nocase or -length';
	
	%String_funcs<equal> := String::equal;
	%Arg_limits<equal> := [ 2, 5, "?-nocase? ?-length int? string1 string2" ];
	%Command_options<equal><-nocase> := 1;
	%Command_options<equal><-length> := 2;
	%Command_options<equal><ERROR> := '-nocase or -length';

	%String_funcs<first> := String::first;
	%Arg_limits<first> := [ 2, 3, "needleString haystackString ?startIndex?" ];

	%String_funcs<index> := String::index;
	%Arg_limits<index> := [ 2, 2, "string charIndex" ];

	%String_funcs<is> := String::is;
	%Arg_limits<is> := [ 2, 5, "class ?-strict? ?-failindex varname? string" ];
	%Command_options<is><offset> := 1;
	%Command_options<is><-strict> := 1;
	%Command_options<is><-failindex> := 2;
	%Command_options<is><ERROR> := '-strict or -failindex';

	%String_funcs<is_alnum>	:= String::is_cclass;
	%String_funcs<is_alpha>	:= String::is_cclass;
	%String_funcs<is_ascii>	:= String::is_ascii;
	%String_funcs<is_boolean>	:= String::is_boolean;
	%String_funcs<is_control>	:= String::is_cclass;
	%String_funcs<is_digit>	:= String::is_cclass;
	%String_funcs<is_double>	:= String::is_token;
	%String_funcs<is_false>	:= String::is_token;
	%String_funcs<is_graph>	:= String::is_cclass;
	%String_funcs<is_integer>	:= String::is_token;
	%String_funcs<is_list>		:= String::is_token;
	%String_funcs<is_lower>	:= String::is_cclass;
	%String_funcs<is_print>	:= String::is_cclass;
	%String_funcs<is_punct>	:= String::is_cclass;
	%String_funcs<is_space>	:= String::is_cclass;
	%String_funcs<is_true>		:= String::is_token;
	%String_funcs<is_upper>	:= String::is_cclass;
	%String_funcs<is_wideinteger> := String::is_token;
	%String_funcs<is_wordchar>	:= String::is_cclass;
	%String_funcs<is_xdigit>	:= String::is_cclass;
	
	%String_funcs<last> := String::last;
	%Arg_limits<last> := [ 2, 3, "needleString haystackString ?startIndex?" ];

	%String_funcs<length> := String::length;
	%Arg_limits<length> := [ 1, 1, "string" ];

	%String_funcs<map> := String::map;

	%String_funcs<match> := String::match;
	%Arg_limits<match> := [ 2, 3, "?-nocase? pattern string" ];
	%Command_options<match><-nocase> := 1;
	%Command_options<match><ERROR> := '-nocase';

	%String_funcs<range> := String::range;
	%Arg_limits<range> := [ 3, 3, "string first last" ];

	%String_funcs<repeat> := String::repeat;
	%Arg_limits<repeat> := [ 2, 2, "string count" ];

	%String_funcs<replace> := String::replace;
	%Arg_limits<replace> := [ 3, 4, "string first last ?string?" ];

	%String_funcs<reverse> := String::reverse;
	%Arg_limits<reverse> := [ 1, 1, "string" ];

	%String_funcs<tolower> := String::tolower;
	%Arg_limits<tolower> := [ 1, 3, "string ?first? ?last?" ];

	%String_funcs<totitle> := String::totitle;
	%Arg_limits<totitle> := [ 1, 3, "string ?first? ?last?" ];

	%String_funcs<toupper> := String::toupper;
	%Arg_limits<toupper> := [ 1, 3, "string ?first? ?last?" ];

	%String_funcs<trim> := String::trim;
	%Arg_limits<trim> := [ 1, 2, "string ?chars?" ];

	%String_funcs<trimleft> := String::trimleft;
	%Arg_limits<trimleft> := [ 1, 2, "string ?chars?" ];

	%String_funcs<trimright> := String::trimright;
	%Arg_limits<trimright> := [ 1, 2, "string ?chars?" ];

	%String_funcs<wordend> := String::wordend;
	%Arg_limits<wordend> := [ 2, 2, "string index" ];

	%String_funcs<wordstart> := String::wordstart;
	%Arg_limits<wordstart> := [ 2, 2, "string index" ];

	%String_token<double>	:= 'dec_number';
	%String_token<false>	:= 'term:sym<false>';
	%String_token<integer>	:= 'integer';
	%String_token<list>	:= 'list';
	%String_token<true>	:= 'term:sym<true>';
	%String_token<wideinteger>	:= 'integer';
	
}
	
my sub bytelength($string) {
	pir::bytelength__is(~ $string);
}

my sub compare($s1, $s2, *%options) {

	my $length := %options<-length>;
	
	if pir::defined($length) {
		unless $length < 0 {
			$s1 := pir::substr__SSII($s1, 0, $length);
			$s2 := pir::substr__SSII($s2, 0, $length);
		}
	}

	if %options<-nocase> {
		$s1 := pir::upcase__SS($s1);
		$s2 := pir::upcase__SS($s2);
	}

	pir::cmp__IPP($s1, $s2);
}

our sub dispatch_command(*@args) {
	my $num_args := +@args;

	if $num_args-- < 1 {
		error('wrong # args: should be "string subcommand ?argument ...?"');
	}

	my @opts := <bytelength compare equal first index is last length map match range repeat replace reverse tolower totitle toupper trim trimleft trimright wordend wordstart>;
	my $cmd := _tcl::select_option(@opts, @args.shift, 'subcommand');

	my @limits := %Arg_limits{$cmd};

	error("wrong # args: should be \"string $cmd {@limits[2]}\"")
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
				%options{$arg} := @args[1 + $opt_offset];
				pir::splice__vPPII(@args, [], $opt_offset, $shift);
			}
			elsif $shift == 1 {
				%options{$arg} := 1;
				pir::splice__vPPII(@args, [], $opt_offset, $shift);
			}
			else {
				error("bad option \"$arg\": must be {%opts_allowed<ERROR>}");
			}

			$num_args := $num_args - $shift;
		}
	}

	error("wrong # args: should be \"string $cmd {@limits[2]}\"")
		if $num_args < @limits[0];

	my &subcommand := %String_funcs{$cmd};
	&subcommand(|@args, |%options);
}

my sub equal(*@args, *%options) {
	compare(|@args, |%options) == 0;
}

my sub first($needle, $haystack, $index = 0) {
	$index := $haystack.getIndex($index);

	if $index < 0 { $index := 0 }

	pir::index__issi($haystack, $needle, $index);
}

my sub index($string, $charIndex) {
	my $index    := $string.getIndex($charIndex);

	if $index < 0 || $index > pir::length__is($string) {
		'';
	}
	else {
		pir::substr__ssii($string, $index, 1);
	}
}

my sub is($class, $string, *%options) {
	my $*length := pir::length__IS($string);

	if $*length == 0 {
		1 - %options<-strict>;
	}
	else {
		my $*failindex := -1;
		my $*class := $class;
		
		my &subcommand := %String_funcs{"is_$class"};
		my $result := &subcommand($string);
		
		unless $result {
			# FIXME: Store $*failindex into variable named by %options<-failindex>
		}
		
		$result;
	}
}

my sub is_boolean($string) {
	is_token($string, :rule('term:sym<true>')) || is_token($string, :rule('term:sym<false>'));
}

my sub is_cclass($string) {
	my $cclass := %CCLASS{%String_cclass{$*class}};
	$*failindex := pir::find_not_cclass__IISII($cclass, $string, 0, $*length);
	$*failindex >= $*length;
}

my sub is_ascii($string) {
	my $index := 0;
	my $result := 1;
	
	while $index < $*length {
		if pir::ord__ISI($string, $index) > 0x7F {
			$*failindex := $index;
			$index := $*length;
			$result := 0;
		}
		
		$index++;
	}
	
	$result;
}

my sub is_token($string, :$rule = %String_token{$*class}) {
	my $compiler := pir::compreg__PS('Partcl');

	# TODO: Currently just recognizes - does not attempt to detect under/overflow,
	# as specified for double, e.g. Need $compiler.parse(:rule) to work, for that.
	my $result := $compiler.parsegrammar.parse($string, :rule($rule));

	# pir::load_bytecode('dumper.pbc');
	# my &dumper := Q:PIR {
		# %r = get_root_global ['parrot'], '_dumper'
	# };
	# &dumper(~$string);
	# &dumper($result);
	
	pir::length__IS(~ $result) == pir::length__IS(trim($string));
}

my sub last($needle, $haystack, $startIndex = 0 + pir::length__IS($haystack)) {

	$startIndex := $haystack.getIndex($startIndex);
	my $len := pir::length__IS($haystack) - 1;

	$startIndex := $len
		if $len <  $startIndex;

	my $result := $haystack.reverse_index($needle, $startIndex);
}

my sub length($string) {
	pir::length__IS($string);
}

my sub map(*@args) {
	'';
}

my sub match($pattern, $string, *%options) {

	if %options<-nocase> {
		$pattern := pir::downcase__ss($pattern);
		$string  := pir::downcase__ss($string);
	}

	## my &dumper := Q:PIR { %r = get_root_global ['parrot'], '_dumper' };
	## &dumper(StringGlob::Compiler.compile($pattern, :target<parse>));
	my $globber := StringGlob::Compiler.compile($pattern);
	?Regex::Cursor.parse($string, :rule($globber), :c(0));
}

my sub range($string, $first, $last) {
	$first := $string.getIndex($first);
	$first := 0 if $first < 0;

	$last := $string.getIndex($last);
	my $last_index := pir::length__is($string) - 1;
	$last := $last_index if $last > $last_index;

	if $first > $last {
		'';
	}
	else {
		pir::substr__ssii($string, $first, $last-$first+1);
	}
}

my sub repeat($string, $count) {
	if $count < 0 {
		'';
	}
	else {
		pir::repeat__ssi($string, $count);
	}
}

my sub replace($string, $first, $last, $replacement = '') {

	my $string_len := pir::length__is($string);

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

my sub replace_internal($string, $first, $last, $replacement) {
	# NB: Can't be fixed - the pir:: format only gives access to ops with a result,
	# and the 5-arg version of substr returns the *replaced* substring.
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
		substr $S0, $I0, $I1, $S1
		%r = box $S0
	};
}

my sub reverse($string) {
	my $src := pir::length__IS($string);
	my $dst := 0;
	my $result := '';

	while $src-- > 0 {
		$result[$dst++] := $string[$src];
	}

	$result;
}

my sub to_case($string, $first, $last, &convert) {

	unless pir::defined($first) {
		$first := 0;
		$last := 'end';
	}

	$first := $string.getIndex($first);
	$first := 0 if $first < 0;

	$last := $string.getIndex($last);
	my $string_len := pir::length__is($string);
	$last := $string_len - 1 if $last >= $string_len;

	if $first >= $string_len {
		$string;
	}
	else {
		my $chunk_len := $last - $first + 1;
		my $replacement := pir::substr__SSII($string, $first, $chunk_len);
		$replacement := &convert($replacement);

		replace_internal($string, $first, $last, $replacement);
	}
}

my sub tolower($string, $first?, $last = $first) {
	to_case($string, $first, $last, -> $str { pir::downcase__SS($str) });
}

my sub totitle($string, $first?, $last = $first) {
	to_case($string, $first, $last, -> $str { pir::titlecase__SS($str) });
}

my sub toupper($string, $first?, $last = $first) {
	to_case($string, $first, $last, -> $str { pir::upcase__SS($str) });
}

my sub trim($string, $chars = " \t\r\n") {
	trimright(trimleft($string, $chars, :op_name<trim>), $chars);
}

my sub trimleft($string, $chars = " \t\r\n") {

	my $pos := 0;
	my $string_len := pir::length__is($string);

	while ($pos < $string_len) {
		if pir::index__ISS($chars, $string[$pos]) < 0 {
			$string := pir::substr__SSI($string, $pos);
			$pos := $string_len;
		}

		++$pos;
	}

	$string;
}

my sub trimright($string, $chars = " \t\r\n") {

	my $pos := pir::length__IS($string);

	while ($pos--) {
		if pir::index__ISS($chars, $string[$pos]) < 0 {
			$string := pir::substr__SSII($string, 0, $pos + 1);
			$pos := 0;
		}
	}

	$string;
}

my sub wordend($string, $index) {
	$index := $string.getIndex( $index );
	my $up_to := pir::length__IS( $string ) - $index;

	if pir::is_cclass__IISI(%CCLASS<WORD>, $string, $index) {
		$index := pir::find_not_cclass__IISII( %CCLASS<WORD>, $string, $index, $up_to);
	}
	else {
		$index := pir::find_cclass__IISII( %CCLASS<WORD>, $string, $index, $up_to);
	}
}

my sub wordstart($string, $index) {
	$index := $string.getIndex( $index );
	my $is_word := pir::is_cclass__IISI(%CCLASS<WORD>, $string, $index);
	--$index;
	
	while $index >= 0 && pir::is_cclass__IISI(%CCLASS<WORD>, $string, $index) {
		--$index;
	}
	
	++$index;
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
