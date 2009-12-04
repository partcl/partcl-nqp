class Partcl::Compiler is HLL::Compiler;

INIT {
    Partcl::Compiler.language('Partcl');
    Partcl::Compiler.parsegrammar(Partcl::Grammar);
    Partcl::Compiler.parseactions(Partcl::Actions);
}
