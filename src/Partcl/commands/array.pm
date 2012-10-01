method array(*@args) {
    Array::dispatch_command(|@args);
}

module Array {

our  %Arg_limits;
our  %Array_funcs;
our  %Auto_vivify;

INIT {

    %Array_funcs<anymore> := Array::anymore;
    %Arg_limits<anymore> := [ 1, 1, "searchId" ];

    %Array_funcs<donesearch> := Array::donesearch;
    %Arg_limits<donesearch> := [ 1, 1, "searchId" ];

    %Array_funcs<exists> := Array::exists;
    %Arg_limits<exists> := [ 0, 0, "" ];

    %Array_funcs<get> := Array::get;
    %Arg_limits<get> := [ 0, 1, "?pattern?" ];

    %Array_funcs<names> := Array::names;
    %Arg_limits<names> := [ 0, 2, "?mode? ?pattern?" ];

    %Array_funcs<nextelement> := Array::nextelement;
    %Arg_limits<nextelement> := [ 1, 1, "searchId" ];

    %Array_funcs<set> := Array::set;
    %Arg_limits<set> := [ 1, 1, "list" ];
    %Auto_vivify<set> := 1;

    %Array_funcs<size> := Array::size;
    %Arg_limits<size> := [ 0, 0, "" ];

    %Array_funcs<startsearch> := Array::startsearch;
    %Arg_limits<startsearch> := [ 0, 0, "" ];

    %Array_funcs<statistics> := Array::statistics;
    %Arg_limits<statistics> := [ 0, 0, "" ];

    %Array_funcs<unset> := Array::unset;
    %Arg_limits<unset> := [ 0, 1, "?pattern?" ];
}

# Parses optional -args, and generates "wrong#args" errors
# Dispatches to fairly normal NQP subs for the detailed work.
our sub dispatch_command(*@args) {
    my $num_args := +@args -2 ; # need option & arrayName

    if $num_args < 0  {
        self.error('wrong # args: should be "array option arrayName ?arg ...?"');
    }

    my @opts := <anymore donesearch exists get names nextelement set size startsearch statistics unset>;
    my $cmd := _tcl::select_option(@opts, @args.shift, 'option');

    my @limits := %Arg_limits{$cmd};

    if $num_args > @limits[1] || $num_args < @limits[0] {
        my $msg := @limits[2];
        $msg := " $msg" unless $msg eq '';
        self.error("wrong # args: should be \"array $cmd arrayName$msg\"")
    }

    my $arrayName := @args.shift();
    my $vivify := %Auto_vivify{$cmd};
    my $array;

    if ($vivify) {
        $array := Q:PIR {
            .local pmc varname, lexpad
            varname = find_lex '$arrayName'
            lexpad = find_dynamic_lex '%LEXPAD'
            %r = vivify lexpad, varname, ['TclArray']
        };
    } else {
        $array := Q:PIR {
            .local pmc varname, lexpad
            varname = find_lex '$arrayName'
            lexpad = find_dynamic_lex '%LEXPAD'
            %r = lexpad[varname]
        };
    }

    my &subcommand := %Array_funcs{$cmd};
    &subcommand($arrayName, $array, |@args);
}


my sub anymore() {
    'XXX';
}

my sub donesearch() {
    'XXX';
}

my sub exists($arrayName, $array) {
    return nqp::defined($array) && pir::isa__IPS($array, 'TclArray');
}

my sub get($arrayName, $array, $pattern = '*') {
    if !exists($arrayName, $array) || +$array == 0 {
        return '';
    }
    my $globber := StringGlob::Compiler.compile($pattern);
    my $result := pir::new__PS('TclList');
    for $array -> $key {
        if (?Regex::Cursor.parse($key, :rule($globber), :c(0))) {
            $result.push($key);
            $result.push($array{$key});
        }
    } 
    $result;
}

my sub names($arrayName, $array, $mode?, $pattern? ) {
    if !nqp::defined($pattern) {
        if nqp::defined($mode) {
            $pattern := $mode;
        } else {
            $pattern := '*';
        }
        $mode := '-glob';
    }

    my $matcher;
    if $mode eq '-glob' {
        $matcher := StringGlob::Compiler.compile($pattern);
    } elsif $mode eq '-regexp' {
        $matcher := ARE::Compiler.compile($pattern);
    } elsif $mode ne '-exact' {
        self.error("bad option \"$mode\": must be -exact, -glob, or -regexp");
    }

    my $result := pir::new__PS('TclList');
    for $array -> $key {
        my $match := 0;
        if $mode ne "-exact" {
            if ?Regex::Cursor.parse($key, :rule($matcher), :c(0)) {
                $match := 1;
            }
        } elsif $key eq $pattern {
            $match := 1;
        }
        $result.push($key) if $match;
    } 
    $result;
}

my sub nextelement() {
    'XXX';
}

my sub set($arrayName, $array, @list) {

    @list := @list.getList();

    self.error("list must have an even number of elements")
        if +@list%2;

    self.error("can't set \"$arrayName(" ~ @list<0> ~")\": variable isn't array")
        if pir::typeof__SP($array) ne "TclArray";

    for @list -> $key, $value {
        $array{$key} := $value;
    }
    '';
}

my sub size($arrayName, $array) {
    return 0 if !exists($arrayName, $array);
    +$array;
}

my sub startsearch() {
    'XXX';
}

my sub statistics() {
    'XXX';
}

my sub unset($arrayName, $array, $pattern = '*') {
    my $globber := StringGlob::Compiler.compile($pattern);
    for $array -> $key {
        if (?Regex::Cursor.parse($key, :rule($globber), :c(0))) {
            nqp::deletekey(
                pir::find_lex__PS("$array"),
                pir::find_lex__PS("$key")
            );
        }
    } 
    '';
}

}

# vim: expandtab shiftwidth=4 ft=perl6:
