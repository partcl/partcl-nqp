class TclLexPad is Hash {
    has $!outer;
    has $!depth;

    method newpad($outer?) {
        self := self.new;
        $!outer := $outer // self;
        $!depth := $outer ?? $outer.depth + 1 !! 0;
        self;
    }

    method depth() { $!depth }
    method outer() { $!outer }
}
