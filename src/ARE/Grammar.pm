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
    <atom> <quantifier>?
}

token atom {
    [
    | \w [ \w+! <?before \w> ]?
    | <metachar>
    ]
}

proto token quantifier { <...> }
token quantifier:sym<*> { <sym> }
token quantifier:sym<+> { <sym> }
token quantifier:sym<?> { <sym> }

proto token metachar { <...> }
token metachar:sym<.> { <sym> }
token metachar:sym<back> { \\ <backslash> }

proto token backslash { <...> }
token backslash:sym<w> { $<sym>=[<[dswnDSWN]>] }

