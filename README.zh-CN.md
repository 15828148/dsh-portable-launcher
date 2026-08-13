# DSH Web UI 便携启动器

[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness)（`dsh`）Web UI 的 Windows 一键启动器。
对最终用户零配置：缺少 Node.js 和 dsh 组件时自动安装，然后启动本地 Web UI（`http://127.0.0.1:3080`）。

> ⚠️ **非官方社区项目**，与 DeepSeek AI 无关联、未经其认可。
> `deepseek.ico` 使用 DeepSeek 官方 logo，版权归 DeepSeek 所有。

## 功能

- **3 个大阶段实时进度**：`[1/3]` 检查 Node.js → `[2/3]` 检查 dsh 组件 → `[3/3]` 启动
- **零下载快路径**：组件全部就绪时直接启动，不下载、不查网络
- **自动安装便携版 Node.js**（免管理员权限，自动加入用户 PATH）
- **自动安装 dsh**：`npm install -g @deepseek-ai/dsh`（重试时自动切换国内镜像）
- **每步最多重试 3 次**，失败有明确提示，之后给出具体手动操作建议
- **断点续传**：中途关掉黑窗口，重开自动接着完成，不从头再来
- 启动计时日志（`dsh-startup.log`）写在启动器旁边
- 64 位系统检测、目录可写检测、端口占用处理

## 环境要求

- Windows 10/11 64 位
- **不需要**预装 Node.js —— 缺失时自动下载

## 使用方法

1. 从 [Releases](../../releases) 下载 `DSH-Web-UI-便携版.zip`，解压到任意位置
   （如 `D:\` 或桌面 —— **不要放 Program Files**）
2. 双击 `setup.bat` 一次 —— 桌面生成带图标的「DSH Web UI」快捷方式
3. 双击 **DSH Web UI**（或 `dsh-web.bat`）
4. 首次运行：提示下载 Node.js 时按 `Y`；下载需几分钟，属正常
5. 在界面设置中填入你自己的 DeepSeek API Key（[platform.deepseek.com](https://platform.deepseek.com)）

## 工作原理

- 检查 Node.js v22+：缺失或过旧时，从 npmmirror（备用：nodejs.org）下载最新 LTS `win-x64`
  便携版，解压到启动器旁，并加入用户 PATH
- 检查 dsh 组件：缺失时执行 `npm install -g @deepseek-ai/dsh`
- 启动 `dsh web`；后台助手轮询 `http://127.0.0.1:3080`，就绪后自动打开浏览器
- 进度状态保存在启动器旁的标记文件中（`node/`、`dsh-ready.txt`、`dsh-startup.log`），
  这是断点续传和零下载快路径的基础

## 隐私

- 启动器本身无遥测、无统计、不上传任何数据
- API Key 由 dsh 保存在 `%USERPROFILE%\.dsh\.credentials.yaml` —— 绝不会出现在本目录
- 启动器只会下载：npmmirror/nodejs.org 的 Node.js LTS，以及 npm 源上的 `@deepseek-ai/dsh`

## 排障

zip 内的 `使用说明.txt` 有完整 FAQ：SmartScreen 弹窗、微信传文件损坏、目录不可写、
3080 端口被占用、首次运行慢等。失败时窗口会显示 `[1/3] [2/3] [3/3]` 阶段标记并给出操作建议；
仍无法解决可提交 issue 并附上窗口内容。

## 许可证

MIT —— 见 [LICENSE](LICENSE)。
