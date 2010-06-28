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
    | <.barechar> [ <.barechar>+! <?before <barechar> > ]?
    | <metachar>
    ]
}

token barechar { <-[\\\[*+?^$]> }

proto token quantifier { <...> }
token quantifier:sym<*> { <sym> }
token quantifier:sym<+> { <sym> }
token quantifier:sym<?> { <sym> }

proto token metachar { <...> }
token metachar:sym<^> { <sym> }
token metachar:sym<$> { <sym> }
token metachar:sym<.> { <sym> }
token metachar:sym<back> { \\ <backslash> }
token metachar:sym<[> {
    '['
    $<invert>=['^'?]
    $<charspec>=( [ \\ (.) | (<-[\]\\]>) ] [ '-' (.) ]? )*
    ']'
}

proto token backslash { <...> }
token backslash:sym<w> { $<sym>=[<[dswDSW]>] }

# vim: filetype=perl6:
