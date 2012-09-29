sub expr(*@args) is export {
    my $code := nqp::join(' ', @args);
    error("empty expression\nin expression \"\"")
        if $code eq '';

    our %EXPRCACHE;
    my &sub := %EXPRCACHE{$code};
    unless nqp::defined(&sub) {
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
