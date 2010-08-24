.loadlib 'bit_ops'
.loadlib 'io_ops'
.loadlib 'trans_ops'

## XXX add cheats to String & Integer to provide 'getList'.
## Shouldn't be necessary, but something isn't boxing properly.

.HLL 'parrot'
.namespace ['String']
.sub 'getList' :method
    $S1 = self
    $P1 = new ['TclString']
    $P1 = $S1
    .tailcall $P1.'getList'()
.end

.namespace ['Integer']
.sub 'getList' :method
    $S1 = self
    $P1 = new ['TclString']
    $P1 = $S1
    .tailcall $P1.'getList'()
.end

.HLL 'tcl'

.namespace []

.sub '' :anon :load :init
    load_bytecode 'HLL.pbc'

    .local pmc hllns, parrotns, imports
    hllns = get_hll_namespace
    parrotns = get_root_namespace ['parrot']
    imports = split ' ', 'PAST PCT HLL Regex Hash ResizablePMCArray'
    parrotns.'export_to'(hllns, imports)
.end

.include 'src/Partcl/Grammar.pir'
.include 'src/Partcl/Actions.pir'
.include 'src/Partcl/Compiler.pir'
.include 'src/Partcl/Operators.pir'
.include 'src/Partcl/commands/after.pir'
.include 'src/Partcl/commands/append.pir'
.include 'src/Partcl/commands/apply.pir'
.include 'src/Partcl/commands/array.pir'
.include 'src/Partcl/commands/binary.pir'
.include 'src/Partcl/commands/break.pir'
.include 'src/Partcl/commands/catch.pir'
.include 'src/Partcl/commands/cd.pir'
.include 'src/Partcl/commands/concat.pir'
.include 'src/Partcl/commands/continue.pir'
.include 'src/Partcl/commands/dict.pir'
.include 'src/Partcl/commands/eof.pir'
.include 'src/Partcl/commands/encoding.pir'
.include 'src/Partcl/commands/error.pir'
.include 'src/Partcl/commands/eval.pir'
.include 'src/Partcl/commands/exit.pir'
.include 'src/Partcl/commands/expr.pir'
.include 'src/Partcl/commands/fileevent.pir'
.include 'src/Partcl/commands/file.pir'
.include 'src/Partcl/commands/flush.pir'
.include 'src/Partcl/commands/foreach.pir'
.include 'src/Partcl/commands/format.pir'
.include 'src/Partcl/commands/for.pir'
.include 'src/Partcl/commands/gets.pir'
.include 'src/Partcl/commands/global.pir'
.include 'src/Partcl/commands/glob.pir'
.include 'src/Partcl/commands/if.pir'
.include 'src/Partcl/commands/incr.pir'
.include 'src/Partcl/commands/info.pir'
.include 'src/Partcl/commands/interp.pir'
.include 'src/Partcl/commands/join.pir'
.include 'src/Partcl/commands/lappend.pir'
.include 'src/Partcl/commands/lassign.pir'
.include 'src/Partcl/commands/lindex.pir'
.include 'src/Partcl/commands/linsert.pir'
.include 'src/Partcl/commands/list.pir'
.include 'src/Partcl/commands/llength.pir'
.include 'src/Partcl/commands/lrange.pir'
.include 'src/Partcl/commands/lrepeat.pir'
.include 'src/Partcl/commands/lreplace.pir'
.include 'src/Partcl/commands/lreverse.pir'
.include 'src/Partcl/commands/lset.pir'
.include 'src/Partcl/commands/lsort.pir'
.include 'src/Partcl/commands/namespace.pir'
.include 'src/Partcl/commands/package.pir'
.include 'src/Partcl/commands/proc.pir'
.include 'src/Partcl/commands/puts.pir'
.include 'src/Partcl/commands/pwd.pir'
.include 'src/Partcl/commands/regexp.pir'
.include 'src/Partcl/commands/rename.pir'
.include 'src/Partcl/commands/return.pir'
.include 'src/Partcl/commands/set.pir'
.include 'src/Partcl/commands/socket.pir'
.include 'src/Partcl/commands/source.pir'
.include 'src/Partcl/commands/split.pir'
.include 'src/Partcl/commands/string.pir'
.include 'src/Partcl/commands/subst.pir'
.include 'src/Partcl/commands/switch.pir'
.include 'src/Partcl/commands/time.pir'
.include 'src/Partcl/commands/trace.pir'
.include 'src/Partcl/commands/unset.pir'
.include 'src/Partcl/commands/uplevel.pir'
.include 'src/Partcl/commands/upvar.pir'
.include 'src/Partcl/commands/variable.pir'
.include 'src/Partcl/commands/vwait.pir'
.include 'src/Partcl/commands/while.pir'
.include 'src/TclArray.pir'
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
