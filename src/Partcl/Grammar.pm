grammar Partcl::Grammar is HLL::Grammar;

token TOP { <TOP_eval> }

## TOP_eval evaluates a script in the current lexical context
## TOP_proc evaluates a script in a new lexical context
## TOP_expr evaluates an expression in the current lexical context
## See the corresponding methods in Actions.pm for lexical context handling

token TOP_eval { <body> }
token TOP_proc { <body> }
token TOP_expr { \h* <EXPR> }

token body { <script> [ $ || <.panic: 'Confused' > ] }

token script {
    [ \h* [ <.comment> | <command> | <?> ] \h* ] ** <.command_sep>
    \s*
}

token comment { '#' [ \\ \n \h* | \N ]* }
token command { <word> ** [[\h+ || \\ \x0a]+] }
token command_sep { ';' | \n }

proto token word { <...> }

token word:sym<{*}> { '{*}' <word> }

token word:sym<{ }> { <braced_word> }

token word:sym<" "> { '"' <quoted_atom>* '"' }

token word:sym<bare> { <bare_atom>+ }

token braced_word { '{' <braced_atom>* '}' }
proto token braced_atom { <...> }
token braced_atom:sym<{ }>    { <braced_word> }
token braced_atom:sym<backnl> { \\ \x0a \h* }
token braced_atom:sym<back{>  { \\ \{ }
token braced_atom:sym<back}>  { \\ \} }
token braced_atom:sym<back>   { \\ }
token braced_atom:sym<chr>    { <-[ \\ { } ]>+ }

proto token quoted_atom { <...> }
token quoted_atom:sym<[ ]> { '[' ~ ']' <script> }
token quoted_atom:sym<var> { <variable> }
token quoted_atom:sym<$>   { '$' }
token quoted_atom:sym<\\>  { <backslash> }
token quoted_atom:sym<chr> { <-[ \[ " \\ $]>+ }

proto token bare_atom { <...> }
token bare_atom:sym<[ ]> { '[' ~ ']' <script> }
token bare_atom:sym<var> { <variable> }
token bare_atom:sym<$>   { '$' }
token bare_atom:sym<\\>  { <backslash> }
token bare_atom:sym<chr> { <-[ \[ \\ $ \] ; ]-space>+ }

proto token backslash { <...> }
token backslash:sym<bel>  { '\a' }
token backslash:sym<bs>   { '\b' }
token backslash:sym<ff>   { '\f' }
token backslash:sym<lf>   { '\n' }
token backslash:sym<cr>   { '\r' }
token backslash:sym<ht>   { '\t' }
token backslash:sym<vt>   { '\v' }
token backslash:sym<chr>  { \\ $<chr>=[\N] }
token backslash:sym<backnl> { \\ \x0a \h* }
token backslash:sym<backx> { \\ x $<x>=[<.xdigit>+] }
token backslash:sym<backo> { \\   $<o>=[<[0..7]> ** 1..3] }
token backslash:sym<backu> { \\ u $<u>=[<.xdigit> ** 1..4] }

token list { 
    \s* 
    [
    | <EXPR=.braced_word>
        [ \S+ <.panic: 'list element in braces followed by extra characters'> ]?
    | <EXPR=.list_word>
    ] ** [\s+]
}
token list_word { <list_atom>+ }
proto token list_atom { <...> }
token list_atom:sym<\\>  { <backslash> }
token list_atom:sym<chr> { <-[ \\ ]-space>+ }

token identifier { <ident> ** '::' }
token variable { '$' <identifier> }

# expression parsing

INIT {
    Partcl::Grammar.O(':prec<13>', '%multiplicative');
    Partcl::Grammar.O(':prec<12>', '%additive');
    Partcl::Grammar.O(':prec<10>', '%compare_numeric');
    Partcl::Grammar.O(':prec<09>', '%equality_numeric');
    Partcl::Grammar.O(':prec<08>', '%equality_string');
}

# The <.ws> rule only gets used in expressions.
token ws { \h* }

token term:sym<integer> { <integer> }
token term:sym<variable> { <variable> }
token term:sym<[ ]> { '[' ~ ']' <script> }
token term:sym<" "> { '"' <quoted_atom>* '"' }

token infix:sym<*> { <sym> <O('%multiplicative, :pirop<mul>')> }
token infix:sym</> { <sym> <O('%multiplicative, :pirop<div>')> }

token infix:sym<+> { <sym> <O('%additive, :pirop<add Nnn>')> }
token infix:sym<-> { <sym> <O('%additive, :pirop<sub Nnn>')> }

token infix:sym«<»  { <sym> <O('%compare_numeric, :pirop<islt Inn>')> }
token infix:sym«<=» { <sym> <O('%compare_numeric, :pirop<isle Inn>')> }
token infix:sym«>»  { <sym> <O('%compare_numeric, :pirop<isgt Inn>')> }
token infix:sym«>=» { <sym> <O('%compare_numeric, :pirop<isge Inn>')> }

token infix:sym<==> { <sym> <O('%equality_numeric, :pirop<iseq Inn>')> }
token infix:sym<!=> { <sym> <O('%equality_numeric, :pirop<isne Inn>')> }

token infix:sym<eq> { <sym> <O('%equality_string, :pirop<iseq Iss>')> }
token infix:sym<ne> { <sym> <O('%equality_string, :pirop<isne Iss>')> }

# vim: filetype=perl6:
