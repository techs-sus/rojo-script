import { $ } from "bun";

await $`rojo build -o place.rbxl ./place.project.json`.quiet();
await $`run-in-roblox --place place.rbxl --script ./scripts/run_tests.luau`;
