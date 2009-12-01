# interpreter initialization

module _tcl {
    sub init() {
        my %GLOBALS := pir::get_hll_global__PS('%GLOBALS');

        %GLOBALS{'tcl_version'}    := '8.5';
        %GLOBALS{'tcl_patchLevel'} := '8.5.6';
    }
}
