#!perl

use strict;
use warnings;

use Math::Matrix;
use Test::More tests => 20;

note("mul() with two matrices");

{
    my $x = Math::Matrix -> new([[ 1, 2, 3 ],
                                 [ 4, 5, 6 ]]);
    my $y = Math::Matrix -> new([[ 7, 10, 13, 16 ],
                                 [ 8, 11, 14, 17 ],
                                 [ 9, 12, 15, 18 ]]);
    my $z = $x -> mul($y);

    is(ref($z), 'Math::Matrix', '$z is a Math::Matrix');
    is_deeply([ @$z ], [[  50,  68,  86, 104 ],
                        [ 122, 167, 212, 257 ]],
              '$z has the right values');

    # Verify that modifying $z does not modify $x or $y.

    my ($nrowy, $ncoly) = $y -> size();
    for (my $i = 0 ; $i < $nrowy ; ++$i) {
        for (my $j = 0 ; $j < $ncoly ; ++$j) {
            $z -> [$i][$j] += 10;
        }
    }

    is_deeply([ @$x ], [[ 1, 2, 3 ],
                        [ 4, 5, 6 ]], '$x is unmodified');
    is_deeply([ @$y ], [[ 7, 10, 13, 16 ],
                        [ 8, 11, 14, 17 ],
                        [ 9, 12, 15, 18 ]], '$y is unmodified');
}

note("mul() with matrix and scalar");

{
    my $x = Math::Matrix -> new([[ 1, 2, 3 ],
                                 [ 4, 5, 6 ]]);
    my $y = Math::Matrix -> new([[ 7 ]]);
    my $z = $x -> mul($y);

    is(ref($z), 'Math::Matrix', '$z is a Math::Matrix');
    is_deeply([ @$z ], [[  7, 14, 21 ],
                        [ 28, 35, 42 ]],
              '$z has the right values');

    # Verify that modifying $z does not modify $x or $y.

    my ($nrowy, $ncoly) = $y -> size();
    for (my $i = 0 ; $i < $nrowy ; ++$i) {
        for (my $j = 0 ; $j < $ncoly ; ++$j) {
            $z -> [$i][$j] += 10;
        }
    }

    is_deeply([ @$x ], [[ 1, 2, 3 ],
                        [ 4, 5, 6 ]], '$x is unmodified');
    is_deeply([ @$y ], [[ 7 ]], '$y is unmodified');
}

note("mul() with scalar and matrix");

{
    my $x = Math::Matrix -> new([[ 7 ]]);
    my $y = Math::Matrix -> new([[ 1, 2, 3 ],
                                 [ 4, 5, 6 ]]);
    my $z = $x -> mul($y);

    is(ref($z), 'Math::Matrix', '$z is a Math::Matrix');
    is_deeply([ @$z ], [[  7, 14, 21 ],
                        [ 28, 35, 42 ]],
              '$z has the right values');

    # Verify that modifying $z does not modify $x or $y.

    my ($nrowy, $ncoly) = $y -> size();
    for (my $i = 0 ; $i < $nrowy ; ++$i) {
        for (my $j = 0 ; $j < $ncoly ; ++$j) {
            $z -> [$i][$j] += 10;
        }
    }

    is_deeply([ @$x ], [[ 7 ]], '$x is unmodified');
    is_deeply([ @$y ], [[ 1, 2, 3 ],
                        [ 4, 5, 6 ]], '$y is unmodified');
}

note("mul() with empty matrices");

{
    my $x = Math::Matrix -> new([]);
    my $y = Math::Matrix -> new([]);
    my $z = $x -> mul($y);

    is(ref($z), 'Math::Matrix', '$z is a Math::Matrix');
    is_deeply([ @$z ], [],
              '$z has the right values');
}

note("overloading");

{
    my $x = Math::Matrix -> new([[3]]);
    my $y = $x * 4;
    is(ref($y), 'Math::Matrix', '$y is a Math::Matrix');
    is_deeply([ @$y ], [[12]],
              '$y has the right values');
}

{
    my $x = Math::Matrix -> new([[3]]);
    my $y = 4 * $x;
    is(ref($y), 'Math::Matrix', '$y is a Math::Matrix');
    is_deeply([ @$y ], [[12]],
              '$y has the right values');
}

{
    my $x = Math::Matrix -> new([[3]]);
    $x *= 4;
    is(ref($x), 'Math::Matrix', '$x is a Math::Matrix');
    is_deeply([ @$x ], [[12]],
              '$x has the right values');
}
