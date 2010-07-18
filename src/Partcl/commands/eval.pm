our sub eval(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "eval arg ?arg ...?"');
    }
    my $code := concat(|@args);
    our %EVALCACHE;
    my &sub := %EVALCACHE{$code};
    unless pir::defined__IP(&sub) {
        &sub := Partcl::Compiler.compile($code);
        %EVALCACHE{$code} := &sub;
    }
    &sub();
}
