# champion-challenger

[日本語](README_JA.md)

A Claude Code skill based on the **champion-challenger** method: it pits candidate improvements (challengers) against the current version (champion) one at a time in head-to-head rounds, replacing the champion only when a challenger wins and adopting the final winner.

Simply asking Claude to "generate a few ideas and pick the best one" often leads to drifting criteria or bias. This skill keeps comparisons consistent through **fixed criteria, a blind pairwise LLM-as-a-Judge, and a bias toward keeping the current champion**. Use it to narrow down UI copy, prompts, designs, names, performance improvements, and similar options.

## What it does

1. Takes the current implementation as the first champion. If there is none, it uses the candidate you specify.
2. Proposes, in one message with recommended values, the evaluation axes (measured axes such as cost and speed, judged axes such as accuracy and quality), their priority order, and one-line outlines of candidates that differ in direction. You only correct what you disagree with.
3. Turns each outline into a concrete challenger one at a time and compares it with the champion. Measured axes are decided by measurement; judged axes are decided by the blind judge agent `cc-judge` once per round, without seeing candidate names or which is current. Per-axis results (win +1 / draw 0 / loss −1) are multiplied by weights derived from your priority order and summed. The challenger is promoted only if the total is positive and the guard axis (accuracy by default) has not worsened beyond its tolerance; a tie or draw keeps the champion.
4. Ends when the champion reaches N consecutive wins (light 2 / standard 4 / strict 6) or hits the round cap (light 5 / standard 13 / strict 28, i.e. 1.5× the expected number of rounds to reach N wins). A losing candidate with a tunable weakness gets one retry after fixing that weakness.
5. If a candidate beat the current implementation, asks for your approval before implementing it, then implements and verifies it.

The evaluation axes, weights, and comparison conditions are fixed before the start and never changed midway. Logs are saved to `tmp/champion-challenger/<theme>/log.md`. Move them elsewhere if you want to keep them.

## Example match log

Rounds and takeaways are recorded in a Markdown table using the [log-template.md](skills/champion-challenger/log-template.md) format:

| Matchup | Winner | Per-axis result and total | Reason | Weakness / Takeaway | Loss kind | Streak |
| --- | --- | --- | --- | --- | --- | --- |
| Current / A: Split error into cause + next action | A | Clarity win (+1) / Length loss (−1) / total +0.5 | Immediately clear what the user should do next | Current only states the cause, not the fix | policy | 1 |
| A / B: Bullet list + links | A | Clarity loss (−1) / Length loss (−1) / total −1 | Too much information clutters the UI | Packed too many items in | tunable (hold) | 2 |
| A / B': Trimmed to 2 bullets | B' | Clarity win (+1) / Length win (+1) / total +1 | Stays concise while making steps clearer | A's steps feel slightly cramped in one sentence | policy | 1 |

## Installation

Requires **Claude Code**.

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
cp champion-challenger/agents/cc-judge.md ~/.claude/agents/
# or, for one project only
cp -r champion-challenger/skills/champion-challenger <project>/.claude/skills/
cp champion-challenger/agents/cc-judge.md <project>/.claude/agents/
```

Restart Claude Code after adding `cc-judge.md`, as it is not loaded until restart. The skill still works without it, but falls back to a general-purpose subagent and uses about 8x more tokens per judgment.

## Usage

Manual invocation only. Claude never triggers it automatically; it runs only when you invoke the command.

```text
/champion-challenger <theme> [light|standard|strict]
```

The strictness keywords are Japanese (`軽め` = light, `標準` = standard, `厳密` = strict).

- Examples: `/champion-challenger test run time reduction 軽め` / `/champion-challenger test run time reduction 厳密`
- If you omit the theme, the skill infers it from the preceding conversation and asks you to confirm. If you omit the strictness, it defaults to standard.
- Token usage is high because it runs multiple rounds. Trying `軽め` (light) first is recommended.

## Configuration

| Item | Default | Where |
| --- | --- | --- |
| Main model / effort | `claude-opus-5-5` / `medium` | `model` and `effort` in [SKILL.md](skills/champion-challenger/SKILL.md) |
| Judge model, effort, and tools | `sonnet` / `low` / `Read` only | Judge section in [SKILL.md](skills/champion-challenger/SKILL.md) and [agents/cc-judge.md](agents/cc-judge.md) |

To change the judge configuration, edit both the judge section in [SKILL.md](skills/champion-challenger/SKILL.md) and [agents/cc-judge.md](agents/cc-judge.md).

Environment overrides and notes:
- The environment variable `CLAUDE_CODE_EFFORT_LEVEL` takes precedence over `effort` in [SKILL.md](skills/champion-challenger/SKILL.md).
- The skill will not work if your organization's `availableModels` forbids the specified models.

## Limitations

- Creating something from scratch is out of scope. You need a current implementation or an initial baseline candidate.
- Judging is Claude's evaluation, not a measurement with real users or a statistical test. Streak counts are rules of thumb, not a significance threshold.
- The judge may rarely promote a candidate that is nearly identical to the champion.
- The judge subagent also reads your `CLAUDE.md`.
- [SKILL.md](skills/champion-challenger/SKILL.md) is written in Japanese. The skill responds in Japanese unless you ask otherwise.

## License

[MIT](LICENSE)
