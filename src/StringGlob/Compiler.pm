use NQPHLL;

class StringGlob::Compiler is HLL::Compiler {
    INIT {
        my $compiler := StringGlob::Compiler.new();
        $compiler.parsegrammar(StringGlob::Grammar);
        $compiler.parseactions(StringGlob::Actions);
        $compiler.language('StringGlob');
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
