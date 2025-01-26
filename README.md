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
# and replace output.bin with whatever you want the output to be
cargo run -- -f input.rbxm -o output.bin
```

##### Development notes

- roblox compresses chunks using lz4 and zstd
- below i used zstd level 22
- react-lua-17-rel.bin.zst = 266kb; react-lua-17-rel.rbxm is 553kb; (we won by 287kb)
- attributes_and_tags.bin.zst = 26kb; attributes_and_tags.rbxm = 15kb; (we lost by 11kb)
- only OpenSB and Roblox Studio are supported
