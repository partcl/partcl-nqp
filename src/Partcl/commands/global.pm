sub global (*@args) is export {
    our %GLOBALS;

    ##  my %CUR_LEXPAD := DYNAMIC::<%LEXPAD>
    my %CUR_LEXPAD := pir::find_dynamic_lex__PS('%LEXPAD');

    for @args {
        %CUR_LEXPAD{$_} := %GLOBALS{$_};
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
