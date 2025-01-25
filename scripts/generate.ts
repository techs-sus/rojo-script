import { Glob, $ } from "bun";

await $`cargo build`;

const platformBinary =
	process.platform === "win32"
		? "./target/debug/rojo-script.exe"
		: "./target/debug/rojo-script";

const glob = new Glob("encoding/testRbxms/*.rbxm");

for await (const file of glob.scan(".")) {
	const binFilePath = (file as string).replace(".rbxm", ".bin");
	await $`${platformBinary} -f ${file} -o ${binFilePath} -r lua-sandbox`;

	const encodedBytes = Buffer.from(
		await Bun.file(binFilePath).arrayBuffer()
	).toString("base64");

	await Bun.write(
		file.replace(".rbxm", ".luau"),
		`return game:GetService("HttpService"):JSONDecode([[{"m":null,"t":"buffer","base64":"${encodedBytes}"}]]) :: buffer`
	);
}
