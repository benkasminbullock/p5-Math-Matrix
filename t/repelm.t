#!perl

use strict;
use warnings;

use Math::Matrix;
use Test::More tests => 20;

note('2-by-3 x 3-by-2 -> 6-by-6');

{
    my $x = Math::Matrix -> new([[4, 5, 6],
                                 [7, 8, 9]]);
    my $y = Math::Matrix -> new([[3, 2]]);
    my $z = $x -> repelm($y);

    is(ref($z), 'Math::Matrix', '$z is a Math::Matrix');
    is_deeply([ @$z ], [[4, 4, 5, 5, 6, 6],
                        [4, 4, 5, 5, 6, 6],
                        [4, 4, 5, 5, 6, 6],
                        [7, 7, 8, 8, 9, 9],
                        [7, 7, 8, 8, 9, 9],
                        [7, 7, 8, 8, 9, 9]],
              '$z has the right values');

    # Verify that modifying $z does not modify $x or $y.

    my ($nrowy, $ncoly) = $z -> size();
    for (my $i = 0 ; $i < $nrowy ; ++$i) {
        for (my $j = 0 ; $j < $ncoly ; ++$j) {
            $z -> [$i][$j] += 100;
        }
    }

    is_deeply([ @$x ], [[4, 5, 6],
                        [7, 8, 9]], '$x is unmodified');
    is_deeply([ @$y ], [[3, 2]], '$y is unmodified');
}

note('empty x 3-by-2 -> empty');

{
    my $x = Math::Matrix -> new([]);
    my $y = Math::Matrix -> new([[3, 2]]);
    my $z = $x -> repelm($y);

    is(ref($z), 'Math::Matrix', '$z is a Math::Matrix');
    is_deeply([ @$z ], [], '$z has the right values');

    is_deeply([ @$x ], [], '$x is unmodified');
    is_deeply([ @$y ], [[3, 2]], '$y is unmodified');
}

note('2-by-3 x 0-by-2 -> empty');

{
    my $x = Math::Matrix -> new([[4, 5, 6],
                                 [7, 8, 9]]);
    my $y = Math::Matrix -> new([[0, 2]]);
    my $z = $x -> repelm($y);

    is(ref($z), 'Math::Matrix', '$z is a Math::Matrix');
    is_deeply([ @$z ], [], '$z has the right values');

    is_deeply([ @$x ], [[4, 5, 6],
                        [7, 8, 9]], '$x is unmodified');
    is_deeply([ @$y ], [[0, 2]], '$y is unmodified');
}

note('2-by-3 x 2-by-0 -> empty');

{
    my $x = Math::Matrix -> new([[4, 5, 6],
                                 [7, 8, 9]]);
    my $y = Math::Matrix -> new([[2, 0]]);
    my $z = $x -> repelm($y);

    is(ref($z), 'Math::Matrix', '$z is a Math::Matrix');
    is_deeply([ @$z ], [], '$z has the right values');

    is_deeply([ @$x ], [[4, 5, 6],
                        [7, 8, 9]], '$x is unmodified');
    is_deeply([ @$y ], [[2, 0]], '$y is unmodified');
}

note('2-by-3 x 0-by-0 -> empty');

{
    my $x = Math::Matrix -> new([[4, 5, 6],
                                 [7, 8, 9]]);
    my $y = Math::Matrix -> new([[0, 0]]);
    my $z = $x -> repelm($y);

    is(ref($z), 'Math::Matrix', '$z is a Math::Matrix');
    is_deeply([ @$z ], [], '$z has the right values');

    is_deeply([ @$x ], [[4, 5, 6],
                        [7, 8, 9]], '$x is unmodified');
    is_deeply([ @$y ], [[0, 0]], '$y is unmodified');
}
