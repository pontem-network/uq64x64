## UQ64x64

Implements fixed point numbers in Move language using the Q number format.

Similar one used in [Uniswap](https://github.com/Uniswap/v2-core/blob/master/contracts/libraries/UQ112x112.sol) v2 core.

## Compile

    aptos move compile

## Test

    aptos move test

## Add as dependency

Add to `Move.toml`:

```toml
[dependencies.UQ64x64]
git = "https://github.com/pontem-network/UQ64x64.git"
rev = "v0.2.0"
```

And then use in code:

```move
use UQ64x64::UQ64x64;
...
let uq = encode(10);
```

## LICENSE

MIT.