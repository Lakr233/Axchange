import { readFileSync, writeFileSync } from 'node:fs'
import path from 'node:path/posix'

import { defineConfig } from 'vitepress'
import { llmstxt } from 'vitepress-plugin-llms'

import { enConfig, jaConfig, zhConfig } from './locales'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: '/docs/',

  title: enConfig.title,
  description: enConfig.description,

  head: [['link', { rel: 'icon', href: '/docs/favicon.ico' }]],

  locales: {
    root: enConfig,
    zh: zhConfig,
    ja: jaConfig,
  },
  sitemap: {
    hostname: 'https://axchange.app/docs/',
    lastmodDateOnly: false,
  },
  vite: {
    plugins: [llmstxt()],
  },
  buildEnd() {
    const __dirname = path.dirname(new URL(import.meta.url).pathname)
    const llms = readFileSync(path.join(__dirname, 'dist/llms.txt'), 'utf-8')

    writeFileSync(
      path.join(__dirname, 'dist/llms.txt'),
      llms.replace('# Redirecting...', ''),
    )
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    socialLinks: [
      { icon: 'github', link: 'https://github.com/Lakr233/Axchange' },
    ],
  },
})
