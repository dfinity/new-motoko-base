import { Principal } from "@dfinity/principal";
import chalk from "chalk";
import { existsSync, readdirSync, statSync } from "fs";
import { readFile } from "fs/promises";
import { glob } from "glob";
import motoko from "motoko";
import { join, relative } from "path";
import { PocketIc, PocketIcServer } from "@hadronous/pic";
import { dirname, basename } from "path";

interface TestResult {
  snippet: Snippet;
  status: "passed" | "failed" | "skipped";
  error?: any;
  time: number;
}

interface ExampleActor {
  example(): Promise<void>;
}

interface Snippet {
  path: string;
  index: number;
  language: string;
  config: string[];
  sourceCode: string;
}

const testStatusEmojis: Record<TestResult["status"], string> = {
  passed: "✅",
  failed: "❌",
  skipped: "🚫",
};

const rootDirectory = join(__dirname, "../../..");

async function main() {
  const testFilter = process.argv[2];

  const virtualBaseDirectory = "motoko-base";
  motoko.usePackage("base", join(virtualBaseDirectory, "src")); // Register `mo:base`

  const snippets: Snippet[] = (
    await Promise.all(
      (
        await glob(join(rootDirectory, "src/**/*.mo"))
      ).map(async (path, index) => {
        const virtualPath = relative(rootDirectory, path);

        // Write to virtual file system
        const content = await readFile(path, "utf8");
        motoko.write(join(virtualBaseDirectory, virtualPath), content);

        if (testFilter && !virtualPath.includes(testFilter)) {
          return [];
        }

        const docComments = [...content.matchAll(/^\s*\/\/\/ ?([^\n]+)*\s*$/gm)]
          .map((match) => match[1])
          .join("\n");

        const codeBlocks: {
          language: string | undefined;
          sourceCode: string;
          config: string[];
        }[] = [];

        for (const match of docComments.matchAll(
          /```(\S+)?(?:\s([^\n]+))?\n([\s\S]*?)```/g
        )) {
          const [_, language, config, sourceCode] = match;
          codeBlocks.push({
            language,
            config: config?.trim() ? config.trim().split(/\s+/) : [],
            sourceCode: sourceCode.trim(),
          });
        }

        const snippets: Snippet[] = [];
        for (const { language, config, sourceCode } of codeBlocks) {
          if (language === "motoko") {
            snippets.push({
              path: virtualPath,
              index,
              language,
              config,
              sourceCode,
            });
          } else {
            throw new Error(`Unexpected language for code block: ${language}`);
          }
        }
        return snippets;
      })
    )
  ).flatMap((snippets) => snippets);

  console.log(
    `Found ${snippets.length} code snippet${snippets.length === 1 ? "" : "s"}.`
  );
  if (snippets.length == 0) {
    process.exit(1);
  }

  // Start PocketIC
  const pocketIcServer = await PocketIcServer.start({
    showRuntimeLogs: false,
    showCanisterLogs: true,
  });
  const pocketIc = await PocketIc.create(pocketIcServer.getUrl());

  console.log("Creating canisters...");
  const sourcePrincipal = await pocketIc.createCanister();
  //   const testPrincipal = await pocketIc.createCanister();
  await pocketIc.updateCanisterSettings({
    canisterId: sourcePrincipal,
    controllers: [Principal.anonymous() /* , testPrincipal */],
  });

  console.log("Running snippets...");
  const testResults: TestResult[] = [];
  for (const snippet of snippets) {
    const startTime = Date.now();
    let status: TestResult["status"];
    let error;
    try {
      await runSnippet(snippet, pocketIc, sourcePrincipal);
      status = "passed";
    } catch (err) {
      error = err;
      status = "failed";
    }
    const result: TestResult = {
      snippet,
      status,
      error,
      time: Date.now() - startTime,
    };
    testResults.push(result);

    // Display test output
    console.log(
      testStatusEmojis[result.status],
      result.snippet.path,
      result.snippet.index,
      chalk.grey(`${(result.time / 1000).toFixed(1)}s`)
    );
    if (result.error) {
      console.error(chalk.red(result.error));
    }
  }

  await pocketIc.tearDown();
  await pocketIcServer.stop();

  // Exit code 1 for failed tests
  const hasError =
    !testResults.length ||
    testResults.some((result) => result.status === "failed");
  process.exit(hasError ? 1 : 0);
}

function extractVersionFromFilename(filePath: string): number | null {
  const pattern = /\.(\d+)\.test\.mo$/;
  const match = filePath.match(pattern);
  return match ? Number(match[1]) : null;
}

const runSnippet = async (
  snippet: Snippet,
  pocketIc: PocketIc,
  sourcePrincipal: Principal
) => {
  const tripleBacktick = "```";
  console.log(
    chalk.gray(
      `${tripleBacktick}${snippet.language || ""}${
        snippet.config.length ? ` ${snippet.config.join(" ")}` : ""
      }\n${snippet.sourceCode}\n${tripleBacktick}`
    )
  );

  // Set canister alias
  const sourceCanisterName = "snippet";
  motoko.setAliases(".", { [sourceCanisterName]: sourcePrincipal.toText() });

  // Write to virtual file system
  const virtualPath = join("snippet", `${snippet.path}${snippet.index}.mo`);
  motoko.write(virtualPath, snippet.sourceCode);

  // Compile source Wasm
  const sourceResult = motoko.wasm(virtualPath, "ic");
  motoko.write(`${sourcePrincipal.toText()}.did`, sourceResult.candid);

  // Compile test Wasm
  //   const testResult = motoko.wasm(`${snippet.file}.test.mo`, "ic");

  // Install Wasm files
  await pocketIc.reinstallCode({
    canisterId: sourcePrincipal,
    wasm: sourceResult.wasm,
  });

  // Call `example()` method
  const actor: ExampleActor = pocketIc.createActor(({ IDL }) => {
    return IDL.Service({
      example: IDL.Func([], []),
    });
  }, sourcePrincipal);
  await actor.example();
};

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
