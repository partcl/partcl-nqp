our sub concat(*@args) {
    my $result := @args ?? String::trim(@args.shift) !! '';
    while @args {
        $result := $result ~ ' ' ~ String::trim(@args.shift);
    }
    $result;
}
