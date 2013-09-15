# nqp

# cat substitute to avoid issues on windows

sub MAIN(*@ARGS) {
    @ARGS.shift; # ignore our filename
    for @ARGS -> $file {
        say(slurp($file));
    }
}
