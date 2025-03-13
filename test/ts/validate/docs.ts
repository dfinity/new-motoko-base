import { Principal } from "@dfinity/principal";
import { PocketIc, PocketIcServer } from "@hadronous/pic";
import chalk from "chalk";
import { readFile } from "fs/promises";
import { glob } from "glob";
import motoko from "motoko";
import { join, relative } from "path";

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
  line: number;
  language: string;
  attrs: string[];
  name: string | undefined;
  includes: Snippet[];
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
      ).map(async (path) => {
        const virtualPath = relative(rootDirectory, path);

        // Write to virtual file system
        const content = await readFile(path, "utf8");
        motoko.write(join(virtualBaseDirectory, virtualPath), content);

        if (testFilter && !virtualPath.includes(testFilter)) {
          return [];
        }

        const docComments = content
          .split("\n")
          .map((line) => {
            // TODO: optimize or something
            const lineTrimmed = line.trimStart();
            return lineTrimmed.startsWith("///")
              ? lineTrimmed.startsWith("/// ")
                ? lineTrimmed.substring("/// ".length)
                : lineTrimmed.substring("///".length)
              : line;
          })
          .join("\n");

        const codeBlocks: {
          line: number;
          language: string | undefined;
          sourceCode: string;
          attrs: string[];
        }[] = [];

        const getLineNumber = (text: string, charIndex: number): number => {
          if (!text || charIndex < 0 || charIndex >= text.length) {
            return -1;
          }
          let line = 1;
          for (let i = 0; i < charIndex; i++) {
            if (text[i] === "\n") {
              line++;
            }
          }
          return line;
        };

        for (const match of docComments.matchAll(
          /```(\S+)?(?:\s([^\n]+))?\n([\s\S]*?)```/g
        )) {
          const [_, language, attrs, sourceCode] = match;
          codeBlocks.push({
            line: getLineNumber(docComments, match.index),
            language,
            attrs: attrs?.trim() ? attrs.trim().split(/\s+/) : [],
            sourceCode: sourceCode.trim(),
          });
        }

        const snippets: Snippet[] = [];
        const snippetMap = new Map<string, Snippet>();
        for (const { line, language, attrs, sourceCode } of codeBlocks) {
          const snippet: Snippet = {
            path: virtualPath,
            line,
            language,
            attrs,
            name: attrs
              .find((attr) => attr.startsWith("name="))
              ?.substring("name=".length),
            includes: [],
            sourceCode,
          };
          snippets.push(snippet);
          if (snippet.name) {
            if (snippetMap.has(snippet.name)) {
              throw new Error(
                `${snippet.path}: duplicate snippet name: ${snippet.name}`
              );
            }
            snippetMap.set(snippet.name, snippet);
          }
        }
        // Resolve "include=..." references
        for (const snippet of snippets) {
          for (const attr of snippet.attrs) {
            if (attr.startsWith("include=")) {
              const name = attr.substring("include=".length);
              const include = snippetMap.get(name);
              if (!include) {
                throw new Error(
                  `${snippet.path}: unresolved snippet attribute: ${attr}`
                );
              }
              snippet.includes.push(include);
            }
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
    if (snippet.language === "motoko") {
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
        testStatusEmojis[status],
        `${snippet.path}:${snippet.line}`,
        chalk.grey(`${(result.time / 1000).toFixed(1)}s`)
      );
      if (result.error) {
        console.error(chalk.red(result.error));
      }
    } else {
      console.log(
        testStatusEmojis["skipped"],
        `${snippet.path}:${snippet.line}`,
        chalk.grey("skipped")
      );
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

const runSnippet = async (
  snippet: Snippet,
  pocketIc: PocketIc,
  sourcePrincipal: Principal
) => {
  const tripleBacktick = "```";
  console.log(
    chalk.gray(
      `${tripleBacktick}${snippet.language || ""}${
        snippet.attrs.length ? ` ${snippet.attrs.join(" ")}` : ""
      }\n${snippet.sourceCode}\n${tripleBacktick}`
    )
  );

  // Set canister alias
  const sourceCanisterName = "snippet";
  motoko.setAliases(".", { [sourceCanisterName]: sourcePrincipal.toText() });

  const extractImports = (source: string) => {
    const importLines = [];
    const nonImportLines = [];
    let doneWithImports = false;
    for (const line of source.split("\n")) {
      // Basic import detection
      if (line.startsWith("import ")) {
        if (doneWithImports) {
          throw new Error("Unexpected import line");
        }
        importLines.push(line);
      } else {
        nonImportLines.push(line);
        const trimmedLine = line.trim();
        if (trimmedLine && !trimmedLine.startsWith("//")) {
          doneWithImports = true;
        }
      }
    }
    return [importLines.join("\n"), nonImportLines.join("\n")];
  };

  const snippetSource = [
    // Prepend source code included from other snippets
    ...snippet.includes.map((include) => include.sourceCode),
    snippet.sourceCode,
  ].join("\n");
  let actorSource = snippetSource;
  if (!actorSource.includes("actor {")) {
    // TODO: more sophisticated check
    const [imports, nonImports] = extractImports(snippetSource);
    actorSource = `${imports}\nactor { public func example() : async () { ignore do {\n${nonImports} } } }`;
  }

  // Write to virtual file system
  const virtualPath = join("snippet", `${snippet.path}_${snippet.line}.mo`);
  motoko.write(virtualPath, actorSource);

  // Compile source Wasm
  const sourceResult = motoko.wasm(virtualPath, "ic");
  motoko.write(`${sourcePrincipal.toText()}.did`, sourceResult.candid);

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
