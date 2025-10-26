# Playdate Odin

Odin language bindings for the Playdate SDK.

## Requirements

- [Odin compiler](https://odin-lang.org/)
- [Playdate SDK 3.0.0](https://play.date/dev/)
- [Playdate SDK C Prerequisites](https://sdk.play.date/3.0.0/Inside%20Playdate%20with%20C.html#_prerequisites) (ARM toolchain for device builds)

Make sure you have these installed before proceeding.

## Quick Start

To try the example:
```bash
cd example
make simulator
```

This will build `Example.pdx` - open it with the Playdate Simulator to run the example game.

## Usage

Place this repository's `playdate` folder somewhere in your project. You can import it in your Odin code as:
```odin
import playdate "path/to/playdate"
```

You can use the files in the `example` folder as the basis for your game. Copy them into your project and configure:
- **`pdxinfo`** - Update with your game's name, author, description, and bundle ID
- **`Makefile`** - Update your product name (the name of the final `.pdx` app folder) and the path to `playdate/buildsupport/Makefile.inc`

Set the Playdate SDK path in your environment:
```bash
export PLAYDATE_SDK_PATH=/path/to/PlaydateSDK
```

Or alternatively, set it at the top of your `Makefile`:
```makefile
PLAYDATE_SDK_PATH=/path/to/PlaydateSDK
```

Build your game with one of these commands:
```bash
make simulator      # Build for simulator
make device         # Build for device
make clean          # Clean build files
```

The build will create a `.pdx` bundle in your project directory that you can run in the Playdate Simulator or upload to your device.

The `eventHandler` function you copied from the example is the entry point of your game. See the [Game Initialization guide](https://sdk.play.date/3.0.0/Inside%20Playdate%20with%20C.html#_game_initialization) for details on how it works.

For the complete API reference, see the [Playdate C API documentation](https://sdk.play.date/3.0.0/Inside%20Playdate%20with%20C.html#_api_reference). These Odin bindings directly mirror the C API, so the C documentation applies to the Odin code as well.

## Acknowledgements

The API bindings are generated using the awesome [odin-c-bindgen](https://github.com/karl-zylinski/odin-c-bindgen) by Karl Zylinski. 

