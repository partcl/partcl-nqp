our sub global (*@args) {
    our %GLOBALS;

    ##  my %CUR_LEXPAD := DYNAMIC::<%LEXPAD>
    my %CUR_LEXPAD := pir::find_dynamic_lex__Ps('%LEXPAD');

    for @args {
        %CUR_LEXPAD{$_} := %GLOBALS{$_};
    }
    '';
}