method expr(*@args) {
    my $code := nqp::join(' ', @args);
    self.error("empty expression\nin expression \"\"")
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
            self.error("Invalid expression");
        }
    }
    &sub();
}

# vim: expandtab shiftwidth=4 ft=perl6:
