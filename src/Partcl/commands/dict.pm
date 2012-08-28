our sub dict(*@args) {
    Dict::dispatch_command(|@args);
}

module Dict {

our  %Arg_limits;
our  %funcs;
our  %Auto_vivify;

INIT {

    ## Negative limit in "max" position => unlimited.
    %funcs<append> := Dict::append;
    %Arg_limits<append> := [ 2, -1, "varName key ?value ...?" ];

    %funcs<create> := Dict::create;
    %Arg_limits<create> := [ 0, -1, "" ];

    %funcs<exists> := Dict::exists;
    %Arg_limits<exists> := [ 2, -1, "dictionary key ?key ...?" ];

    %funcs<filter> := Dict::filter;
    %Arg_limits<filter> := [ 2, -1, "dictionary filterType ..." ];

    %funcs<for> := Dict::for;
    %Arg_limits<for> := [ 3, 3, "\{keyVar valueVar} dictionary script" ];

    %funcs<get> := Dict::get;
    %Arg_limits<get> := [ 1, -1, "dictionary ?key key ...?" ];

    %funcs<incr> := Dict::incr;
    %Arg_limits<incr> := [ 2, 3, "varName key ?increment?" ];

    %funcs<info> := Dict::info;
    %Arg_limits<info> := [ 1, 1, "dictionary" ];

    %funcs<keys> := Dict::keys;
    %Arg_limits<keys> := [ 1, 2, "dictionary ?pattern?" ];

    %funcs<lappend> := Dict::lappend;
    %Arg_limits<lappend> := [ 2, -1, "varName key ?value ...?" ];

    %funcs<merge> := Dict::merge;
    %Arg_limits<merge> := [ 0, -1, "" ];

    %funcs<remove> := Dict::remove;
    %Arg_limits<remove> := [ 1, -1, "dictionary ?key ...?" ];

    %funcs<replace> := Dict::replace;
    %Arg_limits<replace> := [ 1, -1, "dictionary ?key value ...?" ];

    %funcs<set> := Dict::set;
    %Arg_limits<set> := [ 3, -1, "varName key ?key ...? value" ];

    %funcs<size> := Dict::size;
    %Arg_limits<size> := [ 1, 1, "dictionary" ];

    %funcs<unset> := Dict::unset;
    %Arg_limits<unset> := [ 2, -1, "varName key ?key ...?" ];

    %funcs<update> := Dict::update;
    %Arg_limits<update> := [ 4, -1, "varName key varName ?key varName ...? script" ];

    %funcs<values> := Dict::values;
    %Arg_limits<values> := [ 1, 2, "dictionary ?pattern?" ];

    %funcs<with> := Dict::with;
    %Arg_limits<with> := [ 2, -1, "dictVar ?key ...? script" ];
}

# Parses optional -args, and generates "wrong#args" errors
# Dispatches to fairly normal NQP subs for the detailed work.
our sub dispatch_command(*@args) {
    my $num_args := +@args -1 ; # need option

    if $num_args < 0  {
        error('wrong # args: should be "dict subcommand ?argument ...?"');
    }

    my @opts := <append create exists filter for get incr info keys lappend merge remove replace set size unset update values with>;
    my $cmd := _tcl::select_option(@opts, @args.shift, 'subcommand');

    my @limits := %Arg_limits{$cmd};

    if (@limits[1] >= 0 && $num_args > @limits[1]) || $num_args < @limits[0] {
        my $msg := @limits[2];
        $msg := " $msg" unless $msg eq '';
        error("wrong # args: should be \"dict $cmd$msg\"")
    }

    my &subcommand := %funcs{$cmd};
    &subcommand(|@args);
}

sub append (*@args) {
    '';
}

sub create (*@args) {
    error('wrong # args: should be "dict create ?key value ...?"')
        if +@args % 2;

    '';
}

sub filter (*@args) {
    '';
}

sub for (*@args) {
    '';
}

sub get (*@args) {
    '';
}

sub incr (*@args) {
    '';
}

sub info (*@args) {
    '';
}

sub keys (*@args) {
    '';
}

sub lappend (*@args) {
    '';
}

sub merge (*@args) {
    '';
}

sub remove (*@args) {
    '';
}

sub replace (*@args) {
    '';
}

sub set (*@args) {
    '';
}

sub size (*@args) {
    '';
}

sub unset (*@args) {
    '';
}

sub update (*@args) {
    '';
}

sub values (*@args) {
    '';
}

sub with (*@args) {
    '';
}

}

# vim: expandtab shiftwidth=4 ft=perl6:
