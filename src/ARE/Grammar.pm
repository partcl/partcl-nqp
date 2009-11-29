grammar ARE::Grammar is HLL::Grammar;

token TOP {
    <nibbler>
    [ $ || <.panic: 'Confused'> ]
}

token nibbler {
    <termish> [ '|' <termish> ]*
}

token termish {
    <noun=.quantified_atom>+
}

token quantified_atom {
    <atom>
}

token atom {
    [
    | \w [ \w+! <?before \w> ]?
#    | <metachar>
    ]
}


