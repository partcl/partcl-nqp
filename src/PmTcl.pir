.include 'src/gen/pmtcl-grammar.pir'
.include 'src/gen/pmtcl-actions.pir'
.include 'src/gen/pmtcl-compiler.pir'
.include 'src/gen/pmtcl-commands.pir'

.sub 'main' :main
    .param pmc args

    .local pmc lexpad
    lexpad = new ['Hash']
    .lex '%VARS', lexpad

    $P0 = compreg 'PmTcl'
    $P1 = $P0.'command_line'(args)
    .return ($P1)
.end
    
