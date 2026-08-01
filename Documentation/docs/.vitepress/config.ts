import { defineConfig } from 'vitepress'

import { enConfig, jaConfig, zhConfig } from './locales'

// The documentation ships inside the app bundle and is served from the root of
// Documentation.bundle by the in-app scheme handler, so the base stays '/'.
export default defineConfig({
  base: '/',

  title: enConfig.title,
  description: enConfig.description,

  head: [['link', { rel: 'icon', href: '/favicon.ico' }]],

  locales: {
    root: enConfig,
    zh: zhConfig,
    ja: jaConfig,
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    search: {
      provider: 'local',
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/Lakr233/Axchange' },
    ],
  },
})
