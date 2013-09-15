method lrange(*@args) {
    if +@args != 3 {
        self.error('wrong # args: should be "lrange list first last"')
    }
    my @list := Internals.getLits(@args[0]);
    my $from := @list.getIndex(@args[1]);
    my $to   := @list.getIndex(@args[2]);

    if $from < 0 { $from := 0}
    my $listLen := +@list;
    if $to > $listLen { $to := $listLen - 1 }

    my @retval := TclList.new();
    while $from <= $to  {
        @retval.push(@list[$from]);
        $from++;
    }
    return @retval;
}

# vim: expandtab shiftwidth=4 ft=perl6:
