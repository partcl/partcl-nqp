# interpreter initialization

use src::TclLexPad;
use src::TclArray;

INIT {
    our %GLOBALS := TclLexPad.newpad();
    %GLOBALS<tcl_version>    := '8.5';
    %GLOBALS<tcl_patchLevel> := '8.5.6';
    %GLOBALS<tcl_library>    := 'library';

    %GLOBALS<tcl_precision>  := 0;

    %GLOBALS<errorCode>      := 'NONE';
    %GLOBALS<errorInfo>      := '';

    our %CHANNELS := TclLexPad.newpad();
    %CHANNELS<stdout> := pir::getstdout();
    %CHANNELS<stderr> := pir::getstderr();
    %CHANNELS<stdin>  := pir::getstdin();

    my %PConfig := pir::getinterp[8]; ## .IGLOBALS_CONFIG_HASH

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

    pir::loadlib('os');
    pir::loadlib('file');
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

## wrapper sub for invoking tcl builtins - deals with unknown handling and
## namespace desugaring; use a pointy block to avoid tampering with CONTROLs.

INIT {
    GLOBAL::invoke := -> $command, *@args {

        ## Get our caller's namespace, do the lookup from there.
        my $ns := Q:PIR {
           $P1 = getinterp
           %r = $P1['sub'; 1]
        }.get_namespace();

        my &command := $ns{$command};

        ## if that didn't work, check in the root ns.
        if pir::typeof(&command) eq "Undef" {
            $ns := pir::get_hll_namespace__p();
            &command := $ns{$command};
        }

        if pir::typeof(&command) eq "Undef" {
            error("invalid command name \"$command\"");
        }

        &command(|@args);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
