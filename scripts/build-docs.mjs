import { execSync } from 'node:child_process'
import { cpSync, mkdirSync, rmSync } from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const rootDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const distDir = path.join(rootDir, 'dist')
const docsOutDir = path.join(rootDir, 'docs/.vitepress/dist')

execSync('vitepress build docs', { stdio: 'inherit' })

rmSync(distDir, { recursive: true, force: true })
mkdirSync(path.join(distDir, 'docs'), { recursive: true })
cpSync(path.join(rootDir, 'index.html'), path.join(distDir, 'index.html'))
cpSync(docsOutDir, path.join(distDir, 'docs'), { recursive: true })
