# TODO: implement ~user syntax
method cd(*@args) {
    if +@args > 1 {
        self.error('wrong # args: should be "cd ?dirName?"');
    }
    my $dir;
    if @args == 1 {
        $dir := @args[0];
    } else {
        $dir := Env.new()<HOME>;
    }
    nqp::chdir($dir); 
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
