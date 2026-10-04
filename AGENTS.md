# Nofesh — Agent Context

Desk micro-mobility app ("Nofesh" is a working name). 2-minute, silent, zero-sweat
reset routines for desk workers, guided by a consistent 3D clay mannequin.
iOS / SwiftUI, iOS 17+.

## Repo / structure

- GitHub: `https://github.com/e2sway/nofesh` (private)
- Local path: `~/Documents/Nofesh`
- `project.yml` — XcodeGen config. **Do not hand-edit `Nofesh.xcodeproj`**; regenerate with `xcodegen generate`.
- `Sources/` — Swift app code
  - `Models/Content.swift` — exercise data model (`RoutineBlock`, `Exercise`, `ExerciseSegment`, `ExerciseVisual`)
  - `Content/routines.json` — **the content source of truth**: 3 blocks / 5 exercises, cues verbatim from the source exercise doc
  - `Content/Resources/*.mp4` — final video clips (bundled into the app)
  - `Views/` — Onboarding, Home, Preflight, Player, UpgradePrompt, Settings, Root
  - `Visualization/ExerciseVisualView.swift` — renders video (aspectFit + blurred backdrop) or the CAD avatar placeholder
  - `Models/AppSettings.swift` — @Observable app state (onboarding, permissions, environment)
  - `Services/CalendarService.swift` + `NotificationService.swift` — EventKit + UNUserNotificationCenter wiring
- `VEO_EXERCISE_CLIP_COOKBOOK_V2.3.md` — **the generation spec** (character sheet, prompt tokens, per-exercise prompts, QC checklist, future-batch playbook). Authoritative for any video/prompt work.
- `Competitive_Teardown.md` — review-mined competitor research (Wakeout, Bend, Stand Up!, Pliability, Moova). Read before making UX/conversion decisions.
- `_generation/` — COOKBOOK & RESEARCH AGENTS: regenerable stills/raw takes. **Gitignored.** Final clips live in `Sources/Content/Resources/`.
- `character_sheet.*` — canonical 5-view mannequin turnaround. Identity anchor; never regenerate casually.

## Product decisions (locked — do not overturn without a strong reason)

- **Content = 2-minute "micro-breaks"**, silent, text-cue-driven. No voice, no audio, ever.
- **Character = stylized clay mannequin, NOT a realistic AI human** (evidence: Wakeout AI-human backlash — users don't trust fake human form).
- **Permissions are deferred until after the FIRST completed reset** (one combined "enable gaps + nudges" prompt). No permission dialogs on onboarding or first loop. This replaced two dead/mis-timed paths — don't reintroduce in-routine prompts.
- **Player stage is portrait (9:16), aspect-agnostic renderer** (aspectFit + blurred backdrop, never crops).
- The exercise **"why this helps"** copy stays a slim card below the stage; title+cue live in the bottom scrim.

## Build / run (critical gotchas)

```bash
cd ~/Documents/Nofesh
xcodegen generate   # after any project.yml change
# Build to a NON-iCloud derived data path — building inside Documents/
# re-triggers iCloud com.apple.provenance xattrs and breaks codesign:
xcodebuild -project Nofesh.xcodeproj -scheme Nofesh \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath "/var/folders/8t/xhvrmj016jgcrss64gyb96c80000gn/T/opencode/nofesh-build" build
```

- The xcodegen `project.yml` has a `postCompileScripts` step that strips iCloud xattrs before signing — keep it.
- `./encode.sh` — takes raw takes from `_generation/raw/` → muted/crf18 `mp4`s into `Sources/Content/Resources/`.
- Feed one video frame/shot to the mannequin; clips are simple 8s loops.

## Video generation pipeline (if asked to add/modify content)

1. Consult the cookbook (V2.3) for tokens, framing, and QC — never invent new descriptors.
2. Reuse the frozen 5-view character sheet; generate per-exercise start-frame stills + motion takes.
3. Encode via `encode.sh`, then point `routines.json` `exercise.visual` at the asset.

## Decision logging convention (mandatory)

**Whenever a product/architecture decision is locked, record it in this file in the
same commit as the code change.** Without this, handoffs go stale and a future agent
may overturn a settled decision.

Rules:
1. Add the decision under "Product decisions (locked)" (or a new dated subsection
   if it's architectural) in the **same commit** that implements/changes it.
2. Format: keep it one bolded bullet, outcome-first, with a short rationale in parentheses.
3. If you rename/deprecate an earlier decision, strike it out — don't silently delete.
4. When a new chat starts, read this file top to bottom before proposing anything;
   treat every bullet as settled unless the human explicitly reopens it.

## Environment / agent notes

- This dev box: Apple M5, 24GB RAM. Xcode 26.4, iOS 26.4 SDK, simulators available (iPhone 17 Pro etc.).
- CLI is fine for: builds, `simctl` install/launch/log, JSON validation, git/gh.
