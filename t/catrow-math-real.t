#!perl

use strict;
use warnings;

use Test::More;

use lib 't/lib';
use Math::Matrix::Real;

plan tests => 26;

{
    my $x = Math::Matrix::Real -> new([1, 2],
                                      [3, 4]);
    my $y = Math::Matrix::Real -> new([5, 6]);
    my $z = $x -> catrow($y);

    is(ref($z), 'Math::Matrix::Real', '$z is a Math::Matrix::Real');
    is_deeply([ @$z ], [[ 1, 2 ],
                        [ 3, 4 ],
                        [ 5, 6 ]], '$z has the right values');

    # Verify that modifying $z does not modify $x or $y.

    my ($nrowz, $ncolz) = $z -> size();
    for (my $i = 0 ; $i < $nrowz ; ++$i) {
        for (my $j = 0 ; $j < $ncolz ; ++$j) {
            $z -> [$i][$j] += 10;
        }
    }

    is_deeply([ @$x ], [[1, 2],
                        [3, 4]], '$x is unmodified');
    is_deeply([ @$y ], [[5, 6]], '$y is unmodified');
}

{
    my $x = Math::Matrix::Real -> new([0, 1],
                                      [2, 3],
                                      [4, 5]);
    my $y = Math::Matrix::Real -> new([6, 7],
                                      [8, 9]);
    my $z = $x -> catrow($y);
    is(ref($z), 'Math::Matrix::Real', '$z is a Math::Matrix::Real');
    is_deeply([ @$z ], [[ 0, 1 ],
                        [ 2, 3 ],
                        [ 4, 5 ],
                        [ 6, 7 ],
                        [ 8, 9 ]], '$z has the right values');

    # Verify that modifying $z does not modify $x or $y.

    my ($nrowz, $ncolz) = $z -> size();
    for (my $i = 0 ; $i < $nrowz ; ++$i) {
        for (my $j = 0 ; $j < $ncolz ; ++$j) {
            $z -> [$i][$j] += 10;
        }
    }

    is_deeply([ @$x ], [[0, 1],
                        [2, 3],
                        [4, 5]], '$x is unmodified');
    is_deeply([ @$y ], [[6, 7],
                        [8, 9]], '$y is unmodified');
}

{
    my $x = Math::Matrix::Real -> new([0, 1],
                                      [2, 3],
                                      [4, 5]);
    my $y = Math::Matrix::Real -> new([]);
    my $z = $x -> catrow($y);
    is(ref($z), 'Math::Matrix::Real', '$z is a Math::Matrix::Real');
    is_deeply([ @$z ], [[ 0, 1 ],
                        [ 2, 3 ],
                        [ 4, 5 ]], '$z has the right values');

    # Verify that modifying $z does not modify $x or $y.

    my ($nrowz, $ncolz) = $z -> size();
    for (my $i = 0 ; $i < $nrowz ; ++$i) {
        for (my $j = 0 ; $j < $ncolz ; ++$j) {
            $z -> [$i][$j] += 10;
        }
    }

    is_deeply([ @$x ], [[0, 1],
                        [2, 3],
                        [4, 5]], '$x is unmodified');
    is_deeply([ @$y ], [], '$y is unmodified');
}

{
    my $x = Math::Matrix::Real -> new([]);
    my $y = Math::Matrix::Real -> new([6, 7],
                                      [8, 9]);
    my $z = $x -> catrow($y);
    is(ref($z), 'Math::Matrix::Real', '$z is a Math::Matrix::Real');
    is_deeply([ @$z ], [[ 6, 7 ],
                        [ 8, 9 ]], '$z has the right values');

    # Verify that modifying $z does not modify $x or $y.

    my ($nrowz, $ncolz) = $z -> size();
    for (my $i = 0 ; $i < $nrowz ; ++$i) {
        for (my $j = 0 ; $j < $ncolz ; ++$j) {
            $z -> [$i][$j] += 10;
        }
    }

    is_deeply([ @$x ], [], '$x is unmodified');
    is_deeply([ @$y ], [[6, 7],
                        [8, 9]], '$y is unmodified');
}

{
    my $x = Math::Matrix::Real -> new([]);
    my $y = Math::Matrix::Real -> new([]);
    my $z = $x -> catrow($y);
    is(ref($z), 'Math::Matrix::Real', '$z is a Math::Matrix::Real');
    is_deeply([ @$z ], [], '$z has the right values');

    is_deeply([ @$x ], [], '$x is unmodified');
    is_deeply([ @$y ], [], '$y is unmodified');
}

{
    my $x = Math::Matrix::Real -> new([3]);
    my $z = $x -> catrow($x, $x, $x);
    is(ref($z), 'Math::Matrix::Real', '$z is a Math::Matrix::Real');
    is_deeply([ @$z ], [[3], [3], [3], [3]], '$z has the right values');
    is_deeply([ @$x ], [[3]], '$x is unmodified');
}

{
    my $x = Math::Matrix::Real -> new([3]);
    my $z = $x -> catrow();
    is(ref($z), 'Math::Matrix::Real', '$z is a Math::Matrix::Real');
    is_deeply([ @$z ], [[3]], '$z has the right values');
    is_deeply([ @$x ], [[3]], '$x is unmodified');
}
