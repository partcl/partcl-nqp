# TODO: implement ~user syntax
sub cd(*@args) {
    if +@args > 1 {
        error('wrong # args: should be "cd ?dirName?"');
    }
    my $dir;
    if @args == 1 {
        $dir := @args[0];
    } else {
        $dir := pir::new('Env')<HOME>;
    }
    pir::new('OS').chdir($dir);
}

# vim: expandtab shiftwidth=4 ft=perl6:
