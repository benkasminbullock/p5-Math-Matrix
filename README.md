# NAME

Math::Matrix - multiply and invert matrices

# SYNOPSIS

    use Math::Matrix;

    # Generate a random 3-by-3 matrix.
    srand(time);
    my $A = Math::Matrix -> new([rand, rand, rand],
                                [rand, rand, rand],
                                [rand, rand, rand]);
    $A -> print("A\n");

    # Append a fourth column to $A.
    my $x = Math::Matrix -> new([rand, rand, rand]);
    my $E = $A -> concat($x -> transpose);
    $E -> print("Equation system\n");

    # Compute the solution.
    my $s = $E -> solve;
    $s -> print("Solutions s\n");

    # Verify that the solution equals $x.
    $A -> multiply($s) -> print("A*s\n");

# DESCRIPTION

This module implements various constructors and methods for creating and
manipulating matrices.

All methods return new objects, so, for example, `$X->add($Y)` does not
modify `$X`.

    $X -> add($Y);         # $X not modified; output is lost
    $X = $X -> add($Y);    # this works

Some operators are overloaded (see ["OVERLOADING"](#overloading)) and allow the operand to be
modified directly.

    $X = $X + $Y;          # this works
    $X += $Y;              # so does this

# METHODS

## Constructors

- new()

    Creates a new object from the input arguments and returns it.

    If a single input argument is given, and that argument is a reference to array
    whose first element is itself a reference to an array, it is assumed that the
    argument contains the whole matrix, like this:

        $x = Math::Matrix->new([[1, 2, 3], [4, 5, 6]]); # 2-by-3 matrix
        $x = Math::Matrix->new([[1, 2, 3]]);            # 1-by-3 matrix
        $x = Math::Matrix->new([[1], [2], [3]]);        # 3-by-1 matrix

    If a single input argument is given, and that argument is not a reference to an
    array, a 1-by-1 matrix is returned.

        $x = Math::Matrix->new(1);                      # 1-by-1 matrix

    Note that all the folling cases result in an empty matrix:

        $x = Math::Matrix->new([[], [], []]);
        $x = Math::Matrix->new([[]]);
        $x = Math::Matrix->new([]);

    If `["new()"](#new)` is called as an instance method with no input arguments, a zero
    filled matrix with identical dimensions is returned:

        $b = $a->new();     # $b is a zero matrix with the size of $a

    Each row must contain the same number of elements.

- new\_from\_sub()

    Creates a new matrix object by doing a subroutine call to create each element.

        $sub = sub { ... };
        $x = Math::Matrix -> new_from_sub($sub);          # 1-by-1
        $x = Math::Matrix -> new_from_sub($sub, $m);      # $m-by-$m
        $x = Math::Matrix -> new_from_sub($sub, $m, $n);  # $m-by-$n

    The subroutine is called in scalar context with two input arguments, the row and
    column indices of the element to be created. Note that no checks are performed
    on the output of the subroutine.

    Example 1, a 4-by-4 identity matrix can be created with

        $sub = sub { $_[0] == $_[1] ? 1 : 0 };
        $x = Math::Matrix -> new_from_sub($sub, 4);

    Example 2, the code

        $x = Math::Matrix -> new_from_sub(sub { 2**$_[1] }, 1, 11);

    creates the following 1-by-11 vector with powers of two

        [ 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024 ]

    Example 3, the code, using `$i` and `$j` for increased readability

        $sub = sub {
            ($i, $j) = @_;
            $d = $j - $i;
            return $d == -1 ? 5
                 : $d ==  0 ? 6
                 : $d ==  1 ? 7
                 : 0;
        };
        $x = Math::Matrix -> new_from_sub($sub, 5);

    creates the tridiagonal matrix

        [ 6 7 0 0 0 ]
        [ 5 6 7 0 0 ]
        [ 0 5 6 7 0 ]
        [ 0 0 5 6 7 ]
        [ 0 0 0 5 6 ]

- new\_from\_rows()

    Creates a new matrix by assuming each argument is a row vector.

        $x = Math::Matrix -> new_from_rows($y, $z, ...);

    For example

        $x = Math::Matrix -> new_from_rows([1, 2, 3],[4, 5, 6]);

    returns the matrix

        [ 1 2 3 ]
        [ 4 5 6 ]

- new\_from\_cols()

    Creates a matrix by assuming each argument is a column vector.

        $x = Math::Matrix -> new_from_cols($y, $z, ...);

    For example,

        $x = Math::Matrix -> new_from_cols([1, 2, 3],[4, 5, 6]);

    returns the matrix

        [ 1 4 ]
        [ 2 5 ]
        [ 3 6 ]

- id()

    Returns a new identity matrix.

        $I = Math::Matrix -> id($n);    # $n-by-$n identity matrix
        $I = $x -> id($n);              # $n-by-$n identity matrix
        $I = $x -> id();                # identity matrix with size of $x

- new\_identity()

    This is an alias for `["id()"](#id)`.

- eye()

    This is an alias for `["id()"](#id)`.

- exchg()

    Exchange matrix.

        $x = Math::Matrix -> exchg($n);     # $n-by-$n exchange matrix

- scalar()

    Returns a scalar matrix, i.e., a diagonal matrix with all the diagonal elements
    set to the same value.

        # Create an $m-by-$m scalar matrix where each element is $c.
        $x = Math::Matrix -> scalar($c, $m);

        # Create an $m-by-$n scalar matrix where each element is $c.
        $x = Math::Matrix -> scalar($c, $m, $n);

    Multiplying a matrix A by a scalar matrix B is effectively the same as multiply
    each element in A by the constant on the diagonal of B.

- zeros()

    Create a zero matrix.

        # Create an $m-by-$m matrix where each element is 0.
        $x = Math::Matrix -> zeros($m);

        # Create an $m-by-$n matrix where each element is 0.
        $x = Math::Matrix -> zeros($m, $n);

- ones()

    Create a matrix of ones.

        # Create an $m-by-$m matrix where each element is 1.
        $x = Math::Matrix -> ones($m);

        # Create an $m-by-$n matrix where each element is 1.
        $x = Math::Matrix -> ones($m, $n);

- inf()

    Create a matrix of positive infinities.

        # Create an $m-by-$m matrix where each element is Inf.
        $x = Math::Matrix -> inf($m);

        # Create an $m-by-$n matrix where each element is Inf.
        $x = Math::Matrix -> inf($m, $n);

- nan()

    Create a matrix of NaNs (Not-a-Number).

        # Create an $m-by-$m matrix where each element is NaN.
        $x = Math::Matrix -> nan($m);

        # Create an $m-by-$n matrix where each element is NaN.
        $x = Math::Matrix -> nan($m, $n);

- constant()

    Returns a constant matrix, i.e., a matrix whose elements all have the same
    value.

        # Create an $m-by-$m matrix where each element is $c.
        $x = Math::Matrix -> constant($c, $m);

        # Create an $m-by-$n matrix where each element is $c.
        $x = Math::Matrix -> constant($c, $m, $n);

- rand()

    Returns a matrix of uniformly distributed random numbers in the range \[0,1).

        $x = Math::Matrix -> rand($m);          # $m-by-$m matrix
        $x = Math::Matrix -> rand($m, $n);      # $m-by-$n matrix

    To generate an `$m`-by-`$n` matrix of uniformly distributed random numbers in
    the range \[0,`$a`), use

        $x = $a * Math::Matrix -> rand($m, $n);

    To generate an `$m`-by-`$n` matrix of uniformly distributed random numbers in
    the range \[`$a`,`$b`), use

        $x = $a + ($b - $a) * Math::Matrix -> rand($m, $n);

    See also `["randi()"](#randi)` and `["randn()"](#randn)`.

- randi()

    Returns a matrix of uniformly distributed random integers.

        $x = Math::Matrix -> randi($max);                 # 1-by-1 matrix
        $x = Math::Matrix -> randi($max, $n);             # $n-by-$n matrix
        $x = Math::Matrix -> randi($max, $m, $n);         # $m-by-$n matrix

        $x = Math::Matrix -> randi([$min, $max]);         # 1-by-1 matrix
        $x = Math::Matrix -> randi([$min, $max], $n);     # $n-by-$n matrix
        $x = Math::Matrix -> randi([$min, $max], $m, $n); # $m-by-$n matrix

    See also `["rand()"](#rand)` and `["randn()"](#randn)`.

- randn()

    Returns a matrix of random numbers from the standard normal distribution.

        $x = Math::Matrix -> randn($m);         # $m-by-$m matrix
        $x = Math::Matrix -> randn($m, $n);     # $m-by-$n matrix

    To generate an `$m`-by-`$n` matrix with mean `$mu` and standard deviation
    `$sigma`, use

        $x = $mu + $sigma * Math::Matrix -> randn($m, $n);

    See also `["rand()"](#rand)` and `["randi()"](#randi)`.

- clone()

    Clones a matrix and returns the clone.

        $b = $a->clone;

- diagonal()

    A constructor method that creates a diagonal matrix from a single list or array
    of numbers.

        $p = Math::Matrix->diagonal(1, 4, 4, 8);
        $q = Math::Matrix->diagonal([1, 4, 4, 8]);

    The matrix is zero filled except for the diagonal members, which take the
    values of the vector.

    The method returns **undef** in case of error.

- tridiagonal()

    A constructor method that creates a matrix from vectors of numbers.

        $p = Math::Matrix->tridiagonal([1, 4, 4, 8]);
        $q = Math::Matrix->tridiagonal([1, 4, 4, 8], [9, 12, 15]);
        $r = Math::Matrix->tridiagonal([1, 4, 4, 8], [9, 12, 15], [4, 3, 2]);

    In the first case, the main diagonal takes the values of the vector, while both
    of the upper and lower diagonals's values are all set to one.

    In the second case, the main diagonal takes the values of the first vector,
    while the upper and lower diagonals are each set to the values of the second
    vector.

    In the third case, the main diagonal takes the values of the first vector,
    while the upper diagonal is set to the values of the second vector, and the
    lower diagonal is set to the values of the third vector.

    The method returns **undef** in case of error.

- blkdiag()

    Create block diagonal matrix. Returns a block diagonal matrix given a list of
    matrices.

        $z = Math::Matrix -> blkdiag($x, $y, ...);

## Identify matrices

- is\_empty()

    Returns 1 is the invocand is empty, i.e., it has no elements.

        $bool = $x -> is_empty();

- is\_scalar()

    Returns 1 is the invocand is a scalar, i.e., it has one element.

        $bool = $x -> is_scalar();

- is\_vector()

    Returns 1 is the invocand is a vector, i.e., a row vector or a column vector.

        $bool = $x -> is_vector();

- is\_row()

    Returns 1 if the invocand has exactly one row, and 0 otherwise.

        $bool = $x -> is_row();

- is\_col()

    Returns 1 if the invocand has exactly one column, and 0 otherwise.

        $bool = $x -> is_col();

- is\_square()

    Returns 1 is the invocand is square, and 0 otherwise.

        $bool = $x -> is_square();

- is\_symmetric()

    Returns 1 is the invocand is symmetric, and 0 otherwise.

        $bool = $x -> is_symmetric();

    An symmetric matrix satisfies x(i,j) = x(j,i) for all i and j, for example

        [  1  2 -3 ]
        [  2 -4  5 ]
        [ -3  5  6 ]

- is\_antisymmetric()

    Returns 1 is the invocand is antisymmetric a.k.a. skew-symmetric, and 0
    otherwise.

        $bool = $x -> is_antisymmetric();

    An antisymmetric matrix satisfies x(i,j) = -x(j,i) for all i and j, for
    example

        [  0  2 -3 ]
        [ -2  0  4 ]
        [  3 -4  0 ]

- is\_persymmetric()

    Returns 1 is the invocand is persymmetric, and 0 otherwise.

        $bool = $x -> is_persymmetric();

    A persymmetric matrix is a square matrix which is symmetric with respect to the
    anti-diagonal, e.g.:

        [ f  h  j  k ]
        [ c  g  i  j ]
        [ b  d  g  h ]
        [ a  b  c  f ]

- is\_hankel()

    Returns 1 is the invocand is a Hankel matric a.k.a. a catalecticant matrix, and
    0 otherwise.

        $bool = $x -> is_hankel();

    A Hankel matrix is a square matrix in which each ascending skew-diagonal from
    left to right is constant, e.g.:

        [ e f g h i ]
        [ d e f g h ]
        [ c d e f g ]
        [ b c d e f ]
        [ a b c d e ]

- is\_zero()

    Returns 1 is the invocand is a zero matrix, and 0 otherwise. A zero matrix
    contains no element whose value is different from zero.

        $bool = $x -> is_zero();

- is\_one()

    Returns 1 is the invocand is a matrix of ones, and 0 otherwise. A matrix of
    ones contains no element whose value is different from one.

        $bool = $x -> is_one();

- is\_constant()

    Returns 1 is the invocand is a constant matrix, and 0 otherwise. A constant
    matrix is a matrix where no two elements have different values.

        $bool = $x -> is_constant();

- is\_identity()

    Returns 1 is the invocand is an identity matrix, and 0 otherwise. An
    identity matrix contains ones on the main diagonal and zeros elsewhere.

        $bool = $x -> is_identity();

- is\_exchg()

    Returns 1 is the invocand is an exchange matrix, and 0 otherwise.

        $bool = $x -> is_exchg();

    An exchange matrix contains ones on the main anti-diagonal and zeros elsewhere,
    for example

        [ 0 0 1 ]
        [ 0 1 0 ]
        [ 1 0 0 ]

- is\_bool()

    Returns 1 is the invocand is a boolean matrix, and 0 otherwise.

        $bool = $x -> is_bool();

    A boolean matrix is a matrix is a matrix whose entries are either 0 or 1, for
    example

        [ 0 1 1 ]
        [ 1 0 0 ]
        [ 0 1 0 ]

- is\_perm()

    Returns 1 is the invocand is an permutation matrix, and 0 otherwise.

        $bool = $x -> is_perm();

    A permutation matrix is a square matrix with exactly one 1 in each row and
    column, and all other elements 0, for example

        [ 0 1 0 ]
        [ 1 0 0 ]
        [ 0 0 1 ]

- is\_int()

    Returns 1 is the invocand is an integer matrix, i.e., a matrix of integers, and
    0 otherwise.

        $bool = $x -> is_int();

- is\_diag()

    Returns 1 is the invocand is diagonal, and 0 otherwise.

        $bool = $x -> is_diag();

    A diagonal matrix is a square matrix where all non-zero elements, if any, are on
    the main diagonal. It has the following pattern, where only the elements marked
    as `x` can be non-zero,

        [ x 0 0 0 0 ]
        [ 0 x 0 0 0 ]
        [ 0 0 x 0 0 ]
        [ 0 0 0 x 0 ]
        [ 0 0 0 0 x ]

- is\_adiag()

    Returns 1 is the invocand is anti-diagonal, and 0 otherwise.

        $bool = $x -> is_adiag();

    A diagonal matrix is a square matrix where all non-zero elements, if any, are on
    the main antidiagonal. It has the following pattern, where only the elements
    marked as `x` can be non-zero,

        [ 0 0 0 0 x ]
        [ 0 0 0 x 0 ]
        [ 0 0 x 0 0 ]
        [ 0 x 0 0 0 ]
        [ x 0 0 0 0 ]

- is\_tridiag()

    Returns 1 is the invocand is tridiagonal, and 0 otherwise.

        $bool = $x -> is_tridiag();

    A tridiagonal matrix is a square matrix with nonzero elements only on the
    diagonal and slots horizontally or vertically adjacent the diagonal (i.e., along
    the subdiagonal and superdiagonal). It has the following pattern, where only the
    elements marked as `x` can be non-zero,

        [ x x 0 0 0 ]
        [ x x x 0 0 ]
        [ 0 x x x 0 ]
        [ 0 0 x x x ]
        [ 0 0 0 x x ]

- is\_atridiag()

    Returns 1 is the invocand is anti-tridiagonal, and 0 otherwise.

        $bool = $x -> is_tridiag();

    A anti-tridiagonal matrix is a square matrix with nonzero elements only on the
    anti-diagonal and slots horizontally or vertically adjacent the diagonal (i.e.,
    along the anti-subdiagonal and anti-superdiagonal). It has the following
    pattern, where only the elements marked as `x` can be non-zero,

        [ 0 0 0 x x ]
        [ 0 0 x x x ]
        [ 0 x x x 0 ]
        [ x x x 0 0 ]
        [ x x 0 0 0 ]

- is\_pentadiag()

    Returns 1 is the invocand is pentadiagonal, and 0 otherwise.

        $bool = $x -> is_pentadiag();

    A pentadiagonal matrix is a square matrix with nonzero elements only on the
    diagonal and the two diagonals above and below the main diagonal. It has the
    following pattern, where only the elements marked as `x` can be non-zero,

        [ x x x 0 0 0 ]
        [ x x x x 0 0 ]
        [ x x x x x 0 ]
        [ 0 x x x x x ]
        [ 0 0 x x x x ]
        [ 0 0 0 x x x ]

- is\_apentadiag()

    Returns 1 is the invocand is anti-pentadiagonal, and 0 otherwise.

        $bool = $x -> is_pentadiag();

    A anti-pentadiagonal matrix is a square matrix with nonzero elements only on the
    anti-diagonal and two anti-diagonals above and below the main anti-diagonal. It
    has the following pattern, where only the elements marked as `x` can be
    non-zero,

        [ 0 0 0 x x x ]
        [ 0 0 x x x x ]
        [ 0 x x x x x ]
        [ x x x x x 0 ]
        [ x x x x 0 0 ]
        [ x x x 0 0 0 ]

- is\_heptadiag()

    Returns 1 is the invocand is heptadiagonal, and 0 otherwise.

        $bool = $x -> is_heptadiag();

    A heptadiagonal matrix is a square matrix with nonzero elements only on the
    diagonal and the two diagonals above and below the main diagonal. It has the
    following pattern, where only the elements marked as `x` can be non-zero,

        [ x x x x 0 0 ]
        [ x x x x x 0 ]
        [ x x x x x x ]
        [ x x x x x x ]
        [ 0 x x x x x ]
        [ 0 0 x x x x ]

- is\_aheptadiag()

    Returns 1 is the invocand is anti-heptadiagonal, and 0 otherwise.

        $bool = $x -> is_heptadiag();

    A anti-heptadiagonal matrix is a square matrix with nonzero elements only on the
    anti-diagonal and two anti-diagonals above and below the main anti-diagonal. It
    has the following pattern, where only the elements marked as `x` can be
    non-zero,

        [ 0 0 x x x x ]
        [ 0 x x x x x ]
        [ x x x x x x ]
        [ x x x x x x ]
        [ x x x x x 0 ]
        [ x x x x 0 0 ]

- is\_band()

    Returns 1 is the invocand is a band matrix with a specified bandwidth, and 0
    otherwise.

        $bool = $x -> is_band($k);

    A band matrix is a square matrix with nonzero elements only on the diagonal and
    on the `$k` diagonals above and below the main diagonal. The bandwidth `$k`
    must be non-negative.

        $bool = $x -> is_band(0);   # is $x diagonal?
        $bool = $x -> is_band(1);   # is $x tridiagonal?
        $bool = $x -> is_band(2);   # is $x pentadiagonal?
        $bool = $x -> is_band(3);   # is $x heptadiagonal?

    See also `["is_aband()"](#is_aband)` and `["bandwidth()"](#bandwidth)`.

- is\_aband()

    Returns 1 is the invocand is "anti-banded" with a specified bandwidth, and 0
    otherwise.

        $bool = $x -> is_aband($k);

    Some examples

        $bool = $x -> is_aband(0);  # is $x anti-diagonal?
        $bool = $x -> is_aband(1);  # is $x anti-tridiagonal?
        $bool = $x -> is_aband(2);  # is $x anti-pentadiagonal?
        $bool = $x -> is_aband(3);  # is $x anti-heptadiagonal?

    A band matrix is a square matrix with nonzero elements only on the diagonal and
    on the `$k` diagonals above and below the main diagonal. The bandwidth `$k`
    must be non-negative.

    A "anti-banded" matrix is a square matrix with nonzero elements only on the
    anti-diagonal and `$k` anti-diagonals above and below the main anti-diagonal.

    See also `["is_band()"](#is_band)` and `["bandwidth()"](#bandwidth)`.

- is\_triu()

    Returns 1 is the invocand is upper triangular, and 0 otherwise.

        $bool = $x -> is_triu();

    An upper triangular matrix is a square matrix where all non-zero elements are on
    or above the main diagonal. It has the following pattern, where only the
    elements marked as `x` can be non-zero. It has the following pattern, where
    only the elements marked as `x` can be non-zero,

        [ x x x x ]
        [ 0 x x x ]
        [ 0 0 x x ]
        [ 0 0 0 x ]

- is\_striu()

    Returns 1 is the invocand is strictly upper triangular, and 0 otherwise.

        $bool = $x -> is_striu();

    A strictly upper triangular matrix is a square matrix where all non-zero
    elements are strictly above the main diagonal. It has the following pattern,
    where only the elements marked as `x` can be non-zero,

        [ 0 x x x ]
        [ 0 0 x x ]
        [ 0 0 0 x ]
        [ 0 0 0 0 ]

- is\_tril()

    Returns 1 is the invocand is lower triangular, and 0 otherwise.

        $bool = $x -> is_tril();

    A lower triangular matrix is a square matrix where all non-zero elements are on
    or below the main diagonal. It has the following pattern, where only the
    elements marked as `x` can be non-zero,

        [ x 0 0 0 ]
        [ x x 0 0 ]
        [ x x x 0 ]
        [ x x x x ]

- is\_stril()

    Returns 1 is the invocand is strictly lower triangular, and 0 otherwise.

        $bool = $x -> is_stril();

    A strictly lower triangular matrix is a square matrix where all non-zero
    elements are strictly below the main diagonal. It has the following pattern,
    where only the elements marked as `x` can be non-zero,

        [ 0 0 0 0 ]
        [ x 0 0 0 ]
        [ x x 0 0 ]
        [ x x x 0 ]

- is\_atriu()

    Returns 1 is the invocand is upper anti-triangular, and 0 otherwise.

        $bool = $x -> is_atriu();

    An upper anti-triangular matrix is a square matrix where all non-zero elements
    are on or above the main anti-diagonal. It has the following pattern, where only
    the elements marked as `x` can be non-zero,

        [ x x x x ]
        [ x x x 0 ]
        [ x x 0 0 ]
        [ x 0 0 0 ]

- is\_satriu()

    Returns 1 is the invocand is strictly upper anti-triangular, and 0 otherwise.

        $bool = $x -> is_satriu();

    A strictly anti-triangular matrix is a square matrix where all non-zero elements
    are strictly above the main diagonal. It has the following pattern, where only
    the elements marked as `x` can be non-zero,

        [ x x x 0 ]
        [ x x 0 0 ]
        [ x 0 0 0 ]
        [ 0 0 0 0 ]

- is\_atril()

    Returns 1 is the invocand is lower anti-triangular, and 0 otherwise.

        $bool = $x -> is_atril();

    A lower anti-triangular matrix is a square matrix where all non-zero elements
    are on or below the main anti-diagonal. It has the following pattern, where only
    the elements marked as `x` can be non-zero,

        [ 0 0 0 x ]
        [ 0 0 x x ]
        [ 0 x x x ]
        [ x x x x ]

- is\_satril()

    Returns 1 is the invocand is strictly lower anti-triangular, and 0 otherwise.

        $bool = $x -> is_satril();

    A strictly lower anti-triangular matrix is a square matrix where all non-zero
    elements are strictly below the main anti-diagonal. It has the following
    pattern, where only the elements marked as `x` can be non-zero,

        [ 0 0 0 0 ]
        [ 0 0 0 x ]
        [ 0 0 x x ]
        [ 0 x x x ]

## Identify elements

This section contains methods for identifying and locating elements within an
array. See also `["Scalar comparison"](#scalar-comparison)`.

- find()

    Returns the location of each non-zero element.

        $K = $x -> find();          # linear index
        ($I, $J) = $x -> find();    # subscripts

    For example, to find the linear index of each element that is greater than or
    equal to 1, use

        $K = $x -> sge(1) -> find();

- is\_finite()

    Returns a matrix of ones and zeros. The element is one if the corresponding
    element in the invocand matrix is finite, and zero otherwise.

        $y = $x -> is_finite();

- is\_inf()

    Returns a matrix of ones and zeros. The element is one if the corresponding
    element in the invocand matrix is positive or negative infinity, and zero
    otherwise.

        $y = $x -> is_inf();

- is\_nan()

    Returns a matrix of ones and zeros. The element is one if the corresponding
    element in the invocand matrix is a NaN (Not-a-Number), and zero otherwise.

        $y = $x -> is_nan();

- all()

    Tests whether all of the elements along various dimensions of a matrix are
    non-zero. If the dimension argument is not given, the first non-singleton
    dimension is used.

        $y = $x -> all($dim);
        $y = $x -> all();

- any()

    Tests whether any of the elements along various dimensions of a matrix are
    non-zero. If the dimension argument is not given, the first non-singleton
    dimension is used.

        $y = $x -> any($dim);
        $y = $x -> any();

- cumall()

    A cumulative variant of `["all()"](#all)`. If the dimension argument is not given,
    the first non-singleton dimension is used.

        $y = $x -> cumall($dim);
        $y = $x -> cumall();

- cumany()

    A cumulative variant of `["all()"](#all)`. If the dimension argument is not given,
    the first non-singleton dimension is used.

        $y = $x -> cumany($dim);
        $y = $x -> cumany();

## Basic properties

- size()

    You can determine the dimensions of a matrix by calling:

        ($m, $n) = $a -> size;

- nelm()

    Returns the number of elements in the matrix.

        $n = $x -> nelm();

- nrow()

    Returns the number of rows.

        $m = $x -> nrow();

- ncol()

    Returns the number of columns.

        $n = $x -> ncol();

- npag()

    Returns the number of pages. A non-matrix has one page.

        $n = $x -> pag();

- ndim()

    Returns the number of dimensions. This is the number of dimensions along which
    the length is different from one.

        $n = $x -> ndim();

- bandwidth()

    Returns the bandwidth of a matrix. In scalar context, returns the number of the
    non-zero diagonal furthest away from the main diagonal. In list context,
    separate values are returned for the lower and upper bandwidth.

        $n = $x -> bandwidth();
        ($l, $u) = $x -> bandwidth();

    The bandwidth is a non-negative integer. If the bandwidth is 0, the matrix is
    diagonal or zero. If the bandwidth is 1, the matrix is tridiagonal. If the
    bandwidth is 2, the matrix is pentadiagonal etc.

    A matrix with the following pattern, where `x` denotes a non-zero value, would
    return 2 in scalar context, and (1,2) in list context.

        [ x x x 0 0 0 ]
        [ x x x x 0 0 ]
        [ 0 x x x x 0 ]
        [ 0 0 x x x x ]
        [ 0 0 0 x x x ]
        [ 0 0 0 0 x x ]

    See also `["is_band()"](#is_band)` and `["is_aband()"](#is_aband)`.

## Manipulate matrices

These methods are for combining matrices, splitting matrices, extracing parts of
a matrix, inserting new parts into a matrix, deleting parts of a matrix etc.
There are also methods for shuffling elements around (relocating elements)
inside a matrix.

These methods are not concerned with the values of the elements.

- catrow()

    Concatenate rows, i.e., concatenate matrices vertically. Any number of arguments
    is allowed. All non-empty matrices must have the same number or columns. The
    result is a new matrix.

        $x = Math::Matrix -> new([1, 2], [4, 5]);   # 2-by-2 matrix
        $y = Math::Matrix -> new([3, 6]);           # 1-by-2 matrix
        $z = $x -> catrow($y);                      # 3-by-2 matrix

- catcol()

    Concatenate columns, i.e., matrices horizontally. Any number of arguments is
    allowed. All non-empty matrices must have the same number or rows. The result is
    a new matrix.

        $x = Math::Matrix -> new([1, 2], [4, 5]);   # 2-by-2 matrix
        $y = Math::Matrix -> new([3], [6]);         # 2-by-1 matrix
        $z = $x -> catcol($y);                      # 2-by-3 matrix

- getrow()

    Get the specified row(s). Returns a new matrix with the specified rows. The
    number of rows in the output is identical to the number of elements in the
    input.

        $y = $x -> getrow($i);                  # get one
        $y = $x -> getrow([$i0, $i1, $i2]);     # get multiple

- getcol()

    Get the specified column(s). Returns a new matrix with the specified columns.
    The number of columns in the output is identical to the number of elements in
    the input.

        $y = $x -> getcol($j);                  # get one
        $y = $x -> getcol([$j0, $j1, $j2]);     # get multiple

- delrow()

    Delete row(s). Returns a new matrix identical to the invocand but with the
    specified row(s) deleted.

        $y = $x -> delrow($i);                  # delete one
        $y = $x -> delrow([$i0, $i1, $i2]);     # delete multiple

- delcol()

    Delete column(s). Returns a new matrix identical to the invocand but with the
    specified column(s) deleted.

        $y = $x -> delcol($j);                  # delete one
        $y = $x -> delcol([$j0, $j1, $j2]);     # delete multiple

- concat()

    Concatenate two matrices horizontally. The matrices must have the same number of
    rows. The result is a new matrix or **undef** in case of error.

        $x = Math::Matrix -> new([1, 2], [4, 5]);   # 2-by-2 matrix
        $y = Math::Matrix -> new([3], [6]);         # 2-by-1 matrix
        $z = $x -> concat($y);                      # 2-by-3 matrix

- splicerow()

    Row splicing. This is like Perl's built-in splice() function, except that it
    works on the rows of a matrix.

        $y = $x -> splicerow($offset);
        $y = $x -> splicerow($offset, $length);
        $y = $x -> splicerow($offset, $length, $a, $b, ...);

    The built-in splice() function modifies the first argument and returns the
    removed elements, if any. However, since splicerow() does not modify the
    invocand, it returns the modified version as the first output argument and the
    removed part as a (possibly empty) second output argument.

        $x = Math::Matrix -> new([[ 1,  2],
                                  [ 3,  4],
                                  [ 5,  6],
                                  [ 7,  8]]);
        $a = Math::Matrix -> new([[11, 12],
                                  [13, 14]]);
        ($y, $z) = $x -> splicerow(1, 2, $a);

    Gives `$y`

        [  1  2 ]
        [ 11 12 ]
        [ 13 14 ]
        [  7  8 ]

    and `$z`

        [  3  4 ]
        [  5  6 ]

- splicecol()

    Column splicing. This is like Perl's built-in splice() function, except that it
    works on the columns of a matrix.

        $y = $x -> splicecol($offset);
        $y = $x -> splicecol($offset, $length);
        $y = $x -> splicecol($offset, $length, $a, $b, ...);

    The built-in splice() function modifies the first argument and returns the
    removed elements, if any. However, since splicecol() does not modify the
    invocand, it returns the modified version as the first output argument and the
    removed part as a (possibly empty) second output argument.

        $x = Math::Matrix -> new([[ 1, 3, 5, 7 ],
                                  [ 2, 4, 6, 8 ]]);
        $a = Math::Matrix -> new([[11, 13],
                                  [12, 14]]);
        ($y, $z) = $x -> splicerow(1, 2, $a);

    Gives `$y`

        [ 1  11  13  7 ]
        [ 2  12  14  8 ]

    and `$z`

        [ 3  5 ]
        [ 4  6 ]

- swaprc()

    Swap rows and columns. This method does nothing but shuffle elements around. For
    real numbers, swaprc() is identical to the transpose() method.

    A subclass implementing a matrix of complex numbers should provide a transpose()
    method that also takes the complex conjugate of each elements. The swaprc()
    method, on the other hand, should only shuffle elements around.

- flipud()

    Flip upside-down, i.e., flip along dimension 1.

        $y = $x -> flipud();

- fliplr()

    Flip left-to-right, i.e., flip along dimension 2.

        $y = $x -> fliplr();

- flip()

    Flip along various dimensions of a matrix. If the dimension argument is not
    given, the first non-singleton dimension is used.

        $y = $x -> flip($dim);
        $y = $x -> flip();

    See also `["flipud()"](#flipud)` and `["fliplr()"](#fliplr)`.

- rot90()

    Rotate 90 degrees counterclockwise.

        $y = $x -> rot90();     # rotate 90 degrees counterclockwise
        $y = $x -> rot90($n);   # rotate 90*$n degrees counterclockwise

- rot180()

    Rotate 180 degrees.

        $y = $x -> rot180();

- rot270()

    Rotate 270 degrees counterclockwise, i.e., 90 degrees clockwise.

        $y = $x -> rot270();

- repelm()

    Repeat elements.

        $x -> repelm($y);

    Repeats each element in $x the number of times specified in $y.

    If $x is the matrix

        [ 4 5 6 ]
        [ 7 8 9 ]

    and $y is

        [ 3 2 ]

    the returned matrix is

        [ 4 4 5 5 6 6 ]
        [ 4 4 5 5 6 6 ]
        [ 4 4 5 5 6 6 ]
        [ 7 7 8 8 9 9 ]
        [ 7 7 8 8 9 9 ]
        [ 7 7 8 8 9 9 ]

- repmat()

    Repeat elements.

        $x -> repmat($y);

    Repeats the matrix $x the number of times specified in $y.

    If $x is the matrix

        [ 4 5 6 ]
        [ 7 8 9 ]

    and $y is

        [ 3 2 ]

    the returned matrix is

        [ 4 5 6 4 5 6 ]
        [ 7 8 9 7 8 9 ]
        [ 4 5 6 4 5 6 ]
        [ 7 8 9 7 8 9 ]
        [ 4 5 6 4 5 6 ]
        [ 7 8 9 7 8 9 ]

- reshape()

    Returns a reshaped copy of a matrix. The reshaping is done by creating a new
    matrix and looping over the elements in column major order. The new matrix must
    have the same number of elements as the invocand matrix. The following returns
    an `$m`-by-`$n` matrix,

        $y = $x -> reshape($m, $n);

    The code

        $x = Math::Matrix -> new([[1, 3, 5, 7], [2, 4, 6, 8]]);
        $y = $x -> reshape(4, 2);

    creates the matrix $x

        [ 1  3  5  7 ]
        [ 2  4  6  8 ]

    and returns a reshaped copy $y

        [ 1  5 ]
        [ 2  6 ]
        [ 3  7 ]
        [ 4  8 ]

- to\_row()

    Reshape to a row.

        $x -> to_row();

    This method reshapes the matrix into a single row. It is essentially the same
    as, but faster than,

        $x -> reshape(1, $x -> nelm());

- to\_col()

    Reshape to a column.

        $y = $x -> to_col();

    This method reshapes the matrix into a single column. It is essentially the same
    as, but faster than,

        $x -> reshape($x -> nelm(), 1);

- to\_permmat()

    Permutation vector to permutation matrix. Converts a vector of zero-based
    permutation indices to a permutation matrix.

        $P = $v -> to_permmat();

    For example

        $v = Math::Matrix -> new([[0, 3, 1, 4, 2]]);
        $m = $v -> to_permmat();

    gives the permutation matrix `$m`

        [ 1 0 0 0 0 ]
        [ 0 0 0 1 0 ]
        [ 0 1 0 0 0 ]
        [ 0 0 0 0 1 ]
        [ 0 0 1 0 0 ]

- to\_permvec()

    Permutation matrix to permutation vector. Converts a permutation matrix to a
    vector of zero-based permutation indices.

        $v = $P -> to_permvec();

        $v = Math::Matrix -> new([[0, 3, 1, 4, 2]]);
        $m = $v -> to_permmat();

    Gives the permutation matrix `$m`

        [ 1 0 0 0 0 ]
        [ 0 0 0 1 0 ]
        [ 0 1 0 0 0 ]
        [ 0 0 0 0 1 ]
        [ 0 0 1 0 0 ]

    See also `["to_permmat()"](#to_permmat)`.

- triu()

    Upper triangular part. Extract the upper triangular part of a matrix and set all
    other elements to zero.

        $y = $x -> triu();
        $y = $x -> triu($n);

    The optional second argument specifies how many diagonals above or below the
    main diagonal should also be set to zero. The default value of `$n` is zero
    which includes the main diagonal.

- tril()

    Lower triangular part. Extract the lower triangular part of a matrix and set all
    other elements to zero.

        $y = $x -> tril();
        $y = $x -> tril($n);

    The optional second argument specifies how many diagonals above or below the
    main diagonal should also be set to zero. The default value of `$n` is zero
    which includes the main diagonal.

- slice()

    Extract columns:

        a->slice(1,3,5);

- diagonal\_vector()

    Extract the diagonal as an array:

        $diag = $a->diagonal_vector;

- tridiagonal\_vector()

    Extract the diagonals that make up a tridiagonal matrix:

        ($main_d, $upper_d, $lower_d) = $a->tridiagonal_vector;

## Mathematical functions

### Addition

- add()

    Addition. If one operands is a scalar, it is treated like a constant matrix with
    the same size as the other operand. Otherwise ordinary matrix addition is
    performed.

        $z = $x -> add($y);

    See also `["madd()"](#madd)` and `["sadd()"](#sadd)`.

- madd()

    Matrix addition. Add two matrices of the same dimensions. An error is thrown if
    the matrices don't have the same size.

        $z = $x -> madd($y);

    See also `["add()"](#add)` and `["sadd()"](#sadd)`.

- sadd()

    Scalar (element by element) addition with scalar expansion. This method places
    no requirements on the size of the input matrices.

        $z = $x -> sadd($y);

    See also `["add()"](#add)` and `["madd()"](#madd)`.

### Subtraction

- sub()

    Subtraction. If one operands is a scalar, it is treated as a constant matrix
    with the same size as the other operand. Otherwise, ordinarly matrix subtraction
    is performed.

        $z = $x -> sub($y);

    See also `["msub()"](#msub)` and `["ssub()"](#ssub)`.

- msub()

    Matrix subtraction. Subtract two matrices of the same size. An error is thrown
    if the matrices don't have the same size.

        $z = $x -> msub($y);

    See also `["sub()"](#sub)` and `["ssub()"](#ssub)`.

- ssub()

    Scalar (element by element) subtraction with scalar expansion. This method
    places no requirements on the size of the input matrices.

        $z = $x -> ssub($y);

    See also `["sub()"](#sub)` and `["msub()"](#msub)`.

- subtract()

    This is an alias for `["msub()"](#msub)`.

### Negation

- neg()

    Negation. Negate a matrix.

        $y = $x -> neg();

    It is effectively equivalent to

        $y = $x -> map(sub { -$_ });

- negative()

    This is an alias for `["neg()"](#neg)`.

### Multiplication

- mul()

    Multiplication. If one operands is a scalar, it is treated as a constant matrix
    with the same size as the other operand. Otherwise, ordinary matrix
    multiplication is performed.

        $z = $x -> mul($y);

- mmul()

    Matrix multiplication. An error is thrown if the sizes don't match; the number
    of columns in the first operand must be equal to the number of rows in the
    second operand.

        $z = $x -> mmul($y);

- smul()

    Scalar (element by element) multiplication with scalar expansion. This method
    places no requirements on the size of the input matrices.

        $z = $x -> smul($y);

- mmuladd()

    Matrix fused multiply and add. If `$x` is a `$p`-by-`$q` matrix, then `$y`
    must be a `$q`-by-`$r` matrix and `$z` must be a `$p`-by-`$r` matrix. An
    error is thrown if the sizes don't match.

        $w = $x -> mmuladd($y, $z);

    The fused multiply and add is equivalent to, but computed with higher accuracy
    than

        $w = $x -> mmul($y) -> madd($z);

    This method can be used to improve the solution of linear systems.

- kron()

    Kronecker tensor product.

        $A -> kronprod($B);

    If `$A` is an `$m`-by-`$n` matrix and `$B` is a `$p`-by-`$q` matrix, then
    `$A -> kron($B)` is an `$m`\*`$p`-by-`$n`\*`$q` matrix formed by taking
    all possible products between the elements of `$A` and the elements of `$B`.

- multiply()

    This is an alias for `["mmul()"](#mmul)`.

- multiply\_scalar()

    Multiplies a matrix and a scalar resulting in a matrix of the same dimensions
    with each element scaled with the scalar.

        $a->multiply_scalar(2);  scale matrix by factor 2

### Powers

- pow()

    Power function.

    This is an alias for `["mpow()"](#mpow)`.

    See also `["spow()"](#spow)`.

- mpow()

    Matrix power. The second operand must be a non-negative integer.

        $y = $x -> mpow($n);

    The following example

        $x = Math::Matrix -> new([[0, -2],[1, 4]]);
        $y = 4;
        $z = $x -> pow($y);

    returns the matrix

        [ -28  -96 ]
        [  48  164 ]

    See also `["spow()"](#spow)`.

- spow()

    Scalar (element by element) power function. This method doesn't require the
    matrices to have the same size.

        $z = $x -> spow($y);

    See also `["mpow()"](#mpow)`.

### Inversion

- inv()

    This is an alias for `["minv()"](#minv)`.

- invert()

    Invert a Matrix using `solve`.

- minv()

    Matrix inverse. Invert a matrix.

        $y = $x -> inv();

    See the section ["IMPROVING THE SOLUTION OF LINEAR SYSTEMS"](#improving-the-solution-of-linear-systems) for a list of
    additional parameters that can be used for trying to obtain a better solution
    through iteration.

- sinv()

    Scalar (element by element) inverse. Invert each element in a matrix.

        $y = $x -> sinv();

- mldiv()

    Matrix left division. Returns the solution x of the linear system of equations
    A\*x = y, by computing A^(-1)\*y.

        $x = $y -> mldiv($A);

    This method also handles overdetermined and underdetermined systems. There are
    three cases

    - If A is a square matrix, then

            x = A\y = inv(A)*y

        so that A\*x = y to within round-off accuracy.

    - If A is an M-by-N matrix where M > N, then A\\y is computed as

            A\y = (A'*A)\(A'*y) = inv(A'*A)*(A'*y)

        where A' denotes the transpose of A. The returned matrix is the least squares
        solution to the linear system of equations A\*x = y, if it exists. The matrix
        A'\*A must be non-singular.

    - If A is an where M < N, then A\\y is computed as

            A\y = A'*((A*A')\y)

        This solution is not unique. The matrix A\*A' must be non-singular.

    See the section ["IMPROVING THE SOLUTION OF LINEAR SYSTEMS"](#improving-the-solution-of-linear-systems) for a list of
    additional parameters that can be used for trying to obtain a better solution
    through iteration.

- sldiv()

    Scalar (left) division.

        $x -> sldiv($y);

    For scalars, there is no difference between left and right division, so this is
    just an alias for `["sdiv()"](#sdiv)`.

- mrdiv()

    Matrix right division. Returns the solution x of the linear system of equations
    x\*A = y, by computing x = y/A = y\*inv(A) = (A'\\y')', where A' and y' denote the
    transpose of A and y, respectively, and \\ is matrix left division (see
    `["mldiv()"](#mldiv)`).

        $x = $y -> mrdiv($A);

    See the section ["IMPROVING THE SOLUTION OF LINEAR SYSTEMS"](#improving-the-solution-of-linear-systems) for a list of
    additional parameters that can be used for trying to obtain a better solution
    through iteration.

- srdiv()

    Scalar (right) division.

        $x -> srdiv($y);

    For scalars, there is no difference between left and right division, so this is
    just an alias for `["sdiv()"](#sdiv)`.

- sdiv()

    Scalar division. Performs scalar (element by element) division.

        $x -> sdiv($y);

- mpinv()

    Matrix pseudo-inverse, `(A'*A)^(-1)*A'`, where "`'`" is the transpose
    operator.

    See the section ["IMPROVING THE SOLUTION OF LINEAR SYSTEMS"](#improving-the-solution-of-linear-systems) for a list of
    additional parameters that can be used for trying to obtain a better solution
    through iteration.

- pinv()

    This is an alias for `["mpinv()"](#mpinv)`.

- pinvert()

    This is an alias for `["mpinv()"](#mpinv)`.

- solve()

    Solves a equation system given by the matrix. The number of colums must be
    greater than the number of rows. If variables are dependent from each other,
    the second and all further of the dependent coefficients are 0. This means the
    method can handle such systems. The method returns a matrix containing the
    solutions in its columns or **undef** in case of error.

### Factorisation

- chol()

    Cholesky decomposition.

        $L = $A -> chol();

    Every symmetric, positive definite matrix A can be decomposed into a product of
    a unique lower triangular matrix L and its transpose, so that A = L\*L', where L'
    denotes the transpose of L. L is called the Cholesky factor of A.

### Miscellaneous matrix functions

- transpose()

    Returns the transposed matrix. This is the matrix where colums and rows of the
    argument matrix are swapped.

    A subclass implementing matrices of complex numbers should provide a
    `["transpose()"](#transpose)` method that takes the complex conjugate of each element.

- minormatrix()

    Minor matrix. The (i,j) minor matrix of a matrix is identical to the original
    matrix except that row i and column j has been removed.

        $y = $x -> minormatrix($i, $j);

    See also `["minor()"](#minor)`.

- minor()

    Minor. The (i,j) minor of a matrix is the determinant of the (i,j) minor matrix.

        $y = $x -> minor($i, $j);

    See also `["minormatrix()"](#minormatrix)`.

- cofactormatrix()

    Cofactor matrix. Element (i,j) in the cofactor matrix is the (i,j) cofactor,
    which is (-1)^(i+j) multiplied by the determinant of the (i,j) minor matrix.

        $y = $x -> cofactormatrix();

- cofactor()

    Cofactor. The (i,j) cofactor of a matrix is (-1)\*\*(i+j) times the (i,j) minor of
    the matrix.

        $y = $x -> cofactor($i, $j);

- adjugate()

    Adjugate of a matrix. The adjugate, also called classical adjoint or adjunct, of
    a square matrix is the transpose of the cofactor matrix.

        $y = $x -> adjugate();

- det()

    Determinant. Returns the determinant of a matrix. The matrix must be square.

        $y = $x -> det();

    The matrix is computed by forward elimination, which might cause round-off
    errors. So for example, the determinant might be a non-integer even for an
    integer matrix.

- determinant()

    This is an alias for `["det()"](#det)`.

- detr()

    Determinant. Returns the determinant of a matrix. The matrix must be square.

        $y = $x -> determinant();

    The determinant is computed by recursion, so it is generally much slower than
    `["det()"](#det)`.

### Elementwise mathematical functions

These method work on each element of a matrix.

- int()

    Truncate to integer. Truncates each element to an integer.

        $y = $x -> int();

    This function is effectivly the same as

        $y = $x -> map(sub { int });

- floor()

    Round to negative infinity. Rounds each element to negative infinity.

        $y = $x -> floor();

- ceil()

    Round to positive infinity. Rounds each element to positive infinity.

        $y = $x -> int();

- abs()

    Absolute value. The absolute value of each element.

        $y = $x -> abs();

    This is effectivly the same as

        $y = $x -> map(sub { abs });

- sign()

    Sign function. Apply the sign function to each element.

        $y = $x -> sign();

    This is effectivly the same as

        $y = $x -> map(sub { $_ <=> 0 });

### Columnwise or rowwise mathematical functions

These method work along each column or row of a matrix. Some of these methods
return a matrix with the same size as the invocand matrix. Other methods
collapse the dimension, so that, e.g., if the method is applied to the first
dimension a _p_-by-_q_ matrix becomes a 1-by-_q_ matrix, and if applied to
the second dimension, it becomes a _p_-by-1 matrix. Others, like `["diff()"](#diff)`,
reduces the length along the dimension by one, so a _p_-by-_q_ matrix becomes
a (_p_-1)-by-_q_ or a _p_-by-(_q_-1) matrix.

- sum()

    Sum of elements along various dimensions of a matrix. If the dimension argument
    is not given, the first non-singleton dimension is used.

        $y = $x -> sum($dim);
        $y = $x -> sum();

- prod()

    Product of elements along various dimensions of a matrix. If the dimension
    argument is not given, the first non-singleton dimension is used.

        $y = $x -> prod($dim);
        $y = $x -> prod();

- mean()

    Mean of elements along various dimensions of a matrix. If the dimension argument
    is not given, the first non-singleton dimension is used.

        $y = $x -> mean($dim);
        $y = $x -> mean();

- hypot()

    Hypotenuse. Computes the square root of the sum of the square of each element
    along various dimensions of a matrix. If the dimension argument is not given,
    the first non-singleton dimension is used.

        $y = $x -> hypot($dim);
        $y = $x -> hypot();

    For example,

        $x = Math::Matrix -> new([[3,  4],
                                  [5, 12]]);
        $y = $x -> hypot(2);

    returns the 2-by-1 matrix

        [  5 ]
        [ 13 ]

- min()

    Minimum of elements along various dimensions of a matrix. If the dimension
    argument is not given, the first non-singleton dimension is used.

        $y = $x -> min($dim);
        $y = $x -> min();

- max()

    Maximum of elements along various dimensions of a matrix. If the dimension
    argument is not given, the first non-singleton dimension is used.

        $y = $x -> max($dim);
        $y = $x -> max();

- median()

    Median of elements along various dimensions of a matrix. If the dimension
    argument is not given, the first non-singleton dimension is used.

        $y = $x -> median($dim);
        $y = $x -> median();

- cumsum()

    Returns the cumulative sum along various dimensions of a matrix. If the
    dimension argument is not given, the first non-singleton dimension is used.

        $y = $x -> cumsum($dim);
        $y = $x -> cumsum();

- cumprod()

    Returns the cumulative product along various dimensions of a matrix. If the
    dimension argument is not given, the first non-singleton dimension is used.

        $y = $x -> cumprod($dim);
        $y = $x -> cumprod();

- cummean()

    Returns the cumulative mean along various dimensions of a matrix. If the
    dimension argument is not given, the first non-singleton dimension is used.

        $y = $x -> cummean($dim);
        $y = $x -> cummean();

- diff()

    Returns the differences between adjacent elements. If the dimension argument is
    not given, the first non-singleton dimension is used.

        $y = $x -> diff($dim);
        $y = $x -> diff();

- vecnorm()

    Return the `$p`-norm of the elements of `$x`. If the dimension argument is not
    given, the first non-singleton dimension is used.

        $y = $x -> vecnorm($p, $dim);
        $y = $x -> vecnorm($p);
        $y = $x -> vecnorm();

    The `$p`-norm of a vector is defined as the `$p`th root of the sum of the
    absolute values fo the elements raised to the `$p`th power.

- apply()

    Applies a subroutine to each row or column of a matrix. If the dimension
    argument is not given, the first non-singleton dimension is used.

        $y = $x -> apply($sub, $dim);
        $y = $x -> apply($sub);

    The subroutine is passed a list with all elements in a single column or row.

## Comparison

### Matrix comparison

Methods matrix comparison. These methods return a scalar value.

- meq()

    Matrix equal to. Returns 1 if two matrices are identical and 0 otherwise.

        $bool = $x -> meq($y);

- mne()

    Matrix not equal to. Returns 1 if two matrices are different and 0 otherwise.

        $bool = $x -> mne($y);

- equal()

    Decide if two matrices are equal. The criterion is, that each pair of elements
    differs less than $Math::Matrix::eps.

        $bool = $x -> equal($y);

### Scalar comparison

Each of these methods performs scalar (element by element) comparison and
returns a matrix of ones and zeros. Scalar expansion is performed if necessary.

- seq()

    Scalar equality. Performs scalar (element by element) comparison of two
    matrices.

        $bool = $x -> seq($y);

- sne()

    Scalar (element by element) not equal to. Performs scalar (element by element)
    comparison of two matrices.

        $bool = $x -> sne($y);

- slt()

    Scalar (element by element) less than. Performs scalar (element by element)
    comparison of two matrices.

        $bool = $x -> slt($y);

- sle()

    Scalar (element by element) less than or equal to. Performs scalar
    (element by element) comparison of two matrices.

        $bool = $x -> sle($y);

- sgt()

    Scalar (element by element) greater than. Performs scalar (element by element)
    comparison of two matrices.

        $bool = $x -> sgt($y);

- sge()

    Scalar (element by element) greater than or equal to. Performs scalar
    (element by element) comparison of two matrices.

        $bool = $x -> sge($y);

- scmp()

    Scalar (element by element) comparison. Performs scalar (element by element)
    comparison of two matrices. Each element in the output matrix is either -1, 0,
    or 1 depending on whether the elements are less than, equal to, or greater than
    each other.

        $bool = $x -> scmp($y);

## Vector functions

- dot\_product()

    Compute the dot product of two vectors. The second operand does not have to be
    an object.

        # $x and $y are both objects
        $x = Math::Matrix -> new([1, 2, 3]);
        $y = Math::Matrix -> new([4, 5, 6]);
        $p = $x -> dot_product($y);             # $p = 32

        # Only $x is an object.
        $p = $x -> dot_product([4, 5, 6]);      # $p = 32

- outer\_product()

    Compute the outer product of two vectors. The second operand does not have to be
    an object.

        # $x and $y are both objects
        $x = Math::Matrix -> new([1, 2, 3]);
        $y = Math::Matrix -> new([4, 5, 6, 7]);
        $p = $x -> outer_product($y);

        # Only $x is an object.
        $p = $x -> outer_product([4, 5, 6, y]);

- absolute()

    Compute the absolute value (i.e., length) of a vector.

        $v = Math::Matrix -> new([3, 4]);
        $a = $v -> absolute();                  # $v = 5

- normalize()

    Normalize a vector, i.e., scale a vector so its length becomes 1.

        $v = Math::Matrix -> new([3, 4]);
        $u = $v -> normalize();                 # $u = [ 0.6, 0.8 ]

- cross\_product()

    Compute the cross-product of vectors.

        $x = Math::Matrix -> new([1,3,2],
                                 [5,4,2]);
        $p = $x -> cross_product();             # $p = [ -2, 8, -11 ]

## Conversion

- as\_string()

    Creates a string representation of the matrix and returns it.

        $x = Math::Matrix -> new([1, 2], [3, 4]);
        $s = $x -> as_string();

- as\_array()

    Returns the matrix as an unblessed Perl array, i.e., and ordinary, unblessed
    reference.

        $y = $x -> as_array();      # ref($y) returns 'ARRAY'

## Matrix utilities

### Apply a subroutine to each element

- map()

    Call a subroutine for every element of a matrix, locally setting `$_` to each
    element and passing the matrix row and column indices as input arguments.

        # square each element
        $y = $x -> map(sub { $_ ** 2 });

        # set strictly lower triangular part to zero
        $y = $x -> map(sub { $_[0] > $_[1] ? 0 : $_ })'

- sapply()

    Applies a subroutine to each element of a matrix, or each set of corresponding
    elements if multiple matrices are given, and returns the result. The first
    argument is the subroutine to apply. The following arguments, if any, are
    additional matrices on which to apply the subroutine.

        $w = $x -> sapply($sub);            # single operand
        $w = $x -> sapply($sub, $y);        # two operands
        $w = $x -> sapply($sub, $y, $z);    # three operands

    Each matrix element, or corresponding set of elements, are passed to the
    subroutine as input arguments.

    When used with a single operand, this method is similar to the `["map()"](#map)`
    method, the syntax is different, since `["sapply()"](#sapply)` supports multiple
    operands.

    See also `["map()"](#map)`.

    - The subroutine is run in scalar context.
    - No checks are done on the return value of the subroutine.
    - The number of rows in the output matrix equals the number of rows in the operand
    with the largest number of rows. Ditto for columns. So if `$x` is 5-by-2
    matrix, and `$y` is a 3-by-4 matrix, the result is a 5-by-4 matrix.
    - For each operand that has a number of rows smaller than the maximum value, the
    rows are recyled. Ditto for columns.
    - Don't modify the variables $\_\[0\], $\_\[1\] etc. inside the subroutine. Otherwise,
    there is a risk of modifying the operand matrices.
    - If the matrix elements are objects that are not cloned when the "=" (assignment)
    operator is used, you might have to explicitly clone the objects used inside the
    subroutine. Otherwise, the elements in the output matrix might be references to
    objects in the operand matrices, rather than references to new objects.

    Some examples

    - One operand

        With one operand, i.e., the invocand matrix, the subroutine is applied to each
        element of the invocand matrix. The returned matrix has the same size as the
        invocand. For example, multiplying the matrix `$x` with the scalar `$c`

            $sub = sub { $c * $_[0] };      # subroutine to multiply by $c
            $z = $x -> sapply($sub);        # multiply each element by $c

    - Two operands

        When two operands are specfied, the subroutine is applied to each pair of
        corresponding elements in the two operands. For example, adding two matrices can
        be implemented as

            $sub = sub { $_[0] * $_[1] };
            $z = $x -> sapply($sub, $y);

        Note that if the matrices have different sizes, the rows and/or columns of the
        smaller are recycled to match the size of the larger. If `$x` is a
        `$p`-by-`$q` matrix and `$y` is a `$r`-by-`$s` matrix, then `$z` is a
        max(`$p`,`$r`)-by-max(`$q`,`$s`) matrix, and

            $z -> [$i][$j] = $sub -> ($x -> [$i % $p][$j % $q],
                                      $y -> [$i % $r][$j % $s]);

        Because of this recycling, multiplying the matrix `$x` with the scalar `$c`
        (see above) can also be implemented as

            $sub = sub { $_[0] * $_[1] };
            $z = $x -> sapply($sub, $c);

        Generating a matrix with all combinations of `$x**$y` for `$x` being 4, 5, and
        6 and `$y` being 1, 2, 3, and 4 can be done with

            $c = Math::Matrix -> new([[4], [5], [6]]);      # 3-by-1 column
            $r = Math::Matrix -> new([[1, 2, 3, 4]]);       # 1-by-4 row
            $x = $c -> sapply(sub { $_[0] ** $_[1] }, $r);  # 3-by-4 matrix

    - Multiple operands

        In general, the sapply() method can have any number of arguments. For example,
        to compute the sum of the four matrices `$x`, `$y`, `$z`, and `$w`,

            $sub = sub {
                       $sum = 0;
                       for $val (@_) {
                           $sum += $val;
                       };
                       return $sum;
                   };
            $sum = $x -> sapply($sub, $y, $z, $w);

### Forward elimination

These methods take a matrix as input, performs forward elimination, and returns
a matrix where all elements below the main diagonal are zero. In list context,
four additional arguments are returned: an array with the row permutations, an
array with the column permutations, an integer with the number of row swaps and
an integer with the number of column swaps performed during elimination.

The permutation vectors can be converted to permutation matrices with
`["to_permmat()"](#to_permmat)`.

- felim\_np()

    Perform forward elimination with no pivoting.

        $y = $x -> felim_np();

    Forward elimination without pivoting may fail even when the matrix is
    non-singular.

    This method is provided mostly for illustration purposes.

- felim\_tp()

    Perform forward elimination with trivial pivoting, a variant of partial
    pivoting.

        $y = $x -> felim_tp();

    If A is a p-by-q matrix, and the so far remaining unreduced submatrix starts at
    element (i,i), the pivot element is the first element in column i that is
    non-zero.

    This method is provided mostly for illustration purposes.

- felim\_pp()

    Perform forward elimination with (unscaled) partial pivoting.

        $y = $x -> felim_pp();

    If A is a p-by-q matrix, and the so far remaining unreduced submatrix starts at
    element (i,i), the pivot element is the element in column i that has the largest
    absolute value.

    This method is provided mostly for illustration purposes.

- felim\_sp()

    Perform forward elimination with scaled pivoting, a variant of partial pivoting.

        $y = $x -> felim_sp();

    If A is a p-by-q matrix, and the so far remaining unreduced submatrix starts at
    element (i,i), the pivot element is the element in column i that has the largest
    absolute value relative to the other elements on the same row.

- felim\_fp()

    Performs forward elimination with full pivoting.

        $y = $x -> felim_fp();

    The elimination is done with full pivoting, also called complete pivoting or
    total pivoting. If A is a p-by-q matrix, and the so far remaining unreduced
    submatrix starts at element (i,i), the pivot element is the element in the whole
    submatrix that has the largest absolute value. With full pivoting, both rows and
    columns might be swapped.

### Back-substitution

- bsubs()

    Performs back-substitution.

        $y = $x -> bsubs();

    The leftmost square portion of the matrix must be upper triangular.

## Miscellaneous methods

- print()

    Prints the matrix on STDOUT. If the method has additional parameters, these are
    printed before the matrix is printed.

- version()

    Returns a string contining the package name and version number.

# OVERLOADING

The following operators are overloaded.

- `+` and `+=`

    Matrix or scalar addition. Unless one or both of the operands is a scalar, both
    operands must have the same size.

        $C  = $A + $B;      # assign $A + $B to $C
        $A += $B;           # assign $A + $B to $A

    Note that

- `-` and `-=`

    Matrix or scalar subtraction. Unless one or both of the operands is a scalar,
    both operands must have the same size.

        $C  = $A + $B;      # assign $A - $B to $C
        $A += $B;           # assign $A - $B to $A

- `*` and `*=`

    Matrix or scalar multiplication. Unless one or both of the operands is a scalar,
    the number of columns in the first operand must be equal to the number of rows
    in the second operand.

        $C  = $A * $B;      # assign $A * $B to $C
        $A *= $B;           # assign $A * $B to $A

- `**` and `**=`

    Matrix power. The second operand must be a scalar.

        $C  = $A * $B;      # assign $A ** $B to $C
        $A *= $B;           # assign $A ** $B to $A

- `==`

    Equal to.

        $A == $B;           # is $A equal to $B?

- `!=`

    Not equal to.

        $A != $B;           # is $A not equal to $B?

- `neg`

    Negation.

        $B = -$A;           # $B is the negative of $A

- `~`

    Transpose.

        $B = ~$A;           # $B is the transpose of $A

- `abs`

    Absolute value.

        $B = abs $A;        # $B contains absolute values of $A

- `int`

    Truncate to integer.

        $B = int $A;        # $B contains only integers

# IMPROVING THE SOLUTION OF LINEAR SYSTEMS

The methods that do an explicit or implicit matrix left division accept some
additional parameters. If these parameters are specified, the matrix left
division is done repeatedly in an iterative way, which often gives a better
solution.

## Background

The linear system of equations

    $A * $x = $y

can be solved for `$x` with

    $x = $y -> mldiv($A);

Ideally `$A * $x` should equal `$y`, but due to numerical errors, this is not
always the case. The following illustrates how to improve the solution `$x`
computed above:

    $r = $A -> mmuladd($x, -$y);    # compute the residual $A*$x-$y
    $d = $r -> mldiv($A);           # compute the delta for $x
    $x -= $d;                       # improve the solution $x

This procedure is repeated, and at each step, the absolute error

    ||$A*$x - $y|| = ||$r||

and the relative error

    ||$A*$x - $y|| / ||$y|| = ||$r|| / ||$y||

are computed and compared to the tolerances. Once one of the stopping criteria
is satisfied, the algorithm terminates.

## Stopping criteria

The algorithm stops when at least one of the errors are within the specified
tolerances or the maximum number of iterations is reached. If the maximum number
of iterations is reached, but noen of the errors are within the tolerances, a
warning is displayed and the best solution so far is returned.

## Parameters

- MaxIter

    The maximum number of iterations to perform. The value must be a positive
    integer. The default is 20.

- RelTol

    The limit for the relative error. The value must be a non-negative. The default
    value is 1e-19 when perl is compiled with long doubles or quadruple precision,
    and 1e-9 otherwise.

- AbsTol

    The limit for the absolute error. The value must be a non-negative. The default
    value is 0.

- Debug

    If this parameter does not affect when the algorithm terminates, but when set to
    non-zero, some information is displayed at each step.

## Example

If

    $A = [[  8, -8, -5,  6, -1,  3 ],
          [ -7, -1,  5, -9,  5,  6 ],
          [ -7,  8,  9, -2, -4,  3 ],
          [  3, -4,  5,  5,  3,  3 ],
          [  9,  8, -3, -4,  1,  6 ],
          [ -8,  9, -1,  3,  5,  2 ]];

    $y = [[  80, -13 ],
          [  -2, 104 ],
          [ -57, -27 ],
          [  47, -28 ],
          [   5,  77 ],
          [  91, 133 ]];

the result of `$x = $y -> mldiv($A);`, using double precision arithmetic,
is the approximate solution

    $x = [[ -2.999999999999998, -5.000000000000000 ],
          [ -1.000000000000000,  3.000000000000001 ],
          [ -5.999999999999997, -8.999999999999996 ],
          [  8.000000000000000, -2.000000000000003 ],
          [  6.000000000000003,  9.000000000000002 ],
          [  7.999999999999997,  8.999999999999995 ]];

The residual `$res = $A -> mmuladd($x, -$y);` is

    $res = [[  1.24344978758018e-14,  1.77635683940025e-15 ],
            [  8.88178419700125e-15, -5.32907051820075e-15 ],
            [ -1.24344978758018e-14,  1.77635683940025e-15 ],
            [ -7.10542735760100e-15, -4.08562073062058e-14 ],
            [ -1.77635683940025e-14, -3.81916720471054e-14 ],
            [  1.24344978758018e-14,  8.43769498715119e-15 ]];

and the delta `$dx = $res -> mldiv($A);` is

    $dx = [[   -8.592098303124e-16, -2.86724066474914e-15 ],
           [ -7.92220125658508e-16, -2.99693950082398e-15 ],
           [ -2.22533360993874e-16,  3.03465504177947e-16 ],
           [  6.47376093198353e-17, -1.12378127899388e-15 ],
           [  6.35204502123966e-16,  2.40938179521241e-15 ],
           [  1.55166908001001e-15,  2.08339859425849e-15 ]];

giving the improved, and in this case exact, solution `$x -= $dx;`,

    $x = [[ -3, -5 ],
          [ -1,  3 ],
          [ -6, -9 ],
          [  8, -2 ],
          [  6,  9 ],
          [  8,  9 ]];

# SUBCLASSING

The methods should work fine with any kind of numerical objects, provided that
the assignment operator `=` is overloaded, so that Perl knows how to create a
copy.

You can check the behaviour of the assignment operator by assigning a value to a
new variable, modify the new variable, and check whether this also modifies the
original value. Here is an example:

    $x = Some::Class -> new(0);           # create object $x
    $y = $x;                              # create new variable $y
    $y++;                                 # modify $y
    print "it's a clone\n" if $x != $y;   # is $x modified?

The subclass might need to implement some methods of its own. For instance, if
each element is a complex number, a transpose() method needs to be implemented
to take the complex conjugate of each value. An as\_string() method might also be
useful for displaying the matrix in a format more suitable for the subclass.

Here is an example showing Math::Matrix::Complex, a fully-working subclass of
Math::Matrix, where each element is a Math::Complex object.

    use strict;
    use warnings;

    package Math::Matrix::Complex;

    use Math::Matrix;
    use Scalar::Util 'blessed';
    use Math::Complex 1.57;     # "=" didn't clone before 1.57

    our @ISA = ('Math::Matrix');

    # We need a new() method to make sure every element is an object.

    sub new {
        my $self = shift;
        my $x = $self -> SUPER::new(@_);

        my $sub = sub {
            defined(blessed($_[0])) && $_[0] -> isa('Math::Complex')
              ? $_[0]
              : Math::Complex -> new($_[0]);
        };

        return $x -> sapply($sub);
    }

    # We need a transpose() method, since the transpose of a matrix
    # with complex numbers also takes the conjugate of all elements.

    sub transpose {
        my $x = shift;
        my $y = $x -> SUPER::transpose(@_);

        return $y -> sapply(sub { ~$_[0] });
    }

    # We need an as_string() method, since our parent's methods
    # doesn't format complex numbers correctly.

    sub as_string {
        my $self = shift;
        my $out = "";
        for my $row (@$self) {
            for my $elm (@$row) {
                $out = $out . sprintf "%10s ", $elm;
            }
            $out = $out . sprintf "\n";
        }
        $out;
    }

    1;

# BUGS

Please report any bugs or feature requests via
[https://github.com/pjacklam/p5-Math-Matrix/issues](https://github.com/pjacklam/p5-Math-Matrix/issues).

Old bug reports and feature requests can be found at
[http://rt.cpan.org/NoAuth/Bugs.html?Dist=Math-Matrix](http://rt.cpan.org/NoAuth/Bugs.html?Dist=Math-Matrix).

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Math::Matrix

You can also look for information at:

- GitHub Source Repository

    [https://github.com/pjacklam/p5-Math-Matrix](https://github.com/pjacklam/p5-Math-Matrix)

- MetaCPAN

    [https://metacpan.org/release/Math-Matrix](https://metacpan.org/release/Math-Matrix)

- CPAN Ratings

    [http://cpanratings.perl.org/d/Math-Matrix](http://cpanratings.perl.org/d/Math-Matrix)

- CPAN Testers PASS Matrix

    [http://pass.cpantesters.org/distro/A/Math-Matrix.html](http://pass.cpantesters.org/distro/A/Math-Matrix.html)

- CPAN Testers Reports

    [http://www.cpantesters.org/distro/A/Math-Matrix.html](http://www.cpantesters.org/distro/A/Math-Matrix.html)

- CPAN Testers Matrix

    [http://matrix.cpantesters.org/?dist=Math-Matrix](http://matrix.cpantesters.org/?dist=Math-Matrix)

# LICENSE AND COPYRIGHT

Copyright (c) 2020-2021, Peter John Acklam

Copyright (C) 2013, John M. Gamble <jgamble@ripco.com>, all rights reserved.

Copyright (C) 2009, oshalla
https://rt.cpan.org/Public/Bug/Display.html?id=42919

Copyright (C) 2002, Bill Denney <gte273i@prism.gatech.edu>, all rights
reserved.

Copyright (C) 2001, Brian J. Watson <bjbrew@power.net>, all rights reserved.

Copyright (C) 2001, Ulrich Pfeifer <pfeifer@wait.de>, all rights reserved.
Copyright (C) 1995, Universität Dortmund, all rights reserved.

Copyright (C) 2001, Matthew Brett <matthew.brett@mrc-cbu.cam.ac.uk>

This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.

# AUTHORS

Peter John Acklam <pjacklam@gmail.com> (2020-2021)

Ulrich Pfeifer <pfeifer@ls6.informatik.uni-dortmund.de> (1995-2013)

Brian J. Watson <bjbrew@power.net>

Matthew Brett <matthew.brett@mrc-cbu.cam.ac.uk>
