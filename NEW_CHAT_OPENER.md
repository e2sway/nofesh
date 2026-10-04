# Nofesh — New Chat Opener (paste into any AI chat)

> Paste the block below verbatim into a fresh chat, then give one sentence of your current goal.
> The model should read `AGENTS.md` and `Competitive_Teardown.md` in the repo before proposing anything.

---

I work on a project called Nofesh — an iOS (SwiftUI, iOS 17+) app for 2-minute,
silent, zero-sweat "micro-reset" exercises for desk workers, demonstrated by a
consistent 3D clay mannequin. The repo is here:

- Local: `~/Documents/Nofesh`
- GitHub (private): `https://github.com/e2sway/nofesh`
- READ THIS FIRST (in the repo): `AGENTS.md` — it has the architecture, locked product decisions, build commands, and gotchas.
- Research: `Competitive_Teardown.md` (review-mined competitor UX) and `VEO_EXERCISE_CLIP_COOKBOOK_V2.3.md` (the video-generation spec).

Key constraints to respect:
1. Content and product decisions are locked and documented in `AGENTS.md` — read it and don't overturn decisions without strong cause.
2. Builds must use the non-iCloud derived-data path in `AGENTS.md`, or codesign fails.
3. The AI that writes code here can't see images — visual QC is done by a human in the Simulator.
4. App is silent by design (no audio/voice); videos are looping 8s portrait clips of the mannequin.

Current task: <STATE WHAT YOU WANT DONE>

---

Notes: Refresh/extend this file only when a product decision or architecture fact changes —
it's the handoff contract for every new chat.