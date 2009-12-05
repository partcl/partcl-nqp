# interpreter initialization

INIT {
    our %GLOBALS := TclLexPad.newpad();
    %GLOBALS{'tcl_version'}    := '8.5';
    %GLOBALS{'tcl_patchLevel'} := '8.5.6';
    %GLOBALS{'tcl_library'}    := 'library';
}

