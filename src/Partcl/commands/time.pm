sub time(*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "time command ?count?"');
    }

    my $command := @args[0];
    my $count;
    if +@args == 2 {
        $count := pir::set__IP(@args[1]);
    } else {
        $count := 1;
    }

    if $count == 0 {
        return '0 microseconds per iteration';
    }

    my $start := pir::time__N();

    my $loop := pir::set__IP($count);
    while $loop {
        eval($command);
        $loop--;
    }
    my $end := pir::time__N();

    my $ms_per := pir::set__IP(($end-$start)*1000000 / $count);

    ~$ms_per ~ ' microseconds per iteration';
}

# vim: expandtab shiftwidth=4 ft=perl6:
