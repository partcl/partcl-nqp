sub for(*@args) {
    if +@args != 4 {
        error('wrong # args: should be "for start test next command"');
    }
    my $init := @args[0];
    my $cond := @args[1];
    my $incr := @args[2];
    my $body := @args[3];

    eval($init);
    my $loop := 1;
    while $loop && expr($cond) {
        eval($body);
        eval($incr);
        CONTROL {
            if $!<type> == 64 { # CONTROL_LOOP_NEXT
                eval($incr);
            } elsif $!<type> == 65 { # CONTROL_LOOP_LAST
                $loop := 0;
            }
        }
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
