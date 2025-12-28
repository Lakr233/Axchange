export const zhConfig = {
  label: "简体中文",
  lang: "zh",
  link: "/zh/",
  title: "Axchange",
  description: "通过 ADB 传输文件",
  themeConfig: {
    nav: [
      { text: "主页", link: "/zh/" },
      { text: "文档", link: "/zh/documents/welcome" },
    ],
    sidebar: [
      {
        text: "获取 Axchange",
        items: [
          { text: "欢迎", link: "/zh/documents/welcome" },
          { text: "下载", link: "/zh/documents/download_app" },
          { text: "从 App Store 下载", link: "/zh/documents/app_store" },
        ],
      },
      {
        text: "启用 Axchange",
        items: [
          { text: "激活软件", link: "/zh/documents/activation" },
          { text: "在设备上启用 ADB", link: "/zh/documents/enable_adb" },
        ],
      },
      {
        text: "操作指南",
        items: [
          { text: "访问", link: "/zh/documents/navigation" },
          { text: "上传", link: "/zh/documents/upload" },
          { text: "下载", link: "/zh/documents/download" },
          { text: "删除", link: "/zh/documents/delete" },
          { text: "重命名", link: "/zh/documents/rename" },
          { text: "新建文件夹", link: "/zh/documents/mkdir" },
          { text: "预览", link: "/zh/documents/preview" },
          { text: "拖拽", link: "/zh/documents/drag_and_drop" },
          { text: "刷新", link: "/zh/documents/refresh" },
          { text: "快捷键", link: "/zh/documents/keyboard_shortcuts" },
          { text: "查看日志", link: "/zh/documents/view_log" },
        ],
      },
      {
        text: "杂项",
        items: [
          { text: "常见问题", link: "/zh/documents/faq" },
          { text: "隐私政策", link: "/zh/documents/privacy_policy" },
          { text: "软件许可", link: "/zh/documents/software_license" },
          { text: "版本更新", link: "/zh/documents/changelog" },
          { text: "问题反馈", link: "/zh/documents/issue" },
        ],
      },
      {
        text: "合作声明",
        items: [{ text: "Axchange x 数码荔枝", link: "/zh/lizhi/index" }],
      },
    ],
    footer: {
      copyright: "© 2024 Axchange 团队，版权所有，盗版必究。",
    },
    outline: {
      label: "页面导航",
    },
    lastUpdatedText: "最后更新于",
    darkModeSwitchLabel: "外观",
    sidebarMenuLabel: "目录",
    returnToTopLabel: "返回顶部",
    langMenuLabel: "选择语言",
    docFooter: {
      prev: "上一页",
      next: "下一页",
    },
  },
};
