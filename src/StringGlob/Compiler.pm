use NQPHLL;

class StringGlob::Compiler is HLL::Compiler {
    INIT {
        StringGlob::Compiler.parsegrammar(StringGlob::Grammar);
        StringGlob::Compiler.parseactions(StringGlob::Actions);
        StringGlob::Compiler.language('StringGlob');
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
