use NQPHLL;
use src::TclLexPad;
use src::TclArray;

INIT {
    pir::loadlib__Ps("os");
    pir::loadlib__Ps("bit_ops");
    pir::loadlib__Ps("io");
    pir::loadlib__Ps("trans");
    pir::loadlib__PS('file');

    our %GLOBALS := TclLexPad.newpad();
    %GLOBALS<tcl_version>    := '8.5';
    %GLOBALS<tcl_patchLevel> := '8.5.6';
    %GLOBALS<tcl_library>    := 'library';

    %GLOBALS<tcl_precision>  := 0;

    %GLOBALS<errorCode>      := 'NONE';
    %GLOBALS<errorInfo>      := '';

    my %CHANNELS_HASH := TclLexPad.newpad();
    %CHANNELS_HASH<stdout> := pir::getstdout__P();
    %CHANNELS_HASH<stderr> := pir::getstderr__P();
    %CHANNELS_HASH<stdin>  := pir::getstdin__P();

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
}

sub CHANNELS() is export {
    return %CHANNELS_HASH;
}

# Get a channel (XXX put into _tcl NS and move to another file)

sub _getChannel($name) {
    my $ioObj := CHANNELS(){$name};
    $ioObj // error("can not find channel named \"$name\"");
    return $ioObj;
}

##  EXPAND is a helper sub for {*} argument expansion; it probably
##  doesn't belong in the global namespace but this is a convenient
##  place to test it for now.  It takes a string and splits it up
##  into a list of elements, honoring braces and backslash
##  expansion (similar to the Tcl_SplitList function).  The actual
##  parsing and expansion is handled by the <list> token in
##  Partcl::Grammar .

sub EXPAND($args) {
    $args.getList();
}

sub dumper($what, $label = 'VAR1') {
    pir::load_bytecode__PS('dumper.pbc');
    my &dumper := Q:PIR {
        %r = get_root_global ['parrot'], '_dumper'
    };
    &dumper($what, $label);
}

# vim: expandtab shiftwidth=4 ft=perl6:

use src::Partcl::Grammar;
use src::Partcl::Actions;
use src::Partcl::Compiler;
use src::Partcl::Operators;
use src::TclArray;
use src::TclLexPad;
use src::TclList;
use src::TclString;
use src::ARE::Grammar;
use src::ARE::Actions;
use src::ARE::Compiler;
use src::StringGlob::Grammar;
use src::StringGlob::Actions;
use src::StringGlob::Compiler;
use src::FileGlob::Grammar;
use src::FileGlob::Actions;
use src::FileGlob::Compiler;

use src::options;

sub MAIN(*@ARGS) {
    # XXX setup %LEXPAD?
    my $compiler := Partcl::Compiler.new();
    $compiler.language('Partcl');
    $compiler.parsegrammar(Partcl::Grammar);
    $compiler.parseactions(Partcl::Actions);
    $compiler.command_line(@ARGS);
}

