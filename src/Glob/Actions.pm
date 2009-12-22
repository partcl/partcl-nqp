class Glob::Actions is HLL::Actions;

method TOP($/) {
    my $ast := $<termish>.ast;
    
    # globs are anchored on both ends.
    $ast.unshift(PAST::Regex.new( :pasttype('anchor'), :subtype('bos'), :node($/) ));
    $ast.push(PAST::Regex.new( :pasttype('anchor'), :subtype('eos'), :node($/) ));

    my $past := buildsub( $ast );
    $past.node($/);
    make $past;
}

method termish($/) {
    my $past := PAST::Regex.new( :pasttype('concat'), :node($/) );
    my $lastlit := 0;
    for $<noun> {
        my $ast := $_.ast;
        if $ast {
            if $lastlit && $ast.pasttype eq 'literal'
                    && !PAST::Node.ACCEPTS($ast[0]) {
                $lastlit[0] := $lastlit[0] ~ $ast[0];
            }
            else {
                $past.push($ast);
                $lastlit := $ast.pasttype eq 'literal'
                            && !PAST::Node.ACCEPTS($ast[0])
                            ?? $ast !! 0;
            }
        }
    }
    make $past;
}

method atom($/) {
    my $past := $<metachar>
                ?? $<metachar>.ast
                !! PAST::Regex.new( ~$/, :pasttype<literal>, :node($/) );
    make $past;
}

method metachar:sym<*>($/) {
    my $ast := PAST::Regex.new( :pasttype<quant>, :node($/) ); 
    $ast.unshift(PAST::Regex.new( :pasttype<charclass>, :subtype<.>, :node($/)));
    make $ast;
}

method metachar:sym<?>($/) {
    make PAST::Regex.new( :pasttype<charclass>, :subtype<.>, :node($/) );
}

method metachar:sym<back>($/) {
    make PAST::Regex.new( ~$<char>, :pasttype<literal>, :node($/) );
}

method metachar:sym<[>($/) {
    my $str := '';
    for $<charspec> {
        if $_[1] {
            my $a := pir::ord($_[0]);
            my $b := pir::ord(~$_[1][0]);
            while $a <= $b { $str := $str ~ pir::chr($a); $a++; }
        }
        else { $str := $str ~ $_[0]; }
    }
    my $past := PAST::Regex.new( $str, :pasttype<enumcharlist>, :node($/) );
    make $past;
}

method backslash:sym<w>($/) {
}

sub buildsub($rpast, $block = PAST::Block.new() ) {
    $rpast := PAST::Regex.new(
        PAST::Regex.new( :pasttype('scan') ),
        $rpast,
        PAST::Regex.new( :pasttype('pass') ),
        :pasttype('concat'),
    );
    unless $block.symbol('$¢') { $block.symbol('$¢', :scope<lexical>); }
    unless $block.symbol('$/') { $block.symbol('$/', :scope<lexical>); }
    $block.push($rpast);
    $block.blocktype('method');
    $block;
}

# vim: filetype=perl6:
