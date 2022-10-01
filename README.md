## FixedPoint64

Implements fixed point numbers in Move language using the Q number format.

Use u128 as underlying data storage. 64 bits for fractional part.

Similar one used in [Uniswap](https://github.com/Uniswap/v2-core/blob/master/contracts/libraries/UQ112x112.sol) v2 core.

## Compile

    aptos move compile

## Test

    aptos move test

## Add as dependency

Add to `Move.toml`:

```toml
[dependencies.FixedPoint64]
git = "https://github.com/ThalaLabs/FixedPoint64.git"
rev = "<commit hash>"
```

And then use in code:

```move
use fixed_point64::fixed_point64;
...
let number = fixed_point64::encode(10);
```

## LICENSE

MIT.
