module fixed_point64::log_exp_math {
    use fixed_point64::fixed_point64::{Self, FixedPoint64};

    // Error codes.

    /// When exponent is too large
    const ERR_EXPONENT_TOO_LARGE: u64 = 200;
    
    const ONE_RAW: u128 = 1 << 64;
    const TWO_RAW: u128 = 1 << 65;
    const TWO_POW_2_RAW: u128 = 1 << 66;
    const TWO_POW_3_RAW: u128 = 1 << 67;
    const TWO_POW_4_RAW: u128 = 1 << 68;
    const TWO_POW_5_RAW: u128 = 1 << 69;
    const TWO_POW_6_RAW: u128 = 1 << 70;
    const TWO_POW_NEG_1_RAW: u128 = 1 << 63;
    const TWO_POW_NEG_2_RAW: u128 = 1 << 62;
    const TWO_POW_NEG_3_RAW: u128 = 1 << 61;
    const TWO_POW_NEG_4_RAW: u128 = 1 << 60;

    const EXP_1_RAW: u128 = 50143449209799256676;
    const EXP_2_RAW: u128 = 136304026803256390374;
    const EXP_4_RAW: u128 = 1007158100559408450779;
    const EXP_8_RAW: u128 = 54988969081439155349854;
    const EXP_16_RAW: u128 = 163919806582506698216928336;
    const EXP_32_RAW: u128 = 1456609517792428400051253459476158;
    const EXP_1_OVER_2_RAW: u128 = 30413539329486470297;
    const EXP_1_OVER_4_RAW: u128 = 23686088245777032821;
    const EXP_1_OVER_8_RAW: u128 = 20902899511243624352;
    const EXP_1_OVER_16_RAW: u128 = 19636456851539679197;

    const LOG_2_E_INV_RAW: u128 = 12786308645977587712; // 1.0 / log_2(e)

    // code reference: https://github.com/dmoulding/log2fix/blob/master/log2fix.c
    // algorithm: http://www.claysturner.com/dsp/BinaryLogarithm.pdf
    public fun log2(x: FixedPoint64): (u8, FixedPoint64) {
        let precision: u8 = 64;
        let z = fixed_point64::to_u128(x);
        let y: u128 = 0;
        let y_negative: u128 = 0;
        let b: u128 = 1 << (precision - 1);
        let i: u8 = 0;
        let sign: u8 = 1;

        // normalize input to the range [1,2)
        while (z >= TWO_RAW) {
            z = z >> 1;
            y = y + ONE_RAW;
        };

        while (z < ONE_RAW) {
            sign = 0;
            z = z << 1;
            y_negative = y_negative + ONE_RAW;
        };

        while (i < 32) {
            z = (z >> 32) * (z >> 32);
            if (z >= 2 << precision) { 
                z = z >> 1;
                y = y + b;
            };
            b = b >> 1;
            i = i + 1;
        };

        let result = if (sign > 0) { fixed_point64::from_u128(y) } else { fixed_point64::from_u128(y_negative - y) };

        (sign, result)
    }

    public fun ln(x: FixedPoint64): (u8, FixedPoint64) {
        // ln(x) = log_2(x) / log_2(e)
        let (sign, result) = log2(x);
        result = fixed_point64::mul_fp(result, fixed_point64::from_u128(LOG_2_E_INV_RAW));
        (sign, result)
    }

    public fun exp(sign: u8, x: FixedPoint64): FixedPoint64 {
        assert!(fixed_point64::to_u128(x) < TWO_POW_6_RAW, ERR_EXPONENT_TOO_LARGE);
        let result;
        if (fixed_point64::to_u128(x) == 0) {
            result = fixed_point64::one();
        } else if (sign == 0) {
            result = fixed_point64::div_fp(fixed_point64::one(), exp(1, x));
        } else if (fixed_point64::to_u128(x) == ONE_RAW) {
            result = fixed_point64::from_u128(EXP_1_RAW);
        } else {
            result = fixed_point64::one();
            
            if (fixed_point64::to_u128(x) >= TWO_POW_5_RAW) {
                x = fixed_point64::sub_fp(x, fixed_point64::from_u128(TWO_POW_5_RAW));
                result = fixed_point64::mul_fp(result, fixed_point64::from_u128(EXP_32_RAW));
            };
            if (fixed_point64::to_u128(x) >= TWO_POW_4_RAW) {
                x = fixed_point64::sub_fp(x, fixed_point64::from_u128(TWO_POW_4_RAW));
                result = fixed_point64::mul_fp(result, fixed_point64::from_u128(EXP_16_RAW));
            };
            if (fixed_point64::to_u128(x) >= TWO_POW_3_RAW) {
                x = fixed_point64::sub_fp(x, fixed_point64::from_u128(TWO_POW_3_RAW));
                result = fixed_point64::mul_fp(result, fixed_point64::from_u128(EXP_8_RAW));
            };
            if (fixed_point64::to_u128(x) >= TWO_POW_2_RAW) {
                x = fixed_point64::sub_fp(x, fixed_point64::from_u128(TWO_POW_2_RAW));
                result = fixed_point64::mul_fp(result, fixed_point64::from_u128(EXP_4_RAW));
            };
            if (fixed_point64::to_u128(x) >= TWO_RAW) {
                x = fixed_point64::sub_fp(x, fixed_point64::from_u128(TWO_RAW));
                result = fixed_point64::mul_fp(result, fixed_point64::from_u128(EXP_2_RAW));
            };
            if (fixed_point64::to_u128(x) >= ONE_RAW) {
                x = fixed_point64::sub_fp(x, fixed_point64::from_u128(ONE_RAW));
                result = fixed_point64::mul_fp(result, fixed_point64::from_u128(EXP_1_RAW));
            };
            if (fixed_point64::to_u128(x) >= TWO_POW_NEG_1_RAW) {
                x = fixed_point64::sub_fp(x, fixed_point64::from_u128(TWO_POW_NEG_1_RAW));
                result = fixed_point64::mul_fp(result, fixed_point64::from_u128(EXP_1_OVER_2_RAW));
            };
            if (fixed_point64::to_u128(x) >= TWO_POW_NEG_2_RAW) {
                x = fixed_point64::sub_fp(x, fixed_point64::from_u128(TWO_POW_NEG_2_RAW));
                result = fixed_point64::mul_fp(result, fixed_point64::from_u128(EXP_1_OVER_4_RAW));
            };
            if (fixed_point64::to_u128(x) >= TWO_POW_NEG_3_RAW) {
                x = fixed_point64::sub_fp(x, fixed_point64::from_u128(TWO_POW_NEG_3_RAW));
                result = fixed_point64::mul_fp(result, fixed_point64::from_u128(EXP_1_OVER_8_RAW));
            };
            if (fixed_point64::to_u128(x) >= TWO_POW_NEG_4_RAW) {
                x = fixed_point64::sub_fp(x, fixed_point64::from_u128(TWO_POW_NEG_4_RAW));
                result = fixed_point64::mul_fp(result, fixed_point64::from_u128(EXP_1_OVER_16_RAW));
            };

            // now, x is in the range [0, e^{1/16})
            // if x is 0, we can directly return
            // otherwise, use Taylor series expansion for e^x: 1 + x + (x^2 / 2!) + (x^3 / 3!) + ... + (x^n / n!).

            if (fixed_point64::to_u128(x) != 0) {
                let term = x;
                let series_sum = fixed_point64::one();
                series_sum = fixed_point64::add_fp(series_sum, term);

                term = fixed_point64::div(fixed_point64::mul_fp(term, x), 2);
                series_sum = fixed_point64::add_fp(series_sum, term);

                term = fixed_point64::div(fixed_point64::mul_fp(term, x), 3);
                series_sum = fixed_point64::add_fp(series_sum, term);

                term = fixed_point64::div(fixed_point64::mul_fp(term, x), 4);
                series_sum = fixed_point64::add_fp(series_sum, term);

                term = fixed_point64::div(fixed_point64::mul_fp(term, x), 5);
                series_sum = fixed_point64::add_fp(series_sum, term);

                term = fixed_point64::div(fixed_point64::mul_fp(term, x), 6);
                series_sum = fixed_point64::add_fp(series_sum, term);

                term = fixed_point64::div(fixed_point64::mul_fp(term, x), 7);
                series_sum = fixed_point64::add_fp(series_sum, term);

                term = fixed_point64::div(fixed_point64::mul_fp(term, x), 8);
                series_sum = fixed_point64::add_fp(series_sum, term);

                result = fixed_point64::mul_fp(result, series_sum);
            };
        };
        result
    }

    public fun pow(x: FixedPoint64, y: FixedPoint64): FixedPoint64 {
        let result;
        if (fixed_point64::to_u128(y) == 0) {
            // We solve the 0^0 indetermination by making it equal to one.
            result = fixed_point64::one();
        } else if (fixed_point64::to_u128(x) == 0) {
            result = fixed_point64::zero();
        } else {
            // x^y = exp(y * ln(x))
            let (sign, ln_x) = ln(x);
            let y_times_ln_x = fixed_point64::mul_fp(y, ln_x);
            result = exp(sign, y_times_ln_x);
        };
        result
    }
}
