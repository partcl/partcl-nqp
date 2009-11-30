.include 'src/class/tcllist.pir'
.include 'src/class/tclstring.pir'

.HLL 'tcl'

.namespace []

.sub '' :anon :load :init
    load_bytecode 'HLL.pbc'

    .local pmc hllns, parrotns, imports
    hllns = get_hll_namespace
    parrotns = get_root_namespace ['parrot']
    imports = split ' ', 'PAST PCT HLL Regex Hash'
    parrotns.'export_to'(hllns, imports)
.end

.include 'src/gen/pmtcl-grammar.pir'
.include 'src/gen/pmtcl-actions.pir'
.include 'src/gen/pmtcl-compiler.pir'
.include 'src/gen/pmtcl-commands-main.pir'
.include 'src/gen/pmtcl-commands-string.pir'
.include 'src/gen/tcllexpad.pir'
.include 'src/gen/are-grammar.pir'
.include 'src/gen/are-actions.pir'
.include 'src/gen/are-compiler.pir'

.namespace []
.sub 'main' :main
    .param pmc args

    .local pmc lexpad
    $P0 = get_hll_global 'TclLexPad'
    lexpad = $P0.'newpad'()
    .lex '%LEXPAD', lexpad
    set_hll_global '%GLOBALS', lexpad

    $P0 = compreg 'PmTcl'
    $P1 = $P0.'command_line'(args)
    .return ($P1)
.end
