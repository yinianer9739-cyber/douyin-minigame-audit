# Changelog

## 0.3.0 - 2026-07-01

- Add a first-trigger intake gate so bare trigger phrases ask whether this is a new or existing project instead of producing an empty audit result.
- Save audit inputs under project-scoped state directories using project names and aliases.
- Add project nickname fields to the Chinese YAML/Markdown templates.
- Separate missing legal/company-owned materials from the compliance judgment for already provided content.
- Add a contract test for the skill workflow and persistence rules.

## 0.2.2 - 2026-07-01

- Improve the Chinese YAML audit template with explicit local path fields for icons, screenshots, covers, videos, and compliance files.
- Add word-count guidance and examples for submission copy fields.
- Add official option references for category, theme, art style, and age rating.
- Add inline reference hints that point users to the relevant option sections inside the YAML template.

## 0.2.1 - 2026-07-01

- Add Chinese trigger phrases to `SKILL.md` discovery metadata.
- Document common trigger phrases in `README.md`.

## 0.2.0 - 2026-07-01

- Add daily update check support through `scripts/check-update.ps1`.
- Add restart/resume guidance after skill update installation.
- Add release packaging script through `scripts/package-release.ps1`.
- Add README, LICENSE, VERSION, and release package support for GitHub publishing.

## 0.1.0 - 2026-07-01

- Initial `douyin-minigame-audit` skill.
- Add Chinese YAML/Markdown audit input templates.
- Add official Douyin mini-game norms index covering 20 official documents.
- Add audit input save helper.
