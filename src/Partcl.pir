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

.include 'src/gen/partcl-grammar.pir'
.include 'src/gen/partcl-actions.pir'
.include 'src/gen/partcl-compiler.pir'
.include 'src/gen/partcl-operators.pir'
.include 'src/gen/partcl-commands-main.pir'
.include 'src/gen/partcl-commands-file.pir'
.include 'src/gen/partcl-commands-info.pir'
.include 'src/gen/partcl-commands-namespace.pir'
.include 'src/gen/partcl-commands-package.pir'
.include 'src/gen/partcl-commands-string.pir'
.include 'src/gen/tcllexpad.pir'
.include 'src/gen/tclstring.pir'
.include 'src/gen/are-grammar.pir'
.include 'src/gen/are-actions.pir'
.include 'src/gen/are-compiler.pir'
.include 'src/gen/init.pir'
.include 'src/gen/options.pir'

.namespace []
.sub 'main' :main
    .param pmc args

    # Set up iniital lexpad.
    .local pmc lexpad
    lexpad = get_hll_global '%GLOBALS'
    .lex '%LEXPAD', lexpad

    $P0 = compreg 'Partcl'
    $P0.'command_line'(args)
    exit 0
.end
