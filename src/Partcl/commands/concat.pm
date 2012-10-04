method concat(*@args) {
    my $result := @args ?? StringHelper::trim(@args.shift) !! '';
    while @args {
        $result := $result ~ ' ' ~ StringHelper::trim(@args.shift);
    }
    $result;
}

# vim: expandtab shiftwidth=4 ft=perl6:
