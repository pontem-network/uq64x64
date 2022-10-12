/// Implementation of FixedPoint u64 in Move language.
module fixed_point64::fixed_point64 {
    // Error codes.

    /// When divide by zero attempted.
    const ERR_DIVIDE_BY_ZERO: u64 = 100;

    /// When divisor is too small that will cause overflow
    const ERR_DIVISOR_TOO_SMALL: u64 = 101;
    
    /// When divide result is too large that will cause overflow
    const ERR_DIVIDE_RESULT_TOO_LARGE: u64 = 102;

    /// Max uint 32 (0xFFFFFFFF)
    const MAX_U32: u128 = 4294967295;

    /// When a and b are equals.
    const EQUAL: u8 = 0;

    /// When a is less than b equals.
    const LESS_THAN: u8 = 1;

    /// When a is greater than b.
    const GREATER_THAN: u8 = 2;

    /// The resource to store `FixedPoint64`.
    struct FixedPoint64 has copy, store, drop {
        v: u128
    }

    /// Encode `u64` to `FixedPoint64`
    public fun encode(x: u64): FixedPoint64 {
        let v = (x as u128) << 64;
        FixedPoint64{ v }
    }
    spec encode {
        ensures result.v == x << 64;
        ensures result.v <= MAX_U128;
    }

    /// Decode a `FixedPoint64` into a `u64` by rounding down
    /// This should be the default way to convert back to integer
    /// Unless you have a good reason to round up
    public fun decode(fp: FixedPoint64): u64 {
        let a = ((fp.v >> 64) as u64);
        a
    }

    /// Decode a `FixedPoint64` into a `u64` by rounding up
    public fun decode_round_up(fp: FixedPoint64): u64 {
        let a = ((fp.v >> 64) as u64);
        let mask: u128 = (1 << 64) - 1;
        if (fp.v & mask > 0) a = a + 1;
        a
    }

    /// Get `u128` (raw value) from FixedPoint64
    public fun to_u128(fp: FixedPoint64): u128 {
        fp.v
    }
    spec to_u128 {
        ensures result == fp.v;
    }
    
    /// Convert from `u128` (raw value) to FixedPoint64
    public fun from_u128(v: u128): FixedPoint64 {
        FixedPoint64{ v }
    }
    spec from_u128 {
        ensures result.v == v;
    }

    /// Get integer "one" in FixedPoint64
    public fun one(): FixedPoint64 {
        FixedPoint64{ v: 1 << 64 }
    }
    
    /// Get integer "zero" in FixedPoint64
    public fun zero(): FixedPoint64 {
        FixedPoint64{ v: 0 }
    }

    /// Multiply a `FixedPoint64` by a `u64`, returning a `FixedPoint64`
    public fun mul(fp: FixedPoint64, y: u64): FixedPoint64 {
        // vm would direct abort when overflow occured
        let v = fp.v * (y as u128);

        FixedPoint64{ v }
    }
    spec mul {
        ensures result.v == fp.v * y;
    }

    /// Divide a `FixedPoint64` by a `u64`, returning a `FixedPoint64`.
    public fun div(fp: FixedPoint64, y: u64): FixedPoint64 {
        assert!(y != 0, ERR_DIVIDE_BY_ZERO);

        let v = fp.v / (y as u128);
        FixedPoint64{ v }
    }
    spec div {
        aborts_if y == 0 with ERR_DIVIDE_BY_ZERO;
        ensures result.v == fp.v / y;
    }

    /// Add a `FixedPoint64` and a `u64`, returning a `FixedPoint64`
    public fun add(fp: FixedPoint64, y: u64): FixedPoint64 {
        // vm would direct abort when overflow occured
        let v = fp.v + ((y as u128) << 64);

        FixedPoint64{ v }
    }
    spec add {
        ensures result.v == fp.v + y;
    }

    /// Subtract `FixedPoint64` by a `u64`, returning a `FixedPoint64`
    public fun sub(fp: FixedPoint64, y: u64): FixedPoint64 {
        // vm would direct abort when underflow occured
        let v = fp.v - ((y as u128) << 64);

        FixedPoint64{ v }
    }
    spec sub {
        ensures result.v = fp.v - (y << 64);
    }

    /// Add a `FixedPoint64` and a `FixedPoint64`, returning a `FixedPoint64`
    public fun add_fp(a: FixedPoint64, b: FixedPoint64): FixedPoint64 {
        // vm would direct abort when overflow occured
        let v = a.v + b.v;

        FixedPoint64{ v }
    }

    /// Subtract `FixedPoint64` by a `FixedPoint64`, returning a `FixedPoint64`
    public fun sub_fp(a: FixedPoint64, b: FixedPoint64): FixedPoint64 {
        // vm would direct abort when underflow occured
        let v = a.v - b.v;

        FixedPoint64{ v }
    }

    /// Multiply a `FixedPoint64` by a `FixedPoint64`, returning a `FixedPoint64`
    /// To avoid overflow, the result must be smaller than MAX_U64
    public fun mul_fp(a: FixedPoint64, b: FixedPoint64): FixedPoint64 {
        let a_shift = a.v >> 32;
        let b_shift = b.v >> 32;
        let a_low_32 = a.v & MAX_U32;
        let b_low_32 = b.v & MAX_U32;
        // vm would direct abort when overflow occured
        let v = a_shift * b_shift + ((a_shift * b_low_32) >> 32) + ((b_shift * a_low_32) >> 32);

        FixedPoint64{ v }
    }

    
    /// Divide a `FixedPoint64` by a `FixedPoint64`, returning a `FixedPoint64`.
    /// To avoid overflow, the result must be smaller than MAX_U64
    public fun div_fp(a: FixedPoint64, b: FixedPoint64): FixedPoint64 {
        let b_shift = b.v >> 32;
        assert!(b_shift != 0, ERR_DIVISOR_TOO_SMALL);
        
        let result = a.v / b_shift;
        // make sure result << 32 won't overflow
        assert!(result >> 96 == 0, ERR_DIVIDE_RESULT_TOO_LARGE);
        let v = result << 32;

        FixedPoint64{ v }
    }

    /// Returns a `FixedPoint64` which represents the ratio of the numerator to the denominator.
    public fun fraction(numerator: u64, denominator: u64): FixedPoint64 {
        assert!(denominator != 0, ERR_DIVIDE_BY_ZERO);

        let r = (numerator as u128) << 64;
        let v = r / (denominator as u128);

        FixedPoint64{ v }
    }
    spec fraction {
        aborts_if denominator == 0 with ERR_DIVIDE_BY_ZERO;
        ensures result.v == (numerator << 64) / denominator;
    }

    /// Compare two `FixedPoint64` numbers.
    public fun compare(left: &FixedPoint64, right: &FixedPoint64): u8 {
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

    /// Less than
    public fun lt(left: &FixedPoint64, right: &FixedPoint64): bool {
        compare(left, right) == LESS_THAN
    }

    /// Greater than
    public fun gt(left: &FixedPoint64, right: &FixedPoint64): bool {
        compare(left, right) == GREATER_THAN
    }

    /// Less or equal than
    public fun lte(left: &FixedPoint64, right: &FixedPoint64): bool {
        compare(left, right) != GREATER_THAN
    }

    /// Greater or equal then
    public fun gte(left: &FixedPoint64, right: &FixedPoint64): bool {
        compare(left, right) != LESS_THAN
    }

    /// Check if `FixedPoint64` is zero
    public fun is_zero(fp: &FixedPoint64): bool {
        fp.v == 0
    }
    spec is_zero {
        ensures fp.v == 0 ==> result == true;
        ensures fp.v > 0 ==> result == false;
    }

    public fun min(a: &FixedPoint64, b: &FixedPoint64): &FixedPoint64 {
        let result = compare(a, b);
        if (result == LESS_THAN) {
            return a
        } else {
            return b
        }
    }
    
    public fun max(a: &FixedPoint64, b: &FixedPoint64): &FixedPoint64 {
        let result = compare(a, b);
        if (result == GREATER_THAN) {
            return a
        } else {
            return b
        }
    }
}
