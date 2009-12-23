grammar FileGlob::Grammar is StringGlob::Grammar;

# This is how globs do alternation
token metachar:sym<{> {
    '{' ~ '}' [ <word> ** ',' ]
}

token word { <-[,}]>+ }

token barechar { <-[\\\[*+?{]> }

# vim: filetype=perl6:
