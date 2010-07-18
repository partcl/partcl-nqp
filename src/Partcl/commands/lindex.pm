our sub lindex(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "lindex list ?index...?"');
    }
    my $list := @args.shift();

    my @indices;
    if +@args == 0 {
        return $list;
    } elsif +@args == 1 {
        @indices := @args[0].getList();
    } else {
        @indices := @args;
    }

    my $result := $list;
    while (@indices) {
        $result := $result.getList();
        my $index := $result.getIndex(@indices.shift()); # not a TclList?
        my $size := +$result;
        if $index < 0 || $index >= $size {
            $result := '';
        } else {
            $result := $result[$index];
        }
    }
    return $result;
}

# vim: filetype=perl6:
