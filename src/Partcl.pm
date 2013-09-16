use NQPHLL;

use src::init;
use src::Partcl::commands;
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

## XXX JVM/Parrot differ on how to define MAIN
sub MAIN($partcl, $filename) {
    # The first argument is the pm file for partcl
    my @ARGS := [];
    nqp::push(@ARGS, $filename);
    my %LEXPAD;
    my $compiler := Partcl::Compiler.new();
    $compiler.language('Partcl');
    $compiler.parsegrammar(Partcl::Grammar);
    $compiler.parseactions(Partcl::Actions);
    # TODO _ why is @ARGS not being processed?
    $compiler.command_line(@ARGS, :encoding('utf8'), :transcode('ascii iso-8859-1'));
}
