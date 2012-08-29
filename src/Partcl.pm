INIT {
    pir::loadlib("bit_ops");
    pir::loadlib("io");
    pir::loadlib("trans");
}

use src::Partcl::Grammar;
use src::Partcl::Actions;
use src::Partcl::Compiler;
use src::Partcl::Operators;

use src::init;

sub MAIN(*@ARGS) {
    Partcl::Compiler.new().command_line(@ARGS);
}

