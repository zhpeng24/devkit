# Language Stack — 语言检测与适配

主 SKILL.md 给了适配表的简版。本文件提供：检测信号优先级、未实现 `friendly-*` 时的回退策略、多语言项目处理、以及未来扩展时的更新流程。

## 语言检测信号优先级

按下列顺序判定项目主语言：

1. **Manifest 文件**（最强信号）：
   - `pyproject.toml` / `uv.lock` / `poetry.lock` / `pdm.lock` / `Pipfile` / `setup.py` / `setup.cfg` / `requirements.txt` / `tox.ini` / `noxfile.py` → Python
   - `package.json` / `tsconfig.json` → TypeScript / JavaScript
   - `go.mod` → Go
   - `Cargo.toml` → Rust
   - `pom.xml` / `build.gradle` → Java / Kotlin

2. **源码后缀统计**（manifest 不明确时）：
   ```bash
   find . -type f \( -name "*.py" -o -name "*.pyi" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" \) \
     -not -path "./node_modules/*" -not -path "./.venv/*" \
     | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -3
   ```

3. **GitHub 仓库主语言**（兜底）：
   ```bash
   gh repo view --json languages 2>/dev/null
   ```

## 完整语言适配表

| 语言 | 编码规范 skill | 状态 | 未实现时回退到 |
|------|----------------|------|----------------|
| Python | `friendly-python` | ✅ 已有 | — |
| TypeScript / JavaScript | `friendly-typescript` | ⏳ TODO | ESLint 默认规则 + Prettier 格式化 + 项目内 `.eslintrc` |
| Go | `friendly-go` | ⏳ TODO | `gofmt` + `golangci-lint` 默认 + Effective Go |
| Rust | `friendly-rust` | ⏳ TODO | `rustfmt` + `clippy` 默认 |
| Java / Kotlin | `friendly-jvm` | ⏳ TODO | Google Java Style + ktlint |
| Shell | 无 | — | `shellcheck` + Google Shell Style Guide |
| Markdown | 无 | — | markdownlint 默认 |
| 其他 | 无 | — | agent 通用规范 |

## 未实现时的开场提示话术

当用户在一个尚无 `friendly-*` 的语言项目里触发 `using-dev`，开场确认要带一句告知：

```
当前是 [Go] 项目，devkit 暂无 friendly-go skill，编码规范走 gofmt + golangci-lint
默认 + Effective Go。其他流程（issue / plan / 复盘）按 L[N] 正常推进。
```

**不阻塞** —— 编码规范缺失不影响 `github-issue-workflow` / `brainstorming` / `writing-plans` 等流程层 skill 的运行。

## 多语言项目处理

单仓库多语言（如 backend Python + frontend TypeScript）很常见。处理规则：

1. **按本次改动涉及的文件决定挂哪个 friendly-***
   - 只改 `backend/*.py` → 仅挂 `friendly-python`
   - 只改 `frontend/*.ts` → 挂 `friendly-typescript`（未实现时回退 ESLint）
   - 同时改 → 同时挂两套规范

2. **检测改动文件的命令：**
   ```bash
   git status --short | awk '{print $2}' | grep -oE '\.[a-z]+$' | sort -u
   ```

3. **开场确认话术：**
   ```
   检测到本次改动涉及 Python 与 TypeScript，将同时应用 friendly-python
   与 ESLint 默认规则。
   ```

## 文件类型 → 规范的精细映射

某些文件类型即使不属于"主语言"也要遵守特定规范：

| 文件类型 | 规范来源 |
|---------|---------|
| `*.py` | `friendly-python` |
| `*.pyi` | `friendly-python` + stub-specific typing rules |
| `*.ts` / `*.tsx` / `*.js` / `*.jsx` | ESLint / Prettier |
| `*.go` | `gofmt` + `golangci-lint` |
| `*.rs` | `rustfmt` + `clippy` |
| `*.sh` | `shellcheck` |
| `*.md` | markdownlint |
| `*.yaml` / `*.yml` | yamllint |
| `*.json` | `jq --indent 2` 校验语法 |
| `Dockerfile` | hadolint |

涉及哪种文件就检查对应的工具是否在项目里配置好；没配置时**回退到工具默认规则**而不是跳过检查。

## 未来新增 friendly-* 的步骤

当 devkit 新增一个语言专属规范 skill（如 `friendly-typescript`）时，按下面 3 步同步：

1. **Step 1：** 实现 `skills/friendly-<lang>/SKILL.md`（独立 PR）
2. **Step 2：** 更新本文件「完整语言适配表」对应行的 `状态` 为 ✅，删除「未实现时回退到」列说明
3. **Step 3：** 更新主 SKILL.md「语言适配」表的同一行

这 3 步可以在同一个 PR 完成，也可以拆成两个（先实现 skill，再更新 `using-dev` 引用）。

## 检测失败的兜底

如果上述检测都不能确定语言（空仓库 / 没有 manifest / 没有源码）：

1. 询问用户：
   ```
   未能从 manifest 或源码推断主语言。请告知：Python / TypeScript / Go / Rust / 其他？
   ```
2. 用户回答后挂对应 skill；若回答"其他" → 走通用规范回退
3. 不要在没确认语言的情况下假设是 Python
