module NamespaceHelper {

our  %Arg_limits;
our  %funcs;
our  %Auto_vivify;

INIT {

    ## Negative limit in "max" position => unlimited.
    %funcs<children> := NamespaceHelper::children;
    %Arg_limits<children> := [ 0, 2, "?name? ?pattern?" ];

    %funcs<code> := NamespaceHelper::code;
    %Arg_limits<code> := [ 1, 1, "script" ];

    %funcs<current> := NamespaceHelper::current;
    %Arg_limits<current> := [ 0, 0, "" ];

    %funcs<delete> := NamespaceHelper::delete;
    %Arg_limits<delete> := [ 0, -1, "" ];

    %funcs<ensemble> := NamespaceHelper::ensemble;
    %Arg_limits<ensemble> := [ 1, 0, "subcommand ?arg...?" ];

    %funcs<eval> := NamespaceHelper::eval;
    %Arg_limits<eval> := [ 2, -1, "name arg ?arg...?" ];

    %funcs<exists> := NamespaceHelper::exists;
    %Arg_limits<exists> := [ 1, 1, "name" ];

    %funcs<export> := NamespaceHelper::export;
    %Arg_limits<export> := [ 0, 0, "namespace" ];

    %funcs<forget> := NamespaceHelper::forget;
    %Arg_limits<forget> := [ 0, 0, "namespace" ];

    %funcs<import> := NamespaceHelper::import;
    %Arg_limits<import> := [ 0, -1, "namespace" ];

    %funcs<inscope> := NamespaceHelper::inscope;
    %Arg_limits<inscope> := [ 0, 0, "namespace" ];

    %funcs<origin> := NamespaceHelper::origin;
    %Arg_limits<origin> := [ 0, 0, "namespace" ];

    %funcs<parent> := NamespaceHelper::parent;
    %Arg_limits<parent> := [ 0, 1, "?name?" ];

    %funcs<path> := NamespaceHelper::path;
    %Arg_limits<path> := [ 0, 1, "namespaceList" ];

    %funcs<qualifiers> := NamespaceHelper::qualifiers;
    %Arg_limits<qualifiers> := [ 1, 1, "string" ];

    %funcs<tail> := NamespaceHelper::tail;
    %Arg_limits<tail> := [ 1, 1, "string" ];

    %funcs<upvar> := NamespaceHelper::upvar;
    %Arg_limits<upvar> := [ 0, 0, "namespace" ];

    %funcs<unknown> := NamespaceHelper::unknown;
    %Arg_limits<unknown> := [ 0, 0, "namespace" ];

    %funcs<unknown> := NamespaceHelper::unknown;
    %Arg_limits<unknown> := [ 0, 0, "namespace" ];

    %funcs<which> := NamespaceHelper::which;
    %Arg_limits<which> := [ 0, 0, "namespace" ];
}

# Parses optional -args, and generates "wrong#args" errors
# Dispatches to fairly normal NQP subs for the detailed work.
our sub dispatch_command(*@args) {
    my $num_args := +@args -1 ; # need option

    if $num_args < 0  {
        self.error('wrong # args: should be "namespace subcommand ?arg ...?"');
    }

    my @opts := <children code current delete ensemble eval exists export forget import inscope origin parent path qualifiers tail unknown upvar which>;
    my $cmd := _tcl::select_option(@opts, @args.shift, 'option');

    my @limits := %Arg_limits{$cmd};

    if (@limits[1] >= 0 && $num_args > @limits[1]) || $num_args < @limits[0] {
        my $msg := @limits[2];
        $msg := " $msg" unless $msg eq '';
        self.error("wrong # args: should be \"namespace $cmd$msg\"")
    }

    my &subcommand := %funcs{$cmd};
    &subcommand(|@args);
}

our sub children($namespace = TclString.new(), $pattern = '*') {

=begin XXX

# VM agnostic namespaces are going to be done differently than this.

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

    my $ns := pir::get_hll_namespace__P();
    for @ns -> $level {
        $ns := $ns{$level};
        if pir::typeof__SP($ns) ne 'NameSpace' {
            self.error('namespace "' ~ $namespace ~ '" not found in "::"');
        }
    }
 
    my @result := pir::new__PS('TclList');
    for $ns -> $key {
        my $element := $ns{$key};
        if (pir::typeof__SP($element) eq 'NameSpace') {
            if ?Regex::Cursor.parse($element, :rule($regex), :c(0)) {
                @result.push($prefix ~ $element);
            }
        }
    }


    return @result;

=end XXX

}

our sub code(*@args) {
    '';
}

our sub current() {
    return getNamespaceString(:depth(3));
}

our sub delete(*@args) {
    '';
}

our sub ensemble(*@args) {
    '';
}

our sub eval($namespace, *@args) {

    #XXX ignoring $namespace for now

    my $code := concat(|@args);
    my &sub := Partcl::Compiler.compile($code);
    &sub();
    '';
}

our sub exists(*@args) {
    '';
}

our sub export(*@args) {
    '';
}

our sub forget(*@args) {
    '';
}

our sub import(*@args) {
    '';
}

our sub inscope(*@args) {
    eval(@args);
}

our sub origin(*@args) {
    '';
}

our sub parent(*@args) {
    '';
}

our sub path(*@args) {
    '';
}

our sub qualifiers($string) {
    my $match := Regex::Cursor.parse(
        $string, :rule(/$<foo>=(.*)\:\:+<-[:]>*$$/), :c(0)
    );

    return ?$match ?? ~$match<foo> !! '';
}

our sub tail($string) {
    my $match := Regex::Cursor.parse(
        $string, :rule(/\:\:+$<foo>=<-[:]>*$$/), :c(0)
    );

    return ?$match ?? ~$match<foo> !! '';
}

our sub upvar(*@args) {
    '';
}

our sub unknown(*@args) {
    '';
}

our sub which(*@args) {
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


our sub getNamespaceString(int :$depth = 0) {
    return '::' ~ nqp::join('::', getNamespaceArray(:depth($depth+1)) );
}

our sub getNamespaceArray(int :$depth = 0) {

    my @ns := getNamespace(:depth($depth+1)).get_name();

    # The first element would be "::tcl" from parrot's HLL directive, but
    # that's our root.

    my $assert := @ns.shift();
    self.error("ASSERT not rooted in ::tcl namespace")
        if $assert ne "tcl"; # Should never occur.

    my $pos := +@ns;
    while $pos > 0 {
        $pos--;
        @ns.unshift( @ns[$pos] );
    }

    return @ns;
}

our sub getNamespace(int :$depth=0) {
    # XXX namespaces will change on non-parrot
    ##my $looper := 1;

    ##my $ns;
    ##while $looper {
        ##$depth++;
        ## Needed for the multipart keys.
        ##$ns := Q:PIR {
          ##$P0 = find_lex '$depth'
          ##$I0 = $P0
          ##$P1 = getinterp     
          ##%r = $P1['sub'; $I0]
        ##};
        ##$ns := $ns.get_namespace();
        #### XXX in partcl, we'd check $S0 to _tcl, to know to skip this depth,
        ####     and loop one more time.
        #### my $S0 := $temp[0];
        ##$looper := 0;
    ##}
    ##return $ns;
}

}

# vim: expandtab shiftwidth=4 ft=perl6:
