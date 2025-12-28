export const jaConfig = {
  label: "日本語",
  lang: "ja",
  link: "/ja/",
  title: "Axchange",
  description: "ADB経由のAndroidファイル転送",
  themeConfig: {
    nav: [
      { text: "ホーム", link: "/ja/" },
      { text: "ドキュメント", link: "/ja/documents/welcome" },
    ],
    sidebar: [
      {
        text: "Axchangeを入手",
        items: [
          { text: "ようこそ", link: "/ja/documents/welcome" },
          { text: "ダウンロード", link: "/ja/documents/download_app" },
          {
            text: "App Storeからダウンロード",
            link: "/ja/documents/app_store",
          },
        ],
      },
      {
        text: "Axchangeを有効にする",
        items: [
          { text: "ソフトウェアを有効化", link: "/ja/documents/activation" },
          {
            text: "デバイスでADBを有効にする",
            link: "/ja/documents/enable_adb",
          },
        ],
      },
      {
        text: "操作ガイド",
        items: [
          { text: "ナビゲーション", link: "/ja/documents/navigation" },
          { text: "アップロード", link: "/ja/documents/upload" },
          { text: "ダウンロード", link: "/ja/documents/download" },
          { text: "削除", link: "/ja/documents/delete" },
          { text: "名前変更", link: "/ja/documents/rename" },
          { text: "ディレクトリ作成", link: "/ja/documents/mkdir" },
          { text: "プレビュー", link: "/ja/documents/preview" },
          { text: "ドラッグ＆ドロップ", link: "/ja/documents/drag_and_drop" },
          { text: "更新", link: "/ja/documents/refresh" },
          {
            text: "キーボードショートカット",
            link: "/ja/documents/keyboard_shortcuts",
          },
          { text: "ログ閲覧", link: "/ja/documents/view_log" },
        ],
      },
      {
        text: "その他",
        items: [
          { text: "よくある質問", link: "/ja/documents/faq" },
          {
            text: "プライバシーポリシー",
            link: "/ja/documents/privacy_policy",
          },
          {
            text: "ソフトウェアライセンス",
            link: "/ja/documents/software_license",
          },
          { text: "更新履歴", link: "/ja/documents/changelog" },
          { text: "フィードバック", link: "/ja/documents/issue" },
        ],
      },
      {
        text: "協力",
        items: [{ text: "Axchange x Lychee", link: "/ja/lizhi/index" }],
      },
    ],
    footer: {
      copyright: "© 2024 Axchangeチーム。全著作権所有。",
    },
    outline: {
      label: "ページナビゲーション",
    },
    lastUpdatedText: "最終更新",
    darkModeSwitchLabel: "外観",
    sidebarMenuLabel: "メニュー",
    returnToTopLabel: "トップへ戻る",
    langMenuLabel: "言語を選択",
    docFooter: {
      prev: "前へ",
      next: "次へ",
    },
  },
};
