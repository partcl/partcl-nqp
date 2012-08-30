use NQPHLL;

sub invoke(*@ARGS) {
   say("invoked");
}

sub MAIN(*@ARGS) {
        my $compiler := Partcl::Compiler.new();
        $compiler.language('Partcl');
        $compiler.parsegrammar(Partcl::Grammar);
        $compiler.parseactions(Partcl::Actions);
        $compiler.command_line(@ARGS);
}

# vim: expandtab shiftwidth=4 ft=perl6:

