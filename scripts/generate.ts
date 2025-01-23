import { Glob, $ } from "bun";

const glob = new Glob("encoding/testRbxms/*.rbxm");

// Scans the current working directory and each of its sub-directories recursively
for await (const file of glob.scan(".")) {
	await $`cargo run -- -f ${file} -o ${file.replace(
		".rbxm",
		".bin"
	)} -r lua-sandbox`.quiet();

	const encodedBytes = Buffer.from(
		await Bun.file(file.replace(".rbxm", ".bin")).arrayBuffer()
	).toString("base64");

	await Bun.write(
		file.replace(".rbxm", ".luau"),
		`return game:GetService("HttpService"):JSONDecode([[{"m":null,"t":"buffer","base64":"${encodedBytes}"}]]) :: buffer`
	);
}
