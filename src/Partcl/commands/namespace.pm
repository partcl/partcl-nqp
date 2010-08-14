our sub namespace(*@args) {
    Namespace::dispatch_command(|@args);
}

module Namespace;

our  %Arg_limits;
our  %funcs;
our  %Auto_vivify;

INIT {

    ## Negative limit in "max" position => unlimited.
    %funcs<children> := Namespace::children;
    %Arg_limits<children> := [ 0, 2, "?name? ?pattern?" ];

    %funcs<code> := Namespace::code;
    %Arg_limits<code> := [ 1, 1, "script" ];

    %funcs<current> := Namespace::current;
    %Arg_limits<current> := [ 0, 0, "" ];

    %funcs<delete> := Namespace::delete;
    %Arg_limits<delete> := [ 0, -1, "" ];

    %funcs<ensemble> := Namespace::ensemble;
    %Arg_limits<ensemble> := [ 1, 0, "subcommand ?arg...?" ];

    %funcs<eval> := Namespace::eval;
    %Arg_limits<eval> := [ 2, -1, "name arg ?arg...?" ];

    %funcs<exists> := Namespace::exists;
    %Arg_limits<exists> := [ 1, 1, "name" ];

    %funcs<export> := Namespace::export;
    %Arg_limits<export> := [ 0, 0, "namespace" ];

    %funcs<forget> := Namespace::forget;
    %Arg_limits<forget> := [ 0, 0, "namespace" ];

    %funcs<import> := Namespace::import;
    %Arg_limits<import> := [ 0, -1, "namespace" ];

    %funcs<inscope> := Namespace::inscope;
    %Arg_limits<inscope> := [ 0, 0, "namespace" ];

    %funcs<origin> := Namespace::origin;
    %Arg_limits<origin> := [ 0, 0, "namespace" ];

    %funcs<parent> := Namespace::parent;
    %Arg_limits<parent> := [ 0, 1, "?name?" ];

    %funcs<path> := Namespace::path;
    %Arg_limits<path> := [ 0, 1, "namespaceList" ];

    %funcs<qualifiers> := Namespace::qualifiers;
    %Arg_limits<qualifiers> := [ 1, 1, "string" ];

    %funcs<tail> := Namespace::tail;
    %Arg_limits<tail> := [ 1, 1, "string" ];

    %funcs<upvar> := Namespace::upvar;
    %Arg_limits<upvar> := [ 0, 0, "namespace" ];

    %funcs<unknown> := Namespace::unknown;
    %Arg_limits<unknown> := [ 0, 0, "namespace" ];

    %funcs<unknown> := Namespace::unknown;
    %Arg_limits<unknown> := [ 0, 0, "namespace" ];

    %funcs<which> := Namespace::which;
    %Arg_limits<which> := [ 0, 0, "namespace" ];
}

# Parses optional -args, and generates "wrong#args" errors
# Dispatches to fairly normal NQP subs for the detailed work.
our sub dispatch_command(*@args) {
    my $num_args := +@args -1 ; # need option

    if $num_args < 0  {
        error('wrong # args: should be "namespace subcommand ?arg ...?"');
    }

    my @opts := <children code current delete ensemble eval exists export forget import inscope origin parent path qualifiers tail unknown upvar which>;
    my $cmd := _tcl::select_option(@opts, @args.shift, 'option');

    my @limits := %Arg_limits{$cmd};

    if (@limits[1] >= 0 && $num_args > @limits[1]) || $num_args < @limits[0] {
        my $msg := @limits[2];
        $msg := " $msg" unless $msg eq '';
        error("wrong # args: should be \"namespace $cmd$msg\"")
    }

    my &subcommand := %funcs{$cmd};
    &subcommand(|@args);
}

my sub children(*@args) {
    '';
}

my sub code(*@args) {
    '';
}

my sub current(*@args) {
    '';
}

my sub delete(*@args) {
    '';
}

my sub ensemble(*@args) {
    '';
}

my sub eval(*@args) {
    '';
}

my sub exists(*@args) {
    '';
}

my sub export(*@args) {
    '';
}

my sub forget(*@args) {
    '';
}

my sub import(*@args) {
    '';
}

my sub inscope(*@args) {
    eval(@args);
}

my sub origin(*@args) {
    '';
}

my sub parent(*@args) {
    '';
}

my sub path(*@args) {
    '';
}

my sub qualifiers($string) {
    my $match := Regex::Cursor.parse(
        $string, :rule(/$<foo>=(.*)\:\:+<-[:]>*$$/), :c(0)
    );

    return ~$match<foo> if $match;

    '';
}

my sub tail(*@args) {
    '';
}

my sub upvar(*@args) {
    '';
}

my sub unknown(*@args) {
    '';
}

my sub which(*@args) {
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
