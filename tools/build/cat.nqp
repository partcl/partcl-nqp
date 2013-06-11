# nqp

# cat substitute to avoid issues on windows

sub MAIN(*@ARGS) {
    @ARGS.shift; # ignore our filename
    for @ARGS -> $file {
        my $a := open($file);
        say($a.readall());
    }
}
