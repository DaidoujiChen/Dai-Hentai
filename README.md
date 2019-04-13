![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/icon180.png)
======

3.0 傳送門
======
努力生長中的 [3.0 版本](https://github.com/DaidoujiChen/Dai-Hentai/tree/3.0_master)

2.x 預覽圖
======
預覽圖大約 5mb, 請等一下下

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/Dai-Hentai_20141030.gif)

[OptimusKe](https://github.com/OptimusKe)

yeah200077@gmail.com

+

DaidoujiChen

daidoujichen@gmail.com

總覽
======
首先, 這個專案 base on [2DimensionLovers](https://github.com/2DimensionLovers/e-Hentai), 是一個讓 ios device 方便閱讀, 使用, 收藏 e hentai 網站內容的小 app, 由於該網站的內容多半是成人觀看, 如果不喜歡這些內容的話, 請勿使用這個 app, 以及專案, 謝謝.

當然, 撇開內容的部分不談, 程式碼的部分歡迎精進以及指點.

原生 Xcode 直接安裝方法
======
1. 獲取專案(兩種方法)  
  a) 使用 `Download ZIP` 或 `Release` 下載專案打包並解壓縮;  
  b) 通過 `$ git clone https://github.com/DaidoujiChen/Dai-Hentai.git` 複製專案數據庫;  
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
  
Windows / Linux 不需 JB 安裝方法
======
由 [codexss](https://github.com/codexss) 提供不需要 JB 也可以安裝的方法, 因為第三方的軟件沒有開源, 所以不保證整個使用過程的安全性喔, 請要使用的人自行斟酌,

1. 從 [Release](https://github.com/DaidoujiChen/Dai-Hentai/releases) 下載最新版本的 ipa 檔案
2. 從 [Cydia Impactor](http://www.cydiaimpactor.com/) 下載重新打證工具
3. 插上 iPhone 打開 Cydia Impactor 
4. 將 `e-Hentai.ipa` 拖放進 Cydia Impactor 軟件
5. 登上你的蘋果id(安全性待考證)
6. 點擊開始，等待你的手機出現 Dai-Hentai 吧

**需要注意的一點, 這種安裝方式只有七天的賞味期喔, 需要在期限內再裝一次才行**

app icon 與進場圖
======
在 v1.4 版本之後, 會發現 app 不再是白白沒有圖示的樣子了, 不過礙於內容尺度的關係, 並沒有將圖片內含在這個專案的資料夾內, 很感謝 g+ 上的好朋友 [扇扇](https://plus.google.com/u/0/+%E8%8F%AF%E6%89%870402/posts) 願意幫這個忙, 讓這個 app 活在大家裝置裡面的時候不會這麼突兀.

附上這位扇扇大人的一些資料, 如果有興趣製作二次元相關的圖片時, 可以跟她接觸看看,

[扇扇的 g+](https://plus.google.com/u/0/+%E8%8F%AF%E6%89%870402/posts)

[扇扇的 pixiv](http://www.pixiv.net/member.php?id=3225409)

[扇扇的信箱](shanshan910402@gmail.com)

特別感謝
======
感謝網友 [lzs](ggg19960720@gmail.com) 借我可以進入 exHentai 的帳號, 讓我可以完成這部分的功能.

支援
======
- ios7.0 up
- iphone 4" / 3.5"
- ipad

第三方套件
======

- hpple
  - parse html 網頁.

- SDWebImage
  - 異步讀取網路圖片.
  
- LightWeightPlist
  - 我自己隔壁棚的工具, 用來處理 plist 相關事務.

- ReactiveCocoa
  - 好處實在太多, 很難用三言兩語說完.

- FilesManager
  - 在這個專案測試用的工具, 主要用來幫忙管理磁碟存取的動作.

- SupportKit
  - app 內回報系統.

- Chameleon
  - 提供一些不同於系統色的一些額外色調.

- Icons8 App
  - 可以免費取得一些 icon 的小工具.

- SVProgressHUD
  - 換回公定一點的 HUD, 降低錯誤發生率.

- DaiPortalV2
  - 我自己隔壁棚的工具, 導進來試用看看, 一邊做調整, 目前的定位還不是太清楚, 試用中.

- Realm
  - 一個還蠻簡單用的資料庫工具.

- MWPhotoBrowser
  - 看圖片用套件, 本來還是想用 EGO, 不過實在太舊了, 後來找到這個比較新的.

- QuickDialog
  - 用來方便的管理 tableview 形成的設定頁面.

- FXBlurView
  - 模糊效果, 方便好用.

- JDStatusBarNotification
  - 直接在 statusbar 上秀訊息的工具.
  
