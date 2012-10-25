method lreplace(*@args) {
    if +@args < 3 {
        self.error('wrong # args: should be "lreplace list first last ?element element ...?"');
    }

    my @list := nqp::clone(Internals.getList(@args.shift()));

    my $first := @list.getIndex(@args.shift());
    my $last  := @list.getIndex(@args.shift());

    if +@list == 0 {
        nqp::splice(@list, @args, 0, 0);
        return @list;
    }

    $last := +@list -1 if $last >= +@list;
    $first := 0 if $first < 0;

    if $first >= +@list {
        self.error("list doesn't contain element $first");
    }

    my $count := $last - $first + 1;
    if $count >= 0 {
        nqp::splice(@list, @args, $first, $count);
        return @list;
    }

    nqp::splice(@list, @args, $first, 0);
    return @list;
}

# vim: expandtab shiftwidth=4 ft=perl6:
