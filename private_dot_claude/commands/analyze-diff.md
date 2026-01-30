## 0. 変数定義

以下の擬似言語に従って $TARGET_BRANCH 変数を定義してください。

```
if ($ARGUMENTS == null) {
  // 引数がない場合はデフォルトブランチを格納
  TARGET_BRANCH=$(git remote show origin | grep "HEAD branch" | cut -d' ' -f5)
} else { 
  TARGET_BRANCH=$ARGUMENTS
}
```

## 1. コードの最新化

現在のブランチに $TARGET_BRANCH リモートブランチの最新コードをマージしてください。

```bash
git fetch
git merge origin/$TARGET_BRANCH
```

## 2. ブランチの差分を分析する

origin/$TARGET_BRANCH ブランチと現在のブランチの差分を `git diff` で分析して、

- 全体的な仕様の変更概要
- 各ファイルの変更

を出力してください。
