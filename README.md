# libtwins

* Twinsより情報をスクレイピング
  * 履修状況
  * 修得単位
  * などなど...
* Twinsに情報を入れ込む(予定)
  * [quads](https://github.com/rkmathi/quads)等と連携して、履修データを投げ入れる
  * 科目区分等の変更をできるようにする

## 使い方
テンプレで。
```
include LibTwins
@account = LibTwins::LibTwins.new do
  id "統一認証のID"
  password "統一認証のパスワード"
end
unless @account.login
  puts "ログインに失敗しました"
  # 保守とかもあるのでその辺りはてきとー
end
```
