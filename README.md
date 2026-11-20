# champion-challenger

A Claude Code skill that compares candidate improvements head to head, one at a time. The winner stays as champion, and the final champion is the one you adopt. Use it to narrow down candidates for UI copy, prompts, designs, or names.

[日本語](README_JA.md)

## What it does

1. Takes the current implementation as the first champion. If there is none, it uses the candidate you specify.
2. Proposes one-line outlines of candidates that differ in direction, and asks you to confirm them.
3. Turns the outlines into challengers one at a time and compares each with the champion. A separate judge process decides twice, with the order of the two candidates swapped. The challenger is promoted only if it wins both times; a split decision or a `draw` keeps the champion.
4. Ends after N consecutive champion wins (light 3 / standard 5 / strict 7).
5. If a candidate beat the current implementation, asks for your approval before implementing it, then implements and verifies it.

The judging criteria and comparison conditions are fixed before the start and never changed midway. The log is written to `docs/log/`, or to `tmp/<theme>/log.md` if that directory does not exist.

## Requirements

- Claude Code
- node
- bash

## Installation

### Claude Code plugin (recommended)

Run these commands in Claude Code:

```text
/plugin marketplace add w3pe8xmk/champion-challenger
/plugin install champion-challenger@champion-challenger
```

### Manual installation

```bash
git clone https://github.com/w3pe8xmk/champion-challenger
cp -r champion-challenger/skills/champion-challenger ~/.claude/skills/
# or, for one project only
cp -r champion-challenger/skills/champion-challenger <project>/.claude/skills/
```

If `judge.sh` is not executable after copying, run `chmod +x` on it.

## Usage

Manual invocation only.

```text
/champion-challenger <theme> [light|standard|strict, or N wins in a row]
```

The strictness keywords are Japanese (`軽め` = light, `標準` = standard, `厳密` = strict). Free text such as "5 wins in a row" also works.

- Examples: `/champion-challenger settings screen wording 軽め` / `/champion-challenger error message tone 5連勝`
- If you omit the theme, the skill infers it from the preceding conversation and asks you to confirm. If you omit the strictness, it uses standard.
- Usage is heavy because it runs many rounds. Try light first.

### Example run (improving this skill's own description, light)

| R | Challenger | Judge verdicts (order A / B) | Result | Streak |
| --- | --- | --- | --- | --- |
| 1 | List "when to use / when not to use" side by side | challenger / challenger | promoted | 1 |
| 2 | List trigger phrases and state the scope | split | champion kept | 2 |
| 3 | Compress to half the current length | split | champion kept | 3 |

It ended after 3 straight wins and adopted the challenger promoted in R1. The six judge calls cost about $0.01.

## Configuration

| Item | Fixed value | Where |
| --- | --- | --- |
| Main model / effort | `claude-opus-5-5` / `medium` | `model` and `effort` in SKILL.md |
| Judge model / effort | `claude-haiku-5-5` / `medium` | judge.sh |

To use a different judge, pass a model ID and effort as the 2nd and 3rd arguments of `judge.sh`.

What cannot be fixed:
- The environment variable `CLAUDE_CODE_EFFORT_LEVEL` takes precedence over `effort` in SKILL.md.
- It will not work if your organization's `availableModels` forbids the specified models.

## Security

- SKILL.md pre-approves running `judge.sh`, with or without `JUDGE_TOOLS=Read`, through `allowed-tools`. Review SKILL.md before installation.
- The judge runs isolated and does not read CLAUDE.md, skills, hooks, or MCP.

## Limitations

- Judging is Claude's evaluation, not a measurement with real users or a statistical test. The streak counts are rules of thumb, not a significance threshold.
- The judge may rarely promote a candidate that is nearly identical to the champion.
- By default the judge reads text only. To judge images, call `judge.sh` with `JUDGE_TOOLS=Read` and put the image paths in the prompt. Image judging was checked only with simple synthetic images.
- SKILL.md and the judge prompt are written in Japanese. The skill talks to you in Japanese unless you ask otherwise.

## License

[MIT](LICENSE)
