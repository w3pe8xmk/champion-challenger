# champion-challenger

[English](README.md)

案を1つずつ1対1で比較し、勝った方をチャンピオンとして残す Claude Code の skill です。最終チャンピオンを採用します。UI の文言、プロンプト、設計、名前などの案を絞り込むときに使います。

## 何をするか

1. 現行の案を初代チャンピオンにする。現行がなければ、指定した案を使う
2. 方向性の違う概要案を出し、ユーザーに確認する
3. 概要案から1案ずつチャレンジャーにして、チャンピオンと比べる。判定は別プロセスの審判が案の順序を入れ替えて2回行う。両方で勝った場合のみ昇格し、判定が分かれた場合や `draw` の場合はチャンピオン維持とする
4. N連勝（軽め 3 / 標準 5 / 厳密 7）で終了する
5. 現行を倒した案があれば、実装の前にユーザーに確認し、承認されたら実装して検証する

判定基準と比較条件は、開始前に固定して途中で変えません。ログは `docs/log/`、なければ `tmp/<テーマ>/log.md` に残ります。

## 必要環境

- Claude Code
- node
- bash

## インストール

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
# または、プロジェクト限定
cp -r champion-challenger/skills/champion-challenger <project>/.claude/skills/
```

コピー後に `judge.sh` が実行できなければ、`chmod +x` を付けます。

## 使い方

手動起動専用です。

```text
/champion-challenger <テーマ> [軽め|標準|厳密 または N連勝]
```

- 例: `/champion-challenger 設定画面の文言 軽め` / `/champion-challenger エラーメッセージの言い回し 5連勝`
- テーマを省くと、直前の会話から解釈して確認します。厳密さを省くと「標準」です
- 多ラウンドで実行するので、消費が大きくなります。「軽め」で試してください

### 実行例（skill 自体の description の改善、軽め）

| R | チャレンジャー | 審判の判定（順序A / B） | 結果 | 連勝 |
| --- | --- | --- | --- | --- |
| 1 | 「使う場面／使わない場面」を併記 | チャレンジャー / チャレンジャー | 昇格 | 1 |
| 2 | 起動語を列挙し、対象範囲を明記 | 判定が分かれた | チャンピオン維持 | 2 |
| 3 | 現行の半分に圧縮 | 判定が分かれた | チャンピオン維持 | 3 |

3連勝で終了し、R1 で昇格した案を採用しました。審判6回の費用は約 $0.01 でした。

## 設定

| 項目 | 固定値 | 場所 |
| --- | --- | --- |
| メインエージェントのモデルと effort | `claude-opus-5-5` / `medium` | SKILL.md の `model` と `effort` |
| 審判のモデルと effort | `claude-haiku-5-5` / `medium` | judge.sh |

別の審判を使うときは、`judge.sh` の第2・第3引数にモデル ID と effort を渡します。

固定できないもの:
- 環境変数 `CLAUDE_CODE_EFFORT_LEVEL` は SKILL.md の `effort` より優先されます
- 組織の `availableModels` で指定モデルが禁止されている場合は動きません

## セキュリティ

- SKILL.md は `allowed-tools` で、`judge.sh` の実行を事前承認しています。インストール前に SKILL.md を確認してください
- 審判は隔離して動き、CLAUDE.md・skills・hooks・MCP を読みません

## 制約

- 判定は Claude の評価で、実ユーザーでの測定や統計的検定ではありません。連勝数は経験則で、有意性の基準ではありません
- チャンピオンとほぼ同じ内容の案をまれに誤って昇格させることがあります
- 審判は既定では文面のみを読みます。画像を判定するときは、`JUDGE_TOOLS=Read` を付けて `judge.sh` を呼び、プロンプトに画像のパスを書きます。画像の判定は、単純な合成画像でのみ確認しています
- SKILL.md と審判のプロンプトは日本語で書かれています

## ライセンス

[MIT](LICENSE)
