import { Glob, $ } from "bun";
import { ZstdInit, ZstdStream } from "@oneidentity/zstd-js";

await ZstdInit();
await $`cargo build`;

const platformBinary =
	process.platform === "win32"
		? "./target/debug/rojo-script.exe"
		: "./target/debug/rojo-script";

const glob = new Glob("encoding/testRbxms/*.rbxm");
const fileExtensionRegex = /\.[^.]+$/;

for await (const file of glob.scan(".")) {
	const binFilePath = file.replace(fileExtensionRegex, ".bin");
	await $`${platformBinary} -f ${file} -o ${binFilePath}`;

	const encodedBytes = Buffer.from(
		ZstdStream.compress(await Bun.file(binFilePath).bytes(), 22),
		"utf8"
	).toString("base64");

	await Bun.write(
		file.replace(fileExtensionRegex, ".luau"),
		`return game:GetService("HttpService"):JSONDecode([[{"m":null,"t":"buffer","zbase64":"${encodedBytes}"}]]) :: buffer`
	);
}
