# 儲存內容文件
因為都是隔一段時間隔一段時間在寫, 所以每次都不記得儲存的內容, 然後製作這份文件, =w=.

## 資料庫存放
目前分別把資料存放在三個 NoSQL db 裡面, 分別是

### galleries
做為存放某一個頁面裡面的圖片資訊, 以網址 `https://e-hentai.org/g/1166044/2227d8d6a0/?p=0` 為例, 我們會存入這樣的內容

`````
{  
   "gid":"1166044",
   "token":"2227d8d6a0",
   "index":"0",
   "pages":[  
      "https://e-hentai.org/s/cc24fd08ff/1166044-1",
      "https://e-hentai.org/s/0c3283bed8/1166044-2",
      "https://e-hentai.org/s/c7e111b927/1166044-3",
      "https://e-hentai.org/s/0026f161d2/1166044-4",
      "https://e-hentai.org/s/ef83330451/1166044-5",
      "https://e-hentai.org/s/26e5612415/1166044-6",
      "https://e-hentai.org/s/84301d2ec2/1166044-7",
      "https://e-hentai.org/s/8f51fe812a/1166044-8",
      "https://e-hentai.org/s/96434b9f36/1166044-9",
      "https://e-hentai.org/s/9bb362e474/1166044-10",
      "https://e-hentai.org/s/e7be5523f3/1166044-11",
      "https://e-hentai.org/s/3e713667bc/1166044-12",
      "https://e-hentai.org/s/912f237993/1166044-13",
      "https://e-hentai.org/s/620dec1aa4/1166044-14",
      "https://e-hentai.org/s/cec9b67ebd/1166044-15",
      "https://e-hentai.org/s/faf1b145e8/1166044-16",
      "https://e-hentai.org/s/59fab88d45/1166044-17",
      "https://e-hentai.org/s/d3f9819723/1166044-18",
      "https://e-hentai.org/s/027f784365/1166044-19",
      "https://e-hentai.org/s/8f7f9d2f43/1166044-20",
      "https://e-hentai.org/s/c8c198877a/1166044-21",
      "https://e-hentai.org/s/d8a9eba37a/1166044-22",
      "https://e-hentai.org/s/f794752184/1166044-23",
      "https://e-hentai.org/s/fbee0cdf37/1166044-24",
      "https://e-hentai.org/s/e093aec59b/1166044-25",
      "https://e-hentai.org/s/eabc7afdf0/1166044-26",
      "https://e-hentai.org/s/086e13f9f2/1166044-27",
      "https://e-hentai.org/s/387e85e928/1166044-28",
      "https://e-hentai.org/s/a004e382bb/1166044-29",
      "https://e-hentai.org/s/ee8eeaeed1/1166044-30",
      "https://e-hentai.org/s/8e10459524/1166044-31",
      "https://e-hentai.org/s/395478db7e/1166044-32",
      "https://e-hentai.org/s/12d2881cc0/1166044-33",
      "https://e-hentai.org/s/2275870c7d/1166044-34",
      "https://e-hentai.org/s/852f3f7ef7/1166044-35",
      "https://e-hentai.org/s/0f57155e3d/1166044-36",
      "https://e-hentai.org/s/18d7e053a0/1166044-37",
      "https://e-hentai.org/s/0cbc478042/1166044-38",
      "https://e-hentai.org/s/01f347cd11/1166044-39",
      "https://e-hentai.org/s/1e54c78dee/1166044-40"
   ]
}
`````

因為 gid + token + index 可以指向一個唯一的頁面, 不論在 eh / ex, 不會發生衝突的現象, 我們用這三個值當作一組 key, 可以有效的避免頁面反覆 parse.

### search
存放使用者設定的搜尋條件, 只有唯一的一組, 格式如下

`````
{  
   "artistcg":0,
   "asianporn":0,
   "cosplay":0,
   "doujinshi":0,
   "gamecg":0,
   "imageset":0,
   "keyword":"c93",
   "manga":0,
   "misc":0,
   "non_h":1,
   "rating":0,
   "western":0
}
`````

這個就單純又簡單, 就沒什麼好說的.

### histories
只要是瀏覽過的作品都會被放到這邊, 主要在記錄這部作品的相關資訊

`````
{  
   "category":"Non-H",
   "filecount":"355",
   "filesize":"126.7 MB",
   "gid":"1166044",
   "posted":"2018-01-07 02:46",
   "rating":"4.52",
   "tags":[  
      "highschool dxd",
      "rossweisse",
      "big breasts",
      "demon girl"
   ],
   "thumb":"https://ehgt.org/cc/24/cc24fd08ffa102dd92a565e5627a2d27a414d409-276878-640-800-jpg_l.jpg",
   "timeStamp":1515304499.844339,
   "title":"Highschool DxD - Rossweisse",
   "title_jpn":"",
   "token":"2227d8d6a0",
   "uploader":"chaoticthinker",
   "userLatestPage":0
}
`````

在這邊 gid + token 被拿來當作 key 值, 同一部作品, 只會有一組絕對的 gid + token, 額外的, 這個內容裡面, 存了使用者看到第幾頁, 方便下次觀看時
, 跳到相對應的地方.

## 圖片存放
放在 `Documents` 資料夾下, 直接使用作品名稱當做資料夾名稱, 圖片名稱則為 gid + index.
