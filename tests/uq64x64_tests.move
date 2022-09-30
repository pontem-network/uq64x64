#[test_only]
module uq64x64::uq64x64_tests {
    use uq64x64::uq64x64;

    const MAX_U64: u64 = 18446744073709551615; // 2^64 - 1
    const TWO_POWER_64: u128 = 18446744073709551616;

    #[test]
    fun test_is_zero() {
        let zero = uq64x64::encode(0);
        assert!(uq64x64::is_zero(&zero), 0);

        let non_zero = uq64x64::encode(1);
        assert!(!uq64x64::is_zero(&non_zero), 1);
    }

    #[test]
    fun test_compare() {
        assert!(uq64x64::compare(&uq64x64::encode(100), &uq64x64::encode(100)) == 0, 0);
        assert!(uq64x64::compare(&uq64x64::encode(200), &uq64x64::encode(100)) == 2, 1);
        assert!(uq64x64::compare(&uq64x64::encode(100), &uq64x64::encode(200)) == 1, 1);
    }

    #[test]
    fun test_encode() {
        let a = uq64x64::encode(100);
        let b = uq64x64::decode(a);
        assert!(b == 100, 0);

        a = uq64x64::encode(MAX_U64);
        b = uq64x64::decode(a);
        assert!(b == MAX_U64, 1);

        a = uq64x64::encode(0);
        b = uq64x64::decode(a);
        assert!(b == 0, 2);
    }
    
    #[test]
    fun test_from_and_to() {
        let a = uq64x64::from_u128(1);
        let b = uq64x64::to_u128(a);
        assert!(b == 1, 0);
    }

    #[test]
    fun test_mul() {
        let a = uq64x64::encode(5);
        let z = uq64x64::mul(a, 2);
        assert!(uq64x64::to_u128(z) == TWO_POWER_64 * 10, 0);
        assert!(uq64x64::decode(z) == 10, 1);
    }

    #[test]
    fun test_fraction() {
        let a = uq64x64::fraction(8, 2);
        assert!(uq64x64::to_u128(a) == TWO_POWER_64 * 4, 0);
        assert!(uq64x64::decode(a) == 4, 1);
    }

    #[test]
    fun test_fraction_mul() {
        let a = uq64x64::fraction(5, 4); // 1.25
        let z = uq64x64::mul(a, 2); // 2.5
        assert!(uq64x64::to_u128(z) == TWO_POWER_64 * 5 / 2, 0);
        // truncation should happen
        assert!(uq64x64::decode(z) == 2, 1);
    }

    #[test]
    #[expected_failure(abort_code = 100)]
    fun test_fail_fraction() {
        let a = uq64x64::fraction(256, 0);
        uq64x64::to_u128(a);
    }

    #[test]
    fun test_div() {
        let a = uq64x64::encode(8);
        let z = uq64x64::div(a, 2);
        assert!(uq64x64::to_u128(z) == TWO_POWER_64 * 4, 0);
        assert!(uq64x64::decode(z) == 4, 1);
    }

    #[test]
    #[expected_failure(abort_code = 100)]
    fun test_fail_div() {
        let a = uq64x64::encode(1);
        uq64x64::div(a, 0);
    }

    #[test]
    fun test_add() {
        let a = uq64x64::encode(2);
        let z = uq64x64::add(a, 3);
        assert!(uq64x64::to_u128(z) == TWO_POWER_64 * 5, 0);
        assert!(uq64x64::decode(z) == 5, 1);
    }
    
    #[test]
    #[expected_failure]
    fun test_fail_overflow_add() {
        let a = uq64x64::encode(MAX_U64);
        uq64x64::add(a, MAX_U64);
    }

    #[test]
    fun test_sub() {
        let a = uq64x64::encode(3);
        let z = uq64x64::sub(a, 2);
        assert!(uq64x64::to_u128(z) == TWO_POWER_64, 0);
        assert!(uq64x64::decode(z) == 1, 1);
    }
    
    #[test]
    #[expected_failure]
    fun test_fail_underflow_sub() {
        let a = uq64x64::encode(5);
        uq64x64::sub(a, 10);
    }

    #[test]
    fun test_add_q() {
        let a = uq64x64::encode(2);
        let b = uq64x64::encode(3);
        let z = uq64x64::add_q(a, b);
        assert!(uq64x64::to_u128(z) == TWO_POWER_64 * 5, 0);
        assert!(uq64x64::decode(z) == 5, 1);
    }
    
    #[test]
    #[expected_failure]
    fun test_fail_overflow_add_q() {
        let a = uq64x64::encode(MAX_U64);
        let b = uq64x64::encode(3);
        uq64x64::add_q(a, b);
    }

    #[test]
    fun test_sub_q() {
        let a = uq64x64::encode(3);
        let b = uq64x64::encode(2);
        let z = uq64x64::sub_q(a, b);
        assert!(uq64x64::to_u128(z) == TWO_POWER_64, 0);
        assert!(uq64x64::decode(z) == 1, 1);
    }
    
    #[test]
    #[expected_failure]
    fun test_fail_underflow_sub_q() {
        let a = uq64x64::encode(5);
        let b = uq64x64::encode(10);
        uq64x64::sub_q(a, b);
    }

    #[test]
    fun test_mul_q() {
        let a = uq64x64::encode(3);
        let b = uq64x64::encode(2);
        let z = uq64x64::mul_q(a, b);
        assert!(uq64x64::to_u128(z) == TWO_POWER_64 * 6, 0);
        assert!(uq64x64::decode(z) == 6, 1);
    }
    
    #[test]
    fun test_mul_q_fraction() {
        let a = uq64x64::fraction(5, 4); // 1.25
        let b = uq64x64::encode(2);
        let z = uq64x64::mul_q(a, b);
        assert!(uq64x64::to_u128(z) == TWO_POWER_64 * 5 / 2, 0);
        // truncation should happen
        assert!(uq64x64::decode(z) == 2, 1);
    }
    
    #[test]
    #[expected_failure]
    fun test_fail_overflow_mul_q() {
        let a = uq64x64::encode(MAX_U64);
        let b = uq64x64::encode(10);
        uq64x64::mul_q(a, b);
    }
    
    #[test]
    fun test_div_q() {
        let a = uq64x64::encode(6);
        let b = uq64x64::encode(2);
        let z = uq64x64::div_q(a, b);
        assert!(uq64x64::to_u128(z) == TWO_POWER_64 * 3, 0);
        assert!(uq64x64::decode(z) == 3, 1);
    }
    
    #[test]
    fun test_div_q_fraction() {
        let a = uq64x64::fraction(5, 4); // 1.25
        let b = uq64x64::fraction(1, 4); // 0.25
        let z = uq64x64::div_q(a, b);
        assert!(uq64x64::to_u128(z) == TWO_POWER_64 * 5, 0);
        // truncation should happen
        assert!(uq64x64::decode(z) == 5, 1);
    }
    
    #[test]
    #[expected_failure(abort_code = 101)]
    fun test_fail_divisor_too_small_div_q() {
        let a = uq64x64::encode(10);
        let b = uq64x64::from_u128(1);
        uq64x64::div_q(a, b);
    }
    
    #[test]
    #[expected_failure(abort_code = 102)]
    fun test_fail_overflow_div_q() {
        let a = uq64x64::from_u128(1 << 100);
        let b = uq64x64::encode(10);
        uq64x64::div_q(a, b);
    }
}