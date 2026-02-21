# 🎯 Gemini 蒙眼竞速

> 由 Google Gemini Live API 驱动的实时 AI 导航竞速游戏。玩家蒙眼，AI 通过摄像头「看见」场地并实时语音导航，率先触碰奖杯者获胜。

---

## 目录

- [English README](README.en.md)
- [玩法介绍](#玩法介绍)
- [文件说明](#文件说明)
- [准备工作](#准备工作)
- [启动服务（局域网/手机访问）](#启动服务)
- [游戏流程](#游戏流程)
- [技术说明](#技术说明)
- [常见问题](#常见问题)

---

## 玩法介绍

| 角色 | 设备 | 职责 |
|------|------|------|
| **玩家** | 手机（蒙眼佩戴） | 听 AI 语音指令行走，找到并触碰奖杯 |
| **裁判** | 电脑或另一部手机 | 操控全景摄像头，AI 自动监控作弊并宣布胜者 |

游戏中没有人需要盯着屏幕喊路——**一切导航和裁判工作全由 Gemini Live AI 完成**，真人裁判只需启动游戏即可。

---

## 文件说明

```
player.html   —— 玩家端：连接麦克风 + 摄像头，接收 AI 语音导航
referee.html  —— 裁判端：连接全景摄像头，AI 监控赛场并宣判
serve.ps1     —— 本地 HTTP 服务器脚本（用于手机访问）
ngrok.exe     —— HTTPS 内网穿透工具（手机浏览器需要 HTTPS）
```

---

## 准备工作

### 1. 获取 Gemini API Key

前往 [Google AI Studio](https://aistudio.google.com/app/apikey) 创建一个 API Key。  
需要开通 **Gemini Live API** 权限（目前需要申请或使用支持 `gemini-2.5-flash-native-audio-preview` 的账号）。

### 2. 安装环境

- Windows 电脑一台（运行服务器和 ngrok）
- 现代浏览器（Chrome / Edge，**不支持 Safari**）
- 若要在手机上使用：需要 ngrok 提供的 HTTPS 地址

---

## 启动服务

> 手机浏览器要求 HTTPS 才能使用麦克风/摄像头，因此需要 ngrok 做内网穿透。

### 第一步：启动本地 HTTP 服务器

在项目目录打开 PowerShell，运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\serve.ps1
```

服务将运行在 `http://localhost:8080`，保持此窗口不要关闭。

### 第二步：启动 ngrok 穿透

另开一个 PowerShell 窗口，运行：

```powershell
.\ngrok.exe http 8080 --host-header="localhost:8080"
```

启动后终端会显示类似：

```
Forwarding  https://xxxx-xxxx.ngrok-free.app -> http://localhost:8080
```

将这个 `https://` 地址分享给玩家手机即可。

### 访问地址

| 页面 | 地址 |
|------|------|
| 裁判端 | `https://你的ngrok地址/referee.html` |
| 玩家端 | `https://你的ngrok地址/player.html` |

> 本机调试也可直接用 `http://localhost:8080/referee.html`。

---

## 游戏流程

### 裁判端操作步骤

1. 打开 `referee.html`，输入 **Gemini API Key**
2. 按需修改「裁判 Game Prompt」和「玩家 Player Prompt」
3. 点击 **「生成连接码」**，再点击 **「复制连接码」**
4. 将连接码（一串字母数字）发送给所有玩家（微信/短信均可）
5. 点击 **「授权摄像头」** → **「连接 Live」**
6. 确认 AI 连接成功后，点击 **「📢 开始游戏」** — AI 会自动宣布比赛开始
7. 游戏过程中 AI 自动播报：作弊警告、位置播报、胜者宣布

### 玩家端操作步骤

1. 手机打开 `player.html`，输入 **Gemini API Key**（或由裁判统一配置）
2. 在「连接码」框中粘贴裁判发来的连接码，点击 **「导入」**
3. 点击 **「授权麦克风＋摄像头」**（手机摄像头朝前，方便 AI 看路）
4. 点击 **「🎮 连接 Live 并开始」**
5. 佩戴眼罩，听 AI 语音指令行走
6. 率先用手触碰奖杯者获胜！

---

## 技术说明

| 组件 | 技术方案 |
|------|----------|
| AI 模型 | `gemini-2.5-flash-native-audio-preview-12-2025` |
| 实时通信 | Gemini Live API（WebSocket 全双工） |
| 音频输入 | 麦克风 → PCM16 16kHz → Gemini |
| 音频输出 | Gemini → PCM16 24kHz → AudioContext 播放 |
| 视频输入 | 摄像头 → JPEG 帧（0.5/1/2 fps 可选）→ Gemini |
| 本地服务器 | PowerShell HttpListener（`serve.ps1`） |
| HTTPS 穿透 | ngrok v3 |
| 无后端 | 纯静态 HTML，所有逻辑在浏览器内运行 |

**思考模式已关闭**（`thinkingBudget: 0`），减少 AI 响应延迟，保证导航实时性。

断线后自动重连（3 秒延迟），覆盖 Gemini Live 的 2 分钟会话超时。

---

## 常见问题

**Q: 手机页面打开但看不到摄像头/麦克风授权弹窗？**  
A: 必须通过 `https://` 地址访问（ngrok 提供），`http://` 或直接打开文件不支持。

**Q: AI 没有声音？**  
A: iOS Safari 有音频自动播放限制，建议使用 Chrome。连接后需至少一次用户交互（如点击按钮）才能解锁音频。

**Q: 连接后 AI 超过 2 分钟会断线？**  
A: 正常现象，页面会自动重连，游戏不会中断。

**Q: 如何修改游戏目标（不是找奖杯）？**  
A: 在裁判端修改「裁判 Game Prompt」和「玩家 Player Prompt」，重新生成连接码即可。

**Q: 多人同时玩怎么办？**  
A: 每位玩家用自己的手机打开 `player.html`，输入同一连接码，各自独立连接 Gemini，AI 会分别为每人导航。

---

## 许可证

MIT License — 自由使用、修改和分发。

---

*Built for the Google Gemini Hackathon Tokyo*