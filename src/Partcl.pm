use NQPHLL;

use src::init;
use src::Partcl::Grammar;
use src::Partcl::Actions;
use src::Partcl::Compiler;
use src::Partcl::Operators;
use src::TclArray;
use src::TclLexPad;
use src::TclList;
use src::TclString;
use src::ARE::Grammar;
use src::ARE::Actions;
use src::ARE::Compiler;
use src::StringGlob::Grammar;
use src::StringGlob::Actions;
use src::StringGlob::Compiler;
use src::FileGlob::Grammar;
use src::FileGlob::Actions;
use src::FileGlob::Compiler;
use src::options;

sub MAIN(*@ARGS) {
    # XXX setup %LEXPAD?
    my $compiler := Partcl::Compiler.new();
    $compiler.language('Partcl');
    $compiler.parsegrammar(Partcl::Grammar);
    $compiler.parseactions(Partcl::Actions);
    $compiler.command_line(@ARGS);
}
