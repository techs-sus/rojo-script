# rojo-script

rojo-script is an EXPERIMENTAL piece of software designed to turn models into a singular lua file.

You may have seen this approach with m2s (model to script), or other converters.

This approach allows for bringing models into places where it would normally be impossible (e.g script builders)

## Running it

```bash
# pull the repo first obviously
git clone https://github.com/techs-sus/rojo-script
cd rojo-script

# replace input.rbxm with your input
# and replace output.lua with whatever you want the output to be
cargo run -- -f input.rbxm -o output.lua
```
