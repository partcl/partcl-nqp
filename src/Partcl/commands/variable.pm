sub variable(*@args) is export {
    error('wrong # args: should be "variable ?name value...? name ?value?"')
        unless +@args;
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
