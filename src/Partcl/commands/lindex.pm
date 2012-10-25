method lindex(*@args) {
    if +@args < 1 {
        self.error('wrong # args: should be "lindex list ?index...?"');
    }
    my $list := @args.shift();

    my @indices;
    if +@args == 0 {
        return $list;
    } elsif +@args == 1 {
        @indices := Internals.getList(@args[0]);
    } else {
        @indices := @args;
    }

    my $result := $list;
    while (@indices) {
        $result := Internals.getList($result);
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

# vim: expandtab shiftwidth=4 ft=perl6:
