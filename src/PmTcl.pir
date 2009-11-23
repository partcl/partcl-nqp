.include 'src/gen/pmtcl-grammar.pir'
.include 'src/gen/pmtcl-actions.pir'
.include 'src/gen/pmtcl-compiler.pir'
.include 'src/gen/pmtcl-commands.pir'
.include 'src/gen/tcllexpad.pir'

.sub 'main' :main
    .param pmc args

    .local pmc lexpad
    $P0 = get_hll_global 'TclLexPad'
    lexpad = $P0.'newpad'()
    .lex '%LEXPAD', lexpad

    $P0 = compreg 'PmTcl'
    $P1 = $P0.'command_line'(args)
    .return ($P1)
.end
