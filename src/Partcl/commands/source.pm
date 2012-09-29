sub source($filename) is export {
    Partcl::Compiler.evalfiles($filename);
}

# vim: expandtab shiftwidth=4 ft=perl6:
