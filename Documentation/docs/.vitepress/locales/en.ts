export const enConfig = {
  label: "English",
  lang: "en",
  link: "/en/documents/welcome",
  title: "Axchange",
  description: "Android file transfer via ADB",
  themeConfig: {
    sidebar: [
      {
        text: "Getting Started",
        items: [
          { text: "Welcome", link: "/en/documents/welcome" },
          { text: "Enable ADB on Device", link: "/en/documents/enable_adb" },
        ],
      },
      {
        text: "Operation Guide",
        items: [
          { text: "Navigation", link: "/en/documents/navigation" },
          { text: "Upload", link: "/en/documents/upload" },
          { text: "Download", link: "/en/documents/download" },
          { text: "Delete", link: "/en/documents/delete" },
          { text: "Rename", link: "/en/documents/rename" },
          { text: "Create Directory", link: "/en/documents/mkdir" },
          { text: "Preview", link: "/en/documents/preview" },
          { text: "Drag and Drop", link: "/en/documents/drag_and_drop" },
          { text: "Refresh", link: "/en/documents/refresh" },
          {
            text: "Keyboard Shortcuts",
            link: "/en/documents/keyboard_shortcuts",
          },
          { text: "View Log", link: "/en/documents/view_log" },
        ],
      },
      {
        text: "Misc",
        items: [
          { text: "FAQ", link: "/en/documents/faq" },
          { text: "Privacy Policy", link: "/en/documents/privacy_policy" },
          { text: "Feedback", link: "/en/documents/issue" },
        ],
      },
    ],

    footer: {
      copyright: "© 2024 Axchange Team. All Right Reserved.",
    },
  },
};
