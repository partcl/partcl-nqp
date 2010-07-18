our sub glob(*@args) {
    my $dir := ".";
    while @args[0] ne '--' && pir::substr(@args[0],0,1) eq '-' {
        my $opt := @args.shift;
        $dir := @args.shift if $opt eq '-directory';
    }
    my @files := pir::new__ps('OS').readdir($dir);
    my @globs;
    for @args -> $pat {
        @globs.push( FileGlob::Compiler.compile($pat) );
    }

    my @retval := pir::new__ps('TclList');
    for @files -> $f {
        my $matched := 0;
        for @globs -> $g {
            $matched := 1 if ?Regex::Cursor.parse($f, :rule($g), :c(0));
            }
        @retval.push($f) if $matched;
    }
    @retval;
}
