use NQPHLL;

class Partcl::Actions is HLL::Actions {

    method TOP($/) { make $<TOP_eval>.ast; }
    
    ## TOP_eval and TOP_expr create a PAST::Block that uses the
    
    method TOP_eval($/) { make eval_block($<body>.ast); }
    method TOP_expr($/) { make eval_block($<EXPR>.ast); }
    
    sub eval_block($past) {
        ## This is the runtime equivalent of
        ## The body of the code to be evaluated
    }
    
    ## TOP_proc creates a PAST::Block that initializes a
    
    method TOP_proc($/) { make lex_block($<body>.ast); }
    
    sub lex_block($past) {
        ## This is the runtime equivalent of
    }
    
    method body($/) { make $<script>.ast; }
    
    method script($/) {
        my $past := PAST::Stmts.new( :node($/) );
        if $<command> {
            for $<command> { $past.push($_.ast); }
        }
        else { $past.push(''); }
        make $past;
    }
    
    method command($/) {
        my $past := PAST::Op.new( :name('invoke'), :node($/) );
        my $i := 0;
        my $n := +$<word>;
        while $i < $n {
            $past.push($<word>[$i].ast);
            $i++;
        }
        make $past;
    }
    
    method word:sym<{*}>($/)  {
        make PAST::Op.new( :name<EXPAND>, $<word>.ast, :flat);
    }
    method word:sym<{ }>($/)  { make $<braced_word>.ast; }
    method word:sym<" ">($/)  { make $<quoted_word>.ast; }
    method word:sym<bare>($/) { make concat_atoms($<bare_atom>); }
    
    method braced_word($/) { make concat_atoms($<braced_atom>); }
    method braced_atom:sym<{ }>($/)    { make '{' ~ $<braced_word>.ast ~ '}'; }
    method braced_atom:sym<backnl>($/) { make ' '; }
    method braced_atom:sym<back{>($/)  { make "\\" ~ '{'; }
    method braced_atom:sym<back}>($/)  { make "\\" ~ '}'; }
    method braced_atom:sym<backd>($/)  { make "\\" ~ "\\"; }
    method braced_atom:sym<back>($/)   { make "\\"; }
    method braced_atom:sym<chr>($/)    { make ~$/; }
    
    method quoted_word($/) { make concat_atoms($<quoted_atom>); }
    
    method quoted_atom:sym<[ ]>($/) { make $<script>.ast; }
    method quoted_atom:sym<var>($/) { make $<variable>.ast; }
    method quoted_atom:sym<$>($/)   { make '$'; }
    method quoted_atom:sym<\\>($/)  { make $<backslash>.ast; }
    method quoted_atom:sym<chr>($/) { make ~$/; }
    
    method bare_atom:sym<[ ]>($/) { make $<script>.ast; }
    method bare_atom:sym<var>($/) { make $<variable>.ast; }
    method bare_atom:sym<$>($/)   { make '$'; }
    method bare_atom:sym<\\>($/)  { make $<backslash>.ast; }
    method bare_atom:sym<chr>($/) { make ~$/; }
    
    method backslash:sym<bel>($/)   { make "\x07"; }
    method backslash:sym<bs>($/)    { make "\x08"; }
    method backslash:sym<ff>($/)    { make "\x0c"; }
    method backslash:sym<lf>($/)    { make "\x0a"; }
    method backslash:sym<cr>($/)    { make "\x0d"; }
    method backslash:sym<ht>($/)    { make "\x09"; }
    method backslash:sym<vt>($/)    { make "\x0b"; }
    method backslash:sym<chr>($/)   { make ~$<chr>; }
    method backslash:sym<backnl>($/) { make ' '; }
    method backslash:sym<backx>($/) {
        my $len := pir::length(~$<x>);
        my $substr_len := ($len >= 2) ?? -2 !! -$len;
        make pir::chr(HLL::Actions::string_to_int(pir::substr(~$<x>, $substr_len), 16));
    }
    method backslash:sym<backo>($/) {
        make pir::chr(HLL::Actions::string_to_int(~$<o>, 8));
    }
    method backslash:sym<backu>($/) {
        make pir::chr(HLL::Actions::string_to_int(~$<u>, 16));
    }
    
    method list_word($/) { make concat_atoms($<list_atom>); }
    method list_atom:sym<\\>($/)  { make $<backslash>.ast; }
    method list_atom:sym<chr>($/) { make ~$/; }
    
    sub concat_atoms(@atoms) {
        my @parts;
        my $lastlit := '';
        for @atoms {
            my $ast := $_.ast;
            if !PAST::Node.ACCEPTS($ast) {
                $lastlit := $lastlit ~ $ast;
            }
            else {
                if $lastlit gt '' { @parts.push($lastlit); }
                @parts.push($ast);
                $lastlit := '';
            }
        }
        if $lastlit gt '' { @parts.push($lastlit); }
        my $past := @parts ?? @parts.shift !! '';
        while @parts {
            $past := PAST::Op.new( $past, @parts.shift, :pirop<concat>);
        }
        $past;
    }
    
    
    ##  to point to the current lexical scope -- this simply
    ##  the corresponding value.
    
    method variable:sym<normal>($/) {
        my $variable;
    }
    
    method variable:sym<escaped>($/) {
    }
    
    method integer($/) {
        if $<sign> eq '-' {
            make -1 * $<int>.ast;
        } else {
            make $<int>.ast;
        }
    }
    
    method int:sym<oct>($/) { make HLL::Actions::string_to_int(~$<digits>, 8) }
    method int:sym<dec>($/) { make HLL::Actions::string_to_int(~$<digits>, 10) }
    method int:sym<hex>($/) { make HLL::Actions::string_to_int(~$<digits>, 16) }
    
    method term:sym<true>($/)  { make $/.Str }
    method term:sym<false>($/) { make $/.Str }
    
    method term:sym<variable>($/) { make $<variable>.ast; }
    method term:sym<integer>($/) { make $<integer>.ast; }
    
    method term:sym<( )>($/) { make $<EXPR>.ast; }
    
    method term:sym<[ ]>($/) { make $<script>.ast; }
    method term:sym<" ">($/)  { make concat_atoms($<quoted_atom>); }
    
    =begin head1 index
    
    Return a two element list; the first element is either 1 (from 0) or
    2 (from end), the second is the relative position.
    
    =end head1 index
    
    method index:sym<int>($/) {
        my $val := $<a>.ast;
        if $<op> {
           if ~$<op>[0] eq '+' {
               $val := $val + $<b>[0].ast;
           } else {
               $val := $val - $<b>[0].ast;
           }
        }
        make (1, $val);
    }
    
    method index:sym<end>($/) {
        make (2, 0);
    }
    
    method index:sym<end+>($/) {
        make (2, $<a>.ast);
    }
    
    method index:sym<end->($/) {
        make (2, -$<a>.ast);
    }
}
# vim: expandtab shiftwidth=4 ft=perl6:
