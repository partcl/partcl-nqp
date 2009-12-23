class StringGlob::Compiler is HLL::Compiler {
    INIT {
        StringGlob::Compiler.parsegrammar(StringGlob::Grammar);
        StringGlob::Compiler.parseactions(StringGlob::Actions);
        StringGlob::Compiler.language('StringGlob');
    }
}

# vim: filetype=perl6:
