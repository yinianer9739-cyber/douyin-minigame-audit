# douyin-minigame-audit

`douyin-minigame-audit` is a Codex skill for reviewing Douyin mini-game submission materials before platform approval.

It focuses on Chinese YAML/Markdown submission inputs, asset package folders, and optional Unity/Godot/HTML project folders. It checks the submission against the official Douyin Open Platform mini-game norms index included in `references/official-norms.md`.

## What It Reviews

- Basic game information: name, soft copyright name, filing name, category, art style, age rating.
- Submission copy: short description, detailed description, update notes, keywords.
- Assets: icon, screenshots, video covers, promo videos, posters, loading images.
- Gameplay and capabilities: login, sharing, ranking, chat, UGC, location, privacy, minors, multiplayer.
- Monetization: ads, IAP, CPA/CPT/CPM/CPS anchors, traffic promotion, game station, Jianying template.
- Compliance materials: software copyright, filing materials, privacy policy, user agreement, authorization files.
- Optional project scan: Unity, Godot, or HTML/Web project directory.

## Install

Copy the `douyin-minigame-audit` folder into your Codex skills directory:

```text
C:\Users\<YourUser>\.codex\skills\douyin-minigame-audit
```

Restart Codex or your current AI client after installation.

## Trigger Phrases

You can invoke the skill explicitly:

```text
Use $douyin-minigame-audit to review my submission.
```

Common Chinese trigger phrases:

```text
启动抖音提审
抖音小游戏提审
检查抖音过审风险
帮我审核抖音小游戏
```

## Typical Input

Use the Chinese YAML template:

```text
assets/audit-input.zh.yaml
```

Recommended saved location for a real project:

```text
<资料包目录>/.douyin-minigame-audit/audit-input.yaml
```

On later audits, you can say `继续` and provide only changed fields. The skill will look for saved audit input/state under `.douyin-minigame-audit/`.

## Daily Update Check

The skill includes:

```powershell
scripts/check-update.ps1
```

On the first use each local day, the skill checks GitHub for a newer `VERSION`. If an update is installed, restart Codex or the current AI client. After restarting, return to the conversation and say `继续` to resume the unfinished audit flow from the saved input/state.

## Package a Release

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\package-release.ps1
```

The zip is generated under:

```text
release/douyin-minigame-audit-v<VERSION>.zip
```

Upload that zip to GitHub Releases.

## License

MIT License. See `LICENSE`.
