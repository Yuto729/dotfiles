-- アクセスしていないバッファを自動で閉じる
-- https://github.com/chrisgrieser/nvim-early-retirement
return {
  "chrisgrieser/nvim-early-retirement",
  event = "VeryLazy",
  opts = {
    -- この分数だけ非アクティブだったバッファを閉じる
    retirementAgeMins = 20,
    -- 未保存の変更があるバッファは閉じない（false にすると保存してから閉じる）
    ignoreUnsavedChangesBufs = true,
    -- ウィンドウ/タブに表示中のバッファは閉じない
    ignoreVisibleBufs = true,
    -- 直前のバッファ(<C-^> で戻る先)は閉じない
    ignoreAltFile = true,
    -- これ以下の数のバッファしか開いていなければ閉じない
    minimumBufferNum = 1,
    -- 閉じたときに通知を出すか（最初は true で挙動確認すると安心）
    notificationOnAutoClose = false,
  },
}
