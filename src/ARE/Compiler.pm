use NQPP6Regex;

class ARE::Compiler is HLL::Compiler {
    INIT {
        ARE::Compiler.parsegrammar(ARE::Grammar);
        ARE::Compiler.parseactions(ARE::Actions);
        ARE::Compiler.language('ARE');
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
