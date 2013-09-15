module InfoHelper {

our %Arg_limits;
our %Info_funcs;

INIT {
    %Info_funcs<args> := InfoHelper::args;
    %Arg_limits<args> := [1, 1, 'procname'];

    %Info_funcs<body> := InfoHelper::body;
    %Arg_limits<body> := [1, 1, 'procname'];

    %Info_funcs<cmdcount> := InfoHelper::cmdcount;
    %Arg_limits<cmdcount> := [0, 0, ''];

    %Info_funcs<commands> := InfoHelper::commands;
    %Arg_limits<commands> := [0, 1, '?pattern?'];

    %Info_funcs<complete> := InfoHelper::complete;
    %Arg_limits<complete> :=  [1, 1, 'complete'];

    %Info_funcs<default> := InfoHelper::default;
    %Arg_limits<default> := [3, 3, 'procname arg varname'];

    %Info_funcs<exists> := InfoHelper::exists;
    %Arg_limits<exists> := [1, 1, 'varName']; 

    %Info_funcs<frame> := InfoHelper::frame;
    %Arg_limits<frame> := [0, 1, '?number?'];

    %Info_funcs<functions> := InfoHelper::functions;
    %Arg_limits<functions> := [0, 1, '?pattern?'];

    %Info_funcs<globals> := InfoHelper::globals;
    %Arg_limits<globals> := [0, 1, '?pattern?']; 

    %Info_funcs<hostname> := InfoHelper::hostname;
    %Arg_limits<hostname> := [0, 0, ''];

    %Info_funcs<level> := InfoHelper::level;
    %Arg_limits<level> := [0, 1, '?number?'];

    %Info_funcs<library> := InfoHelper::library;
    %Arg_limits<library> := [0, 0, '']; 

    %Info_funcs<loaded> := InfoHelper::loaded;
    %Arg_limits<loaded> := [0, 1, '?interp?'];

    %Info_funcs<locals> := InfoHelper::locals;
    %Arg_limits<locals> := [0, 1, '?pattern?'];

    %Info_funcs<nameofexecutable> := InfoHelper::nameofexecutable;
    %Arg_limits<nameofexecutable> := [0, 0, ''];

    %Info_funcs<patchlevel> := InfoHelper::patchlevel;
    %Arg_limits<patchlevel> := [0, 0, ''];

    %Info_funcs<procs> := InfoHelper::procs;
    %Arg_limits<procs> :=  [0, 1, '?pattern?'];

    %Info_funcs<script> := InfoHelper::script;
    %Arg_limits<script> := [0, 1, '?filename?'];

    %Info_funcs<sharedlibextension> := InfoHelper::sharedlibextension;
    %Arg_limits<sharedlibextension> := [0, 0, ''];

    %Info_funcs<tclversion> := InfoHelper::tclversion;
    %Arg_limits<tclversion> := [0, 0, ''];

    %Info_funcs<vars> := InfoHelper::vars;
    %Arg_limits<vars> := [0, 1, '?pattern?'];
}

# Handle wrong # args, bad option errors.
# dispatch to internal NQP subs for actual work.

our sub dispatch_command(*@args) {
    my $argc := +@args;

    if $argc-- < 1 {
        self.error('wrong # args: should be "info subcommand ?argument ...?"');
    }

    my @opts := <args body cmdcount commands complete default exists frame functions globals hostname level library loaded locals nameofexecutable patchlevel procs script sharedlibextension tclversion vars>;

    my $cmd := _tcl::select_option(@opts, @args.shift, 'subcommand');

    my @limits := %Arg_limits{$cmd};

    if $argc > @limits[1] || $argc < @limits[0] {
        my $msg := @limits[2];
        $msg := ' ' ~ $msg if $msg ne '';
    self.error("wrong # args: should be \"info $cmd$msg\"")
    }

    my &subcommand := %Info_funcs{$cmd};
    &subcommand(|@args);
}

our sub args($procname) {
    # XXX different in non-parrot
    #my $sub := pir::get_hll_global__PS($procname);
    #self.error("\"$procname\" isn't a procedure")
    #    if nqp::isnull($sub);
   # 
   # pir::getprop__PPS($sub, 'args');
   "";
}

our sub body($procname) {
    # XXX different in non-parrot
    #my $sub := pir::get_hll_global__PS($procname);
    #self.error("\"$procname\" isn't a procedure")
        #if nqp::isnull($sub);
    #
    #pir::getprop__PPS($sub, 'body');
    "";
}

our sub cmdcount() {
    0;
}

our sub commands($pattern = '*') {
    # XXX other NS.

    my $globber := StringGlob::Compiler.compile($pattern);

    my @result := TclList.new();

    # XXX different in non parrot
    #my $globalNS := pir::get_root_global__PS('tcl');
    #for $globalNS -> $elem {
        #@result.push($elem) if
            #?Regex::Cursor.parse($elem, :rule($globber), :c(0));
    #}
    @result;
}

our sub complete($command) {
    0;
}

our sub default($procname, $arg, $varname) {
# XXX different in non-parrot
    #my $sub := pir::get_hll_global__PS($procname);
    #self.error("\"$procname\" isn't a procedure")
        #if nqp::isnull($sub);
    #
    #my $defaults := pir::getprop__PPS($sub, 'defaults');
    #self.error("procedure \"$procname\" doesn't have an argument \"$arg\"")
        #unless ?pir::exists__IQs($defaults, $arg);
#
    #my $parameter := $defaults{$arg};
    #if nqp::defined($parameter) {
        #set($varname, $parameter);
        #return 1;
    #} else {
        #set($varname, '');
        #return 0;
    #}
}

our sub exists($varname) {
    0;
}

our sub frame($number?) {
    0;
}

our sub functions($pattern = '*') {
    '';
}

our sub globals($pattern = '*') {

# XXX different in non-parrot
    #my %GLOBALS := pir::get_hll_global__PS('%GLOBALS');
    #my $globber := StringGlob::Compiler.compile($pattern);
    #my @result := pir::new__PS('TclList');
#
    #for %GLOBALS -> $var {
        #@result.push($var) if
            #?Regex::Cursor.parse($var, :rule($globber), :c(0));
    #}
    #@result;
}

our sub hostname() {
    '';
}

our sub level($number?) {
    '';
}

our sub library() {
# XXX different in non-parrot
    #my %GLOBALS := pir::get_hll_global__PS('%GLOBALS');
    #%GLOBALS<tcl_library>;
}

our sub loaded($interp?) {
    '';
}

our sub locals($pattern = '*') {
    '';
}

our sub nameofexecutable() {
    '';
}

our sub patchlevel() {
    # XXX different in non-parrot
    ##my %GLOBALS := pir::get_hll_global__PS('%GLOBALS');
    ##%GLOBALS<tcl_patchLevel>;
}

our sub procs($pattern = '*') {
    '';
}

our sub tclversion() {
    # XXX different in non-parrot
    ##my %GLOBALS := pir::get_hll_global__PS('%GLOBALS');
    ##%GLOBALS<tcl_version>;
}

our sub script($filename?) {
    '';
}

our sub sharedlibextension() {
    '';
}

our sub vars($pattern = '*') {
    # XXX different in non-parrot
    ## my %LEXPAD := pir::find_dynamic_lex__PS('%LEXPAD');
    ## my $globber := StringGlob::Compiler.compile($pattern);
    ## my @result := pir::new__PS('TclList');
## 
    ## for %LEXPAD -> $var {
        ## @result.push($var) if
            ## ?Regex::Cursor.parse($var, :rule($globber), :c(0));
    ## }
    ## @result;
}

}

# vim: expandtab shiftwidth=4 ft=perl6:
