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

.include 'src/Partcl/Grammar.pir'
.include 'src/Partcl/Actions.pir'
.include 'src/Partcl/Compiler.pir'
.include 'src/Partcl/Operators.pir'
.include 'src/Partcl/commands/main.pir'
.include 'src/Partcl/commands/array.pir'
.include 'src/Partcl/commands/dict.pir'
.include 'src/Partcl/commands/file.pir'
.include 'src/Partcl/commands/info.pir'
.include 'src/Partcl/commands/interp.pir'
.include 'src/Partcl/commands/namespace.pir'
.include 'src/Partcl/commands/package.pir'
.include 'src/Partcl/commands/string.pir'
.include 'src/Partcl/commands/trace.pir'
.include 'src/TclLexPad.pir'
.include 'src/TclList.pir'
.include 'src/TclString.pir'
.include 'src/ARE/Grammar.pir'
.include 'src/ARE/Actions.pir'
.include 'src/ARE/Compiler.pir'
.include 'src/StringGlob/Grammar.pir'
.include 'src/StringGlob/Actions.pir'
.include 'src/StringGlob/Compiler.pir'
.include 'src/FileGlob/Grammar.pir'
.include 'src/FileGlob/Actions.pir'
.include 'src/FileGlob/Compiler.pir'
.include 'src/init.pir'
.include 'src/options.pir'

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
