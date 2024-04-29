cd examples/fusion
rojo build --output ..\fusion.rbxm .\default.project.json
cd ../..
cargo run -- --file .\examples\fusion.rbxm --output .\examples\fusion.lua --runtime lua-sandbox

cd examples/react-lua
rojo build --output ..\react-lua.rbxm .\default.project.json
cd ../..
cargo run -- --file .\examples\react-lua.rbxm --output .\examples\react-lua.lua --runtime lua-sandbox

cd examples/roact
rojo build --output ..\roact.rbxm .\default.project.json
cd ../..
cargo run -- --file .\examples\roact.rbxm --output .\examples\roact.lua --runtime lua-sandbox

cargo run -- --file .\examples\test.rbxm --output .\examples\test.lua --runtime lua-sandbox

rm examples/fusion.rbxm
rm examples/react-lua.rbxm
rm examples/roact.rbxm
