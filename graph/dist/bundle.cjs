#!/usr/bin/env node
"use strict";
var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __commonJS = (cb, mod) => function __require() {
  return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));

// src/util.js
var require_util = __commonJS({
  "src/util.js"(exports2, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var { execSync } = require("child_process");
    var CYAN = "\x1B[36m";
    var GREEN = "\x1B[32m";
    var YELLOW = "\x1B[33m";
    var RED = "\x1B[31m";
    var NC = "\x1B[0m";
    var log2 = (msg) => console.log(`${CYAN}[graph]${NC} ${msg}`);
    var done2 = (msg) => console.log(`${GREEN}[done]${NC} ${msg}`);
    var warn2 = (msg) => console.error(`${YELLOW}[warn]${NC} ${msg}`);
    var die2 = (msg) => {
      console.error(`${RED}[error]${NC} ${msg}`);
      process.exit(1);
    };
    function parseArgs2(argv) {
      const args2 = { _: [] };
      for (let i = 0; i < argv.length; i++) {
        const a = argv[i];
        if (a.startsWith("--")) {
          const key = a.slice(2);
          const next = argv[i + 1];
          if (!next || next.startsWith("--")) {
            args2[key] = true;
          } else {
            if (args2[key] !== void 0) {
              args2[key] = [].concat(args2[key], next);
            } else {
              args2[key] = next;
            }
            i++;
          }
        } else {
          args2._.push(a);
        }
      }
      return args2;
    }
    var SKIP_ARTIFACT_DIRS = /* @__PURE__ */ new Set(["node_modules", "dist", "build", "out"]);
    function walkFiles(dir, extensions, excludeRes2 = [], root = null) {
      const resolveRoot = root || dir;
      const results = [];
      const extSet = new Set(extensions);
      function walk(current) {
        let entries;
        try {
          entries = fs2.readdirSync(current, { withFileTypes: true });
        } catch (_) {
          return;
        }
        for (const entry of entries) {
          if (entry.name.startsWith(".")) continue;
          const full = path2.join(current, entry.name);
          const rel = path2.relative(resolveRoot, full);
          if (entry.isSymbolicLink()) continue;
          if (entry.isDirectory()) {
            if (SKIP_ARTIFACT_DIRS.has(entry.name)) continue;
            if (shouldExclude(rel, excludeRes2)) continue;
            walk(full);
          } else if (entry.isFile()) {
            if (shouldExclude(rel, excludeRes2)) continue;
            if (extSet.size === 0 || extSet.has(path2.extname(entry.name))) {
              results.push(full);
            }
          }
        }
      }
      walk(dir);
      return results;
    }
    var ALL_SOURCE_EXTS = /* @__PURE__ */ new Set([
      ".go",
      ".py",
      ".ts",
      ".tsx",
      ".js",
      ".jsx",
      ".mjs",
      ".cjs",
      ".c",
      ".h",
      ".cc",
      ".cpp",
      ".cxx",
      ".hpp",
      ".hxx",
      ".h++",
      ".proto",
      ".java",
      ".rs",
      ".rb",
      ".swift",
      ".kt",
      ".cs",
      ".scala",
      ".php",
      ".lua"
    ]);
    function collectAllFiles2(repo, excludeRes2 = []) {
      const map = /* @__PURE__ */ new Map();
      const files = walkFiles(repo, [...ALL_SOURCE_EXTS], excludeRes2);
      for (const f of files) {
        const ext = path2.extname(f);
        if (!map.has(ext)) map.set(ext, []);
        map.get(ext).push(f);
      }
      return map;
    }
    function compileExcludes2(patterns) {
      return patterns.map((p) => {
        const escaped = p.replace(/[.+^${}()|[\]\\]/g, "\\$&").replace(/\*\*/g, "<<<GLOBSTAR>>>").replace(/\*/g, "[^/]*").replace(/<<<GLOBSTAR>>>/g, ".*");
        return new RegExp("^" + escaped + "$");
      });
    }
    function shouldExclude(filePath, excludeRes2) {
      const normalized = filePath.replace(/\\/g, "/");
      return excludeRes2.some((re) => re.test(normalized));
    }
    function fileSizeKB(filePath) {
      try {
        return Math.round(fs2.statSync(filePath).size / 1024);
      } catch (_) {
        return 0;
      }
    }
    function dirSizeKB(dirPath) {
      let total = 0;
      try {
        const files = walkFiles(dirPath, []);
        for (const f of files) total += fileSizeKB(f);
      } catch (_) {
      }
      return total;
    }
    function sanitizeRecord(obj) {
      if (typeof obj === "string") {
        return obj.replace(/\0/g, "").replace(/[\uD800-\uDFFF]/g, "").replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, "");
      }
      if (Array.isArray(obj)) return obj.map(sanitizeRecord);
      if (obj && typeof obj === "object") {
        const out = {};
        for (const [k, v] of Object.entries(obj)) {
          out[sanitizeRecord(k)] = sanitizeRecord(v);
        }
        return out;
      }
      return obj;
    }
    function writeJsonl(filePath, records) {
      let count = 0;
      const fd = fs2.openSync(filePath, "w");
      try {
        for (const r of records) {
          let line;
          try {
            line = JSON.stringify(r);
          } catch (_) {
            try {
              line = JSON.stringify(sanitizeRecord(r));
            } catch (_2) {
              continue;
            }
          }
          fs2.writeSync(fd, line + "\n");
          count++;
        }
      } finally {
        fs2.closeSync(fd);
      }
      return count;
    }
    var _treeSitterParser = void 0;
    async function initTreeSitter() {
      if (_treeSitterParser !== void 0) return _treeSitterParser || null;
      try {
        const Parser = require("web-tree-sitter");
        await Parser.init();
        _treeSitterParser = Parser;
        return Parser;
      } catch (_) {
        _treeSitterParser = false;
        return null;
      }
    }
    function countLines(filePath) {
      try {
        const buf = fs2.readFileSync(filePath);
        let count = 0;
        for (let i = 0; i < buf.length; i++) {
          if (buf[i] === 10) count++;
        }
        return count;
      } catch (_) {
        return 0;
      }
    }
    function countLinesFromContent(content) {
      if (!content) return 0;
      let count = 0;
      for (let i = 0; i < content.length; i++) {
        if (content.charCodeAt(i) === 10) count++;
      }
      return count;
    }
    function walkNodeEnterLeave(node, enter, leave) {
      const stack = [{ n: node, phase: 0 }];
      while (stack.length > 0) {
        const frame = stack.pop();
        if (frame.phase === 1) {
          leave(frame.n);
          continue;
        }
        stack.push({ n: frame.n, phase: 1 });
        enter(frame.n);
        for (let i = frame.n.childCount - 1; i >= 0; i--) {
          stack.push({ n: frame.n.child(i), phase: 0 });
        }
      }
    }
    var C_CPP_EXTS_LIST = [".c", ".h", ".cc", ".cpp", ".cxx", ".hpp", ".hxx", ".h++"];
    var _ctagsBinCache = null;
    var _ctagsChecked = false;
    function detectUniversalCtags() {
      if (_ctagsChecked) return _ctagsBinCache;
      _ctagsChecked = true;
      try {
        const ver = execSync("ctags --version 2>&1", { encoding: "utf8", stdio: ["pipe", "pipe", "pipe"] });
        if (/universal/i.test(ver)) {
          _ctagsBinCache = "ctags";
          return _ctagsBinCache;
        }
        return null;
      } catch (_) {
        return null;
      }
    }
    module2.exports = {
      log: log2,
      done: done2,
      warn: warn2,
      die: die2,
      parseArgs: parseArgs2,
      walkFiles,
      collectAllFiles: collectAllFiles2,
      compileExcludes: compileExcludes2,
      shouldExclude,
      fileSizeKB,
      dirSizeKB,
      writeJsonl,
      countLines,
      countLinesFromContent,
      initTreeSitter,
      walkNodeEnterLeave,
      C_CPP_EXTS_LIST,
      detectUniversalCtags
    };
  }
});

// src/extractor-includes.js
var require_extractor_includes = __commonJS({
  "src/extractor-includes.js"(exports2, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var { walkFiles, countLines, warn: warn2, C_CPP_EXTS_LIST } = require_util();
    function buildIncludeGraph2(repo, modules, excludeRes2 = [], preCollectedFiles = null) {
      const repoName = path2.basename(repo);
      const modulePaths = /* @__PURE__ */ new Map();
      for (const mod of modules) {
        modulePaths.set(mod.path, mod.name);
      }
      const allFiles = preCollectedFiles ? C_CPP_EXTS_LIST.flatMap((ext) => preCollectedFiles.get(ext) || []) : walkFiles(repo, C_CPP_EXTS_LIST, excludeRes2);
      const pathToId = /* @__PURE__ */ new Map();
      const nodes = [];
      for (const f of allFiles) {
        const rel = path2.relative(repo, f);
        const parts = rel.split(path2.sep);
        const module3 = parts.length > 1 ? parts[0] : "__root__";
        const ext = path2.extname(f);
        const kind = ext === ".h" || ext === ".hpp" || ext === ".hxx" ? "header" : "source";
        const lines = countLines(f);
        const node = {
          id: rel,
          module: module3,
          path: rel,
          file: path2.basename(f),
          kind,
          lines,
          ext: ext.slice(1)
        };
        nodes.push(node);
        pathToId.set(f, rel);
        pathToId.set(rel, rel);
      }
      const edges = [];
      const moduleEdgeMap = /* @__PURE__ */ new Map();
      const fileIndex = buildFileIndex(allFiles, repo);
      for (const f of allFiles) {
        const rel = path2.relative(repo, f);
        const parts = rel.split(path2.sep);
        const srcModule = parts.length > 1 ? parts[0] : "__root__";
        let content;
        try {
          content = fs2.readFileSync(f).toString("utf8").replace(/\0/g, "");
        } catch (_) {
          continue;
        }
        const lines = content.split("\n");
        for (const line of lines) {
          const trimmed = line.trimStart();
          if (!trimmed.startsWith("#include")) continue;
          const quotedMatch = trimmed.match(/^#include\s+"([^"]+)"/);
          if (!quotedMatch) continue;
          const includePath = quotedMatch[1];
          const targetRel = resolveInclude(includePath, f, repo, repoName, fileIndex, pathToId);
          if (!targetRel) continue;
          const targetParts = targetRel.split("/");
          const targetModule = targetParts.length > 1 ? targetParts[0] : "__root__";
          edges.push({
            source: rel,
            target: targetRel,
            type: "INCLUDES"
          });
          if (srcModule !== targetModule) {
            const key = `${srcModule}\u2192${targetModule}`;
            moduleEdgeMap.set(key, (moduleEdgeMap.get(key) || 0) + 1);
          }
        }
      }
      const moduleEdges = [];
      for (const [key, weight] of moduleEdgeMap.entries()) {
        const [source, target] = key.split("\u2192");
        moduleEdges.push({ source, target, type: "INCLUDES", weight });
      }
      moduleEdges.sort((a, b) => b.weight - a.weight);
      return { nodes, edges, moduleEdges };
    }
    function buildFileIndex(files, repo) {
      const index = /* @__PURE__ */ new Map();
      for (const f of files) {
        const rel = path2.relative(repo, f);
        const base = path2.basename(f);
        if (!index.has(base)) index.set(base, []);
        index.get(base).push(rel);
      }
      return index;
    }
    function resolveInclude(includePath, currentFile, repo, repoName, fileIndex, pathToId) {
      const inc = includePath.replace(/\\/g, "/");
      let candidate = inc;
      if (candidate.startsWith(repoName + "/")) {
        candidate = candidate.slice(repoName.length + 1);
      }
      if (pathToId.has(candidate)) {
        return candidate;
      }
      const currentDir = path2.dirname(currentFile);
      const abs2 = path2.resolve(currentDir, inc);
      if (pathToId.has(abs2)) {
        return path2.relative(repo, abs2).replace(/\\/g, "/");
      }
      const base = path2.basename(inc);
      const candidates = fileIndex.get(base);
      if (candidates && candidates.length === 1) {
        return candidates[0];
      }
      if (candidates && candidates.length > 1) {
        const scored = candidates.map((c) => ({
          rel: c,
          score: pathSimilarity(inc, c)
        }));
        scored.sort((a, b) => b.score - a.score);
        return scored[0].rel;
      }
      return null;
    }
    function pathSimilarity(a, b) {
      const aParts = a.split("/").reverse();
      const bParts = b.split("/").reverse();
      let score = 0;
      for (let i = 0; i < Math.min(aParts.length, bParts.length); i++) {
        if (aParts[i] === bParts[i]) score++;
        else break;
      }
      return score;
    }
    module2.exports = { buildIncludeGraph: buildIncludeGraph2 };
  }
});

// src/extractor-proto.js
var require_extractor_proto = __commonJS({
  "src/extractor-proto.js"(exports2, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var { walkFiles } = require_util();
    function buildProtoIndex2(repo, excludeRes2 = [], allFiles = null) {
      const protoFiles = allFiles ? allFiles.get(".proto") || [] : walkFiles(repo, [".proto"], excludeRes2);
      const services = [];
      const rpcs = [];
      const messages = [];
      const enums = [];
      for (const f of protoFiles) {
        const rel = path2.relative(repo, f);
        const parts = rel.split(path2.sep);
        const module3 = parts.length > 1 ? parts[0] : "__root__";
        let content;
        try {
          content = fs2.readFileSync(f).toString("utf8").replace(/\0/g, "");
        } catch (_) {
          continue;
        }
        parseProtoFile(content, rel, module3, services, rpcs, messages, enums);
      }
      return { services, rpcs, messages, enums };
    }
    function parseProtoFile(content, filePath, module3, services, rpcs, messages, enums) {
      const lines = content.split("\n");
      let currentService = null;
      let blockDepth = 0;
      let inService = false;
      let rpcBuffer = "";
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const trimmed = line.trim();
        if (trimmed.startsWith("//") || trimmed.startsWith("*")) continue;
        const strippedLine = line.replace(/\[[^\]]*\]/g, "").replace(/"(?:[^"\\]|\\.)*"/g, '""');
        const opens = (strippedLine.match(/{/g) || []).length;
        const closes = (strippedLine.match(/}/g) || []).length;
        const svcMatch = trimmed.match(/^service\s+(\w+)/);
        if (svcMatch) {
          currentService = svcMatch[1];
          inService = true;
          blockDepth = 1;
          services.push({
            name: currentService,
            file: filePath,
            module: module3,
            line: i + 1
          });
        }
        const msgMatch = trimmed.match(/^message\s+(\w+)/);
        if (msgMatch) {
          messages.push({
            name: msgMatch[1],
            file: filePath,
            module: module3,
            line: i + 1
          });
        }
        const enumMatch = trimmed.match(/^enum\s+(\w+)/);
        if (enumMatch) {
          enums.push({
            name: enumMatch[1],
            file: filePath,
            module: module3,
            line: i + 1
          });
        }
        if (inService) {
          if (trimmed.startsWith("rpc ") || rpcBuffer) {
            rpcBuffer += " " + trimmed;
            const rpcMatch = rpcBuffer.match(
              /rpc\s+(\w+)\s*\(\s*(?:stream\s+)?([\w.]+)\s*\)\s*returns\s*\(\s*(?:stream\s+)?([\w.]+)\s*\)/i
            );
            if (rpcMatch) {
              const streamReqRe = /rpc\s+\w+\s*\(\s*stream\s+[\w.]+\s*\)/i;
              const streamRespRe = /returns\s*\(\s*stream\s+[\w.]+\s*\)/i;
              rpcs.push({
                name: rpcMatch[1],
                request: rpcMatch[2],
                response: rpcMatch[3],
                streaming_request: streamReqRe.test(rpcBuffer),
                streaming_response: streamRespRe.test(rpcBuffer),
                service: currentService,
                file: filePath,
                module: module3,
                line: i + 1
              });
              rpcBuffer = "";
            } else if (rpcBuffer.length > 500) {
              rpcBuffer = "";
            }
          }
        }
        blockDepth += opens - closes;
        if (inService && blockDepth <= 0) {
          inService = false;
          currentService = null;
          blockDepth = 0;
          rpcBuffer = "";
        }
      }
    }
    module2.exports = { buildProtoIndex: buildProtoIndex2 };
  }
});

// src/extractor-go.js
var require_extractor_go = __commonJS({
  "src/extractor-go.js"(exports2, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var { walkFiles, countLinesFromContent, warn: warn2, initTreeSitter, walkNodeEnterLeave } = require_util();
    async function buildGoIndex2(repo, excludeRes2 = [], allFiles = null) {
      const goFiles = allFiles ? allFiles.get(".go") || [] : walkFiles(repo, [".go"], excludeRes2);
      const functions = [];
      const types = [];
      const imports = [];
      const calls = [];
      if (goFiles.length === 0) {
        return { functions, types, imports, calls };
      }
      const tsAvailable = await tryLoadTreeSitter();
      for (const f of goFiles) {
        const rel = path2.relative(repo, f);
        const parts = rel.split(path2.sep);
        const module3 = parts.length > 1 ? parts[0] : "__root__";
        let content;
        try {
          content = fs2.readFileSync(f).toString("utf8").replace(/\0/g, "");
        } catch (_) {
          continue;
        }
        const lines = countLinesFromContent(content);
        if (tsAvailable) {
          parseGoTreeSitter(content, rel, module3, lines, functions, types, imports, calls);
        } else {
          parseGoRegex(content, rel, module3, lines, functions, types, imports);
        }
      }
      return { functions, types, imports, calls };
    }
    function parseGoRegex(content, filePath, module3, totalLines, functions, types, imports) {
      const lines = content.split("\n");
      let pkg = "__unknown__";
      const pkgMatch = content.match(/^package\s+(\w+)/m);
      if (pkgMatch) pkg = pkgMatch[1];
      let inImportBlock = false;
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const trimmed = line.trim();
        const lineNo = i + 1;
        if (trimmed.startsWith("//") || trimmed === "*" || trimmed.startsWith("* ")) continue;
        const funcMatch = trimmed.match(
          /^func\s+(?:\([^)]*\)\s+)?(\w+)\s*\(/
        );
        if (funcMatch) {
          const receiverMatch = trimmed.match(/^func\s+\(([^)]*)\)\s+(\w+)/);
          const name = receiverMatch ? receiverMatch[2] : funcMatch[1];
          const receiver = receiverMatch ? receiverMatch[1].trim().replace(/^\*/, "").split(/\s+/).pop() : null;
          functions.push({
            name,
            receiver,
            qualified: receiver ? `${receiver}.${name}` : name,
            file: filePath,
            module: module3,
            package: pkg,
            line: lineNo,
            lines: totalLines
          });
          continue;
        }
        const typeMatch = trimmed.match(/^type\s+(\w+)\s+(struct|interface|=|\w)/);
        if (typeMatch) {
          const kind = typeMatch[2] === "struct" ? "struct" : typeMatch[2] === "interface" ? "interface" : typeMatch[2] === "=" ? "alias" : "type";
          types.push({
            name: typeMatch[1],
            kind,
            file: filePath,
            module: module3,
            package: pkg,
            line: lineNo
          });
          continue;
        }
        if (trimmed === "import (") {
          inImportBlock = true;
          continue;
        }
        if (inImportBlock && trimmed === ")") {
          inImportBlock = false;
          continue;
        }
        if (inImportBlock) {
          const importMatch = trimmed.match(/^(?:\w+\s+)?"([^"]+)"/);
          if (importMatch) {
            imports.push({
              path: importMatch[1],
              file: filePath,
              module: module3
            });
          }
          continue;
        }
        const singleImport = trimmed.match(/^import\s+(?:\w+\s+)?"([^"]+)"/);
        if (singleImport) {
          imports.push({
            path: singleImport[1],
            file: filePath,
            module: module3
          });
        }
      }
    }
    var _parser = null;
    async function tryLoadTreeSitter() {
      if (_parser !== null) return _parser !== false;
      try {
        const Parser = await initTreeSitter();
        if (!Parser) {
          _parser = false;
          return false;
        }
        let goWasm;
        try {
          const { getAssetAsBlob } = require("node:sea");
          goWasm = getAssetAsBlob("tree-sitter-go.wasm");
        } catch (_) {
          goWasm = require.resolve("tree-sitter-wasms/out/tree-sitter-go.wasm");
        }
        const GoLang = await Parser.Language.load(goWasm);
        const parser = new Parser();
        parser.setLanguage(GoLang);
        _parser = parser;
        return true;
      } catch (e) {
        warn2(`tree-sitter WASM unavailable, using regex for Go: ${e.message}`);
        _parser = false;
        return false;
      }
    }
    function parseGoTreeSitter(content, filePath, module3, totalLines, functions, types, imports, calls) {
      if (!_parser) {
        parseGoRegex(content, filePath, module3, totalLines, functions, types, imports);
        return;
      }
      try {
        const tree = _parser.parse(content);
        const root = tree.rootNode;
        let pkg = "__unknown__";
        const pkgNode = root.children.find((n) => n.type === "package_clause");
        if (pkgNode) {
          const pkgName = pkgNode.children.find((n) => n.type === "package_identifier");
          if (pkgName) pkg = pkgName.text;
        }
        walkNode(root, (node) => {
          switch (node.type) {
            case "function_declaration":
            case "method_declaration": {
              const nameNode = node.childForFieldName("name");
              const recvNode = node.childForFieldName("receiver");
              const name = nameNode ? nameNode.text : "__anon__";
              let receiver = null;
              if (recvNode) {
                const txt = recvNode.text.replace(/^\(|\)$/g, "").trim();
                const m = txt.match(/\*?(\w+)$/);
                if (m) receiver = m[1];
              }
              functions.push({
                name,
                receiver,
                qualified: receiver ? `${receiver}.${name}` : name,
                file: filePath,
                module: module3,
                package: pkg,
                line: node.startPosition.row + 1,
                lines: totalLines
              });
              break;
            }
            case "type_declaration": {
              const specs = node.children.filter((n) => n.type === "type_spec");
              for (const spec of specs) {
                const nameNode = spec.childForFieldName("name");
                const typeNode = spec.childForFieldName("type");
                if (!nameNode) continue;
                const isAlias = spec.children.some((n) => n.type === "=");
                const kind = isAlias ? "alias" : !typeNode ? "type" : typeNode.type === "struct_type" ? "struct" : typeNode.type === "interface_type" ? "interface" : "type";
                types.push({
                  name: nameNode.text,
                  kind,
                  file: filePath,
                  module: module3,
                  package: pkg,
                  line: spec.startPosition.row + 1
                });
              }
              break;
            }
            case "import_spec": {
              const pathNode = node.childForFieldName("path");
              if (pathNode) {
                imports.push({
                  path: pathNode.text.replace(/"/g, ""),
                  file: filePath,
                  module: module3
                });
              }
              break;
            }
          }
        });
        const funcStack = [];
        walkNodeEnterLeave(
          root,
          (node) => {
            if (node.type === "function_declaration" || node.type === "method_declaration") {
              const nameNode = node.childForFieldName("name");
              funcStack.push(nameNode ? nameNode.text : "__anon__");
            }
            if (node.type === "call_expression" && funcStack.length > 0) {
              const enclosing = funcStack[funcStack.length - 1];
              const funcNode = node.childForFieldName("function") || node.child(0);
              let callee = null;
              let confidence = "direct";
              if (funcNode) {
                if (funcNode.type === "identifier") {
                  callee = funcNode.text;
                } else if (funcNode.type === "selector_expression") {
                  const field = funcNode.childForFieldName("field");
                  if (field) {
                    callee = field.text;
                    confidence = "inferred";
                  }
                }
              }
              if (callee && callee !== enclosing) {
                calls.push({
                  kind: "go-call",
                  from: enclosing,
                  to: callee,
                  fromFile: filePath,
                  module: module3,
                  line: node.startPosition.row + 1,
                  resolved: false,
                  confidence
                });
              }
            }
          },
          (node) => {
            if (node.type === "function_declaration" || node.type === "method_declaration") {
              funcStack.pop();
            }
          }
        );
      } catch (e) {
        warn2(`tree-sitter parse failed for ${filePath}, falling back to regex: ${e.message}`);
        parseGoRegex(content, filePath, module3, totalLines, functions, types, imports);
      }
    }
    function walkNode(node, visitor) {
      const stack = [node];
      while (stack.length > 0) {
        const n = stack.pop();
        visitor(n);
        for (let i = n.childCount - 1; i >= 0; i--) stack.push(n.child(i));
      }
    }
    module2.exports = { buildGoIndex: buildGoIndex2 };
  }
});

// src/extractor-python.js
var require_extractor_python = __commonJS({
  "src/extractor-python.js"(exports2, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var { walkFiles, countLinesFromContent, warn: warn2, initTreeSitter, walkNodeEnterLeave } = require_util();
    async function buildPythonIndex2(repo, excludeRes2 = [], allFiles = null) {
      const pyFiles = allFiles ? allFiles.get(".py") || [] : walkFiles(repo, [".py"], excludeRes2);
      const functions = [];
      const classes = [];
      const imports = [];
      const calls = [];
      if (pyFiles.length === 0) return { functions, classes, imports, calls };
      const tsAvailable = await tryLoadTreeSitter();
      for (const f of pyFiles) {
        const rel = path2.relative(repo, f);
        const parts = rel.split(path2.sep);
        const module3 = parts.length > 1 ? parts[0] : "__root__";
        let content;
        try {
          content = fs2.readFileSync(f).toString("utf8").replace(/\0/g, "");
        } catch (_) {
          continue;
        }
        const lines = countLinesFromContent(content);
        if (tsAvailable) {
          parsePythonTreeSitter(content, rel, module3, lines, functions, classes, imports, calls);
        } else {
          parsePythonRegex(content, rel, module3, lines, functions, classes, imports);
        }
      }
      return { functions, classes, imports, calls };
    }
    var _parser = null;
    async function tryLoadTreeSitter() {
      if (_parser !== null) return _parser !== false;
      try {
        const Parser = await initTreeSitter();
        if (!Parser) {
          _parser = false;
          return false;
        }
        let pyWasm;
        try {
          const { getAssetAsBlob } = require("node:sea");
          pyWasm = getAssetAsBlob("tree-sitter-python.wasm");
        } catch (_) {
          pyWasm = require.resolve("tree-sitter-wasms/out/tree-sitter-python.wasm");
        }
        const PyLang = await Parser.Language.load(pyWasm);
        const parser = new Parser();
        parser.setLanguage(PyLang);
        _parser = parser;
        return true;
      } catch (e) {
        warn2(`tree-sitter WASM unavailable for Python, using regex: ${e.message}`);
        _parser = false;
        return false;
      }
    }
    function parsePythonTreeSitter(content, filePath, module3, totalLines, functions, classes, imports, calls) {
      try {
        const tree = _parser.parse(content);
        const root = tree.rootNode;
        const funcStack = [];
        const classStack = [];
        walkNodeEnterLeave(
          root,
          // enter
          (node) => {
            switch (node.type) {
              case "function_definition": {
                const nameNode = node.childForFieldName("name");
                const name = nameNode ? nameNode.text : "__anon__";
                const cls = classStack.length > 0 ? classStack[classStack.length - 1] : null;
                functions.push({
                  name,
                  receiver: cls,
                  file: filePath,
                  module: module3,
                  line: node.startPosition.row + 1,
                  lines: totalLines
                });
                funcStack.push(name);
                break;
              }
              case "class_definition": {
                const nameNode = node.childForFieldName("name");
                const name = nameNode ? nameNode.text : "__anon__";
                const argsNode = node.childForFieldName("superclasses") || node.children.find((c) => c.type === "argument_list");
                const bases = [];
                if (argsNode) {
                  for (const child of argsNode.children) {
                    if (child.type === "identifier" || child.type === "attribute") {
                      bases.push(child.text);
                    }
                  }
                }
                classes.push({
                  name,
                  bases,
                  file: filePath,
                  module: module3,
                  line: node.startPosition.row + 1
                });
                classStack.push(name);
                break;
              }
              case "import_statement": {
                for (const child of node.children) {
                  if (child.type === "dotted_name" || child.type === "identifier") {
                    imports.push({ path: child.text, file: filePath, module: module3 });
                  }
                }
                break;
              }
              case "import_from_statement": {
                const modNode = node.childForFieldName("module_name") || node.children.find((c) => c.type === "dotted_name" || c.type === "relative_import");
                if (modNode) {
                  imports.push({ path: modNode.text, file: filePath, module: module3 });
                }
                break;
              }
              case "call": {
                const enclosing = funcStack.length > 0 ? funcStack[funcStack.length - 1] : null;
                if (!enclosing) break;
                const funcNode = node.childForFieldName("function") || node.child(0);
                let callee = null;
                let confidence = "direct";
                if (funcNode) {
                  if (funcNode.type === "identifier") {
                    callee = funcNode.text;
                  } else if (funcNode.type === "attribute") {
                    const attr = funcNode.childForFieldName("attribute");
                    if (attr) {
                      callee = attr.text;
                      confidence = "inferred";
                    }
                  }
                }
                if (callee && callee !== enclosing && callee !== "self" && callee !== "super") {
                  calls.push({
                    kind: "py-call",
                    from: enclosing,
                    to: callee,
                    fromFile: filePath,
                    module: module3,
                    line: node.startPosition.row + 1,
                    resolved: false,
                    confidence
                  });
                }
                break;
              }
            }
          },
          // leave
          (node) => {
            if (node.type === "function_definition") funcStack.pop();
            if (node.type === "class_definition") classStack.pop();
          }
        );
      } catch (e) {
        warn2(`tree-sitter parse failed for ${filePath}, falling back to regex: ${e.message}`);
        parsePythonRegex(content, filePath, module3, totalLines, functions, classes, imports);
      }
    }
    function parsePythonRegex(content, filePath, module3, totalLines, functions, classes, imports) {
      const lines = content.split("\n");
      const classStack = [];
      const getCurrentClass = (lineIndent) => {
        while (classStack.length > 0 && lineIndent <= classStack[classStack.length - 1].indent) {
          classStack.pop();
        }
        return classStack.length > 0 ? classStack[classStack.length - 1].name : null;
      };
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const trimmed = line.trim();
        if (trimmed.startsWith("#") || trimmed === "") continue;
        const currentIndent = line.length - line.trimStart().length;
        const importMatch = trimmed.match(/^import\s+([\w.]+)/);
        if (importMatch) {
          imports.push({ path: importMatch[1], file: filePath, module: module3 });
          continue;
        }
        const fromImportMatch = trimmed.match(/^from\s+([\w.]+)\s+import/);
        if (fromImportMatch) {
          imports.push({ path: fromImportMatch[1], file: filePath, module: module3 });
          continue;
        }
        const classMatch = trimmed.match(/^class\s+(\w+)\s*(?:\(([^)]*)\))?\s*:/);
        if (classMatch) {
          getCurrentClass(currentIndent);
          classStack.push({ name: classMatch[1], indent: currentIndent });
          classes.push({
            name: classMatch[1],
            bases: classMatch[2] ? classMatch[2].split(",").map((b) => b.trim()) : [],
            file: filePath,
            module: module3,
            line: i + 1
          });
          continue;
        }
        const funcMatch = trimmed.match(/^def\s+(\w+)\s*\(/);
        if (funcMatch) {
          const currentClass = getCurrentClass(currentIndent);
          const isMethod = currentIndent > 0 && currentClass !== null;
          functions.push({
            name: funcMatch[1],
            receiver: isMethod ? currentClass : null,
            file: filePath,
            module: module3,
            line: i + 1,
            lines: totalLines
          });
        }
      }
    }
    module2.exports = { buildPythonIndex: buildPythonIndex2 };
  }
});

// src/extractor-ts.js
var require_extractor_ts = __commonJS({
  "src/extractor-ts.js"(exports2, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var { walkFiles, countLinesFromContent, warn: warn2, initTreeSitter, walkNodeEnterLeave } = require_util();
    var TS_EXTS = /* @__PURE__ */ new Set([".ts", ".js", ".mjs", ".cjs"]);
    var TSX_EXTS = /* @__PURE__ */ new Set([".tsx", ".jsx"]);
    var ALL_EXTS = [...TS_EXTS, ...TSX_EXTS];
    var TS_EXTS_LIST = [".ts", ".js", ".mjs", ".cjs"];
    var TSX_EXTS_LIST = [".tsx", ".jsx"];
    async function buildTsIndex2(repo, excludeRes2 = [], allFiles = null) {
      const tsFiles = allFiles ? [...TS_EXTS_LIST, ...TSX_EXTS_LIST].flatMap((ext) => allFiles.get(ext) || []) : walkFiles(repo, ALL_EXTS, excludeRes2);
      const functions = [];
      const classes = [];
      const imports = [];
      const calls = [];
      if (tsFiles.length === 0) return { functions, classes, imports, calls };
      await tryLoadParsers();
      for (const f of tsFiles) {
        const rel = path2.relative(repo, f);
        const parts = rel.split(path2.sep);
        const module3 = parts.length > 1 ? parts[0] : "__root__";
        const ext = path2.extname(f);
        let content;
        try {
          content = fs2.readFileSync(f).toString("utf8").replace(/\0/g, "");
        } catch (_) {
          continue;
        }
        const totalLines = countLinesFromContent(content);
        const useTsx = TSX_EXTS.has(ext);
        if (_parsers.ts || _parsers.tsx) {
          parseTsTreeSitter(content, rel, module3, totalLines, functions, classes, imports, calls, useTsx);
        } else {
          parseTsRegex(content, rel, module3, totalLines, functions, classes, imports);
        }
      }
      return { functions, classes, imports, calls };
    }
    var _parsers = { ts: null, tsx: null, attempted: false };
    async function tryLoadParsers() {
      if (_parsers.attempted) return;
      _parsers.attempted = true;
      const Parser = await initTreeSitter();
      if (!Parser) return;
      try {
        let wasm;
        try {
          const { getAssetAsBlob } = require("node:sea");
          wasm = getAssetAsBlob("tree-sitter-typescript.wasm");
        } catch (_) {
          wasm = require.resolve("tree-sitter-wasms/out/tree-sitter-typescript.wasm");
        }
        const lang = await Parser.Language.load(wasm);
        const p = new Parser();
        p.setLanguage(lang);
        _parsers.ts = p;
      } catch (e) {
        warn2(`tree-sitter TypeScript grammar unavailable: ${e.message}`);
      }
      try {
        let wasm;
        try {
          const { getAssetAsBlob } = require("node:sea");
          wasm = getAssetAsBlob("tree-sitter-tsx.wasm");
        } catch (_) {
          wasm = require.resolve("tree-sitter-wasms/out/tree-sitter-tsx.wasm");
        }
        const lang = await Parser.Language.load(wasm);
        const p = new Parser();
        p.setLanguage(lang);
        _parsers.tsx = p;
      } catch (e) {
        warn2(`tree-sitter TSX grammar unavailable: ${e.message}`);
      }
    }
    function parseTsTreeSitter(content, filePath, module3, totalLines, functions, classes, imports, calls, useTsx) {
      const parser = useTsx ? _parsers.tsx : _parsers.ts || _parsers.tsx;
      if (!parser) {
        parseTsRegex(content, filePath, module3, totalLines, functions, classes, imports);
        return;
      }
      try {
        const tree = parser.parse(content);
        const root = tree.rootNode;
        const funcStack = [];
        const classStack = [];
        let exportDepth = 0;
        walkNodeEnterLeave(
          root,
          // enter
          (node) => {
            switch (node.type) {
              case "export_statement":
                exportDepth++;
                break;
              case "function_declaration": {
                const nameNode = node.childForFieldName("name");
                const name = nameNode ? nameNode.text : "__anon__";
                const isAsync = !!node.children.find((c) => c.type === "async");
                functions.push({
                  name,
                  file: filePath,
                  module: module3,
                  line: node.startPosition.row + 1,
                  lines: totalLines,
                  exported: exportDepth > 0,
                  class: classStack.length > 0 ? classStack[classStack.length - 1] : null,
                  async: isAsync
                });
                funcStack.push(name);
                break;
              }
              case "method_definition": {
                const nameNode = node.childForFieldName("name");
                const name = nameNode ? nameNode.text : "__anon__";
                const isAsync = !!node.children.find((c) => c.type === "async");
                if (name !== "constructor") {
                  functions.push({
                    name,
                    file: filePath,
                    module: module3,
                    line: node.startPosition.row + 1,
                    lines: totalLines,
                    exported: false,
                    class: classStack.length > 0 ? classStack[classStack.length - 1] : null,
                    async: isAsync
                  });
                }
                funcStack.push(name);
                break;
              }
              case "variable_declarator": {
                const valueNode = node.childForFieldName("value");
                if (valueNode && (valueNode.type === "arrow_function" || valueNode.type === "function")) {
                  const nameNode = node.childForFieldName("name");
                  const name = nameNode ? nameNode.text : "__anon__";
                  const isAsync = !!valueNode.children.find((c) => c.type === "async");
                  functions.push({
                    name,
                    file: filePath,
                    module: module3,
                    line: node.startPosition.row + 1,
                    lines: totalLines,
                    exported: exportDepth > 0,
                    class: classStack.length > 0 ? classStack[classStack.length - 1] : null,
                    async: isAsync
                  });
                  funcStack.push(name);
                }
                break;
              }
              case "class_declaration": {
                const nameNode = node.childForFieldName("name");
                const name = nameNode ? nameNode.text : "__anon__";
                classStack.push(name);
                classes.push({
                  name,
                  file: filePath,
                  module: module3,
                  line: node.startPosition.row + 1,
                  lines: totalLines,
                  exported: exportDepth > 0,
                  kind: "class"
                });
                break;
              }
              case "interface_declaration": {
                const nameNode = node.childForFieldName("name");
                if (nameNode) {
                  classes.push({
                    name: nameNode.text,
                    file: filePath,
                    module: module3,
                    line: node.startPosition.row + 1,
                    lines: totalLines,
                    exported: exportDepth > 0,
                    kind: "interface"
                  });
                }
                break;
              }
              case "type_alias_declaration": {
                const nameNode = node.childForFieldName("name");
                if (nameNode) {
                  classes.push({
                    name: nameNode.text,
                    file: filePath,
                    module: module3,
                    line: node.startPosition.row + 1,
                    lines: totalLines,
                    exported: exportDepth > 0,
                    kind: "type"
                  });
                }
                break;
              }
              case "import_statement": {
                const sourceNode = node.children.find((c) => c.type === "string");
                const from = sourceNode ? sourceNode.text.replace(/['"]/g, "") : "";
                const names = [];
                for (const child of node.children) {
                  if (child.type === "import_clause") {
                    for (const ic of child.children) {
                      if (ic.type === "named_imports") {
                        for (const spec of ic.children) {
                          if (spec.type === "import_specifier") {
                            const n = spec.child(0);
                            if (n) names.push(n.text);
                          }
                        }
                      } else if (ic.type === "identifier") {
                        names.push(ic.text);
                      }
                    }
                  }
                }
                imports.push({ from, names, file: filePath, module: module3 });
                break;
              }
              case "call_expression": {
                const enclosing = funcStack.length > 0 ? funcStack[funcStack.length - 1] : null;
                if (!enclosing) break;
                const funcNode = node.child(0);
                let callee = null;
                let confidence = "direct";
                if (funcNode) {
                  if (funcNode.type === "identifier") {
                    callee = funcNode.text;
                  } else if (funcNode.type === "member_expression") {
                    const prop = funcNode.childForFieldName("property");
                    if (prop) {
                      callee = prop.text;
                      confidence = "inferred";
                    }
                  }
                }
                if (callee && callee !== enclosing) {
                  calls.push({
                    kind: "ts-call",
                    from: enclosing,
                    to: callee,
                    fromFile: filePath,
                    module: module3,
                    line: node.startPosition.row + 1,
                    resolved: false,
                    confidence
                  });
                }
                break;
              }
            }
          },
          // leave
          (node) => {
            switch (node.type) {
              case "export_statement":
                exportDepth--;
                break;
              case "function_declaration":
              case "method_definition":
                funcStack.pop();
                break;
              case "variable_declarator": {
                const valueNode = node.childForFieldName("value");
                if (valueNode && (valueNode.type === "arrow_function" || valueNode.type === "function")) {
                  funcStack.pop();
                }
                break;
              }
              case "class_declaration":
                classStack.pop();
                break;
            }
          }
        );
      } catch (e) {
        warn2(`tree-sitter parse failed for ${filePath}, falling back to regex: ${e.message}`);
        parseTsRegex(content, filePath, module3, totalLines, functions, classes, imports);
      }
    }
    function parseTsRegex(content, filePath, module3, totalLines, functions, classes, imports) {
      const lines = content.split("\n");
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const trimmed = line.trim();
        if (trimmed.startsWith("//") || trimmed === "") continue;
        const lineNo = i + 1;
        const importMatch = trimmed.match(/^import\s+(?:type\s+)?(?:.*?\s+from\s+)?['"]([^'"]+)['"]/);
        if (importMatch) {
          imports.push({ from: importMatch[1], names: [], file: filePath, module: module3 });
          continue;
        }
        const funcMatch = trimmed.match(/^(?:export\s+)?(?:async\s+)?function\s+(\w+)\s*[(<]/);
        if (funcMatch) {
          functions.push({
            name: funcMatch[1],
            file: filePath,
            module: module3,
            line: lineNo,
            lines: totalLines,
            exported: trimmed.startsWith("export"),
            class: null,
            async: trimmed.includes("async")
          });
          continue;
        }
        const arrowMatch = trimmed.match(/^(?:export\s+)?(?:const|let)\s+(\w+)\s*=\s*(?:async\s+)?(?:\(|function)/);
        if (arrowMatch) {
          functions.push({
            name: arrowMatch[1],
            file: filePath,
            module: module3,
            line: lineNo,
            lines: totalLines,
            exported: trimmed.startsWith("export"),
            class: null,
            async: trimmed.includes("async")
          });
          continue;
        }
        const classMatch = trimmed.match(/^(?:export\s+)?(?:abstract\s+)?class\s+(\w+)/);
        if (classMatch) {
          classes.push({
            name: classMatch[1],
            file: filePath,
            module: module3,
            line: lineNo,
            lines: totalLines,
            exported: trimmed.startsWith("export"),
            kind: "class"
          });
          continue;
        }
        const ifaceMatch = trimmed.match(/^(?:export\s+)?interface\s+(\w+)/);
        if (ifaceMatch) {
          classes.push({
            name: ifaceMatch[1],
            file: filePath,
            module: module3,
            line: lineNo,
            lines: totalLines,
            exported: trimmed.startsWith("export"),
            kind: "interface"
          });
          continue;
        }
        const typeMatch = trimmed.match(/^(?:export\s+)?type\s+(\w+)\s*[=<]/);
        if (typeMatch) {
          classes.push({
            name: typeMatch[1],
            file: filePath,
            module: module3,
            line: lineNo,
            lines: totalLines,
            exported: trimmed.startsWith("export"),
            kind: "type"
          });
        }
      }
    }
    module2.exports = { buildTsIndex: buildTsIndex2 };
  }
});

// src/extractor-c.js
var require_extractor_c = __commonJS({
  "src/extractor-c.js"(exports2, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var { spawnSync } = require("child_process");
    var {
      walkFiles,
      countLinesFromContent,
      warn: warn2,
      initTreeSitter,
      walkNodeEnterLeave,
      C_CPP_EXTS_LIST,
      detectUniversalCtags
    } = require_util();
    var CPP_EXTS = /* @__PURE__ */ new Set([".cc", ".cpp", ".cxx", ".hpp", ".hxx", ".h++"]);
    async function buildCIndex2(repo, excludeRes2 = [], allFiles = null) {
      const cFiles = allFiles ? C_CPP_EXTS_LIST.flatMap((ext) => allFiles.get(ext) || []) : walkFiles(repo, C_CPP_EXTS_LIST, excludeRes2);
      const functions = [];
      const types = [];
      const calls = [];
      if (cFiles.length === 0) return { functions, types, calls };
      await tryLoadParsers();
      const ctagsBin = detectUniversalCtags();
      for (const f of cFiles) {
        const rel = path2.relative(repo, f);
        const parts = rel.split(path2.sep);
        const module3 = parts.length > 1 ? parts[0] : "__root__";
        const ext = path2.extname(f).toLowerCase();
        let content;
        try {
          content = fs2.readFileSync(f).toString("utf8").replace(/\0/g, "");
        } catch (_) {
          continue;
        }
        const totalLines = countLinesFromContent(content);
        const isCpp = CPP_EXTS.has(ext) || ext === ".h" && /\bclass\s+\w+\s*[:{]/.test(content);
        if (isCpp && _parsers.cpp) {
          parseCTreeSitter(content, rel, module3, totalLines, functions, types, calls, _parsers.cpp, "cpp");
        } else if (!isCpp && _parsers.c) {
          parseCTreeSitter(content, rel, module3, totalLines, functions, types, calls, _parsers.c, "c");
        } else if (ctagsBin) {
          parseCCtags(ctagsBin, f, rel, module3, totalLines, functions, types);
        }
      }
      return { functions, types, calls };
    }
    var _parsers = { c: null, cpp: null, attempted: false };
    async function tryLoadParsers() {
      if (_parsers.attempted) return;
      _parsers.attempted = true;
      const Parser = await initTreeSitter();
      if (!Parser) return;
      try {
        let wasm;
        try {
          const { getAssetAsBlob } = require("node:sea");
          wasm = getAssetAsBlob("tree-sitter-c.wasm");
        } catch (_) {
          wasm = require.resolve("tree-sitter-wasms/out/tree-sitter-c.wasm");
        }
        const lang = await Parser.Language.load(wasm);
        const p = new Parser();
        p.setLanguage(lang);
        _parsers.c = p;
      } catch (e) {
        warn2(`tree-sitter C grammar unavailable: ${e.message}`);
      }
      try {
        let wasm;
        try {
          const { getAssetAsBlob } = require("node:sea");
          wasm = getAssetAsBlob("tree-sitter-cpp.wasm");
        } catch (_) {
          wasm = require.resolve("tree-sitter-wasms/out/tree-sitter-cpp.wasm");
        }
        const lang = await Parser.Language.load(wasm);
        const p = new Parser();
        p.setLanguage(lang);
        _parsers.cpp = p;
      } catch (e) {
        warn2(`tree-sitter C++ grammar unavailable: ${e.message}`);
      }
    }
    function parseCTreeSitter(content, filePath, module3, totalLines, functions, types, calls, parser, language) {
      try {
        const tree = parser.parse(content);
        const root = tree.rootNode;
        const funcStack = [];
        const nsStack = [];
        walkNodeEnterLeave(
          root,
          // enter
          (node) => {
            switch (node.type) {
              case "namespace_definition": {
                const nameNode = node.childForFieldName("name");
                nsStack.push(nameNode ? nameNode.text : null);
                break;
              }
              case "function_definition": {
                const name = extractFuncName(node);
                if (name) {
                  functions.push({
                    name,
                    file: filePath,
                    module: module3,
                    line: node.startPosition.row + 1,
                    lines: totalLines,
                    language,
                    namespace: nsStack.length > 0 ? nsStack[nsStack.length - 1] : null
                  });
                  funcStack.push(name);
                }
                break;
              }
              case "struct_specifier": {
                const nameNode = node.childForFieldName("name");
                if (nameNode && node.childForFieldName("body")) {
                  types.push({
                    name: nameNode.text,
                    file: filePath,
                    module: module3,
                    line: node.startPosition.row + 1,
                    kind: "struct",
                    language
                  });
                }
                break;
              }
              case "class_specifier": {
                const nameNode = node.childForFieldName("name");
                if (nameNode && node.childForFieldName("body")) {
                  types.push({
                    name: nameNode.text,
                    file: filePath,
                    module: module3,
                    line: node.startPosition.row + 1,
                    kind: "class",
                    language
                  });
                }
                break;
              }
              case "enum_specifier": {
                const nameNode = node.childForFieldName("name");
                if (nameNode && node.childForFieldName("body")) {
                  types.push({
                    name: nameNode.text,
                    file: filePath,
                    module: module3,
                    line: node.startPosition.row + 1,
                    kind: "enum",
                    language
                  });
                }
                break;
              }
              case "call_expression": {
                const enclosing = funcStack.length > 0 ? funcStack[funcStack.length - 1] : null;
                if (!enclosing) break;
                const funcNode = node.child(0);
                let callee = null;
                let confidence = "direct";
                if (funcNode) {
                  if (funcNode.type === "identifier") {
                    callee = funcNode.text;
                  } else if (funcNode.type === "field_expression") {
                    const field = funcNode.childForFieldName("field");
                    if (field) {
                      callee = field.text;
                      confidence = "inferred";
                    }
                  } else if (funcNode.type === "qualified_identifier") {
                    const last = funcNode.children[funcNode.childCount - 1];
                    if (last) callee = last.text;
                  }
                }
                if (callee && callee !== enclosing) {
                  calls.push({
                    kind: "c-call",
                    from: enclosing,
                    to: callee,
                    fromFile: filePath,
                    module: module3,
                    line: node.startPosition.row + 1,
                    resolved: false,
                    confidence
                  });
                }
                break;
              }
            }
          },
          // leave
          (node) => {
            if (node.type === "function_definition") funcStack.pop();
            if (node.type === "namespace_definition") nsStack.pop();
          }
        );
      } catch (e) {
        warn2(`tree-sitter C/C++ parse failed for ${filePath}: ${e.message}`);
      }
    }
    function extractFuncName(funcDefNode) {
      const declaratorNode = funcDefNode.childForFieldName("declarator");
      if (!declaratorNode) return null;
      return extractNameFromDeclarator(declaratorNode);
    }
    function extractNameFromDeclarator(node) {
      if (!node) return null;
      switch (node.type) {
        case "function_declarator": {
          const inner = node.childForFieldName("declarator");
          return extractNameFromDeclarator(inner);
        }
        case "pointer_declarator":
        case "reference_declarator":
        case "abstract_pointer_declarator": {
          for (let i = 0; i < node.childCount; i++) {
            const result = extractNameFromDeclarator(node.child(i));
            if (result) return result;
          }
          return null;
        }
        case "identifier":
        case "field_identifier":
          return node.text;
        case "qualified_identifier": {
          const last = node.children[node.childCount - 1];
          return last ? last.text : null;
        }
        case "destructor_name":
          return node.text;
        case "operator_name":
          return node.text;
        default:
          return null;
      }
    }
    function parseCCtags(ctagsBin, filePath, relPath, module3, totalLines, functions, types) {
      if (!ctagsBin) return;
      try {
        const result = spawnSync(
          ctagsBin,
          ["--output-format=json", "--fields=+n", "-f", "-", filePath],
          { encoding: "utf8", timeout: 1e4, maxBuffer: 2 * 1024 * 1024 }
        );
        if (result.error) throw result.error;
        const output = result.stdout || "";
        for (const line of output.split("\n")) {
          if (!line.trim() || line.startsWith("!_")) continue;
          try {
            const tag = JSON.parse(line);
            if (tag.kind === "function" || tag.kind === "f") {
              functions.push({
                name: tag.name,
                file: relPath,
                module: module3,
                line: tag.line || 1,
                lines: totalLines,
                language: tag.language ? tag.language.toLowerCase() : "c",
                namespace: tag.scope || null
              });
            } else if (tag.kind === "struct" || tag.kind === "s" || tag.kind === "class" || tag.kind === "c" || tag.kind === "enum" || tag.kind === "g") {
              types.push({
                name: tag.name,
                file: relPath,
                module: module3,
                line: tag.line || 1,
                kind: tag.kind === "class" || tag.kind === "c" ? "class" : tag.kind === "enum" || tag.kind === "g" ? "enum" : "struct",
                language: tag.language ? tag.language.toLowerCase() : "c"
              });
            }
          } catch (_) {
          }
        }
      } catch (_) {
      }
    }
    module2.exports = { buildCIndex: buildCIndex2 };
  }
});

// src/extractor-ctags.js
var require_extractor_ctags = __commonJS({
  "src/extractor-ctags.js"(exports2, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var { spawnSync } = require("child_process");
    var { walkFiles, countLines, warn: warn2, detectUniversalCtags } = require_util();
    var CTAGS_EXTS = /* @__PURE__ */ new Set([
      ".java",
      ".rs",
      ".rb",
      ".swift",
      ".kt",
      ".cs",
      ".scala",
      ".php",
      ".lua",
      ".r",
      ".m"
      // .m = Objective-C
    ]);
    function buildCtagsIndex2(repo, excludeRes2 = [], allFiles = null) {
      const bin = detectUniversalCtags();
      if (!bin) {
        warnIfCtagsNonUniversal();
        return { symbols: [] };
      }
      const files = allFiles ? [...CTAGS_EXTS].flatMap((ext) => allFiles.get(ext) || []) : walkFiles(repo, [...CTAGS_EXTS], excludeRes2);
      if (files.length === 0) return { symbols: [] };
      const symbols = [];
      const byModule = /* @__PURE__ */ new Map();
      for (const f of files) {
        const rel = path2.relative(repo, f);
        const parts = rel.split(path2.sep);
        const module3 = parts.length > 1 ? parts[0] : "__root__";
        if (!byModule.has(module3)) byModule.set(module3, []);
        byModule.get(module3).push({ f, rel });
      }
      for (const [module3, entries] of byModule) {
        const BATCH = 100;
        for (let i = 0; i < entries.length; i += BATCH) {
          const batch = entries.slice(i, i + BATCH);
          const batchByPath = /* @__PURE__ */ new Map();
          const linesCache = /* @__PURE__ */ new Map();
          for (const e of batch) {
            batchByPath.set(e.f, e);
            const resolved = path2.resolve(e.f);
            if (resolved !== e.f) batchByPath.set(resolved, e);
          }
          const ctagsArgs = ["--output-format=json", "--fields=+nKz", "-f", "-", ...batch.map((e) => e.f)];
          try {
            const result = spawnSync(
              bin,
              ctagsArgs,
              { encoding: "utf8", timeout: 3e4, maxBuffer: 10 * 1024 * 1024 }
            );
            if (result.error) throw result.error;
            const output = result.stdout || "";
            for (const line of output.split("\n")) {
              if (!line.trim() || line.startsWith("!_")) continue;
              try {
                const tag = JSON.parse(line);
                if (!isIndexableKind(tag.kind)) continue;
                const entryMatch = tag.path ? batchByPath.get(tag.path) : null;
                const relPath = entryMatch ? entryMatch.rel : path2.relative(repo, tag.path || "");
                let totalLines = 0;
                if (entryMatch) {
                  if (!linesCache.has(entryMatch.f)) linesCache.set(entryMatch.f, countLines(entryMatch.f));
                  totalLines = linesCache.get(entryMatch.f);
                }
                symbols.push({
                  name: tag.name,
                  file: relPath,
                  module: module3,
                  line: tag.line || 1,
                  lines: totalLines,
                  ctagsKind: normalizeCtagsKind(tag.kind),
                  language: tag.language ? tag.language.toLowerCase() : "unknown"
                });
              } catch (_) {
              }
            }
          } catch (e) {
            warn2(`ctags failed for module ${module3}: ${e.message}`);
          }
        }
      }
      return { symbols };
    }
    var _warnedNonUniversal = false;
    function warnIfCtagsNonUniversal() {
      if (_warnedNonUniversal) return;
      _warnedNonUniversal = true;
      try {
        const { execSync } = require("child_process");
        const ver = execSync("ctags --version 2>&1", { encoding: "utf8", stdio: ["pipe", "pipe", "pipe"] });
        if (!/universal/i.test(ver)) {
          warn2("ctags found but is not universal-ctags (no JSON support) \u2014 skipping ctags extraction");
        }
      } catch (_) {
      }
    }
    var INDEXABLE_KINDS = /* @__PURE__ */ new Set([
      "function",
      "method",
      "class",
      "interface",
      "enum",
      "struct",
      "trait",
      "f",
      "m",
      "c",
      "i",
      "g",
      "s",
      "t"
    ]);
    function isIndexableKind(kind) {
      if (!kind) return false;
      return INDEXABLE_KINDS.has(kind.toLowerCase());
    }
    function normalizeCtagsKind(kind) {
      if (!kind) return "unknown";
      const k = kind.toLowerCase();
      if (k === "function" || k === "f" || k === "method" || k === "m") return "function";
      if (k === "class" || k === "c") return "class";
      if (k === "interface" || k === "i") return "interface";
      if (k === "enum" || k === "g") return "enum";
      if (k === "struct" || k === "s") return "struct";
      if (k === "trait" || k === "t") return "trait";
      return k;
    }
    module2.exports = { buildCtagsIndex: buildCtagsIndex2 };
  }
});

// src/mermaid.js
var require_mermaid = __commonJS({
  "src/mermaid.js"(exports2, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var MAX_NODES_FULL = 30;
    var MAX_EDGES_FULL = 80;
    var DEFAULT_TOP_EDGES = 20;
    var WEIGHT_DIVISOR = 10;
    function loadJsonl(filePath) {
      if (!fs2.existsSync(filePath)) return [];
      return fs2.readFileSync(filePath, "utf8").split("\n").map((line) => line.replace(/\r$/, "")).filter(Boolean).map((line) => {
        try {
          return JSON.parse(line);
        } catch (_) {
          return null;
        }
      }).filter(Boolean);
    }
    function generateModuleDeps(graphDir, opts = {}) {
      const records = opts.records || loadJsonl(path2.join(graphDir, "module-graph.jsonl"));
      const nodes = records.filter((r) => r.kind === "node");
      const edges = records.filter((r) => r.kind === "edge").sort((a, b) => b.weight - a.weight);
      if (nodes.length === 0) {
        return { mermaid: "", filtered: false, stats: { nodes: 0, edges: 0 } };
      }
      const direction = opts.direction || "LR";
      let filtered = false;
      let visibleEdges = edges;
      if (nodes.length > MAX_NODES_FULL || edges.length > MAX_EDGES_FULL) {
        filtered = true;
        const maxWeight = edges.length > 0 ? edges[0].weight : 0;
        const autoMin = opts.minWeight || Math.max(1, Math.floor(maxWeight / WEIGHT_DIVISOR));
        const maxEdges = opts.maxEdges || DEFAULT_TOP_EDGES;
        visibleEdges = edges.filter((e) => e.weight >= autoMin).slice(0, maxEdges);
      }
      const referencedNodes = /* @__PURE__ */ new Set();
      for (const e of visibleEdges) {
        referencedNodes.add(e.source);
        referencedNodes.add(e.target);
      }
      const visibleNodes = filtered ? nodes.filter((n) => referencedNodes.has(n.id)) : nodes.filter((n) => referencedNodes.has(n.id) || edges.some((e) => e.source === n.id || e.target === n.id) || nodes.length <= MAX_NODES_FULL);
      const usedIds = /* @__PURE__ */ new Map();
      const nodeIdMap = /* @__PURE__ */ new Map();
      for (const n of visibleNodes) {
        const base = sanitizeId(n.id);
        if (usedIds.has(base)) {
          const count = usedIds.get(base) + 1;
          usedIds.set(base, count);
          nodeIdMap.set(n.id, `${base}_${count}`);
        } else {
          usedIds.set(base, 1);
          nodeIdMap.set(n.id, base);
        }
      }
      const nodeLabels = /* @__PURE__ */ new Map();
      for (const n of visibleNodes) {
        const safeId = nodeIdMap.get(n.id);
        const totalFiles = n.files ? n.files.total : 0;
        const label = totalFiles > 0 ? `${safeId}["${n.id}<br/>${totalFiles} files"]` : `${safeId}["${n.id}"]`;
        nodeLabels.set(n.id, label);
      }
      const cycleEdges = detectCycleEdges(nodes.map((n) => n.id), edges);
      const lines = [`graph ${direction}`];
      for (const [id, label] of nodeLabels) {
        lines.push(`    ${label}`);
      }
      for (const e of visibleEdges) {
        if (!referencedNodes.has(e.source) || !referencedNodes.has(e.target)) continue;
        const src = nodeIdMap.get(e.source) || sanitizeId(e.source);
        const tgt = nodeIdMap.get(e.target) || sanitizeId(e.target);
        const isCycle = cycleEdges.has(`${e.source}->${e.target}`);
        const arrow = isCycle ? "-.->" : "-->";
        lines.push(`    ${src} ${arrow}|${e.weight}| ${tgt}`);
      }
      const stats = {
        nodes: visibleNodes.length,
        edges: visibleEdges.length,
        totalNodes: nodes.length,
        totalEdges: edges.length
      };
      return { mermaid: lines.join("\n"), filtered, stats };
    }
    function generateProtoMap(graphDir, opts = {}) {
      const records = opts.records || loadJsonl(path2.join(graphDir, "proto-index.jsonl"));
      const services = records.filter((r) => r.kind === "service");
      const rpcs = records.filter((r) => r.kind === "rpc");
      if (services.length === 0) {
        return { mermaid: "", stats: { services: 0, rpcs: 0 } };
      }
      const rpcCounts = /* @__PURE__ */ new Map();
      for (const r of rpcs) {
        const key = `${r.module}::${r.service}`;
        rpcCounts.set(key, (rpcCounts.get(key) || 0) + 1);
      }
      const byModule = /* @__PURE__ */ new Map();
      for (const s of services) {
        const mod = s.module || "__root__";
        if (!byModule.has(mod)) byModule.set(mod, []);
        byModule.get(mod).push(s);
      }
      const usedSvcIds = /* @__PURE__ */ new Map();
      const svcNodeIdMap = /* @__PURE__ */ new Map();
      for (const [mod, svcList] of byModule) {
        for (const svc of svcList) {
          const base = sanitizeId(`${mod}_${svc.name}`);
          const mapKey = `${mod}::${svc.name}`;
          if (usedSvcIds.has(base)) {
            const cnt = usedSvcIds.get(base) + 1;
            usedSvcIds.set(base, cnt);
            svcNodeIdMap.set(mapKey, `${base}_${cnt}`);
          } else {
            usedSvcIds.set(base, 1);
            svcNodeIdMap.set(mapKey, base);
          }
        }
      }
      const usedModIds = /* @__PURE__ */ new Map();
      const modNodeIdMap = /* @__PURE__ */ new Map();
      for (const mod of byModule.keys()) {
        const base = sanitizeId(mod);
        if (usedModIds.has(base)) {
          const cnt = usedModIds.get(base) + 1;
          usedModIds.set(base, cnt);
          modNodeIdMap.set(mod, `${base}_${cnt}`);
        } else {
          usedModIds.set(base, 1);
          modNodeIdMap.set(mod, base);
        }
      }
      const lines = ["graph TD"];
      for (const [mod, svcList] of byModule) {
        const safeMod = modNodeIdMap.get(mod);
        lines.push(`    subgraph ${safeMod}["${mod}"]`);
        for (const svc of svcList) {
          const mapKey = `${mod}::${svc.name}`;
          const rpcKey = `${svc.module}::${svc.name}`;
          const count = rpcCounts.get(rpcKey) || 0;
          const nodeId = svcNodeIdMap.get(mapKey);
          lines.push(`        ${nodeId}["${svc.name}<br/>${count} RPCs"]`);
        }
        lines.push("    end");
      }
      const stats = {
        services: services.length,
        rpcs: rpcs.length,
        modules: byModule.size
      };
      return { mermaid: lines.join("\n"), stats };
    }
    function generateAllMermaid(graphDir) {
      const sections = [];
      const deps = generateModuleDeps(graphDir);
      if (deps.mermaid) {
        let header = "## Module Dependency Graph (auto-generated)";
        header += "\n\n<!-- AUTO-GENERATED by draft:init from draft/graph/module-graph.jsonl -->";
        if (deps.filtered) {
          header += `

> Showing top ${deps.stats.edges} edges by weight (${deps.stats.totalEdges} total). Dashed edges indicate cycles.`;
        } else if (deps.stats.edges > 0) {
          header += "\n\n> Dashed edges indicate circular dependencies.";
        }
        header += "\n\n```mermaid\n" + deps.mermaid + "\n```";
        sections.push(header);
      }
      const proto = generateProtoMap(graphDir);
      if (proto.mermaid) {
        let header = "## Proto Service Map (auto-generated)";
        header += "\n\n<!-- AUTO-GENERATED by draft:init from draft/graph/proto-index.jsonl -->";
        header += `

> ${proto.stats.services} proto services across ${proto.stats.modules} modules (${proto.stats.rpcs} RPCs total).`;
        header += "\n\n```mermaid\n" + proto.mermaid + "\n```";
        sections.push(header);
      }
      return sections.join("\n\n");
    }
    function sanitizeId(id) {
      return id.replace(/[^a-zA-Z0-9_]/g, "_");
    }
    function detectCycleEdges(nodeIds, edges) {
      const adj = /* @__PURE__ */ new Map();
      for (const n of nodeIds) adj.set(n, []);
      for (const e of edges) {
        if (adj.has(e.source)) adj.get(e.source).push(e.target);
      }
      const WHITE = 0, GRAY = 1, BLACK = 2;
      const color = new Map(nodeIds.map((n) => [n, WHITE]));
      const cycleNodes = /* @__PURE__ */ new Set();
      for (const startNode of nodeIds) {
        if (color.get(startNode) !== WHITE) continue;
        const stack = [[startNode, 0, [startNode]]];
        color.set(startNode, GRAY);
        while (stack.length > 0) {
          const frame = stack[stack.length - 1];
          const [node, , currentPath] = frame;
          const neighbors = adj.get(node) || [];
          if (frame[1] >= neighbors.length) {
            color.set(node, BLACK);
            stack.pop();
            continue;
          }
          const neighbor = neighbors[frame[1]++];
          if (color.get(neighbor) === GRAY) {
            const cycleStart = currentPath.indexOf(neighbor);
            for (const n of currentPath.slice(cycleStart)) {
              cycleNodes.add(n);
            }
            cycleNodes.add(neighbor);
          } else if (color.get(neighbor) === WHITE) {
            color.set(neighbor, GRAY);
            stack.push([neighbor, 0, [...currentPath, neighbor]]);
          }
        }
      }
      const cycleEdgeSet = /* @__PURE__ */ new Set();
      for (const e of edges) {
        if (cycleNodes.has(e.source) && cycleNodes.has(e.target)) {
          cycleEdgeSet.add(`${e.source}->${e.target}`);
        }
      }
      return cycleEdgeSet;
    }
    module2.exports = { generateModuleDeps, generateProtoMap, generateAllMermaid };
  }
});

// src/writer.js
var require_writer = __commonJS({
  "src/writer.js"(exports2, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var { writeJsonl, dirSizeKB } = require_util();
    var { generateModuleDeps, generateProtoMap } = require_mermaid();
    function writeGraph2({
      out,
      existingOut = out,
      repo,
      modules,
      includeGraph,
      protoIndex,
      goIndex = { functions: [], types: [], imports: [], calls: [] },
      pythonIndex = { functions: [], classes: [], imports: [], calls: [] },
      tsIndex = { functions: [], classes: [], imports: [], calls: [] },
      cIndex = { functions: [], types: [], calls: [] },
      ctagsIndex = { symbols: [] },
      skipModules = /* @__PURE__ */ new Set()
    }) {
      const modulesDir = path2.join(out, "modules");
      fs2.mkdirSync(modulesDir, { recursive: true });
      const moduleNodes = modules.map((m) => ({
        id: m.name,
        type: "module",
        sizeKB: m.sizeKB,
        files: m.files
      }));
      const moduleNames = new Set(modules.map((m) => m.name));
      const goModuleEdgeMap = /* @__PURE__ */ new Map();
      for (const imp of goIndex.imports) {
        const srcModule = imp.module;
        if (!srcModule) continue;
        const segments = imp.path.split("/");
        let matched = null;
        for (let len = segments.length; len >= 1; len--) {
          const candidate = segments.slice(segments.length - len).join("/");
          if (moduleNames.has(candidate)) {
            matched = candidate;
            break;
          }
        }
        if (!matched || matched === srcModule) continue;
        const key = `${srcModule}->${matched}`;
        goModuleEdgeMap.set(key, (goModuleEdgeMap.get(key) || 0) + 1);
      }
      const tsModuleEdgeMap = /* @__PURE__ */ new Map();
      for (const imp of tsIndex.imports || []) {
        const srcModule = imp.module;
        if (!srcModule || !imp.from) continue;
        let importPath = imp.from;
        if (importPath.startsWith("./") || importPath.startsWith("../")) {
          const baseDir = imp.file ? path2.posix.dirname(imp.file.split(path2.sep).join("/")) : srcModule;
          importPath = path2.posix.normalize(path2.posix.join(baseDir, importPath));
        }
        const segments = importPath.split("/").filter((s) => s && s !== ".");
        let matched = null;
        for (let len = segments.length; len >= 1; len--) {
          const candidate = segments.slice(0, len).join("/");
          if (moduleNames.has(candidate)) {
            matched = candidate;
            break;
          }
        }
        if (!matched || matched === srcModule) continue;
        const key = `${srcModule}->${matched}`;
        tsModuleEdgeMap.set(key, (tsModuleEdgeMap.get(key) || 0) + 1);
      }
      const mergedEdgeMap = /* @__PURE__ */ new Map();
      for (const e of includeGraph.moduleEdges) {
        const key = `${e.source}->${e.target}`;
        mergedEdgeMap.set(key, { source: e.source, target: e.target, weight: (mergedEdgeMap.get(key)?.weight || 0) + e.weight });
      }
      for (const [key, weight] of goModuleEdgeMap) {
        const [source, target] = key.split("->");
        if (mergedEdgeMap.has(key)) {
          mergedEdgeMap.get(key).weight += weight;
        } else {
          mergedEdgeMap.set(key, { source, target, weight });
        }
      }
      for (const [key, weight] of tsModuleEdgeMap) {
        const [source, target] = key.split("->");
        if (mergedEdgeMap.has(key)) {
          mergedEdgeMap.get(key).weight += weight;
        } else {
          mergedEdgeMap.set(key, { source, target, weight });
        }
      }
      const allModuleEdges = Array.from(mergedEdgeMap.values());
      const moduleGraphRecords = [
        ...moduleNodes.map((n) => ({ kind: "node", ...n })),
        ...allModuleEdges.map((e) => ({ kind: "edge", ...e }))
      ];
      writeJsonl(path2.join(out, "module-graph.jsonl"), moduleGraphRecords);
      const protoRecords = [
        ...protoIndex.services.map((s) => ({ kind: "service", ...s })),
        ...protoIndex.rpcs.map((r) => ({ kind: "rpc", ...r })),
        ...protoIndex.messages.map((m) => ({ kind: "message", ...m })),
        ...protoIndex.enums.map((e) => ({ kind: "enum", ...e }))
      ];
      writeJsonl(path2.join(out, "proto-index.jsonl"), protoRecords);
      const fanInMap = buildFanInMap(includeGraph.edges);
      const goFileMap = /* @__PURE__ */ new Map();
      for (const fn of goIndex.functions) {
        const entry = goFileMap.get(fn.file) || { lines: 0, module: fn.module };
        entry.lines = Math.max(entry.lines, fn.lines || 0);
        goFileMap.set(fn.file, entry);
      }
      const pyFileMap = /* @__PURE__ */ new Map();
      for (const fn of pythonIndex.functions) {
        const entry = pyFileMap.get(fn.file) || { lines: 0, module: fn.module };
        entry.lines = Math.max(entry.lines, fn.lines || 0);
        pyFileMap.set(fn.file, entry);
      }
      for (const cls of pythonIndex.classes) {
        if (!pyFileMap.has(cls.file)) pyFileMap.set(cls.file, { lines: 0, module: cls.module });
      }
      const tsFileMap = /* @__PURE__ */ new Map();
      for (const fn of tsIndex.functions) {
        const entry = tsFileMap.get(fn.file) || { lines: 0, module: fn.module };
        entry.lines = Math.max(entry.lines, fn.lines || 0);
        tsFileMap.set(fn.file, entry);
      }
      for (const cls of tsIndex.classes) {
        if (!tsFileMap.has(cls.file)) tsFileMap.set(cls.file, { lines: 0, module: cls.module });
      }
      const cFileMap = /* @__PURE__ */ new Map();
      for (const fn of cIndex.functions) {
        const entry = cFileMap.get(fn.file) || { lines: 0, module: fn.module };
        entry.lines = Math.max(entry.lines, fn.lines || 0);
        cFileMap.set(fn.file, entry);
      }
      for (const t of cIndex.types) {
        if (!cFileMap.has(t.file)) cFileMap.set(t.file, { lines: 0, module: t.module });
      }
      const syntheticGoNodes = Array.from(goFileMap.entries()).map(([file, { lines, module: module3 }]) => ({ id: file, lines, module: module3, fanIn: 0 }));
      const syntheticPyNodes = Array.from(pyFileMap.entries()).map(([file, { lines, module: module3 }]) => ({ id: file, lines, module: module3, fanIn: 0 }));
      const syntheticTsNodes = Array.from(tsFileMap.entries()).map(([file, { lines, module: module3 }]) => ({ id: file, lines, module: module3, fanIn: 0 }));
      const syntheticCNodes = Array.from(cFileMap.entries()).map(([file, { lines, module: module3 }]) => ({ id: file, lines, module: module3, fanIn: 0 }));
      const allFileNodes = [
        ...includeGraph.nodes,
        ...syntheticGoNodes,
        ...syntheticPyNodes,
        ...syntheticTsNodes,
        ...syntheticCNodes
      ];
      const hotspots = allFileNodes.map((n) => ({
        ...n,
        fanIn: fanInMap.get(n.id) || 0,
        score: n.lines + (fanInMap.get(n.id) || 0) * 50
      })).sort((a, b) => b.score - a.score).slice(0, 50).map(({ score, ...rest }) => ({ kind: "hotspot", ...rest }));
      writeJsonl(path2.join(out, "hotspots.jsonl"), hotspots);
      if (goIndex.functions.length > 0 || goIndex.types.length > 0) {
        const goRecords = [
          ...goIndex.functions.map((f) => ({ kind: "func", ...f })),
          ...goIndex.types.map((t) => ({ kind: "type", ...t })),
          ...goIndex.imports.map((i) => ({ kind: "import", ...i })),
          ...goIndex.calls.map((c) => ({ ...c }))
        ];
        writeJsonl(path2.join(out, "go-index.jsonl"), goRecords);
      }
      if (pythonIndex.functions.length > 0 || pythonIndex.classes.length > 0) {
        const pyRecords = [
          ...pythonIndex.functions.map((f) => ({ kind: "func", ...f })),
          ...pythonIndex.classes.map((c) => ({ kind: "class", ...c })),
          ...pythonIndex.imports.map((i) => ({ kind: "import", ...i })),
          ...pythonIndex.calls.map((c) => ({ ...c }))
        ];
        writeJsonl(path2.join(out, "python-index.jsonl"), pyRecords);
      }
      if (tsIndex.functions.length > 0 || tsIndex.classes.length > 0) {
        const tsRecords = [
          ...tsIndex.functions.map((f) => ({ kind: "ts-func", ...f })),
          ...tsIndex.classes.map((c) => ({ kind: "ts-class", ...c })),
          ...(tsIndex.imports || []).map((i) => ({ kind: "ts-import", ...i })),
          ...tsIndex.calls.map((c) => ({ ...c }))
        ];
        writeJsonl(path2.join(out, "ts-index.jsonl"), tsRecords);
      }
      if (cIndex.functions.length > 0 || cIndex.types.length > 0) {
        const cRecords = [
          ...cIndex.functions.map((f) => ({ kind: "c-func", ...f })),
          ...cIndex.types.map((t) => ({ kind: "c-type", ...t })),
          ...cIndex.calls.map((c) => ({ ...c }))
        ];
        writeJsonl(path2.join(out, "c-index.jsonl"), cRecords);
      }
      const allCalls = [
        ...goIndex.calls,
        ...pythonIndex.calls,
        ...tsIndex.calls,
        ...cIndex.calls
      ];
      if (allCalls.length > 0) {
        writeJsonl(path2.join(out, "call-index.jsonl"), allCalls);
      }
      const edgesByModule = /* @__PURE__ */ new Map();
      for (const edge of includeGraph.edges) {
        const srcParts = edge.source.split("/");
        const mod = srcParts.length > 1 ? srcParts[0] : "__root__";
        if (!edgesByModule.has(mod)) edgesByModule.set(mod, []);
        edgesByModule.get(mod).push(edge);
      }
      const goByModule = /* @__PURE__ */ new Map();
      for (const fn of goIndex.functions) {
        if (!goByModule.has(fn.module)) goByModule.set(fn.module, { functions: [], types: [], calls: [] });
        goByModule.get(fn.module).functions.push(fn);
      }
      for (const t of goIndex.types) {
        if (!goByModule.has(t.module)) goByModule.set(t.module, { functions: [], types: [], calls: [] });
        goByModule.get(t.module).types.push(t);
      }
      for (const c of goIndex.calls) {
        if (!goByModule.has(c.module)) goByModule.set(c.module, { functions: [], types: [], calls: [] });
        goByModule.get(c.module).calls.push(c);
      }
      const pyByModule = /* @__PURE__ */ new Map();
      for (const fn of pythonIndex.functions) {
        if (!pyByModule.has(fn.module)) pyByModule.set(fn.module, { functions: [], classes: [], calls: [] });
        pyByModule.get(fn.module).functions.push(fn);
      }
      for (const c of pythonIndex.classes) {
        if (!pyByModule.has(c.module)) pyByModule.set(c.module, { functions: [], classes: [], calls: [] });
        pyByModule.get(c.module).classes.push(c);
      }
      for (const c of pythonIndex.calls) {
        if (!pyByModule.has(c.module)) pyByModule.set(c.module, { functions: [], classes: [], calls: [] });
        pyByModule.get(c.module).calls.push(c);
      }
      const tsByModule = /* @__PURE__ */ new Map();
      for (const fn of tsIndex.functions) {
        if (!tsByModule.has(fn.module)) tsByModule.set(fn.module, { functions: [], classes: [], calls: [] });
        tsByModule.get(fn.module).functions.push(fn);
      }
      for (const c of tsIndex.classes) {
        if (!tsByModule.has(c.module)) tsByModule.set(c.module, { functions: [], classes: [], calls: [] });
        tsByModule.get(c.module).classes.push(c);
      }
      for (const c of tsIndex.calls) {
        if (!tsByModule.has(c.module)) tsByModule.set(c.module, { functions: [], classes: [], calls: [] });
        tsByModule.get(c.module).calls.push(c);
      }
      const cByModule = /* @__PURE__ */ new Map();
      for (const fn of cIndex.functions) {
        if (!cByModule.has(fn.module)) cByModule.set(fn.module, { functions: [], types: [], calls: [] });
        cByModule.get(fn.module).functions.push(fn);
      }
      for (const t of cIndex.types) {
        if (!cByModule.has(t.module)) cByModule.set(t.module, { functions: [], types: [], calls: [] });
        cByModule.get(t.module).types.push(t);
      }
      for (const c of cIndex.calls) {
        if (!cByModule.has(c.module)) cByModule.set(c.module, { functions: [], types: [], calls: [] });
        cByModule.get(c.module).calls.push(c);
      }
      const ctagsByModule = /* @__PURE__ */ new Map();
      for (const sym of ctagsIndex.symbols) {
        if (!ctagsByModule.has(sym.module)) ctagsByModule.set(sym.module, []);
        ctagsByModule.get(sym.module).push(sym);
      }
      let moduleFilesCount = 0;
      for (const mod of modules) {
        if (skipModules.has(mod.name)) {
          const srcPath = path2.join(existingOut, "modules", `${mod.name}.jsonl`);
          const destPath = path2.join(modulesDir, `${mod.name}.jsonl`);
          if (fs2.existsSync(srcPath)) {
            fs2.copyFileSync(srcPath, destPath);
            moduleFilesCount++;
            continue;
          }
        }
        const modNodes = includeGraph.nodes.filter((n) => n.module === mod.name);
        const modEdges = edgesByModule.get(mod.name) || [];
        const goData = goByModule.get(mod.name) || { functions: [], types: [], calls: [] };
        const pyData = pyByModule.get(mod.name) || { functions: [], classes: [], calls: [] };
        const tsData = tsByModule.get(mod.name) || { functions: [], classes: [], calls: [] };
        const cData = cByModule.get(mod.name) || { functions: [], types: [], calls: [] };
        const ctagsSym = ctagsByModule.get(mod.name) || [];
        const modNodeIds = new Set(modNodes.map((n) => n.id));
        const intraEdges = modEdges.filter((e) => modNodeIds.has(e.target));
        const crossEdges = modEdges.filter((e) => !modNodeIds.has(e.target));
        const records = [
          { kind: "module", name: mod.name, sizeKB: mod.sizeKB, files: mod.files },
          ...modNodes.map((n) => ({ kind: "file", ...n })),
          ...intraEdges.map((e) => ({ kind: "include", ...e })),
          ...crossEdges.map((e) => ({ kind: "cross-include", ...e })),
          // Go
          ...goData.functions.map((f) => ({ kind: "go-func", ...f })),
          ...goData.types.map((t) => ({ kind: "go-type", ...t })),
          ...goData.calls.map((c) => ({ ...c })),
          // Python
          ...pyData.functions.map((f) => ({ kind: "py-func", ...f })),
          ...pyData.classes.map((c) => ({ kind: "py-class", ...c })),
          ...pyData.calls.map((c) => ({ ...c })),
          // TypeScript/JS
          ...tsData.functions.map((f) => ({ kind: "ts-func", ...f })),
          ...tsData.classes.map((c) => ({ kind: "ts-class", ...c })),
          ...tsData.calls.map((c) => ({ ...c })),
          // C/C++
          ...cData.functions.map((f) => ({ kind: "c-func", ...f })),
          ...cData.types.map((t) => ({ kind: "c-type", ...t })),
          ...cData.calls.map((c) => ({ ...c })),
          // ctags fallback (Java, Rust, etc.)
          ...ctagsSym.map((s) => ({ kind: "ctags-sym", ...s }))
        ];
        if (records.length > 1) {
          writeJsonl(path2.join(modulesDir, `${mod.name}.jsonl`), records);
          moduleFilesCount++;
        }
      }
      const depsDiagram = generateModuleDeps(out, { records: moduleGraphRecords });
      const protoDiagram = generateProtoMap(out, { records: protoRecords });
      if (depsDiagram.mermaid) {
        fs2.writeFileSync(path2.join(out, "module-deps.mermaid"), depsDiagram.mermaid, "utf8");
      }
      if (protoDiagram.mermaid) {
        fs2.writeFileSync(path2.join(out, "proto-map.mermaid"), protoDiagram.mermaid, "utf8");
      }
      const schema = generateSchema(
        repo,
        modules,
        includeGraph,
        allModuleEdges,
        protoIndex,
        goIndex,
        pythonIndex,
        tsIndex,
        cIndex,
        ctagsIndex,
        allCalls
      );
      fs2.writeFileSync(path2.join(out, "schema.yaml"), schema);
      const totalSizeKB = dirSizeKB(out);
      return {
        moduleEdges: allModuleEdges.length,
        rpcs: protoIndex.rpcs.length,
        hotspots: hotspots.length,
        moduleFiles: moduleFilesCount,
        totalSizeKB,
        tsFunctions: tsIndex.functions.length,
        tsClasses: tsIndex.classes.length,
        cFunctions: cIndex.functions.length,
        cTypes: cIndex.types.length,
        ctagsSymbols: ctagsIndex.symbols.length
      };
    }
    function buildFanInMap(edges) {
      const map = /* @__PURE__ */ new Map();
      for (const e of edges) {
        map.set(e.target, (map.get(e.target) || 0) + 1);
      }
      return map;
    }
    function generateSchema(repo, modules, includeGraph, allModuleEdges, protoIndex, goIndex, pythonIndex, tsIndex, cIndex, ctagsIndex, allCalls) {
      const repoName = path2.basename(repo);
      const now = (/* @__PURE__ */ new Date()).toISOString().replace("T", " ").slice(0, 19);
      const modList = modules.map((m) => `  ${m.name}:  # ${m.sizeKB}KB, ${m.files.cc}cc ${m.files.h}h ${m.files.go}go ${m.files.ts}ts ${m.files.py}py`).join("\n");
      const tsFuncs = tsIndex.functions.length;
      const tsClasses = tsIndex.classes.length;
      const cFuncs = cIndex.functions.length;
      const cTypes = cIndex.types.length;
      const totalCalls = allCalls.length;
      return `# draft/graph/schema.yaml
# Auto-generated by graph \u2014 do not edit manually
# Re-generate with: graph --repo <path>

repo:      ${repoName}
generated: ${now}
version:   2

stats:
  modules:       ${modules.length}
  file_nodes:    ${includeGraph.nodes.length}
  include_edges: ${includeGraph.edges.length}
  module_edges:  ${allModuleEdges.length}
  proto_services: ${protoIndex.services.length}
  proto_rpcs:    ${protoIndex.rpcs.length}
  proto_enums:   ${protoIndex.enums.length}
  go_functions:  ${goIndex.functions.length}
  go_types:      ${goIndex.types.length}
  py_functions:  ${pythonIndex.functions.length}
  py_classes:    ${pythonIndex.classes.length}
  ts_functions:  ${tsFuncs}
  ts_classes:    ${tsClasses}
  c_functions:   ${cFuncs}
  c_types:       ${cTypes}
  ctags_symbols: ${ctagsIndex.symbols.length}
  call_edges:    ${totalCalls}

indexers:
  cpp:
    method: include-graph
    accuracy: "~95% (quoted includes only; angle-bracket system headers excluded)"
    excludes: ["*.pb.cc", "*.pb.h", "*_generated*", "*/test/*"]
  c_symbols:
    method: ${cFuncs > 0 ? "tree-sitter (with ctags fallback)" : "skipped (no C/C++ files)"}
    accuracy: "~95%"
  go:
    method: ${goIndex.functions.length > 0 ? "tree-sitter (with regex fallback)" : "skipped (no Go files)"}
    accuracy: "~95%"
  python:
    method: ${pythonIndex.functions.length > 0 ? "tree-sitter (with regex fallback)" : "skipped (no Python files)"}
    accuracy: "~98%"
  typescript:
    method: ${tsFuncs > 0 ? "tree-sitter (with regex fallback)" : "skipped (no TS/JS files)"}
    accuracy: "~95%"
  proto:
    method: line-parser
    accuracy: "100%"
  other_languages:
    method: ${ctagsIndex.symbols.length > 0 ? "universal-ctags" : "skipped (ctags not found or no supported files)"}

graph_levels:
  module_graph:
    file: module-graph.jsonl
    load: always
    nodes: ${modules.length}
    edges: ${allModuleEdges.length}
  proto_index:
    file: proto-index.jsonl
    load: always
    rpcs: ${protoIndex.rpcs.length}
  hotspots:
    file: hotspots.jsonl
    load: always
    entries: 50
  go_index:
    file: go-index.jsonl
    load: when-working-in-go-modules
    functions: ${goIndex.functions.length}
  python_index:
    file: python-index.jsonl
    load: when-working-in-python-modules
    functions: ${pythonIndex.functions.length}
  ts_index:
    file: ts-index.jsonl
    load: when-working-in-ts-js-modules
    functions: ${tsFuncs}
  c_index:
    file: c-index.jsonl
    load: when-working-in-c-cpp-modules
    functions: ${cFuncs}
  call_index:
    file: call-index.jsonl
    load: when-tracing-call-paths
    edges: ${totalCalls}
  per_module:
    dir: modules/
    load: on-demand
    files: ${modules.length}

modules:
${modList}
`;
    }
    module2.exports = { writeGraph: writeGraph2 };
  }
});

// src/modules.js
var require_modules = __commonJS({
  "src/modules.js"(exports2, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var { walkFiles, compileExcludes: compileExcludes2, dirSizeKB, fileSizeKB, countLines } = require_util();
    var SOURCE_EXTS = /* @__PURE__ */ new Set([".cc", ".cpp", ".cxx", ".c", ".h", ".hpp", ".go", ".py", ".java", ".rs", ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".proto"]);
    function detectModules2(repo, excludesOrExcludeRes = []) {
      const excludeRes2 = excludesOrExcludeRes.length > 0 && excludesOrExcludeRes[0] instanceof RegExp ? excludesOrExcludeRes : compileExcludes2(excludesOrExcludeRes);
      const modules = [];
      let entries;
      try {
        entries = fs2.readdirSync(repo, { withFileTypes: true });
      } catch (e) {
        return modules;
      }
      for (const entry of entries) {
        if (!entry.isDirectory()) continue;
        if (entry.name.startsWith(".")) continue;
        const modPath = path2.join(repo, entry.name);
        const counts = countSourceFiles(modPath, excludeRes2, repo);
        if (counts.total === 0) continue;
        modules.push({
          name: entry.name,
          path: modPath,
          sizeKB: dirSizeKB(modPath),
          files: {
            cc: counts.cc,
            h: counts.h,
            go: counts.go,
            proto: counts.proto,
            py: counts.py,
            java: counts.java,
            rs: counts.rs,
            ts: counts.ts,
            total: counts.total
          }
        });
      }
      const rootCounts = { cc: 0, h: 0, go: 0, proto: 0, py: 0, java: 0, rs: 0, ts: 0, total: 0 };
      let rootSizeKB = 0;
      for (const entry of entries) {
        if (entry.isDirectory()) continue;
        if (entry.name.startsWith(".")) continue;
        const ext = path2.extname(entry.name);
        if (!SOURCE_EXTS.has(ext)) continue;
        const full = path2.join(repo, entry.name);
        const rel = path2.relative(repo, full);
        if (excludeRes2.some((re) => re.test(rel))) continue;
        rootSizeKB += fileSizeKB(full);
        switch (ext) {
          case ".cc":
          case ".cpp":
          case ".cxx":
            rootCounts.cc++;
            break;
          case ".h":
          case ".hpp":
            rootCounts.h++;
            break;
          case ".go":
            rootCounts.go++;
            break;
          case ".proto":
            rootCounts.proto++;
            break;
          case ".py":
            rootCounts.py++;
            break;
          case ".java":
            rootCounts.java++;
            break;
          case ".rs":
            rootCounts.rs++;
            break;
          case ".ts":
          case ".tsx":
          case ".js":
          case ".jsx":
          case ".mjs":
          case ".cjs":
            rootCounts.ts++;
            break;
        }
        if (SOURCE_EXTS.has(ext)) rootCounts.total++;
      }
      if (rootCounts.total > 0) {
        modules.push({
          name: "__root__",
          path: repo,
          sizeKB: rootSizeKB,
          files: rootCounts,
          rootOnly: true
          // flag: only index root-level files, not subdirectories
        });
      }
      modules.sort((a, b) => a.name.localeCompare(b.name));
      return modules;
    }
    function countSourceFiles(dir, excludeRes2, root) {
      const counts = { cc: 0, h: 0, go: 0, proto: 0, py: 0, java: 0, rs: 0, ts: 0, total: 0 };
      const files = walkFiles(dir, [], excludeRes2, root);
      for (const f of files) {
        const ext = path2.extname(f);
        switch (ext) {
          case ".cc":
          case ".cpp":
          case ".cxx":
            counts.cc++;
            break;
          case ".h":
          case ".hpp":
            counts.h++;
            break;
          case ".go":
            counts.go++;
            break;
          case ".proto":
            counts.proto++;
            break;
          case ".py":
            counts.py++;
            break;
          case ".java":
            counts.java++;
            break;
          case ".rs":
            counts.rs++;
            break;
          case ".ts":
          case ".tsx":
          case ".js":
          case ".jsx":
          case ".mjs":
          case ".cjs":
            counts.ts++;
            break;
        }
        if (SOURCE_EXTS.has(ext)) counts.total++;
      }
      return counts;
    }
    module2.exports = { detectModules: detectModules2 };
  }
});

// src/query.js
var require_query = __commonJS({
  "src/query.js"(exports2, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var { die: die2, warn: warn2 } = require_util();
    var { generateModuleDeps, generateProtoMap, generateAllMermaid } = require_mermaid();
    function query({ out, symbol, file, mode }) {
      if (!mode) die2("--mode required for query. Options: callers|impact|hotspots|modules|mermaid");
      if (!fs2.existsSync(out)) die2(`Graph not found at ${out}. Run graph --repo <path> first.`);
      switch (mode) {
        case "callers":
          return queryCallers(out, symbol || file);
        case "impact":
          return queryImpact(out, symbol || file);
        case "hotspots":
          return queryHotspots(out, symbol);
        case "modules":
          return queryModules(out);
        case "cycles":
          return queryCycles(out);
        case "mermaid":
          return queryMermaid(out, symbol);
        default:
          die2(`Unknown mode: ${mode}. Options: callers|impact|hotspots|modules|cycles|mermaid`);
      }
    }
    function loadJsonl(filePath) {
      if (!fs2.existsSync(filePath)) return [];
      const buf = fs2.readFileSync(filePath);
      const results = [];
      let start = 0;
      for (let i = 0; i <= buf.length; i++) {
        if (i === buf.length || buf[i] === 10) {
          if (i > start) {
            const line = buf.toString("utf8", start, i).trimEnd();
            if (line) {
              try {
                const r = JSON.parse(line);
                if (r !== null) results.push(r);
              } catch (_) {
              }
            }
          }
          start = i + 1;
        }
      }
      return results;
    }
    function loadModuleGraph(out) {
      return loadJsonl(path2.join(out, "module-graph.jsonl"));
    }
    function loadModuleFile(out, moduleName) {
      return loadJsonl(path2.join(out, "modules", `${moduleName}.jsonl`));
    }
    function loadHotspots(out) {
      return loadJsonl(path2.join(out, "hotspots.jsonl"));
    }
    function queryCallers(out, target) {
      if (!target) die2("--symbol or --file required for callers mode");
      const looksLikeFile = target.includes("/");
      if (looksLikeFile) {
        return queryFileCallers(out, target);
      } else {
        return queryFunctionCallers(out, target);
      }
    }
    function queryFileCallers(out, target) {
      const targetModule = target.includes("/") ? target.split("/")[0] : "__root__";
      const modFileCache = /* @__PURE__ */ new Map();
      const getCachedModFile = (moduleName) => {
        if (!modFileCache.has(moduleName)) {
          modFileCache.set(moduleName, loadModuleFile(out, moduleName));
        }
        return modFileCache.get(moduleName);
      };
      const moduleRecords = getCachedModFile(targetModule);
      const intraCallers = moduleRecords.filter((r) => r.kind === "include" && r.target === target).map((r) => ({ file: r.source, module: targetModule, type: "intra-module" }));
      const moduleGraph = loadModuleGraph(out);
      const moduleNodes = moduleGraph.filter((r) => r.kind === "node").map((r) => r.id);
      const crossCallers = [];
      for (const mod of moduleNodes) {
        if (mod === targetModule) continue;
        const recs = getCachedModFile(mod);
        for (const r of recs) {
          if (r.kind === "cross-include" && r.target === target) {
            crossCallers.push({ file: r.source, module: mod, type: "cross-module" });
          }
        }
      }
      const result = {
        target,
        callers: [...intraCallers, ...crossCallers],
        summary: {
          intra: intraCallers.length,
          cross: crossCallers.length,
          total: intraCallers.length + crossCallers.length
        }
      };
      console.log(JSON.stringify(result, null, 2));
    }
    function queryFunctionCallers(out, target) {
      const callIndexPath = path2.join(out, "call-index.jsonl");
      if (!fs2.existsSync(callIndexPath)) {
        console.log(JSON.stringify({
          error: "no call index \u2014 rebuild graph to generate call edges",
          hint: "Run: graph --repo <path> --out " + out
        }, null, 2));
        return;
      }
      const allCalls = loadJsonl(callIndexPath);
      const callers = allCalls.filter((r) => r.to === target).map((r) => ({
        func: r.from,
        file: r.fromFile,
        module: r.module,
        line: r.line,
        kind: r.kind,
        resolved: r.resolved
      }));
      const seen = /* @__PURE__ */ new Set();
      const unique = callers.filter((c) => {
        const key = `${c.func}::${c.file}`;
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
      });
      const byModule = {};
      for (const c of unique) {
        byModule[c.module] = (byModule[c.module] || 0) + 1;
      }
      const result = {
        target,
        callers: unique,
        total: unique.length,
        by_module: byModule,
        note: "intra-file call edges only; cross-file resolution requires type information"
      };
      console.log(JSON.stringify(result, null, 2));
    }
    function classifyFile(filePath) {
      const path3 = filePath.toLowerCase();
      const base = path3.split("/").pop() || path3;
      if (/(^|\/)(tests?|__tests__|specs?)\//.test(path3)) return "test";
      if (/(^|_)test_|_test\.(go|py|sh)$|test_.*\.py$|tests?\.py$|conftest\.py$/.test(base)) return "test";
      if (/\.(test|spec)\.(ts|tsx|js|jsx|mjs|cjs)$/.test(base)) return "test";
      if (/(test|tests|spec)\.java$/.test(base)) return "test";
      if (/\.(md|markdown|rst|txt|adoc)$/.test(base)) return "doc";
      if (/\.(ya?ml|toml|json|ini|cfg|conf|env|properties)$/.test(base)) return "config";
      if (/^(makefile|dockerfile|jenkinsfile|\.gitignore|\.dockerignore)$/i.test(base)) return "config";
      return "code";
    }
    function queryImpact(out, target) {
      if (!target) die2("--file required for impact mode");
      const moduleGraph = loadModuleGraph(out);
      const moduleNodes = moduleGraph.filter((r) => r.kind === "node").map((r) => r.id);
      const reverseIndex = /* @__PURE__ */ new Map();
      for (const mod of moduleNodes) {
        for (const r of loadModuleFile(out, mod)) {
          if (r.kind !== "include" && r.kind !== "cross-include") continue;
          if (!reverseIndex.has(r.target)) reverseIndex.set(r.target, []);
          reverseIndex.get(r.target).push({ source: r.source, module: mod });
        }
      }
      const visited = /* @__PURE__ */ new Set([target]);
      const queue = [target];
      const impactList = [];
      const depthMap = /* @__PURE__ */ new Map([[target, 0]]);
      let head = 0;
      while (head < queue.length) {
        const current = queue[head++];
        const depth = depthMap.get(current) ?? 0;
        for (const { source, module: module3 } of reverseIndex.get(current) || []) {
          if (!visited.has(source)) {
            visited.add(source);
            depthMap.set(source, depth + 1);
            impactList.push({
              file: source,
              module: module3,
              depth: depth + 1,
              category: classifyFile(source)
            });
            queue.push(source);
          }
        }
      }
      const affectedModules = [...new Set(impactList.map((i) => i.module))];
      const byCategory = { code: 0, test: 0, doc: 0, config: 0 };
      for (const item of impactList) byCategory[item.category]++;
      const result = {
        target,
        impact: {
          files: impactList.length,
          modules: affectedModules.length,
          affected_modules: affectedModules,
          by_category: byCategory,
          files_by_depth: groupByDepth(impactList),
          files_by_category: groupByCategory(impactList)
        },
        warning: impactList.length > 50 ? `High blast radius: ${impactList.length} files affected. Consider breaking this dependency.` : null
      };
      console.log(JSON.stringify(result, null, 2));
    }
    function queryHotspots(out, moduleFilter) {
      let hotspots = loadHotspots(out);
      if (moduleFilter) {
        hotspots = hotspots.filter((h) => h.module === moduleFilter);
      }
      console.log(JSON.stringify({ hotspots: hotspots.slice(0, 20) }, null, 2));
    }
    function queryModules(out) {
      const records = loadModuleGraph(out);
      const nodes = records.filter((r) => r.kind === "node");
      const edges = records.filter((r) => r.kind === "edge").sort((a, b) => b.weight - a.weight);
      const cycles = detectCycles(nodes.map((n) => n.id), edges);
      console.log(JSON.stringify({
        modules: nodes,
        dependencies: edges,
        cycles,
        summary: {
          modules: nodes.length,
          edges: edges.length,
          cycles: cycles.length,
          hub_modules: findHubs(nodes, edges)
        }
      }, null, 2));
    }
    function queryCycles(out) {
      const records = loadModuleGraph(out);
      const nodes = records.filter((r) => r.kind === "node").map((r) => r.id);
      const edges = records.filter((r) => r.kind === "edge");
      const cycles = detectCycles(nodes, edges);
      if (cycles.length === 0) {
        console.log(JSON.stringify({ cycles: [], message: "No circular dependencies detected." }));
      } else {
        console.log(JSON.stringify({
          cycles,
          count: cycles.length,
          warning: `${cycles.length} circular dependency cycle(s) detected. These indicate tight coupling.`
        }, null, 2));
      }
    }
    function queryMermaid(out, diagramType) {
      if (diagramType === "module-deps") {
        const result = generateModuleDeps(out);
        console.log(JSON.stringify(result, null, 2));
      } else if (diagramType === "proto-map") {
        const result = generateProtoMap(out);
        console.log(JSON.stringify(result, null, 2));
      } else {
        const markdown = generateAllMermaid(out);
        if (markdown) {
          console.log(markdown);
        } else {
          console.log(JSON.stringify({ message: "No graph data found to generate diagrams." }));
        }
      }
    }
    function detectCycles(nodes, edges) {
      const adj = /* @__PURE__ */ new Map();
      for (const n of nodes) adj.set(n, []);
      for (const e of edges) {
        if (adj.has(e.source)) adj.get(e.source).push(e.target);
      }
      const WHITE = 0, GRAY = 1, BLACK = 2;
      const color = new Map(nodes.map((n) => [n, WHITE]));
      const cycles = [];
      for (const startNode of nodes) {
        if (color.get(startNode) !== WHITE) continue;
        const stack = [[startNode, 0, [startNode]]];
        color.set(startNode, GRAY);
        while (stack.length > 0) {
          const frame = stack[stack.length - 1];
          const [node, , currentPath] = frame;
          const neighbors = adj.get(node) || [];
          if (frame[1] >= neighbors.length) {
            color.set(node, BLACK);
            stack.pop();
            continue;
          }
          const neighbor = neighbors[frame[1]++];
          if (color.get(neighbor) === GRAY) {
            const cycleStart = currentPath.indexOf(neighbor);
            cycles.push([...currentPath.slice(cycleStart), neighbor]);
          } else if (color.get(neighbor) === WHITE) {
            color.set(neighbor, GRAY);
            stack.push([neighbor, 0, [...currentPath, neighbor]]);
          }
        }
      }
      return cycles;
    }
    function findHubs(nodes, edges) {
      const inDegree = new Map(nodes.map((n) => [n.id, 0]));
      for (const e of edges) {
        inDegree.set(e.target, (inDegree.get(e.target) || 0) + e.weight);
      }
      return [...inDegree.entries()].sort((a, b) => b[1] - a[1]).slice(0, 5).map(([id, weight]) => ({ module: id, dependents_weight: weight }));
    }
    function groupByDepth(items) {
      const groups = {};
      for (const item of items) {
        const d = item.depth;
        if (!groups[d]) groups[d] = [];
        groups[d].push(item.file);
      }
      return groups;
    }
    function groupByCategory(items) {
      const groups = { code: [], test: [], doc: [], config: [] };
      for (const item of items) groups[item.category].push(item.file);
      return groups;
    }
    module2.exports = { query };
  }
});

// src/index.js
var path = require("path");
var fs = require("fs");
var crypto = require("crypto");
var { buildIncludeGraph } = require_extractor_includes();
var { buildProtoIndex } = require_extractor_proto();
var { buildGoIndex } = require_extractor_go();
var { buildPythonIndex } = require_extractor_python();
var { buildTsIndex } = require_extractor_ts();
var { buildCIndex } = require_extractor_c();
var { buildCtagsIndex } = require_extractor_ctags();
var { writeGraph } = require_writer();
var { detectModules } = require_modules();
var { log, warn, done, die, parseArgs, compileExcludes, collectAllFiles } = require_util();
var args = parseArgs(process.argv.slice(2));
if (args.help || !args.repo && !args._[0]) {
  console.log(`
graph \u2014 knowledge graph builder for Draft

Usage:
  graph --repo <path> [--out <dir>] [--exclude <pattern>] [--incremental]
  graph --repo <path> --query --symbol <name> --mode callers
  graph --repo <path> --query --file <path> --mode impact

Options:
  --repo        <path>     Repository root to analyze (required)
  --out         <dir>      Output directory (default: <repo>/draft/graph)
  --exclude     <pattern>  Additional exclusion glob (repeatable)
  --incremental            Skip unchanged modules (uses hashes.json for diffing)
  --query                  Query mode (reads existing graph, does not rebuild)
  --symbol      <name>     Symbol to query (use with --query)
  --file        <path>     File to query (use with --query)
  --mode        <mode>     Query mode: callers|impact|hotspots|modules|cycles|mermaid
  --help                   Show this help
`);
  process.exit(0);
}
var REPO = path.resolve(args.repo || args._[0]);
var FINAL_OUT = path.resolve(args.out || path.join(REPO, "draft", "graph"));
var TEMP_OUT = FINAL_OUT + ".tmp-" + process.pid;
if (!fs.existsSync(REPO)) die(`Repo path does not exist: ${REPO}`);
if (args.query) {
  const { query } = require_query();
  query({ out: FINAL_OUT, symbol: args.symbol, file: args.file, mode: args.mode });
  if (process.stdout.writableNeedDrain) {
    process.stdout.once("drain", () => process.exit(0));
  } else {
    process.stdout.write("", () => process.exit(0));
  }
  return;
}
var EXCLUDE_DEFAULTS = [
  "*.pb.cc",
  "*.pb.h",
  "*_generated*",
  "*/test/*",
  "*_test.cc",
  "*_test.go",
  "*/vendor/*",
  "*/third_party/*",
  "*/dist/*",
  "*/.next/*",
  "*/build/*",
  "*/out/*",
  "*.pem",
  "*.key",
  "*.crt"
];
var excludePatterns = [
  ...EXCLUDE_DEFAULTS,
  ...args.exclude ? [].concat(args.exclude) : []
];
var INCREMENTAL = !!args.incremental;
var excludeRes = compileExcludes(excludePatterns);
function computeModuleHash(modPath) {
  const hash = crypto.createHash("sha256");
  const files = [];
  const walk = (dir) => {
    let entries;
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch (_) {
      return;
    }
    for (const e of entries) {
      const full = path.join(dir, e.name);
      if (e.isDirectory()) walk(full);
      else files.push(full);
    }
  };
  walk(modPath);
  for (const f of files.sort()) {
    try {
      hash.update(fs.readFileSync(f));
    } catch (_) {
    }
  }
  return hash.digest("hex").slice(0, 16);
}
function loadHashes() {
  try {
    return JSON.parse(fs.readFileSync(path.join(FINAL_OUT, "hashes.json"), "utf8"));
  } catch (_) {
    return { modules: {} };
  }
}
function saveHashes(modules) {
  fs.writeFileSync(path.join(TEMP_OUT, "hashes.json"), JSON.stringify({
    generated: (/* @__PURE__ */ new Date()).toISOString(),
    modules
  }, null, 2), "utf8");
}
async function main() {
  log(`Analyzing: ${REPO}`);
  log(`Output:    ${FINAL_OUT}`);
  const parentDir = path.dirname(FINAL_OUT);
  const baseName = path.basename(FINAL_OUT);
  try {
    for (const entry of fs.readdirSync(parentDir, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      const n = entry.name;
      if (n.startsWith(baseName + ".tmp-") || n.startsWith(baseName + ".old-")) {
        fs.rmSync(path.join(parentDir, n), { recursive: true, force: true });
      }
    }
  } catch (_) {
  }
  fs.mkdirSync(TEMP_OUT, { recursive: true });
  fs.mkdirSync(path.join(TEMP_OUT, "modules"), { recursive: true });
  const allFiles = collectAllFiles(REPO, excludeRes);
  const prevHashes = INCREMENTAL ? loadHashes().modules : {};
  const newHashes = {};
  const skipModules = /* @__PURE__ */ new Set();
  log("Phase 1/5  Detecting modules...");
  const modules = detectModules(REPO, excludePatterns);
  log(`           Found ${modules.length} modules`);
  if (INCREMENTAL) {
    for (const mod of modules) {
      const hash = computeModuleHash(mod.path);
      newHashes[mod.name] = hash;
      if (prevHashes[mod.name] === hash) {
        skipModules.add(mod.name);
      }
    }
    const skipped = skipModules.size;
    if (skipped > 0) log(`           Incremental: skipping ${skipped} unchanged module(s)`);
  }
  log("Phase 2/5  Building C++ include graph...");
  const includeGraph = buildIncludeGraph(REPO, modules, excludeRes, allFiles);
  log(`           ${includeGraph.nodes.length} file nodes, ${includeGraph.edges.length} include edges`);
  log(`           ${includeGraph.moduleEdges.length} inter-module edges`);
  log("Phase 3/5  Parsing proto definitions...");
  const protoIndex = buildProtoIndex(REPO, excludeRes, allFiles);
  log(`           ${protoIndex.services.length} services, ${protoIndex.rpcs.length} RPCs, ${protoIndex.messages.length} messages, ${protoIndex.enums.length} enums`);
  log("Phases 4/5  Indexing Go / Python / TS / C++ in parallel...");
  const [goIndex, pythonIndex, tsIndex, cIndex] = await Promise.all([
    buildGoIndex(REPO, excludeRes, allFiles),
    buildPythonIndex(REPO, excludeRes, allFiles),
    buildTsIndex(REPO, excludeRes, allFiles),
    buildCIndex(REPO, excludeRes, allFiles)
  ]);
  log(`           Go: ${goIndex.functions.length} functions, ${goIndex.calls.length} calls`);
  log(`           Python: ${pythonIndex.functions.length} functions, ${pythonIndex.calls.length} calls`);
  log(`           TS/JS: ${tsIndex.functions.length} functions, ${tsIndex.calls.length} calls`);
  log(`           C/C++: ${cIndex.functions.length} functions, ${cIndex.calls.length} calls`);
  log("Phase 5/5  Running ctags for unsupported languages...");
  const ctagsIndex = buildCtagsIndex(REPO, excludeRes, allFiles);
  log(`           ${ctagsIndex.symbols.length} symbols (Java/Rust/Ruby/Swift/etc.)`);
  log("Writing graph files...");
  const stats = writeGraph({
    out: TEMP_OUT,
    existingOut: FINAL_OUT,
    // for incremental: copy unchanged module files from here
    repo: REPO,
    modules,
    includeGraph,
    protoIndex,
    goIndex,
    pythonIndex,
    tsIndex,
    cIndex,
    ctagsIndex,
    skipModules
  });
  if (INCREMENTAL) {
    saveHashes(newHashes);
  }
  const backupOut = FINAL_OUT + ".old-" + process.pid;
  try {
    if (fs.existsSync(FINAL_OUT)) fs.renameSync(FINAL_OUT, backupOut);
    fs.renameSync(TEMP_OUT, FINAL_OUT);
    if (fs.existsSync(backupOut)) fs.rmSync(backupOut, { recursive: true, force: true });
  } catch (e) {
    die(`Failed to commit output (temp dir preserved at ${TEMP_OUT}): ${e.message}`);
  }
  const totalCalls = goIndex.calls.length + pythonIndex.calls.length + tsIndex.calls.length + cIndex.calls.length;
  console.log("");
  done("Graph build complete");
  console.log(`  module-graph.jsonl   ${stats.moduleEdges} edges`);
  console.log(`  proto-index.jsonl    ${stats.rpcs} RPCs`);
  console.log(`  hotspots.jsonl       ${stats.hotspots} files`);
  if (stats.tsFunctions > 0) console.log(`  ts-index.jsonl       ${stats.tsFunctions} functions, ${stats.tsClasses} classes`);
  if (stats.cFunctions > 0) console.log(`  c-index.jsonl        ${stats.cFunctions} functions, ${stats.cTypes} types`);
  if (stats.ctagsSymbols > 0) console.log(`  ctags symbols        ${stats.ctagsSymbols}`);
  if (totalCalls > 0) console.log(`  call-index.jsonl     ${totalCalls} call edges`);
  console.log(`  modules/             ${stats.moduleFiles} files`);
  console.log(`  Total output:        ${stats.totalSizeKB}KB`);
  console.log("");
}
main().catch(die);
