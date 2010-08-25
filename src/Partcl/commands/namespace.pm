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

my sub children($namespace = pir::new('TclString'), $pattern = '*') {

    my @ns := $namespace.split(/\:\:+/);
    if +@ns && @ns[+@ns-1] eq '' {
        @ns.pop();
    }
    if +@ns && @ns[0] eq '' {
        @ns.shift();
    }
    my $prefix := "::" ~ @ns.join("::");
    $prefix := $prefix ~ "::" unless $prefix eq "::";

    my $regex := StringGlob::Compiler.compile($pattern);

    my $ns := pir::get_hll_namespace__p();
    for @ns -> $level {
        $ns := $ns{$level};
        if pir::typeof($ns) ne 'NameSpace' {
            error('namespace "' ~ $namespace ~ '" not found in "::"');
        }
    }
 
    my @result := pir::new('TclList');
    for $ns -> $key {
        my $element := $ns{$key};
        if (pir::typeof($element) eq 'NameSpace') {
            if ?Regex::Cursor.parse($element, :rule($regex), :c(0)) {
                @result.push($prefix ~ $element);
            }
        }
    }


    return @result;
}

my sub code(*@args) {
    '';
}

my sub current() {
    return getNamespaceString(:depth(3));
}

my sub delete(*@args) {
    '';
}

my sub ensemble(*@args) {
    '';
}

my sub eval($namespace, *@args) {

    my @*PARTCL_COMPILER_NAMESPACE := $namespace.split(/\:\:+/);

    my $code := concat(|@args);
    my &sub := Partcl::Compiler.compile($code);
    &sub();
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

    return ?$match ?? ~$match<foo> !! '';
}

my sub tail($string) {
    my $match := Regex::Cursor.parse(
        $string, :rule(/\:\:+$<foo>=<-[:]>*$$/), :c(0)
    );

    return ?$match ?? ~$match<foo> !! '';
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

### XXX this code from partcl for when old splitNS was called with a string.
## my @list := $name.split(/':' ':'+/);

## my $I0 := +@list;
## if $I0 != 0 && @list[0] == '' {
##     @list.shift();
##     return @list;
## }

## Depth is the number of frames to skip when checking for current
## namespace.


my sub getNamespaceString(int :$depth = 0) {
    return '::' ~ pir::join('::', getNamespaceArray(:depth($depth+1)) );
}

my sub getNamespaceArray(int :$depth = 0) {

    my @ns := getNamespace(:depth($depth+1)).get_name();

    # The first element would be "::tcl" from parrot's HLL directive, but
    # that's our root.

    my $assert := @ns.shift();
    error("ASSERT not rooted in ::tcl namespace")
        if $assert ne "tcl"; # Should never occur.

    my $pos := +@ns;
    while $pos > 0 {
        $pos--;
        @ns.unshift( @ns[$pos] );
    }

    return @ns;
}

my sub getNamespace(int :$depth=0) {
    my $looper := 1;

    my $ns;
    while $looper {
        $depth++;
        ## Needed for the multipart keys.
        $ns := Q:PIR {
          $P0 = find_lex '$depth'
          $I0 = $P0
          $P1 = getinterp     
          %r = $P1['sub'; $I0]
        };
        $ns := $ns.get_namespace();
        ## XXX in partcl, we'd check $S0 to _tcl, to know to skip this depth,
        ##     and loop one more time.
        ## my $S0 := $temp[0];
        $looper := 0;
    }
    return $ns;
}

# vim: expandtab shiftwidth=4 ft=perl6:
