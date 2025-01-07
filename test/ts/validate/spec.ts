import { existsSync, readdirSync, readFileSync } from "fs";
import { join } from "path";

const rootDir = join(__dirname, "../../..");
const srcDir = join(rootDir, "src");
const interfaceDir = join(rootDir, "interface");

interface Module {
  functions: Func[];
}

interface Func {
  name: string;
  type: string;
}

interface Spec {
  name: string;
  modules: string[];
  functions: string[];
  extends: string[];
}

const moduleMap = new Map<string, Module>();

function readModules(dir: string, subdir: string = "") {
  readdirSync(join(dir, subdir), { withFileTypes: true }).forEach((entry) => {
    const subPath = join(subdir, entry.name);
    const fullPath = join(dir, subPath);
    if (entry.isDirectory()) {
      readModules(dir, subPath);
    } else if (entry.isFile() && entry.name.endsWith(".mo")) {
      const name = entry.name.replace(/\.mo$/, "");
      const functions = parseFunctions(readFileSync(fullPath, "utf8"));
      moduleMap.set(subPath, { functions });
    }
  });
}

// Heuristic regex-based function parser
function parseFunctions(source: string) {
  const regex = /public\s+func\s+(\w+)([^{]+)\s*{/g;
  const functions: Func[] = [];
  let match;
  while ((match = regex.exec(source)) !== null) {
    const [_, name, type] = match;
    functions.push({ name, type: type.replace(/\s+/g, " ") });
  }
  return functions;
}

if (!existsSync(srcDir)) {
  throw new Error(`Directory "${srcDir}" does not exist.`);
}

let hasError = false;

// Module files
readModules(srcDir);

// Spec files
const specs: Spec[] = [];
const specMap = new Map<string, Spec>();
readdirSync(interfaceDir)
  .filter((file) => file.endsWith(".json"))
  .forEach((file) => {
    try {
      const content = JSON.parse(
        readFileSync(join(interfaceDir, file), "utf-8")
      );
      const items = Array.isArray(content) ? content : [content];
      specs.push(
        ...items.map((config: any, index: number) => {
          const name = config.name;
          if (!name) {
            throw new Error(`Unnamed spec with index ${index}`);
          }
          if (specMap.has(name)) {
            throw new Error(`Spec already exists with name: '${name}'`);
          }
          const spec = <Spec>{
            name,
            modules: config.modules || [],
            functions: config.functions || [],
            extends: config.extends || [],
          };
          specMap.set(name, spec);
          return spec;
        })
      );
    } catch (err) {
      hasError = true;
      console.error(`Error while reading spec file: ${file}`);
      // throw err;
    }

    // const content = readFileSync(join(interfaceDir, file), "utf-8");
    // const lines = content.split("\n");
    // let spec: Spec | undefined;
    // for (let line of lines) {
    //   // Skip comments and trim whitespace
    //   line = line.replace(/\/\/.*$/, "").trim();
    //   if (line === "") continue;
    //   if (line.startsWith(">")) {
    //     // Beginning of new spec
    //     spec = {
    //       names: line
    //         .substring(1)
    //         .split(",")
    //         .map((item) => item.trim()),
    //       functions: [],
    //     };
    //     specs.push(spec);
    //   } else {
    //     spec.functions.push(line.trim());
    //   }
    // }
  });

const extendSpec=(spec:Spec, extend:Spec)=>
{

}
specs.forEach((spec) => {
  const specModules=[...spec.modules];
  const specFunctions = [...spec.functions];
  spec.extends.forEach(extend=>extendSpec(spec,extend))
  specModules.forEach((moduleName) => {
    const module = moduleMap.get(moduleName);
    if (!module) {
      hasError = true;
      console.error(`Unknown module: ${module}`);
    }
    specFunctions.forEach((functionName) => {
      if (!module.functions.some((func) => func.name == functionName)) {
        hasError = true;
        console.error(
          `Module '${moduleName}' is missing function '${functionName}'`
        );
      }
    });
  });
});

if (hasError) {
  process.exit(1);
}
