# interpreter initialization

INIT {
    our %GLOBALS := TclLexPad.newpad();
    %GLOBALS<tcl_version>    := '8.5';
    %GLOBALS<tcl_patchLevel> := '8.5.6';
    %GLOBALS<tcl_library>    := 'library';

    %GLOBALS<tcl_precision>  := 0;

    %GLOBALS<errorCode>      := 'NONE';
    %GLOBALS<errorInfo>      := '';

    our %CHANNELS := TclLexPad.newpad();
    %CHANNELS<stdout> := pir::getstdout__p();
    %CHANNELS<stderr> := pir::getstderr__p();
    %CHANNELS<stdin>  := pir::getstdin__p();

    my %PConfig := pir::getinterp__p()[8]; ## .IGLOBALS_CONFIG_HASH

    my %tcl_platform := pir::new__Ps('TclArray');
    
    %tcl_platform<platform> := (%PConfig<slash> eq "/") ??? 'unix'
                                                        !!! 'windows';

    %tcl_platform<byteOrder> := (?%PConfig<bigendian>) ??? 'littleEndian'
                                                       !!! 'bigEndian';
    %tcl_platform<intsize>     := %PConfig<intsize>;
    %tcl_platform<os>          := %PConfig<osname>;
    %tcl_platform<machine>     := %PConfig<cpuarch>;
    %tcl_platform<pointerSize> := %PConfig<ptrsize>;

    %GLOBALS<tcl_platform> := %tcl_platform;

    pir::loadlib__ps('os');
    pir::loadlib__ps('file');
}

# Get a channel (XXX put into _tcl NS and move to another file)

sub _getChannel($name) {
    our %CHANNELS;
    my $ioObj := %CHANNELS{$name};
    $ioObj // error("can not find channel named \"$name\"");
    return $ioObj;
}

INIT {
    pir::load_bytecode('P6object.pir');
    P6metaclass().register('ResizablePMCArray', :hll<parrot>);
}

sub P6metaclass() {
    Q:PIR {
        %r = get_root_global ['parrot'], 'P6metaclass'
    };
}

##  EXPAND is a helper sub for {*} argument expansion; it probably
##  doesn't belong in the global namespace but this is a convenient
##  place to test it for now.  It takes a string and splits it up
##  into a list of elements, honoring braces and backslash
##  expansion (similar to the Tcl_SplitList function).  The actual
##  parsing and expansion is handled by the <list> token in
##  Partcl::Grammar .

our sub EXPAND($args) {
    $args.getList();
}

sub dumper($what, $label = 'VAR1') {
    pir::load_bytecode('dumper.pbc');
    my &dumper := Q:PIR {
        %r = get_root_global ['parrot'], '_dumper'
    };
    &dumper($what, $label);
}

# vim: filetype=perl6:
