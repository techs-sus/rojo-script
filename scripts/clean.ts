import { Glob } from "bun";

const glob = new Glob("encoding/testRbxms/*.{luau,bin}");

for await (const file of glob.scan(".")) {
	await Bun.file(file).delete();
}
