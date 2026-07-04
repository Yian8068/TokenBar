## Highlights

- **Claude limits now work with `setup-token` / `CLAUDE_CODE_OAUTH_TOKEN`.** If you authenticate Claude Code with `claude setup-token` (or export `CLAUDE_CODE_OAUTH_TOKEN`) instead of the interactive `/login`, the limits card used to show `Session: No data / Weekly: No data`. A setup-token is inference-only, so Anthropic's usage endpoint returns `403 … user:profile`; TokenBar now falls back to a 1-token probe and reads your Session (5h) and Weekly (7d) windows straight from the `anthropic-ratelimit-unified-*` response headers, resolving the token from your environment or Keychain. Thanks [@sayre4ux](https://github.com/sayre4ux) for the thorough root-cause report ([#26](https://github.com/Nanako0129/TokenBar/issues/26)). ([#27](https://github.com/Nanako0129/TokenBar/pull/27))
- **Accuracy: the parsing engine caught up to tokscale v4.0.7.** A broad correctness sweep — your totals, cost, and per-agent breakdowns should now line up much more closely with each tool's own numbers. Delivered as faithful vendored ports of [junhoyeo/tokscale](https://github.com/junhoyeo/tokscale). ([#19](https://github.com/Nanako0129/TokenBar/pull/19), [#20](https://github.com/Nanako0129/TokenBar/pull/20), [#22](https://github.com/Nanako0129/TokenBar/pull/22), [#24](https://github.com/Nanako0129/TokenBar/pull/24))

## What got more accurate

| Agent | Before → After |
|---|---|
| **MiMo Code** | usage read as **empty** (wrong scan path) → now parsed correctly; timestamp seconds/ms normalized |
| **Codex** | ~**50% token under-count** on same-millisecond forks → fixed fork-replay de-duplication; provider inferred from the model instead of hard-defaulting to OpenAI |
| **GitHub Copilot** | sub-agents collapsed into one bucket → **per-agent attribution** |
| **gjc, Pi** | messages with tokens but no provider field were **silently dropped** → recovered via model inference |
| **Droid** | a whole session dropped on a bad timestamp → falls back to the file's mtime |
| **OpenCode, MiMo, Kilo, Mux, Antigravity, Jcode** | raw provider aliases split aggregation buckets and mis-priced → canonicalized |
| **Qwen, Mux** | double-counted on re-parse → stable de-dup keys |
| **fable-5** | resolved to `unknown` with no price → mapped to Anthropic |
| **RooCode / KiloCode / Cline** | stale cache after a sibling history rewrite → invalidates correctly |
| **All agents** | "active days" / average-per-day counted only days with `tokens > 0` → now also counts days active by cost or message |

## Changes

- **Refreshed every agent brand icon.** Audited each against its official source and rendered it through the app's real CoreSVG path: fixed 4 wrong icons (Pi, Kimi, Codebuff, MiMo Code) and 2 that looked right in a browser but broke in the app (Antigravity, KiloCode), and added brand marks for 8 agents that were showing a plain letter disc (Hermes, Roo Code, Mux, Crush, Goose, Zed, Trae, OpenClaw). ([#21](https://github.com/Nanako0129/TokenBar/pull/21))

## Fixes

- **Homebrew:** silenced the `depends_on macos:` string-comparison deprecation warning in the cask. Thanks [@yiskang](https://github.com/yiskang) ([#23](https://github.com/Nanako0129/TokenBar/issues/23)).
