import { existsSync, readdirSync, readFileSync, writeFileSync } from "fs";
import { join } from "path";

const rootDir = join(__dirname, "../../..");
const srcDir = join(rootDir, "src");
const validationDir = join(rootDir, "validation");
const apiDir = join(validationDir, "api");

interface Module {
  name: string;
  functions: Func[];
}

interface Func {
  name: string;
  declaration: string;
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
      const name = subPath.replace(/\.mo$/, "");
      const functions = parseFunctions(name, readFileSync(fullPath, "utf8"));
      moduleMap.set(name, { name, functions });
    }
  });
}

// Regex-based module function parser
function parseFunctions(moduleName: string, source: string) {
  const regex =
    /(public\s+(?:func|let|class)\s+(\w+)?([^{:=]+(?::\s*\{?[^{:=]*)*))\s*[{=]/g;
  const functions: Func[] = [];
  let match;
  while ((match = regex.exec(source)) !== null) {
    const [_, declaration, name, type] = match;
    const parsedDeclaration = declaration.replace(/\s+/g, " ").trim();
    if (
      !parsedDeclaration ||
      parsedDeclaration.endsWith(":") ||
      parsedDeclaration.endsWith("{")
    ) {
      throw new Error(
        `Validation regex was unable to correctly parse a declaration in ${moduleName}: ${parsedDeclaration}`
      );
    }
    functions.push({ name, declaration: parsedDeclaration });
  }
  functions.sort((a, b) => a.name.localeCompare(b.name));
  return functions;
}

if (!existsSync(srcDir)) {
  throw new Error(`Directory "${srcDir}" does not exist.`);
}

const errors: string[] = [];

// Read module files
readModules(srcDir);

// Read spec files
const specs: Spec[] = [];
const specMap = new Map<string, Spec>();
readdirSync(validationDir)
  .filter((file) => file.endsWith(".json"))
  .forEach((file) => {
    try {
      const content = JSON.parse(
        readFileSync(join(validationDir, file), "utf-8")
      );
      const items = content.specs;
      if (!Array.isArray(items)) {
        throw new Error(`Unexpected spec format`);
      }
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
      console.error(`Error while reading spec file: ${file}`);
      throw err;
    }
  });

// Update lockfile
writeFileSync(
  join(apiDir, "api.lock.json"),
  JSON.stringify(
    [...moduleMap.keys()].sort().map((key) => {
      const module = moduleMap.get(key);
      return {
        name: module.name,
        exports: module.functions.map((f) => f.declaration),
      };
    }),
    null,
    2
  ),
  "utf8"
);

// Validate spec files
const resolveSpec = (spec: Spec, functions: string[]) => {
  functions.push(
    ...spec.functions.filter((funcName) => !functions.includes(funcName))
  );
  spec.extends.forEach((extendName) => {
    const extend = specMap.get(extendName);
    if (!extend) {
      errors.push(
        `Unknown module: '${extendName}' (referenced in '${spec.name}')`
      );
      return;
    }
    resolveSpec(extend, functions);
  });
};
specs.forEach((spec) => {
  // Resolve inherited values
  const specFunctions: string[] = [];
  resolveSpec(spec, specFunctions);

  // Check module functions
  spec.modules.forEach((moduleName) => {
    const module = moduleMap.get(moduleName);
    if (!module) {
      errors.push(`Unknown module: '${moduleName}'`);
      return;
    }
    specFunctions.forEach((functionName) => {
      if (
        !module.functions.some((moduleFunc) => functionName == moduleFunc.name)
      ) {
        errors.push(`Missing function: ${module.name}.${functionName}()`);
      }
    });
  });
});

if (errors.length) {
  errors
    .filter((err, i) => !errors.slice(0, i).includes(err))
    .forEach((err) => {
      console.error(err);
    });
  process.exit(1);
}
