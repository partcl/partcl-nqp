method uplevel($level, *@args) {
    ##  my %LEXPAD := DYNAMIC::<%LEXPAD>
    my %LEXPAD := pir::find_dynamic_lex__PS('%LEXPAD');

    ##  0x23 == '#'
    if nqp::ord($level) == 0x23 {
        $level := %LEXPAD.depth - nqp::substr($level, 1);
    }

    ##  walk up the chain of outer contexts
    while $level > 0 {
        %LEXPAD := %LEXPAD.outer;
        $level := $level - 1;
    }

    ##  now evaluate @args in the current context
    my $code := concat(|@args);
    Partcl::Compiler.eval($code);
}

# vim: expandtab shiftwidth=4 ft=perl6:
