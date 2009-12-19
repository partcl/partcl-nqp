class Glob::Compiler is HLL::Compiler {
    INIT {
        Glob::Compiler.parsegrammar(Glob::Grammar);
        Glob::Compiler.parseactions(Glob::Actions);
        Glob::Compiler.language('Glob');
    }
}

# vim: filetype=perl6:
