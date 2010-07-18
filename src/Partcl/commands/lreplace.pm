our sub lreplace(*@args) {
    if +@args < 3 {
        error('wrong # args: should be "lreplace list first last ?element element ...?"');
    }

    my @list := pir::clone__pp(@args.shift().getList());

    my $first := @list.getIndex(@args.shift());
    my $last  := @list.getIndex(@args.shift());

    if +@list == 0 {
        pir::splice__vppii(@list, @args, 0, 0);
        return @list;
    }

    $last := +@list -1 if $last >= +@list;
    $first := 0 if $first < 0;

    if $first >= +@list {
        error("list doesn't contain element $first");
    }

    my $count := $last - $first + 1;
    if $count >= 0 {
        pir::splice__vppii(@list, @args, $first, $count);
        return @list;
    }

    pir::splice__vppii(@list, @args, $first, 0);
    return @list;
}

# vim: filetype=perl6:
