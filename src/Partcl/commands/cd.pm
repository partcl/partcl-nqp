# TODO: implement ~user syntax
our sub cd(*@args) {
    if +@args > 1 {
        error('wrong # args: should be "cd ?dirName?"');
    }
    my $dir;
    if @args == 1 {
        $dir := @args[0];
    } else {
        $dir := pir::new__ps('Env')<HOME>;
    }
    my $OS := pir::new__ps('OS');
    $OS.chdir($dir);
}
