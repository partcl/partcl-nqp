use NQPHLL;

class ARE::Compiler is HLL::Compiler {
    INIT {
        my $compiler := ARE::Compiler.new();
        $compiler.parsegrammar(ARE::Grammar);
        $compiler.parseactions(ARE::Actions);
        $compiler.language('ARE');
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
