import { readFile } from "fs/promises";
import { join } from "path";

const rootDirectory = join(__dirname, "../../..");

async function getMopsVersion(): Promise<string> {
  const mopsContent = await readFile(join(rootDirectory, "mops.toml"), "utf-8");
  const versionMatch = mopsContent.match(/version\s*=\s*"([^"]+)"/);
  if (!versionMatch) {
    throw new Error("Could not find package version in mops.toml");
  }
  return versionMatch[1];
}

async function getMocVersion(): Promise<string> {
  const mopsContent = await readFile(join(rootDirectory, "mops.toml"), "utf-8");
  const mocMatch = mopsContent.match(/moc\s*=\s*"([^"]+)"/);
  if (!mocMatch) {
    throw new Error("Could not find 'moc' version in mops.toml");
  }
  return mocMatch[1];
}

async function getReadmeVersions(): Promise<{
  newBase: string;
  base: string;
}> {
  const readmeContent = await readFile(
    join(rootDirectory, "README.md"),
    "utf-8"
  );
  const newBaseMatch = readmeContent.match(/new-base\s*=\s*"(\d+\.\d+\.\d+)"/);
  if (!newBaseMatch) {
    throw new Error("Could not find 'new-base' version in README.md");
  }
  const baseMatch = readmeContent.match(/base\s*=\s*"(\d+\.\d+\.\d+)"/);
  if (!baseMatch) {
    throw new Error("Could not find 'base' version in README.md");
  }
  return {
    newBase: newBaseMatch[1],
    base: baseMatch[1],
  };
}

async function main() {
  try {
    const [mopsVersion, mocVersion, readmeVersions] = await Promise.all([
      getMopsVersion(),
      getMocVersion(),
      getReadmeVersions(),
    ]);
    if (mopsVersion !== readmeVersions.newBase) {
      throw new Error(
        `Version mismatch: mops.toml version (${mopsVersion}) does not match 'new-base' version in README.md (${readmeVersions.newBase})`
      );
    }
    const baseVersionMajorMinor = readmeVersions.base
      .split(".")
      .slice(0, 2)
      .join(".");
    const mocVersionMajorMinor = mocVersion.split(".").slice(0, 2).join(".");
    if (baseVersionMajorMinor !== mocVersionMajorMinor) {
      throw new Error(
        `Version mismatch: 'base' version in README.md (${readmeVersions.base}) is not compatible with 'moc' toolchain version (${mocVersion})`
      );
    }
    console.log("✓ All version checks passed:");
    console.log(
      `  • mops.toml version (${mopsVersion}) matches 'new-base' version in README.md`
    );
    console.log(
      `  • 'base' version (${readmeVersions.base}) is compatible with 'moc' version (${mocVersion})`
    );
    process.exit(0);
  } catch (error) {
    console.error("✗ Version validation failed:");
    console.error(error.message);
    process.exit(1);
  }
}

main();
