# estell-dalamud-declarative

estell の Dalamud 配布トラック設定とビルド自動化(`goatcorp/dalamud-declarative` 相当)。

- `config.yaml` … 配布トラックの唯一の真実(キー / 対応ゲームver / ランタイム等)
- `.github/workflows/build-and-publish.yml` … `rioriopu/Dalamud` をビルドし
  `rioriopu/estell-dalamud-distrib` へ配布する自動化

## パッチ当日の手順

1. `rioriopu/Dalamud` の `lib/FFXIVClientStructs` を新パッチ対応へ更新し、必要ならバージョンタグを打つ。
2. Actions →「Build & Publish Dalamud (estell)」→ **Run workflow**:
   - `game_version`: 新ゲームバージョン(例 `2026.06.02.0000.0000`)
   - `dalamud_ref`: ビルドする ref(例 `master` / タグ / sha)
3. 自動で `estell-dalamud-distrib` の Release(タグ `estell`)に `latest.zip` が上がり、
   `estell/version` と `meta.json` が更新される。
4. 改変版 XIVLauncher でベータキー入力 → estell ブランチ選択で配信開始。

## 必要なシークレット

| 名前 | 用途 | 必要権限 |
|---|---|---|
| `DISTRIB_PAT` | distrib への push / Release アップロード | `rioriopu/estell-dalamud-distrib` の Contents: Read/Write(Fine-grained PAT 推奨) |

設定: 本リポジトリ Settings → Secrets and variables → Actions → `DISTRIB_PAT` を追加。

## AssemblyVersion の採番規則

公式 Dalamud は `git describe --tags --long` を AssemblyVersion に使う:

```
15.0.1.1-34-g3730337d3
└─最新タグ─┘ └┘ └──┬───┘
            │     g + 短縮コミットハッシュ
            └ そのタグからのコミット数
```

本 Action はこれに **`-estell.{Actions実行番号}`** を付けて公式と区別する(フォルダ衝突回避):

```
15.0.1.1-34-g3730337d3-estell.5
```

> launcher は `Hooks/{AssemblyVersion}` にインストールするため、公式と必ず別値であることが重要。
