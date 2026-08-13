# DSH Web UI Portable Launcher

One-click launcher for [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) (`dsh`) Web UI on Windows.
Zero-config for end users: it auto-installs a portable Node.js and the `dsh` package when missing, then starts the local
Web UI at `http://127.0.0.1:3080`.

> ⚠️ **Unofficial community project.** Not affiliated with or endorsed by DeepSeek AI.
> The `deepseek.ico` icon uses the DeepSeek logo, © DeepSeek.

## Features

- **3 major stages with live progress**: `[1/3]` Node.js check → `[2/3]` dsh package check → `[3/3]` launch
- **Zero-download fast path**: when everything is already installed, launch is direct — no downloads, no registry checks
- **Automatic portable Node.js install** (no admin required; added to the user PATH)
- **Automatic dsh install** via `npm install -g @deepseek-ai/dsh` (switches to the China npm mirror on retries)
- **Up to 3 retries per step** with clear prompts, then concrete manual instructions
- **Resume support**: close the window mid-setup, run again — it continues from where it stopped
- Boot-time log (`dsh-startup.log`) written next to the launcher
- 64-bit check, writable-folder check, port-conflict handling

## Requirements

- Windows 10/11 x64
- Node.js is **not** required — it is downloaded automatically if missing

## Usage

1. Download `DSH-Web-UI-便携版.zip` from [Releases](../../releases) and extract it anywhere
   (e.g. `D:\` or Desktop — **not** Program Files)
2. Run `setup.bat` once — creates a desktop shortcut "DSH Web UI" with the icon
3. Double-click **DSH Web UI** (or `dsh-web.bat`)
4. First run: press `Y` if asked to download Node.js; downloads take a few minutes
5. Add your own DeepSeek API key in the UI Settings ([platform.deepseek.com](https://platform.deepseek.com))

## How it works

- Checks for Node.js v22+; if missing or too old, downloads the latest LTS `win-x64` portable build
  from npmmirror (fallback: nodejs.org), extracts it next to the launcher, and adds it to the user PATH
- Checks for the `dsh` package; if missing, runs `npm install -g @deepseek-ai/dsh`
- Launches `dsh web`; a background helper polls `http://127.0.0.1:3080` and opens the browser when ready
- Progress state lives in marker files next to the launcher (`node/`, `dsh-ready.txt`, `dsh-startup.log`),
  which is what makes resume and the zero-download fast path possible

## Privacy

- No telemetry, no analytics, nothing phone-home by the launcher itself
- Your API key is stored by dsh in `%USERPROFILE%\.dsh\.credentials.yaml` — never in this folder
- The launcher only downloads: Node.js LTS from npmmirror/nodejs.org, and `@deepseek-ai/dsh` from the npm registry

## Troubleshooting

The zip contains `使用说明.txt` (Chinese) with the full FAQ: SmartScreen prompts, WeChat file corruption,
folder-not-writable, port 3080 in use, slow first run, and more. If something fails, the window shows
`[1/3] [2/3] [3/3]` stage markers and tells you exactly what to do — or open an issue with the window content.

## License

MIT — see [LICENSE](LICENSE).
