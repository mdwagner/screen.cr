# screen

Port of [screen](https://github.com/inancgumus/screen) package in Go, to provide an easy way to clear the screen or move the cursor in cross-platform way (Linux, Mac OS, Windows).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     screen:
       github: mdwagner/screen.cr
       version: "~> 0.2.0"
   ```

2. Run `shards install`

## Usage

```crystal
require "screen"

Screen.clear # Clear all the characters on the screen

Screen.move_top_left # Moves the cursor to the top-left position of the screen

Screen.cls # Performs both methods above (typical `cls` or `clear` terminal behavior)
```

## Contributing

1. Fork it (<https://github.com/mdwagner/screen/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Michael Wagner](https://github.com/mdwagner)
