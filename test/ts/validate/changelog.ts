import { readFile } from "fs/promises";
import { join } from "path";

const rootDirectory = join(__dirname, "../../..");

async function getMopsVersion(): Promise<string> {
  const mopsContent = await readFile(
    join(rootDirectory, "/mops.toml"),
    "utf-8"
  );
  const versionMatch = mopsContent.match(/version\s*=\s*"([^"]+)"/);
  if (!versionMatch) {
    throw new Error("Could not find version in mops.toml");
  }
  return versionMatch[1];
}

async function getChangelogVersion(): Promise<string> {
  const changelogContent = await readFile(
    join(rootDirectory, "Changelog.md"),
    "utf-8"
  );
  const versionMatch = changelogContent.match(/##\s+(\d+\.\d+\.\d+)/);
  if (!versionMatch) {
    throw new Error("Could not find latest version in Changelog.md");
  }
  return versionMatch[1];
}

async function main() {
  try {
    const [mopsVersion, changelogVersion] = await Promise.all([
      getMopsVersion(),
      getChangelogVersion(),
    ]);

    if (mopsVersion !== changelogVersion) {
      throw new Error(
        `Version mismatch: mops.toml version (${mopsVersion}) does not match latest version in Changelog.md (${changelogVersion})`
      );
    }

    console.log("✓ Changelog version matches mops.toml version");
    process.exit(0);
  } catch (error) {
    console.error("✗ Changelog validation failed:");
    console.error(error.message);
    process.exit(1);
  }
}

main();
