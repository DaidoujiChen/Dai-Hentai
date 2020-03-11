# Dai-Hentai 3.0

## 總覽
這個專案是一個讓 iOS 裝置方便閱讀, 使用, 收藏 e / ex hentai 網站內容的 App, 由於該網站的內容多半是成人觀看, 如果不喜歡這些內容的話, 請勿使用 >x<, 感恩

當然, 撇開內容的部分不談, 程式碼的部分或是使用上有任何問題, 都歡迎提出指教 >w<

下面的縮圖點擊後可以導向 youtube 觀看大致上功能使用的影片

<a href="http://www.youtube.com/watch?feature=player_embedded&v=DqkIxhpzP9s
" target="_blank"><img src="http://img.youtube.com/vi/DqkIxhpzP9s/0.jpg" 
alt="newHentai" width="240" height="180" border="10" /></a>

整體的使用體驗應該會比 2.x 來的穩定跟快速, 也加上了上鎖的功能, 讓大家在使用上可以更安心一些 =w=

## Tag 中文轉換
感謝隔壁的朋友有整理好的 tag 可以查找了, 所以這邊的轉換參考內容都是從 [https://github.com/Mapaler/EhTagTranslator](https://github.com/Mapaler/EhTagTranslator) 來的, 深表感謝

## 原生 Xcode 直接安裝方法
1. 獲取專案（兩種方法）

 - 使用 `Download ZIP` 或 `Release` 下載專案打包並解壓縮；
 - 通過 `$ git clone https://github.com/DaidoujiChen/Dai-Hentai.git` 複製專案數據庫；
 
2. 重建（還原） `Pods`
  ![](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2016-12-07+%E4%B8%8A%E5%8D%8810.27.08.png)

 ```bash
 $ cd Dai-Hentai # 進入專案目錄
 $ pod install # 不要使用 pod update
```

 *如果無法使用 `pod` 指令, 請先安裝 [CocoaPods](https://cocoapods.org/)*

 ```bash
 sudo gem install cocoapods
```
3. 開啓專案
  **請選擇 `e-Hentai.xcworkspace` 而非 `e-Hentai.xcodeproj` 呦**

  ![](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2016-10-22+%E4%B8%8B%E5%8D%8810.26.35.png)
  
## Windows / Linux 不需 JB 安裝方法
後來 [VVVVictorJ](https://github.com/VVVVictorJ) 提出 Cydia Impactor 已經沒有辦法安裝囉, 可以使用 [shinrenpan](https://github.com/shinrenpan) 提到的 [AltStore](https://altstore.io/) 試試

**需要注意的一點, 這種安裝方式只有七天的賞味期喔, 需要在期限內再裝一次才行**

## 支援
- iOS9.0 以上
- iPhone / iPad

## 最新測試版本試玩

[點我導向 appetize](https://appetize.io/embed/qk23vcyrmbtecy7n12h6118wa4?device=iphone7&scale=100&orientation=portrait&osVersion=10.0&deviceColor=white)

但是由於是免費帳號, 所以試玩一個月只有 100 分鐘的額度, 付費每一分鐘 0.05 鎂, 成本實在過高, 有玩到的人只能說有拜拜, 沒有玩到的人可以直接用下面的 IPA 檔案...如果能的話啦 O3Ob

## 最新測試版本 IPA

因為懶惰所以懶得每次一直手動發布版本, 所以用了一個自動生產 ipa 的服務, 會在每當有新的 commit 時運作

![](https://app.bitrise.io/app/446db4b9b316a724.svg?token=I0YMFQ8S5i30cN95ZVgvhw)

^^^^^^^^^^^^^ 上面這串文字為 `Bitrise Passing` 時, 可以取得最新的版本

版本的識別由兩個部分組合而成
  * [版本號](https://github.com/DaidoujiChen/Dai-Hentai/blob/3.0_master/Dai-Hentai/Info.plist#L18)
  * [Build號](https://github.com/DaidoujiChen/Dai-Hentai/blob/3.0_master/Dai-Hentai/Info.plist#L20)

可以組成如下的網址

```
https://s3-ap-northeast-1.amazonaws.com/dai-hentai-ipa/bitrise/{版本號}_{Build號}/Dai-Hentai.ipa
```

以當前編譯文件時的範例網址為 `https://s3-ap-northeast-1.amazonaws.com/dai-hentai-ipa/bitrise/1.0_201703090649/Dai-Hentai.ipa`

## 1 鎂捐獻箱
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=N86FK92G3V4BS)
<img alt="" border="0" src="https://www.paypalobjects.com/zh_TW/i/scr/pixel.gif" width="1" height="1">

[捐獻紀錄表](https://docs.google.com/spreadsheets/d/17eY6Hi2Ol-tbb3pL11yRoAg6SeNKa-plj4VJvSuPQY8/edit#gid=0)
