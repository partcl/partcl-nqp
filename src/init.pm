use src::TclLexPad;
use src::TclArray;

INIT {
    # only necessary on parrot?
    #pir::loadlib__Ps("os");
    #pir::loadlib__Ps("bit_ops");
    #pir::loadlib__Ps("io");
    #pir::loadlib__Ps("trans");
    #pir::loadlib__PS('file');

    my %GLOBALS := TclLexPad.newpad();
    %GLOBALS<tcl_version>    := '8.5';
    %GLOBALS<tcl_patchLevel> := '8.5.6';
    %GLOBALS<tcl_library>    := 'library';

    %GLOBALS<tcl_precision>  := 0;

    %GLOBALS<errorCode>      := 'NONE';
    %GLOBALS<errorInfo>      := '';

=begin XXX    

    my %PConfig := pir::getinterp__P()[8]; ## .IGLOBALS_CONFIG_HASH

    my %tcl_platform := TclArray.new();
    
    %tcl_platform<platform> := (%PConfig<slash> eq "/") ??? 'unix'
                                                        !!! 'windows';

    %tcl_platform<byteOrder> := (?%PConfig<bigendian>) ??? 'littleEndian'
                                                       !!! 'bigEndian';
    %tcl_platform<intsize>     := %PConfig<intsize>;
    %tcl_platform<os>          := %PConfig<osname>;
    %tcl_platform<machine>     := %PConfig<cpuarch>;
    %tcl_platform<pointerSize> := %PConfig<ptrsize>;

    %GLOBALS<tcl_platform> := %tcl_platform;

=end XXX
}

##  EXPAND is a helper sub for {*} argument expansion; it probably
##  doesn't belong in the global namespace but this is a convenient
##  place to test it for now.  It takes a string and splits it up
##  into a list of elements, honoring braces and backslash
##  expansion (similar to the Tcl_SplitList function).  The actual
##  parsing and expansion is handled by the <list> token in
##  Partcl::Grammar .

sub EXPAND($args) is export {
    Internals.getList($args);
}

=begin XXX

sub dumper($what, $label = 'VAR1') {
    #pir::load_bytecode__PS('dumper.pbc');
    my &dumper := Q:PIR {
        %r = get_root_global ['parrot'], '_dumper'
    };
    &dumper($what, $label);
}

=end XXX

# vim: expandtab shiftwidth=4 ft=perl6:
