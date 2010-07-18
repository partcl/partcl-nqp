##  use bare block to avoid catching control exceptions

INIT {
    GLOBAL::return := -> $result = '' { return $result; }
}

# vim: filetype=perl6:
