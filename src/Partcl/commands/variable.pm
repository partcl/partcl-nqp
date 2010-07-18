our sub variable(*@args) {
    error('wrong # args: should be "variable ?name value...? name ?value?"')
        unless +@args;
    '';
}
