# @workmule/codegraph

**Codebase intelligence as an MCP server.** Native Rust. Sub-second indexing. Zero runtime dependencies.

## Install

```bash
npx @workmule/codegraph init
```

One command: downloads the binary, indexes your codebase, registers MCP server, installs hooks.

Or install globally:

```bash
npm install -g @workmule/codegraph
codegraph init
```

Or install without npm:

```bash
curl -fsSL https://raw.githubusercontent.com/workmule/codegraph/main/install.sh | bash
codegraph init
```

## What It Does

CodeGraph builds a semantic graph of your codebase (32 languages, 44 MCP tools) and makes it instantly available to AI coding agents. **68% fewer tokens** per task compared to reading all files.

See [GitHub](https://github.com/workmule/codegraph) for full documentation.
