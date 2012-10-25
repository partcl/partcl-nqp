method lassign(*@args) {
    if +@args < 2 {
        self.error('wrong # args: should be "lassign list varName ?varName ...?"');
    }
    my @list := Internals.getList(@args.shift());
    my $listLen := +@list;
    my $pos := 0;
    for @args -> $var {
        if $pos < $listLen {
            set($var, @list.shift());
        } else {
            set($var,'');
        }
        $pos++;
    }
    return @list;
}

# vim: expandtab shiftwidth=4 ft=perl6:
