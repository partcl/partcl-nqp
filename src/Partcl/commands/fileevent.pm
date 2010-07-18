our sub fileevent(*@args) {
    if +@args < 2 || +@args > 3 {
        error('wrong # args: should be "fileevent channelId event ?script?"');
    }
    my $channelId := @args.shift;
    my $event     := @args.shift;
    if $event ne 'readable' || $event ne 'writable' {
        error("bad event name \"$event\": must be readable or writable");
    }
    '';
}
