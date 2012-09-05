#sub split(*@args) {
#    if +@args < 1 || +@args > 2 {
#        error('wrong # args: should be "split string ?splitChars?"')
#    }
#
#    my $string     := ~@args[0];
#    my $splitChars := @args[1] // " \r\n\t";
#
#    if $string eq '' {
#        return list();
#    }
#
#    if $splitChars eq '' {
#        return pir::split('',$string);
#    }
#
#    my @result;
#    my $element := '';
#    for $string -> $char {
#        my $active := 1;
#        for $splitChars -> $sc {
#            if $active {
#                if $char eq $sc {
#                    @result.push($element);
#                    $element := '';
#                    $active := 0;
#                }
#            }
#        }
#        if $active {
#            $element := $element ~ $char;
#        }
#    };
#    @result.push($element);
#
#    @result := list(|@result); # convert to a TclList
#    @result;
#}
#
## vim: expandtab shiftwidth=4 ft=perl6:
