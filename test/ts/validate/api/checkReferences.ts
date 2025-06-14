// Detect "mo:core/..." imports within the core library itself (https://github.com/dfinity/motoko-base/pull/487)

import { join } from "path";
import { readFileSync } from "fs";
import glob from "fast-glob";

const srcDirectory = join(__dirname, "../../../../src");

const moFiles = glob.sync(join(srcDirectory, "**/*.mo"));
if (moFiles.length === 0) {
  throw new Error("Expected at least one Motoko file in `src` directory");
}
moFiles.forEach((srcPath) => {
  const source = readFileSync(srcPath, "utf8");
  source.split("\n").forEach((line, i) => {
    line = line.trim();
    if (
      line.includes('"mo:core') &&
      !line.startsWith("//") &&
      !line.endsWith("// ignore-reference-check")
    ) {
      console.error(
        `A possible reference to \`mo:core\` was found at ${srcPath}:${
          i + 1
        }\n\nIf this was intentional, consider adding an \`// ignore-reference-check\` comment to the end of the line.\nOtherwise, try removing the "mo:core/..." prefix in favor of a relative path.`
      );
      process.exit(1);
    }
  });
});
