class ARE::Actions is HLL::Actions;

method TOP($/) {
    my $past := buildsub( $<nibbler>.ast );
    $past.node($/);
    make $past;
}

method nibbler($/) {
    my $past;
    if +$<termish> > 1 {
        $past := PAST::Regex.new( :pasttype('alt'), :node($/) );
        for $<termish> { $past.push($_.ast); }
    }
    else {
        $past := $<termish>[0].ast;
    }
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

method quantified_atom($/) {
    my $past := $<atom>.ast;
    if $<quantifier> {
        my $qast := $<quantifier>[0].ast;
        $qast.unshift($past);
        $past := $qast;
    }
    make $past;
}

method atom($/) {
    my $past := PAST::Regex.new( ~$/, :pasttype<literal>, :node($/) );
    make $past;
}

method quantifier:sym<*>($/) {
    make PAST::Regex.new( :pasttype<quant>, :node($/) );
}
method quantifier:sym<+>($/) {
    make PAST::Regex.new( :pasttype<quant>, :min(1), :node($/) );
}
method quantifier:sym<?>($/) {
    make PAST::Regex.new( :pasttype<quant>, :min(0), :max(1), :node($/) );
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

