method gets(*@args) {
    our %CHANNELS;

    if +@args < 1 || +@args > 2 {
        self.error('wrong # args: should be "gets channelId ?varName?"');
    }

    my $channelId := @args[0];
    my $chanObj := _getChannel($channelId);

    my $result := $chanObj.readline();

    if nqp::chars($result) >0 && nqp::substr($result, -1) eq "\n" {
        $result := nqp::substr($result, 0, nqp::chars($result) - 1);
    }
    if +@args == 2 {
        set(@args[1], $result);
        return nqp::chars($result);
    } else {
        return $result;
    }

}

# vim: expandtab shiftwidth=4 ft=perl6:
