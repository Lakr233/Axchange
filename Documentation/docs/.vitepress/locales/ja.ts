export const jaConfig = {
  label: "日本語",
  lang: "ja",
  link: "/ja/documents/welcome",
  title: "Axchange",
  description: "ADB経由のAndroidファイル転送",
  themeConfig: {
    sidebar: [
      {
        text: "はじめに",
        items: [
          { text: "ようこそ", link: "/ja/documents/welcome" },
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
          { text: "フィードバック", link: "/ja/documents/issue" },
        ],
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
