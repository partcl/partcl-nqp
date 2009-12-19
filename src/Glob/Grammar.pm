grammar Glob::Grammar is HLL::Grammar;

token TOP {
    <nibbler>
    [ $ || <.panic: 'Confused'> ]
}

token nibbler {
    <termish> [ '|' <termish> ]*
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
