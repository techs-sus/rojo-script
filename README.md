# rojo-script

rojo-script is an **EXPERIMENTAL** piece of software designed to turn models into a singular lua file.

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

### Notes for end users

- NS will completely seperate the instanced script and that script will not be able to access it's parents.
- NLS does the same and does not have runtime

#### TODO list

lua-sandbox runtime:

- add modules to NLS (use fione + yueliang (possibly even a luau bytecode runner))

##### Development notes

- roblox compresses chunks using lz4 and zstd
- react-lua-17-rel.bin.zst = 266kb; react-lua-17-rel.rbxm is 553kb
