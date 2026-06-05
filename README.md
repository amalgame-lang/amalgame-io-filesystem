# amalgame-io-filesystem

Directory listing for Amalgame — the `readdir`/`stat` slice the bundled
`File` facade is missing. The syscalls sit behind a thin `@c` frontier
(POSIX `opendir`/`readdir` + Windows `FindFirstFile`); the recursion,
filtering and path joining are pure Amalgame.

```amalgame
import Amalgame.IO.Filesystem

// direct entries (files + subdirs), excluding "." and ".."
for name in Filesystem.List("./src") { ... }

Filesystem.IsDir("./src")        // true
Filesystem.IsFile("./README.md") // true

// every file under a tree, depth-first, paths relative to the root
let mds = Filesystem.ListRecursive("docs/guide")  // ["01.md", "sub/02.md", …]
```

## API

| Method | Returns | Notes |
|---|---|---|
| `Filesystem.List(dir)` | `List<string>` | entry names in `dir` (not sorted; empty if unreadable) |
| `Filesystem.IsDir(path)` | `bool` | |
| `Filesystem.IsFile(path)` | `bool` | exists and is not a directory |
| `Filesystem.ListRecursive(root)` | `List<string>` | all files under `root` (DFS), paths relative to `root`, `/`-joined; directories descended but not emitted |

## Install

```toml
[dependencies]
amalgame-io-filesystem = "0.1.0"
```

## Test

```sh
./tests/run_tests.sh
```

## License

Apache-2.0
