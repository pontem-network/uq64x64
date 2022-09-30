/// Implementation of FixedPoint u64 in Move language.
module uq64x64::uq64x64 {
    // Error codes.

    /// When divide by zero attempted.
    const ERR_DIVIDE_BY_ZERO: u64 = 100;

    /// When divisor is too small that will cause overflow
    const ERR_DIVISOR_TOO_SMALL: u64 = 101;
    
    /// When divident is too large that will cause overflow
    const ERR_DIVIDENT_TOO_LARGE: u64 = 102;

    /// When a and b are equals.
    const EQUAL: u8 = 0;

    /// When a is less than b equals.
    const LESS_THAN: u8 = 1;

    /// When a is greater than b.
    const GREATER_THAN: u8 = 2;

    /// The resource to store `UQ64x64`.
    struct UQ64x64 has copy, store, drop {
        v: u128
    }

    /// Encode `u64` to `UQ64x64`
    public fun encode(x: u64): UQ64x64 {
        let v = (x as u128) << 64;
        UQ64x64{ v }
    }
    spec encode {
        ensures result.v == x << 64;
        ensures result.v <= MAX_U128;
    }

    /// Decode a `UQ64x64` into a `u64` by truncating after the radix point.
    public fun decode(uq: UQ64x64): u64 {
        ((uq.v >> 64) as u64)
    }
    spec decode {
        ensures result == uq.v >> 64;
    }

    /// Get `u128` (raw value) from UQ64x64
    public fun to_u128(uq: UQ64x64): u128 {
        uq.v
    }
    spec to_u128 {
        ensures result == uq.v;
    }
    
    /// Convert from `u128` (raw value) to UQ64x64
    public fun from_u128(v: u128): UQ64x64 {
        UQ64x64{ v }
    }
    spec to_u128 {
        ensures result.v == v;
    }

    /// Multiply a `UQ64x64` by a `u64`, returning a `UQ64x64`
    public fun mul(uq: UQ64x64, y: u64): UQ64x64 {
        // vm would direct abort when overflow occured
        let v = uq.v * (y as u128);

        UQ64x64{ v }
    }
    spec mul {
        ensures result.v == uq.v * y;
    }

    /// Divide a `UQ64x64` by a `u64`, returning a `UQ64x64`.
    public fun div(uq: UQ64x64, y: u64): UQ64x64 {
        assert!(y != 0, ERR_DIVIDE_BY_ZERO);

        let v = uq.v / (y as u128);
        UQ64x64{ v }
    }
    spec div {
        aborts_if y == 0 with ERR_DIVIDE_BY_ZERO;
        ensures result.v == uq.v / y;
    }

    /// Add a `UQ64x64` and a `u64`, returning a `UQ64x64`
    public fun add(uq: UQ64x64, y: u64): UQ64x64 {
        // vm would direct abort when overflow occured
        let v = uq.v + ((y as u128) << 64);

        UQ64x64{ v }
    }
    spec add {
        ensures result.v == uq.v + y;
    }

    /// Subtract `UQ64x64` by a `u64`, returning a `UQ64x64`
    public fun sub(uq: UQ64x64, y: u64): UQ64x64 {
        // vm would direct abort when underflow occured
        let v = uq.v - ((y as u128) << 64);

        UQ64x64{ v }
    }
    spec sub {
        ensures result.v = uq.v - (y << 64);
    }

    /// Add a `UQ64x64` and a `UQ64x64`, returning a `UQ64x64`
    public fun add_q(a: UQ64x64, b: UQ64x64): UQ64x64 {
        // vm would direct abort when overflow occured
        let v = a.v + b.v;

        UQ64x64{ v }
    }

    /// Subtract `UQ64x64` by a `UQ64x64`, returning a `UQ64x64`
    public fun sub_q(a: UQ64x64, b: UQ64x64): UQ64x64 {
        // vm would direct abort when underflow occured
        let v = a.v - b.v;

        UQ64x64{ v }
    }

    /// Multiply a `UQ64x64` by a `UQ64x64`, returning a `UQ64x64`
    /// To avoid overflow, the result must be smaller than MAX_U64
    public fun mul_q(a: UQ64x64, b: UQ64x64): UQ64x64 {
        let a_shift = a.v >> 32;
        let b_shift = b.v >> 32;
        // vm would direct abort when overflow occured
        let v = a_shift * b_shift;

        UQ64x64{ v }
    }

    
    /// Divide a `UQ64x64` by a `UQ64x64`, returning a `UQ64x64`.
    /// To avoid overflow, the divident must be smaller than MAX_U96
    public fun div_q(a: UQ64x64, b: UQ64x64): UQ64x64 {
        // make sure a.v << 32 won't overflow
        let a_overflow_check = a.v >> 96;
        assert!(a_overflow_check == 0, ERR_DIVIDENT_TOO_LARGE);

        let a_shift = a.v << 32;
        let b_shift = b.v >> 32;
        assert!(b_shift != 0, ERR_DIVISOR_TOO_SMALL);
        let v = a_shift / b_shift;

        UQ64x64{ v }
    }

    /// Returns a `UQ64x64` which represents the ratio of the numerator to the denominator.
    public fun fraction(numerator: u64, denominator: u64): UQ64x64 {
        assert!(denominator != 0, ERR_DIVIDE_BY_ZERO);

        let r = (numerator as u128) << 64;
        let v = r / (denominator as u128);

        UQ64x64{ v }
    }
    spec fraction {
        aborts_if denominator == 0 with ERR_DIVIDE_BY_ZERO;
        ensures result.v == (numerator << 64) / denominator;
    }

    /// Compare two `UQ64x64` numbers.
    public fun compare(left: &UQ64x64, right: &UQ64x64): u8 {
        if (left.v == right.v) {
            return EQUAL
        } else if (left.v < right.v) {
            return LESS_THAN
        } else {
            return GREATER_THAN
        }
    }
    spec compare {
        ensures left.v == right.v ==> result == EQUAL;
        ensures left.v < right.v ==> result == LESS_THAN;
        ensures left.v > right.v ==> result == GREATER_THAN;
    }

    /// Check if `UQ64x64` is zero
    public fun is_zero(uq: &UQ64x64): bool {
        uq.v == 0
    }
    spec is_zero {
        ensures uq.v == 0 ==> result == true;
        ensures uq.v > 0 ==> result == false;
    }
}
