method time(*@args) {
    if nqp::elems(@args) < 1 || nqp::elems(@args) > 2 {
        self.error('wrong # args: should be "time command ?count?"');
    }

    my $command := @args[0];
    my $count;
    if nqp::elems(@args) == 2 {
        $count := +@args[1];
    } else {
        $count := 1;
    }

    if $count == 0 {
        return '0 microseconds per iteration';
    }

    my $start := nqp::time_n();

    my $loop := +$count;
    while $loop {
        eval($command);
        $loop--;
    }
    my $end := nqp::time_n();

    my $ms_per := ($end-$start)*1000000 / $count;

    ~$ms_per ~ ' microseconds per iteration';
}

# vim: expandtab shiftwidth=4 ft=perl6:
