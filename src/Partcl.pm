use NQPHLL;

INIT {
    pir::loadlib__Ps("os");
    pir::loadlib__Ps("bit_ops");
    pir::loadlib__Ps("io");
    pir::loadlib__Ps("trans");
}

use src::Partcl::Grammar;
use src::Partcl::Actions;
use src::Partcl::Compiler;
use src::Partcl::Operators;
use src::Partcl::commands::after;
use src::Partcl::commands::append;
use src::Partcl::commands::apply;
use src::Partcl::commands::array;
use src::Partcl::commands::binary;
use src::Partcl::commands::break;
use src::Partcl::commands::catch;
use src::Partcl::commands::cd;
use src::Partcl::commands::concat;
use src::Partcl::commands::continue;
use src::Partcl::commands::dict;
use src::Partcl::commands::eof;
use src::Partcl::commands::encoding;
use src::Partcl::commands::error;
use src::Partcl::commands::eval;
use src::Partcl::commands::exit;
use src::Partcl::commands::expr;
use src::Partcl::commands::fileevent;
use src::Partcl::commands::file;
use src::Partcl::commands::flush;
use src::Partcl::commands::foreach;
use src::Partcl::commands::format;
use src::Partcl::commands::for;
use src::Partcl::commands::gets;
use src::Partcl::commands::global;
use src::Partcl::commands::glob;
use src::Partcl::commands::if;
use src::Partcl::commands::incr;
use src::Partcl::commands::info;
use src::Partcl::commands::interp;
use src::Partcl::commands::join;
use src::Partcl::commands::lappend;
use src::Partcl::commands::lassign;
use src::Partcl::commands::lindex;
use src::Partcl::commands::linsert;
use src::Partcl::commands::list;
use src::Partcl::commands::llength;
use src::Partcl::commands::lrange;
use src::Partcl::commands::lrepeat;
use src::Partcl::commands::lreplace;
use src::Partcl::commands::lreverse;
use src::Partcl::commands::lset;
use src::Partcl::commands::lsort;
use src::Partcl::commands::namespace;
use src::Partcl::commands::package;
use src::Partcl::commands::proc;
use src::Partcl::commands::puts;
use src::Partcl::commands::pwd;
use src::Partcl::commands::regexp;
use src::Partcl::commands::rename;
use src::Partcl::commands::return;
use src::Partcl::commands::set;
use src::Partcl::commands::socket;
use src::Partcl::commands::source;
use src::Partcl::commands::split;
use src::Partcl::commands::string;
use src::Partcl::commands::subst;
use src::Partcl::commands::switch;
use src::Partcl::commands::time;
use src::Partcl::commands::trace;
use src::Partcl::commands::unset;
use src::Partcl::commands::uplevel;
use src::Partcl::commands::upvar;
use src::Partcl::commands::variable;
use src::Partcl::commands::vwait;
use src::Partcl::commands::while;
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

use src::init;
use src::options;

sub MAIN(*@ARGS) {
    # XXX setup %LEXPAD?
    my $compiler := Partcl::Compiler.new();
    $compiler.language('Partcl');
    $compiler.parsegrammar(Partcl::Grammar);
    $compiler.parseactions(Partcl::Actions);
    $compiler.command_line(@ARGS);
}

