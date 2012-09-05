#sub flush(*@args) {
#    if +@args != 1 {
#        error('wrong # args: should be "flush channelId"');
#    }
#    my $ioObj := _getChannel(@args[0]);
#    if pir::can($ioObj, 'flush') {
#        $ioObj.flush();
#    }
#    '';
#}
#
## vim: expandtab shiftwidth=4 ft=perl6:
