# nqp

# cat substitute to avoid issues on windows

sub MAIN(*@ARGS) {
    @ARGS.shift; # ignore our filename
    say(nqp::join(" ", @ARGS));
}
