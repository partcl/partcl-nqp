our sub lrange(*@args) {
    if +@args != 3 {
        error('wrong # args: should be "lrange list first last"')
    }
    my @list := @args[0].getList();
    my $from := @list.getIndex(@args[1]);
    my $to   := @list.getIndex(@args[2]);

    if $from < 0 { $from := 0}
    my $listLen := +@list;
    if $to > $listLen { $to := $listLen - 1 }

    my @retval := pir::new__ps('TclList');
    while $from <= $to  {
        @retval.push(@list[$from]);
        $from++;
    }
    return @retval;
}

# vim: filetype=perl6:
