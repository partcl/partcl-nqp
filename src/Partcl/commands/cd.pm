# TODO: implement ~user syntax
sub cd(*@args) {
    if +@args > 1 {
        error('wrong # args: should be "cd ?dirName?"');
    }
    my $dir;
    if @args == 1 {
        $dir := @args[0];
    } else {
        $dir := pir::new__PS('Env')<HOME>;
    }
    pir::new__PS('OS').chdir($dir);
}

# vim: expandtab shiftwidth=4 ft=perl6:
