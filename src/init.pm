# interpreter initialization

INIT {
    our %GLOBALS := TclLexPad.newpad();
    %GLOBALS{'tcl_version'}    := '8.5';
    %GLOBALS{'tcl_patchLevel'} := '8.5.6';
    %GLOBALS{'tcl_library'}    := 'library';

    our %CHANNELS := TclLexPad.newpad();
    %CHANNELS{'stdout'} := pir::getstdout__p();
    %CHANNELS{'stderr'} := pir::getstderr__p();
    %CHANNELS{'stdin'}  := pir::getstdin__p();

    my @interp  := pir::getinterp__p();
    my %PConfig := @interp[6]; ## .IGLOBALS_CONFIG_HASH
    # ... 
}

# Get a channel (XXX put into _tcl NS and move to another file)

sub _getChannel($name) {
    our %CHANNELS;
    my $ioObj := %CHANNELS{$name};
    $ioObj // error("can not find channel named \"$name\"");
    return $ioObj;
}

# vim: filetype=perl6:
