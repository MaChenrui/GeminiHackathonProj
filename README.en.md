# 🎯 Gemini Blindfolded Treasure Hunt

> A real-time AI navigation racing game powered by the Google Gemini Live API.  
> Players are blindfolded. AI watches through the camera and guides them by voice — first to touch the trophy wins.

---

## Table of Contents

- [How It Works](#how-it-works)
- [File Overview](#file-overview)
- [Prerequisites](#prerequisites)
- [Starting the Server (LAN / Mobile Access)](#starting-the-server)
- [Game Flow](#game-flow)
- [Technical Details](#technical-details)
- [FAQ](#faq)

---

## How It Works

| Role | Device | Responsibility |
|------|--------|----------------|
| **Player** | Smartphone (worn blindfolded) | Follows AI voice instructions to walk and find the trophy |
| **Referee** | PC or another phone | Points a wide-angle camera at the arena; AI automatically monitors for cheating and announces the winner |

No human needs to shout directions — **all navigation and refereeing is handled by Gemini Live AI**. The human referee only needs to click "Start Game".

---

## File Overview

```
player.html   —  Player page: captures mic + camera, receives AI voice navigation
referee.html  —  Referee page: captures panoramic camera, AI monitors arena and judges
serve.ps1     —  Local HTTP server script (required for mobile access)
ngrok.exe     —  HTTPS tunneling tool (mobile browsers require HTTPS for camera/mic)
```

---

## Prerequisites

### 1. Get a Gemini API Key

Go to [Google AI Studio](https://aistudio.google.com/app/apikey) and create an API key.  
Your account must have access to the **Gemini Live API** (requires a model supporting `gemini-2.5-flash-native-audio-preview`).

### 2. Environment

- A Windows PC to run the local server and ngrok
- A modern browser on the PC: **Chrome or Edge** (Safari is not supported)
- For mobile access: ngrok provides the required HTTPS URL

---

## Starting the Server

> Mobile browsers require HTTPS to access the microphone and camera. ngrok creates a secure tunnel from the internet to your local server.

### Step 1 — Start the local HTTP server

Open PowerShell in the project folder and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\serve.ps1
```

This starts a server at `http://localhost:8080`. Keep this window open.

### Step 2 — Start ngrok

Open a second PowerShell window and run:

```powershell
.\ngrok.exe http 8080 --host-header="localhost:8080"
```

The terminal will show something like:

```
Forwarding  https://xxxx-xxxx.ngrok-free.app -> http://localhost:8080
```

Share that `https://` URL with the players' phones.

### Access URLs

| Page | URL |
|------|-----|
| Referee | `https://your-ngrok-address/referee.html` |
| Player | `https://your-ngrok-address/player.html` |

> For local testing on the same PC, you can use `http://localhost:8080/referee.html` directly.

---

## Game Flow

### Referee Setup

1. Open `referee.html` and enter your **Gemini API Key**.
2. Optionally edit the **Referee Game Prompt** and **Player Prompt** to customize the game objective.
3. Click **「生成连接码」(Generate Connection Code)**, then **「复制连接码」(Copy Code)**.
4. Send the connection code (a short alphanumeric string) to all players via any messaging app.
5. Click **「授权摄像头」(Authorize Camera)** → **「连接 Live」(Connect Live)**.
6. Once connected, click **「📢 开始游戏」(Start Game)** — the AI will announce the start automatically.
7. The AI handles everything from here: cheating warnings, position updates, and announcing the winner.

### Player Setup

1. Open `player.html` on your phone and enter a **Gemini API Key** (or have the referee pre-configure one).
2. Paste the connection code from the referee into the **Connection Code** field and tap **「导入」(Import)**.
3. Tap **「授权麦克风＋摄像头」(Authorize Mic + Camera)** — point your phone camera forward so the AI can see the path.
4. Tap **「🎮 连接 Live 并开始」(Connect & Start)**.
5. Put on your blindfold and follow the AI's voice instructions.
6. First player to touch the trophy wins!

---

## Technical Details

| Component | Implementation |
|-----------|----------------|
| AI Model | `gemini-2.5-flash-native-audio-preview-12-2025` |
| Real-time Communication | Gemini Live API (full-duplex WebSocket) |
| Audio Input | Microphone → PCM16 16 kHz → Gemini |
| Audio Output | Gemini → PCM16 24 kHz → Web AudioContext |
| Video Input | Camera → JPEG frames (0.5 / 1 / 2 fps selectable) → Gemini |
| Local Server | PowerShell HttpListener (`serve.ps1`) |
| HTTPS Tunnel | ngrok v3 |
| Backend | None — pure static HTML, all logic runs in the browser |

**Thinking mode is disabled** (`thinkingBudget: 0`) to minimize AI response latency and keep navigation real-time.

Sessions automatically reconnect after a 3-second delay, covering Gemini Live's 2-minute session timeout.

---

## FAQ

**Q: The camera/microphone permission prompt never appears on my phone.**  
A: You must access the page via an `https://` URL (provided by ngrok). Pages opened via `http://` or as local files do not have access to media devices.

**Q: There is no audio from the AI.**  
A: iOS Safari has strict autoplay restrictions — use Chrome on Android or desktop Chrome/Edge instead. Audio may also be blocked until the user interacts with the page (e.g., taps a button).

**Q: The connection drops after ~2 minutes.**  
A: This is expected — Gemini Live sessions have a 2-minute limit. The page will automatically reconnect and resume without interrupting the game.

**Q: How do I change the game objective (not a trophy hunt)?**  
A: Edit the **Referee Game Prompt** and **Player Prompt** in `referee.html`, then regenerate and share a new connection code.

**Q: Can multiple players participate simultaneously?**  
A: Yes. Each player opens `player.html` on their own phone, pastes the same connection code, and connects to Gemini independently. The AI navigates each player separately.

---

## License

MIT License — free to use, modify, and distribute.

---

*Built for the Google Gemini API Developer Competition 2026*
