class FileGlob::Compiler is HLL::Compiler {
    INIT {
        FileGlob::Compiler.parsegrammar(FileGlob::Grammar);
        FileGlob::Compiler.parseactions(FileGlob::Actions);
        FileGlob::Compiler.language('FileGlob');
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
