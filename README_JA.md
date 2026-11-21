# champion-challenger

[English](README.md)

現行案（チャンピオン）に対して改善案（チャレンジャー）を1つずつ1対1で挑ませ、勝ち抜いた最終案を採用する「チャンピオン・チャレンジャー方式」の Claude Code skill です。

普通に「良い案をいくつか出して選んで」と頼むと判定基準がブレたり先入観が入ったりしがちですが、この skill では **判定基準の固定・ブラインド審判・現行維持バイアス** によって納得感のある絞り込みを行います。UI の文言、プロンプト、設計、名前、パフォーマンス改善などの絞り込みに使えます。

## 何をするか

1. 現行の案を初代チャンピオンにする。現行がなければ、ユーザーが指定した案を使う。
2. 方向性の違う概要案を出し、ユーザーに確認する。
3. 概要案を1つずつ具体的なチャレンジャー案に仕上げ、チャンピオンと比べる。数値指標がある場合は実測値で判定し、定性比較は案の名前や経緯を伏せた審判エージェント `cc-judge` が1回行う。チャレンジャーが勝った場合のみ昇格し、引き分けの場合はチャンピオンを維持する。
4. チャンピオンが N 連勝（軽め 3 / 標準 5 / 厳密 7）するか、ラウンド上限（`N×3`）に達したら終了する。調整で直せる敗因の案は、弱点を直して1回だけ再挑戦する。
5. 現行を倒した案があれば、実装の前にユーザーへ確認し、承認されたら実装して検証する。

判定基準と比較条件は、開始前に固定して途中で変えません。ログは `docs/log/` があればその配下に、なければ `tmp/<テーマ>/log.md` に保存されます。

## 対戦ログの例

対戦の経過と学びは、[log-template.md](skills/champion-challenger/log-template.md) の形式で Markdown の表として記録されます。

| 対戦 | 勝者 | 判断理由 | 敗因・学び | 敗因の種類 | 連勝 |
| --- | --- | --- | --- | --- | --- |
| 現行 / A: エラー文を原因＋次の行動に分離 | A | ユーザーが次に何をすべきか一目で分かる | 現行は原因のみで対処が不明 | 方針 | 1 |
| A / B: 箇条書き＋リンク付き | A | 情報量が増えて画面が煩雑になる | 項目を詰め込みすぎた | 調整（保留） | 2 |
| A / B': 箇条書きを2点に削減 | B' | 簡潔さを保ちつつ手順がより明確 | A は手順が1文に詰まりやや長い | 方針 | 1 |

## インストール

前提: **Claude Code** が必要です。

### Claude Code プラグイン（推奨）

Claude Code で次を実行します。

```text
/plugin marketplace add w3pe8xmk/champion-challenger
/plugin install champion-challenger@champion-challenger
```

### 手動インストール

```bash
git clone https://github.com/w3pe8xmk/champion-challenger
cp -r champion-challenger/skills/champion-challenger ~/.claude/skills/
cp champion-challenger/agents/cc-judge.md ~/.claude/agents/
# または、プロジェクト限定
cp -r champion-challenger/skills/champion-challenger <project>/.claude/skills/
cp champion-challenger/agents/cc-judge.md <project>/.claude/agents/
```

`cc-judge.md` は再起動するまで読み込まれないため、配置後に Claude Code を再起動してください。配置しなくても動作しますが、その場合は汎用サブエージェントで代用されるため、判定1回あたりのトークン消費が約8倍になります。

## 使い方

手動起動専用です。Claude が自動で呼び出すことはなく、コマンドを実行したときだけ動きます。

```text
/champion-challenger <テーマ> [軽め|標準|厳密 または N連勝]
```

- 例: `/champion-challenger テストの実行時間の短縮 軽め` / `/champion-challenger テストの実行時間の短縮 5連勝`
- テーマを省くと、直前の会話から解釈して確認します。厳密さを省くと「標準」になります。
- ラウンド数が多くなりやすいため、トークン消費が大きくなります。まずは「軽め」で試すのがおすすめです。

## 設定

| 項目 | 既定値 | 設定箇所 |
| --- | --- | --- |
| メインエージェントのモデルと effort | `claude-opus-5-5` / `medium` | [SKILL.md](skills/champion-challenger/SKILL.md) の `model` と `effort` |
| 審判のモデル・effort・ツール | `sonnet` / `low` / `Read` のみ | [SKILL.md](skills/champion-challenger/SKILL.md) の「審判への依頼」と [agents/cc-judge.md](agents/cc-judge.md) |

審判の設定を変えるときは、[SKILL.md](skills/champion-challenger/SKILL.md) の「審判への依頼」と [agents/cc-judge.md](agents/cc-judge.md) の両方を編集します。

環境による上書き・注意点:
- 環境変数 `CLAUDE_CODE_EFFORT_LEVEL` は [SKILL.md](skills/champion-challenger/SKILL.md) の `effort` より優先されます。
- 組織の `availableModels` で指定モデルが禁止されている場合は動作しません。

## 制約

- ゼロからの新規作成は対象外です。現行実装か、ベースとなる案が必要です。
- 判定は Claude による評価であり、実ユーザーでの測定や統計的検定ではありません。連勝数は経験則であり、統計的な有意性の基準ではありません。
- 審判が、チャンピオンとほぼ同じ内容の案をまれに誤って昇格させてしまうことがあります。
- 審判のサブエージェントも `CLAUDE.md` を読み込みます。
- [SKILL.md](skills/champion-challenger/SKILL.md) は日本語で書かれています。

## ライセンス

[MIT](LICENSE)
