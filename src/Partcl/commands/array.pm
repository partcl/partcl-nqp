our sub array(*@args) {
    Array::dispatch_command(|@args);
}

module Array;

our    %Arg_limits;
our    %Array_funcs;

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
        error('wrong # args: should be "array option arrayName ?arg ...?"');
    }

    my @opts := <anymore donesearch exists get names nextelement set size startsearch statistics unset>;
    my $cmd := _tcl::select_option(@opts, @args.shift, 'option');

    my @limits := %Arg_limits{$cmd};

    if $num_args > @limits[1] || $num_args < @limits[0] {
        my $msg := @limits[2];
        $msg := " $msg" unless $msg eq '';
        error("wrong # args: should be \"array $cmd arrayName$msg\"")
    }

    my $arrayName := @args.shift();
    my $array := Q:PIR {
        .local pmc varname, lexpad
        varname = find_lex '$arrayName'
        lexpad = find_dynamic_lex '%LEXPAD'
        %r = lexpad[varname]
    };

    my &subcommand := %Array_funcs{$cmd};
    &subcommand($array, |@args);
}


my sub anymore() {
    'XXX';
}

my sub donesearch() {
    'XXX';
}

my sub exists($array) {
    return pir::defined($array) && pir::isa($array, 'TclArray');
}

my sub get() {
    'XXX';
}

my sub names() {
    'XXX';
}

my sub nextelement() {
    'XXX';
}

my sub set() {
    'XXX';
}

my sub size($array) {
    return 0 if !exists($array);
    return +$array;
}

my sub startsearch() {
    'XXX';
}

my sub statistics() {
    'XXX';
}

my sub unset() {
    'XXX';
}


# vim: filetype=perl6:
