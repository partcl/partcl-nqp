class ARE::Compiler is HLL::Compiler {
    INIT {
        ARE::Compiler.parsegrammar(ARE::Grammar);
        ARE::Compiler.parseactions(ARE::Actions);
        ARE::Compiler.language('ARE');
    }
}

# vim: filetype=perl6:
