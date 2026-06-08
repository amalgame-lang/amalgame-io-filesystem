# amalgame-io-filesystem

Filesystem operations for Amalgame — the `readdir`/`mkdir`/`rmdir`/
`rename` slice the bundled `File` facade is missing (it only does
single-file read/write/delete/exists). The syscalls sit behind a thin
`@c` frontier (POSIX `opendir`/`readdir`/`mkdir` + Windows
`FindFirstFile`/`_mkdir`/`RemoveDirectory`); the recursion, filtering
and path joining are pure Amalgame.

```amalgame
import Amalgame.IO.Filesystem

// — enumeration —
// direct entries (files + subdirs), excluding "." and ".."
for name in Filesystem.List("./src") { ... }

Filesystem.IsDir("./src")        // true
Filesystem.IsFile("./README.md") // true

// every file under a tree, depth-first, paths relative to the root
let mds = Filesystem.ListRecursive("docs/guide")  // ["01.md", "sub/02.md", …]

// — mutation —
Filesystem.MakeDir("build/linux/obj")  // mkdir -p (recursive, idempotent)
Filesystem.Move(tmp, final)            // rename within a volume
Filesystem.Remove("build")             // rm -rf (recursive, idempotent)
```

## API

| Method | Returns | Notes |
|---|---|---|
| `Filesystem.List(dir)` | `List<string>` | entry names in `dir` (not sorted; empty if unreadable) |
| `Filesystem.IsDir(path)` | `bool` | |
| `Filesystem.IsFile(path)` | `bool` | exists and is not a directory |
| `Filesystem.ListRecursive(root)` | `List<string>` | all files under `root` (DFS), paths relative to `root`, `/`-joined; directories descended but not emitted |
| `Filesystem.MakeDir(path)` | `bool` | `mkdir -p` — creates missing parents; true if it already exists |
| `Filesystem.Move(from, to)` | `bool` | rename a file or dir within a volume; on Windows `to` must not exist |
| `Filesystem.Remove(path)` | `bool` | `rm -rf` — recursive; a missing path is success (idempotent) |

## Install

```toml
[dependencies]
amalgame-io-filesystem = "0.2.0"
```

## Test

```sh
./tests/run_tests.sh
```

## License

Apache-2.0
