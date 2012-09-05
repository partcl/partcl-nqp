##  use bare block to avoid catching control exceptions
#
#INIT {
    #GLOBAL::return := -> $result = '' { return $result; }
#}
#
# vim: expandtab shiftwidth=4 ft=perl6:
