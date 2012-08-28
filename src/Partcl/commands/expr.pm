sub expr(*@args) {
    my $code := pir::join(' ', @args);
    error("empty expression\nin expression \"\"")
        if $code eq '';

    our %EXPRCACHE;
    my &sub := %EXPRCACHE{$code};
    unless pir::defined(&sub) {
        my $parse :=
            Partcl::Grammar.parse(
                $code,
                :rule('TOP_expr'),
                :actions(Partcl::Actions)
            );
        if $parse {
            &sub := PAST::Compiler.compile($parse.ast);
            %EXPRCACHE{$code} := &sub;
        } else {
            error("Invalid expression");
        }
    }
    &sub();
}

# vim: expandtab shiftwidth=4 ft=perl6:
