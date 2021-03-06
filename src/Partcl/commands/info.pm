our sub info(*@args) {
    Info::dispatch_command(|@args);
}

module Info;

our %Arg_limits;
our %Info_funcs;

INIT {
    %Info_funcs<args> := Info::args;
    %Arg_limits<args> := [1, 1, 'procname'];

    %Info_funcs<body> := Info::body;
    %Arg_limits<body> := [1, 1, 'procname'];

    %Info_funcs<cmdcount> := Info::cmdcount;
    %Arg_limits<cmdcount> := [0, 0, ''];

    %Info_funcs<commands> := Info::commands;
    %Arg_limits<commands> := [0, 1, '?pattern?'];

    %Info_funcs<complete> := Info::complete;
    %Arg_limits<complete> :=  [1, 1, 'complete'];

    %Info_funcs<default> := Info::default;
    %Arg_limits<default> := [3, 3, 'procname arg varname'];

    %Info_funcs<exists> := Info::exists;
    %Arg_limits<exists> := [1, 1, 'varName']; 

    %Info_funcs<frame> := Info::frame;
    %Arg_limits<frame> := [0, 1, '?number?'];

    %Info_funcs<functions> := Info::functions;
    %Arg_limits<functions> := [0, 1, '?pattern?'];

    %Info_funcs<globals> := Info::globals;
    %Arg_limits<globals> := [0, 1, '?pattern?']; 

    %Info_funcs<hostname> := Info::hostname;
    %Arg_limits<hostname> := [0, 0, ''];

    %Info_funcs<level> := Info::level;
    %Arg_limits<level> := [0, 1, '?number?'];

    %Info_funcs<library> := Info::library;
    %Arg_limits<library> := [0, 0, '']; 

    %Info_funcs<loaded> := Info::loaded;
    %Arg_limits<loaded> := [0, 1, '?interp?'];

    %Info_funcs<locals> := Info::locals;
    %Arg_limits<locals> := [0, 1, '?pattern?'];

    %Info_funcs<nameofexecutable> := Info::nameofexecutable;
    %Arg_limits<nameofexecutable> := [0, 0, ''];

    %Info_funcs<patchlevel> := Info::patchlevel;
    %Arg_limits<patchlevel> := [0, 0, ''];

    %Info_funcs<procs> := Info::procs;
    %Arg_limits<procs> :=  [0, 1, '?pattern?'];

    %Info_funcs<script> := Info::script;
    %Arg_limits<script> := [0, 1, '?filename?'];

    %Info_funcs<sharedlibextension> := Info::sharedlibextension;
    %Arg_limits<sharedlibextension> := [0, 0, ''];

    %Info_funcs<tclversion> := Info::tclversion;
    %Arg_limits<tclversion> := [0, 0, ''];

    %Info_funcs<vars> := Info::vars;
    %Arg_limits<vars> := [0, 1, '?pattern?'];
}

# Handle wrong # args, bad option errors.
# dispatch to internal NQP subs for actual work.

our sub dispatch_command(*@args) {
    my $argc := +@args;

    if $argc-- < 1 {
        error('wrong # args: should be "info subcommand ?argument ...?"');
    }

    my @opts := <args body cmdcount commands complete default exists frame functions globals hostname level library loaded locals nameofexecutable patchlevel procs script sharedlibextension tclversion vars>;

    my $cmd := _tcl::select_option(@opts, @args.shift, 'subcommand');

    my @limits := %Arg_limits{$cmd};

    if $argc > @limits[1] || $argc < @limits[0] {
        my $msg := @limits[2];
        $msg := ' ' ~ $msg if $msg ne '';
    error("wrong # args: should be \"info $cmd$msg\"")
    }

    my &subcommand := %Info_funcs{$cmd};
    &subcommand(|@args);
}

my sub args($procname) {
    my $sub := pir::get_hll_global__PS($procname);
    error("\"$procname\" isn't a procedure")
        if pir::isnull($sub);
    
    pir::getprop($sub, 'args');
}

my sub body($procname) {
    my $sub := pir::get_hll_global__PS($procname);
    error("\"$procname\" isn't a procedure")
        if pir::isnull($sub);
    
    pir::getprop($sub, 'body');
}

my sub cmdcount() {
    0;
}

my sub commands($pattern = '*') {
    # XXX other NS.

    my $globber := StringGlob::Compiler.compile($pattern);

    my @result := pir::new('TclList');

    my $globalNS := pir::get_root_global__PS('tcl');
    for $globalNS -> $elem {
        @result.push($elem) if
            ?Regex::Cursor.parse($elem, :rule($globber), :c(0));
    }
    @result;
}

my sub complete($command) {
    0;
}

my sub default($procname, $arg, $varname) {
    my $sub := pir::get_hll_global__PS($procname);
    error("\"$procname\" isn't a procedure")
        if pir::isnull($sub);
    
    my $defaults := pir::getprop($sub, 'defaults');
    error("procedure \"$procname\" doesn't have an argument \"$arg\"")
        unless ?pir::exists($defaults, $arg);

    my $parameter := $defaults{$arg};
    if pir::defined($parameter) {
        set($varname, $parameter);
        return 1;
    } else {
        set($varname, '');
        return 0;
    }
}

my sub exists($varname) {
    0;
}

my sub frame($number?) {
    0;
}

my sub functions($pattern = '*') {
    '';
}

my sub globals($pattern = '*') {

    my %GLOBALS := pir::get_hll_global__ps('%GLOBALS');
    my $globber := StringGlob::Compiler.compile($pattern);
    my @result := pir::new('TclList');

    for %GLOBALS -> $var {
        @result.push($var) if
            ?Regex::Cursor.parse($var, :rule($globber), :c(0));
    }
    @result;
}

my sub hostname() {
    '';
}

my sub level($number?) {
    '';
}

my sub library() {
    my %GLOBALS := pir::get_hll_global__ps('%GLOBALS');
    %GLOBALS<tcl_library>;
}

my sub loaded($interp?) {
    '';
}

my sub locals($pattern = '*') {
    '';
}

my sub nameofexecutable() {
    '';
}

my sub patchlevel() {
    my %GLOBALS := pir::get_hll_global__ps('%GLOBALS');
    %GLOBALS<tcl_patchLevel>;
}

my sub procs($pattern = '*') {
    '';
}

my sub tclversion() {
    my %GLOBALS := pir::get_hll_global__ps('%GLOBALS');
    %GLOBALS<tcl_version>;
}

my sub script($filename?) {
    '';
}

my sub sharedlibextension() {
    '';
}

my sub vars($pattern = '*') {
    my %LEXPAD := pir::find_dynamic_lex('%LEXPAD');
    my $globber := StringGlob::Compiler.compile($pattern);
    my @result := pir::new('TclList');

    for %LEXPAD -> $var {
        @result.push($var) if
            ?Regex::Cursor.parse($var, :rule($globber), :c(0));
    }
    @result;
}

# vim: expandtab shiftwidth=4 ft=perl6:
