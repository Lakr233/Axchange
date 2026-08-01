export const zhConfig = {
  label: "简体中文",
  lang: "zh",
  link: "/zh/documents/welcome",
  title: "Axchange",
  description: "通过 ADB 传输文件",
  themeConfig: {
    sidebar: [
      {
        text: "开始使用",
        items: [
          { text: "欢迎", link: "/zh/documents/welcome" },
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
          { text: "问题反馈", link: "/zh/documents/issue" },
        ],
      },
    ],
    footer: {
      copyright: "© 2024 Axchange 团队，版权所有。",
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
