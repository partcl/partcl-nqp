use NQPHLL;

class FileGlob::Compiler is HLL::Compiler {
    INIT {
        my $compiler := FileGlob::Compiler.new();
        $compiler.parsegrammar(FileGlob::Grammar);
        $compiler.parseactions(FileGlob::Actions);
        $compiler.language('FileGlob');
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
