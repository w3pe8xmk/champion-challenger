#!/usr/bin/env bash
# 審判を1回実行し、structured_output（JSON）を1行で標準出力に出す。失敗したら1回やり直す。
# 使い方: judge.sh <プロンプトファイル> [モデル ID] [effort。実験用。既定 medium]
# モデル・effort は固定（既定 claude-haiku-5-5 / medium）。
# 画像などファイルを読ませる場合のみ、環境変数 JUDGE_TOOLS=Read を付ける（既定はツールなし）。
set -uo pipefail
prompt_file="${1:?prompt file required}"
model="${2:-claude-haiku-5-5}"
effort="${3:-medium}"
tools="${JUDGE_TOOLS:-}"
schema='{"type":"object","properties":{"winner":{"enum":["X","Y","draw"]},"reason":{"type":"string"},"loser_weakness":{"type":"string"},"loss_kind":{"enum":["policy","tunable"]},"unverified":{"type":"string"}},"required":["winner","reason","loser_weakness","loss_kind"]}'
parse='
let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{
  let j;try{j=JSON.parse(s)}catch(e){console.error("judge failed: invalid JSON");process.exit(1)}
  if(j.is_error||!j.structured_output){console.error("judge failed: "+(j.result||"no structured_output"));process.exit(1)}
  console.log(JSON.stringify({...j.structured_output,cost_usd:j.total_cost_usd}))})'
for attempt in 1 2; do
  env -u CLAUDE_CODE_EFFORT_LEVEL -u ANTHROPIC_MODEL claude -p --safe-mode --tools "$tools" --model "$model" --effort "$effort" --no-session-persistence \
    --output-format json --json-schema "$schema" < "$prompt_file" | node -e "$parse" && exit 0
done
exit 1
