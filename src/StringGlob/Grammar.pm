grammar StringGlob::Grammar is HLL::Grammar;

token TOP {
    <termish>
    [ $ || <.panic: 'Confused'> ]
}

token termish {
    <noun=.atom>+
}

token atom {
    [
    | <.barechar> [ <.barechar>+! <?before <barechar> > ]?
    | <metachar>
    ]
}

token barechar { <-[\\\[*+?]> }

proto token metachar { <...> }
token metachar:sym<*> { '*' }
token metachar:sym<?> { '?' }
token metachar:sym<back> { \\ $<char>=. }
token metachar:sym<[> {
    '['
    $<charspec>=( [ \\ (.) | (<-[\]\\]>) ] [ '-' (.) ]? )*
    ']'
}

# vim: filetype=perl6:
