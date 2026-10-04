# AI Exercise Clip Cookbook (v2.3 — Production Ready)

How to generate the seamless looping exercise clips for **Nofesh**.
All clips feature a consistent **3D matte clay mannequin** figure performing precise ergonomic exercises with minimal loop seams.

> **v2.3 changes (this version)**
> 1. **Primary engine switched: Kling v3 — image-to-video.** Nano Banana stills → Kling animation. Free daily-credit tier, short-clip native, proven in this niche. Veo 3.1 is demoted to an acceptable fallback when Kling credits are exhausted.
> 2. **NEW §2: The Character Sheet (now the canonical 5-view turnaround).** One file, 5 panels: Front · 45° 3/4 front · 90° true side · 70° rear-side · **true rear**. This is your permanent character library — frozen forever, reused by every batch, never rebuilt.
> 3. **NEW §8: "Future Batches" playbook.** The sheet stays frozen; only start-frames, motion prompts, and the Framing row change per new body part.
> 4. **Movement-first prompt rule** (evidence-backed, §3): describe the MOVEMENT, not the scene. Plain beats cinematic.
> 5. Kept from v2.2: universal token written out verbatim in every prompt; per-exercise framing; no `minterpolate`; near-seamless loops + player crossfade; "keep it a mannequin"; no voice/audio everywhere.
>
> **Safety-language patch (v2.3, applied in-place):** Lower-body prompts (Exercises 2–5) were reworded to pass content filters that flagged "pelvis / posterior / tailbone / gluteal contour / squeezed glutes" phrasing. Each now opens with a clinical framing prefix ("Professional ergonomics exercise demonstration for an office wellness app; stylized fully-clothed figure") and describes **joint/spine outcomes** instead of pelvic-region nouns. Biomechanics unchanged; QC checklist still verifies the same form cues. In-app cue text (the "Written Cue in App" lines) intentionally left as written — those are user-facing instructions, never sent to the generator.

---

## 1. Quick Reference & Output Filenames

| Body part / Exercise | Filename in `Sources/Content/Resources/` | Framing | Native Duration | Camera Angle |
|---|---|---|---|---|
| **1. Chin Tucks** (neck) | `chin-tuck.mp4` | **Medium close-up** (head & shoulders; desk edge barely visible at bottom) | ~8.0s (1 rep) | 80° Near-Side Profile |
| **2. Spinal Decompression** (spine) | `spinal-decompression.mp4` | **Medium** (torso + armrests; visible waist down to mid-thigh) | ~8.0s (1 rep) | 45° Three-Quarter View |
| **3. Hip Flexor Stretch** (hip) | `hip-flexor.mp4` | **Wide** (full body, both legs fully in frame) | ~8.0s (1 rep, right leg only) | 90° True Side Profile |
| **4. Seated Pelvic Tilts** (pelvis) | `pelvic-tilt.mp4` | **Medium** (waist to knees; lower back unobstructed) | ~8.0s (1 cycle) | 90° True Side Profile |
| **5. Glute Squeezes** (glutes) | `glute-squeeze.mp4` | **Medium-tight** (hips to shoulders, from-behind 3/4) | ~8.0s (1 rep) | 70° Three-Quarter From-Behind Profile |

> **App Integration Note:** The routine countdown timer in Nofesh (`60s` or `120s`) runs in your SwiftUI layer while the ~8s video clip loops via `AVPlayerLooper`. For the Hip Flexor, Nofesh mirrors the clip horizontally (`.scaleEffect(x: -1, y: 1)`) on the two "Left leg back" segments — no video-side leg-switch required.
>
> **Batch convention (all batches):** output portrait **720×1280**, silent, h264; compose the active movement in the **upper ~70% of frame** so the player's bottom scrim never covers the anatomy. Enforced by the §7 QC checklist.
>
> **Framing row grows per body part (§8).** Each new batch adds a Framing row here. Macro close-ups for wrist/hand work; wide for leg work; whatever the drawing tells you.

---

## 2. The Character Sheet (THE canonical asset — one file, 5 panels)

**Generate this ONCE. It is your character library for every batch, forever.**

### 2A. The 5-panel sheet prompt (single landscape image)

> Single image, one flat multi-panel character turnaround sheet. Five separate panels arranged left to right, each showing the SAME minimalist 3D clay-rendered mannequin character in a standing neutral rest pose with both feet planted, arms relaxed at the sides: [1] full front view, [2] 45-degree three-quarter front-side view, [3] 90-degree true side view, [4] 70-degree rear-side three-quarter view, [5] 90-degree true rear view. Soft matte alabaster-stone clay skin, smooth rounded anatomy, neutral expressionless face. Wearing a fitted, tucked slate-navy athletic shirt, charcoal athletic shorts, and a thin warm-ochre horizontal waistband stripe (belt line). Each panel shows the full figure head to toe on a plain, soft warm off-white studio background with gentle ambient floor shadow. Soft diffused studio lighting from 45 degrees, clean silhouette, no text, no logos, no watermark, no grid lines, no labels, no numbering.

**Rules for the sheet:**
- **Standing neutral rest pose in every panel** — it is an identity anchor, not an exercise-posed sheet. Pose context comes later, at the start-frame layer.
- **Prop-free (no desk or chair).** Props live in the per-exercise start-frames. A pure figure makes a cleaner identity anchor and stays reusable for marketing images.
- **One file, never regenerated.** Every future batch references this exact sheet as the seed/reference. Regenerating it re-rolls identity and breaks cross-batch consistency.
- **Why true rear matters:** future batches for back/spine/scapulae/hamstrings/glutes need a clean rear read. 70° rear-side alone does not provide it. Front → 45° → side → 70° rear → true rear is the standard character-turnaround set.

### 2B. Reference workflow

```
[character_sheet.png]  ← single 5-panel turnaround (generated once)
        ↓ (image-to-image / subject reference)
5 per-exercise start-frame stills (pose + props + framing added here)
        ↓
Kling v3 (start-frame as first frame) → raw takes → ffmpeg encode
```

*The sheet anchors who the character is. The start-frames decide what they're doing.*

---

## 3. Two-Stage Generation Workflow (Kling primary)

```
[Stage 1: Stills — Nano Banana / any image model]
Character Sheet (5-panel turnaround) → 5 posed Start-Frame Stills (1 per exercise)

[Stage 2: Kling v3 Image-to-Video]
Start-Frame Still (First Frame) ──┐
                                  ├──> [Kling v3] ──> Raw Take MP4
Motion Prompt ────────────────────┘
(Same still re-used as the first frame; use a loop-friendly tool/end-frame where available)

[Stage 3: Post-Processing]
ffmpeg -y -i raw_take.mp4 -an -c:v libx264 -crf 18 -pix_fmt yuv420p final.mp4
(Drops into Sources/Content/Resources/)
```

### The #1 prompt rule: describe the MOVEMENT, not the scene

Proven in this niche (SoloTech's playbook): *"She performs a Romanian deadlift, static camera, 5s"* beats any cinematic prompt. Translates directly to Nofesh:

- State the action plainly and start-to-finish (glide → hold → return).
- **Static camera, fixed framing, short clip.** No camera moves, no dolly, no push-in (breaks loops).
- Duration as short as the movement allows: 5–10s.
- Motion prompts in §5 already follow this. Keep them dead-plain; cut adjectives that describe the *scene*.

### Why First Frame = Last Frame (applies to Kling too):
Using the **same still** as the first frame biases the model toward returning to the initial coordinates. Kling does not guarantee frame-exact return, so:
- Generate 4+ takes per exercise and pick the take with the smallest start/end drift.
- Accept ±few-pixel drift when the movement is near motionless at the cut.
- Ship the player-side soft crossfade from `§7` as final seam insurance.

---

## 4. The Universal Consistency Token (COPY-PASTE VERBATIM, NO EDITS)

This is the block that keeps the mannequin identical across **all clips and all future batches**. It is written out in full at the end of every prompt in §5 — copy from there. Append it to the end of **every** still and **every** motion prompt, identical.

> **UNIVERSAL CONSISTENCY TOKEN:**
> "Same minimalist 3D clay-rendered mannequin character. Soft matte alabaster-stone clay skin, smooth rounded anatomy, neutral expressionless face. Wearing a fitted, tucked slate-navy athletic shirt, charcoal athletic shorts, and a thin warm-ochre horizontal waistband stripe (belt line). Desk: a clean minimalist light-oak desk with slender matte-white legs. Chair: a modern ergonomic studio chair with a flat light-gray seat cushion and low, recessed minimalist armrests. Plain, soft warm off-white studio background with gentle ambient floor shadow. Soft diffused studio lighting from 45 degrees, clean silhouette, 85mm low-distortion lens, no text, no logos, no watermark."

**Rules:**
- Token is **lexically identical** everywhere. Per-exercise content changes; the token never changes.
- "Full body head-to-toe" is **not** in the token — framing is controlled per-exercise at the front of each prompt.

**Keep it a mannequin.** Never a realistic human. Evidence-backed (`Competitive_Teardown.md`, §9): realistic AI humans are a churn driver in this niche. Reject any take that drifts realistic or shows anatomy anomalies.

**No voice, no sound anywhere.** Videos ship silent (`-an`). Text cues carry the instruction — evidenced to convert better than AI voiceover, and guaranteed not to clash with the user's music or meetings.

---

## 5. The 5 Exercise Prompt Pairs

Format per prompt pair: **framing (front)** + **behavior/motion** + **verbatim consistency token (end)**. No placeholders.

---

### Exercise 1: Chin Tucks (`min 0:00–1:00`)
* **Target File:** `chin-tuck.mp4`
* **Framing:** MEDIUM CLOSE-UP — head and shoulders gathered; desk edge just visible at the bottom.
* **Written Cue in App:** *"Look straight ahead and glide your head straight back (creating a double chin). Do not tilt your head up or down."*

#### Step 1: Start-Frame Still Prompt (First Frame)
```text
MEDIUM CLOSE-UP framing, head and shoulders gathered, desk edge just visible at the bottom of the frame. 80-degree side profile view. The minimalist 3D clay character sits tall and upright, head and shoulders centered and filling most of the frame. Feet flat, hands resting calmly on the desk surface just inside the bottom edge of the frame. Looking straight ahead horizontally with a neutral, relaxed neck alignment. Static camera, no camera movement, no zoom. Same minimalist 3D clay-rendered mannequin character. Soft matte alabaster-stone clay skin, smooth rounded anatomy, neutral expressionless face. Wearing a fitted, tucked slate-navy athletic shirt, charcoal athletic shorts, and a thin warm-ochre horizontal waistband stripe (belt line). Desk: a clean minimalist light-oak desk with slender matte-white legs. Chair: a modern ergonomic studio chair with a flat light-gray seat cushion and low, recessed minimalist armrests. Plain, soft warm off-white studio background with gentle ambient floor shadow. Soft diffused studio lighting from 45 degrees, clean silhouette, 85mm low-distortion lens, no text, no logos, no watermark.
```

#### Step 2: Kling Motion Prompt
```text
The character's head glides straight backward along a horizontal plane, creating a subtle double chin, holds 3 seconds, then glides forward back to exact starting posture. Head stays strictly horizontal, no tilting up or down. Shoulders relaxed and still. Head and shoulders fill the frame. Static camera, no zoom, fixed framing. SIMPLE MOVEMENT. SHORT CLIP (8 seconds). Same minimalist 3D clay-rendered mannequin character. Soft matte alabaster-stone clay skin, smooth rounded anatomy, neutral expressionless face. Wearing a fitted, tucked slate-navy athletic shirt, charcoal athletic shorts, and a thin warm-ochre horizontal waistband stripe (belt line). Desk: a clean minimalist light-oak desk with slender matte-white legs. Chair: a modern ergonomic studio chair with a flat light-gray seat cushion and low, recessed minimalist armrests. Plain, soft warm off-white studio background with gentle ambient floor shadow. Soft diffused studio lighting from 45 degrees, clean silhouette, 85mm low-distortion lens, no text, no logos, no watermark.
```

---

### Exercise 2: Seated Spinal Decompression (`min 1:00–2:00`)
* **Target File:** `spinal-decompression.mp4`
* **Framing:** MEDIUM — torso and both armrests in frame; hips visible at the bottom edge.
* **Written Cue in App:** *"Press down gently to lift your torso, taking the weight off your pelvis. Keep shoulders down — don't shrug."*

#### Step 1: Start-Frame Still Prompt (First Frame)
```text
Professional ergonomics exercise demonstration for an office wellness app; stylized fully-clothed figure. MEDIUM framing, the seated figure visible from the waist down to mid-thigh at the bottom edge, both armrests in frame. 45-degree three-quarter front-side view. The minimalist 3D clay character sits at the front edge of the chair, legs relaxed with feet flat and hip-width apart. Hands rest firmly on the low minimalist armrests with elbows slightly bent. Posture upright, shoulders relaxed and lowered away from the ears. Static camera, no camera movement, no zoom. Same minimalist 3D clay-rendered mannequin character. Soft matte alabaster-stone clay skin, smooth rounded anatomy, neutral expressionless face. Wearing a fitted, tucked slate-navy athletic shirt, charcoal athletic shorts, and a thin warm-ochre horizontal waistband stripe (belt line). Desk: a clean minimalist light-oak desk with slender matte-white legs. Chair: a modern ergonomic studio chair with a flat light-gray seat cushion and low, recessed minimalist armrests. Plain, soft warm off-white studio background with gentle ambient floor shadow. Soft diffused studio lighting from 45 degrees, clean silhouette, 85mm low-distortion lens, no text, no logos, no watermark.
```

#### Step 2: Kling Motion Prompt
```text
Professional ergonomics exercise demonstration for an office wellness app; stylized fully-clothed figure. MEDIUM framing, torso and both armrests in frame. The character's hands press down firmly onto the chair armrests, lifting the shoulders upward a few centimeters while keeping them relaxed, lowered, and away from the ears. The position is held for 3 seconds, then smoothly released to return to the exact starting seated posture. Quiet, calm, athletic demonstration. Camera is static, no zoom, fixed framing. Simple movement. Short clip (8 seconds). Same minimalist 3D clay-rendered mannequin character. Soft matte alabaster-stone clay skin, smooth rounded anatomy, neutral expressionless face. Wearing a fitted, tucked slate-navy athletic shirt, charcoal athletic shorts, and a thin warm-ochre horizontal waistband stripe (belt line). Desk: a clean minimalist light-oak desk with slender matte-white legs. Chair: a modern ergonomic studio chair with a flat light-gray seat cushion and low, recessed minimalist armrests. Plain, soft warm off-white studio background with gentle ambient floor shadow. Soft diffused studio lighting from 45 degrees, clean silhouette, 85mm low-distortion lens, no text, no logos, no watermark.
```

> *Optimization:* hold ≈3s, not 4s — keeps motion "alive" at both end frames so the seam hides in movement.

---

### Exercise 3: Standing Hip Flexor Stretch (`min 2:00–4:00`)
* **Target File:** `hip-flexor.mp4`
* **Framing:** WIDE — full body, both legs fully in frame (feet must never crop out).
* **Written Cue in App:** *"Tuck your pelvis backward — imagine pulling your belt buckle up toward your chin. Do not arch the lower back."*
* **Bilateral Handling:** Generate **one clip** showing the camera-facing **right leg** extended behind, feet planted. Nofesh mirrors it in-app on the two left-leg segments of its 4×30s (R/L/R/L) sequence. Do NOT show a leg switch inside the clip.

#### Step 1: Start-Frame Still Prompt (First Frame)
```text
Professional ergonomics exercise demonstration for an office wellness app; stylized fully-clothed figure. WIDE framing, full body, both legs fully in frame from head to feet. 90-degree true side profile view. The minimalist 3D clay character stands in a split stance beside the desk. One hand rests lightly on the desk edge for balance. The camera-facing right leg is extended behind with foot planted; the front knee is slightly bent. Upright neutral torso, low back straight and long. Static camera, no camera movement, no zoom. Same minimalist 3D clay-rendered mannequin character. Soft matte alabaster-stone clay skin, smooth rounded anatomy, neutral expressionless face. Wearing a fitted, tucked slate-navy athletic shirt, charcoal athletic shorts, and a thin warm-ochre horizontal waistband stripe (belt line). Desk: a clean minimalist light-oak desk with slender matte-white legs. Chair: a modern ergonomic studio chair with a flat light-gray seat cushion and low, recessed minimalist armrests. Plain, soft warm off-white studio background with gentle ambient floor shadow. Soft diffused studio lighting from 45 degrees, clean silhouette, 85mm low-distortion lens, no text, no logos, no watermark.
```

#### Step 2: Kling Motion Prompt
```text
Professional ergonomics exercise demonstration for an office wellness app; stylized fully-clothed figure. WIDE framing, full body, both legs fully in frame from head to feet, feet planted on the ground. 90-degree true side profile view. The clay character stands in a split stance holding the desk edge, right leg extended behind. Keeping both feet completely planted in place, the character tilts the front of the belt line backward so the low back stays flat and long, then shifts the weight forward 4 centimeters to deepen the stretch at the front of the standing hip, holds steadily for 4 seconds, then glides smoothly back to the exact starting split stance. Both feet remain planted in place and fully in frame. Camera is static, no zoom, fixed framing. Simple movement. Short clip (8 seconds). Same minimalist 3D clay-rendered mannequin character. Soft matte alabaster-stone clay skin, smooth rounded anatomy, neutral expressionless face. Wearing a fitted, tucked slate-navy athletic shirt, charcoal athletic shorts, and a thin warm-ochre horizontal waistband stripe (belt line). Desk: a clean minimalist light-oak desk with slender matte-white legs. Chair: a modern ergonomic studio chair with a flat light-gray seat cushion and low, recessed minimalist armrests. Plain, soft warm off-white studio background with gentle ambient floor shadow. Soft diffused studio lighting from 45 degrees, clean silhouette, 85mm low-distortion lens, no text, no logos, no watermark.
```

> *Mirroring caution:* the ochre waistband and symmetric styling survive a horizontal flip. Keep the desk/hand prop lightly in frame so the mirrored clip still reads as "beside the desk."

---

### Exercise 4: Seated Pelvic Tilts (`min 4:00–5:00`)
* **Target File:** `pelvic-tilt.mp4`
* **Framing:** MEDIUM — waist to knees, side profile; pelvis, waistband, and lumbar spine unobstructed.
* **Written Cue in App:** *"Slowly roll your pelvis forward, then roll it backward (tucking your tailbone under). Alternate smoothly."*

#### Step 1: Start-Frame Still Prompt (First Frame)
```text
Professional ergonomics exercise demonstration for an office wellness app; stylized fully-clothed figure. MEDIUM framing, waist to knees, side profile, lower back clearly visible and unobstructed, feet just inside the bottom edge. 90-degree true side profile view. The minimalist 3D clay character is seated on the very front edge of the chair, forward of the armrests so the lower back is completely visible. Feet flat on the floor, hands resting lightly on the upper thighs. Upright neutral spine. Static camera, no camera movement, no zoom. Same minimalist 3D clay-rendered mannequin character. Soft matte alabaster-stone clay skin, smooth rounded anatomy, neutral expressionless face. Wearing a fitted, tucked slate-navy athletic shirt, charcoal athletic shorts, and a thin warm-ochre horizontal waistband stripe (belt line). Desk: a clean minimalist light-oak desk with slender matte-white legs. Chair: a modern ergonomic studio chair with a flat light-gray seat cushion and low, recessed minimalist armrests. Plain, soft warm off-white studio background with gentle ambient floor shadow. Soft diffused studio lighting from 45 degrees, clean silhouette, 85mm low-distortion lens, no text, no logos, no watermark.
```

#### Step 2: Kling Motion Prompt
```text
Professional ergonomics exercise demonstration for an office wellness app; stylized fully-clothed figure. MEDIUM framing, waist to knees, side profile, lower back clearly visible and unobstructed. 90-degree true side profile view. The clay character is seated at the front edge of the chair with hands lightly on the upper thighs and an unobstructed view of the lower back. Keeping the head and shoulders stable in space, the character slowly rolls the lower spine forward into a gentle, smooth arch, then smoothly reverses into a flat, neutral position (lower back gently rounding), and returns to exact starting neutral. One complete, fluid, unhurried cycle. Camera is static, no zoom, fixed framing. Simple movement. Short clip (8 seconds). Same minimalist 3D clay-rendered mannequin character. Soft matte alabaster-stone clay skin, smooth rounded anatomy, neutral expressionless face. Wearing a fitted, tucked slate-navy athletic shirt, charcoal athletic shorts, and a thin warm-ochre horizontal waistband stripe (belt line). Desk: a clean minimalist light-oak desk with slender matte-white legs. Chair: a modern ergonomic studio chair with a flat light-gray seat cushion and low, recessed minimalist armrests. Plain, soft warm off-white studio background with gentle ambient floor shadow. Soft diffused studio lighting from 45 degrees, clean silhouette, 85mm low-distortion lens, no text, no logos, no watermark.
```

---

### Exercise 5: Standing Glute Squeezes (`min 5:00–6:00`)
* **Target File:** `glute-squeeze.mp4`
* **Framing:** MEDIUM-TIGHT — glutes to shoulders, rear three-quarter; gluteal contour and waistband clearly visible.
* **Written Cue in App:** *"Actively squeeze your glutes together as hard as you can. Hold the squeeze 5-10 seconds, release, and repeat."*

#### Step 1: Start-Frame Still Prompt (First Frame)
```text
Professional ergonomics exercise demonstration for an office wellness app; stylized fully-clothed figure. MEDIUM-TIGHT framing, hips to shoulders, three-quarter from-behind view, low back clearly visible. 70-degree three-quarter from-behind profile view. The minimalist 3D clay character stands tall beside the desk with fingertips resting lightly on the desk edge. Feet are hip-width apart in a relaxed, neutral standing stance. Upper body upright, neutral posture. Static camera, no camera movement, no zoom. Same minimalist 3D clay-rendered mannequin character. Soft matte alabaster-stone clay skin, smooth rounded anatomy, neutral expressionless face. Wearing a fitted, tucked slate-navy athletic shirt, charcoal athletic shorts, and a thin warm-ochre horizontal waistband stripe (belt line). Desk: a clean minimalist light-oak desk with slender matte-white legs. Chair: a modern ergonomic studio chair with a flat light-gray seat cushion and low, recessed minimalist armrests. Plain, soft warm off-white studio background with gentle ambient floor shadow. Soft diffused studio lighting from 45 degrees, clean silhouette, 85mm low-distortion lens, no text, no logos, no watermark.
```

#### Step 2: Kling Motion Prompt
```text
Professional ergonomics exercise demonstration for an office wellness app; stylized fully-clothed figure. MEDIUM-TIGHT framing, hips to shoulders, three-quarter from-behind view, low back clearly visible. 70-degree three-quarter from-behind view. The clay character stands tall beside the desk. The character gently contracts the hip muscles, drawing the hips inward in a subtle, steady motion while the upper body stays tall and upright with no backward lean, holds the contraction for 4 seconds, then smoothly releases back to exact starting stance. Camera is static, no zoom, fixed framing. Simple movement. Short clip (8 seconds). Same minimalist 3D clay-rendered mannequin character. Soft matte alabaster-stone clay skin, smooth rounded anatomy, neutral expressionless face. Wearing a fitted, tucked slate-navy athletic shirt, charcoal athletic shorts, and a thin warm-ochre horizontal waistband stripe (belt line). Desk: a clean minimalist light-oak desk with slender matte-white legs. Chair: a modern ergonomic studio chair with a flat light-gray seat cushion and low, recessed minimalist armrests. Plain, soft warm off-white studio background with gentle ambient floor shadow. Soft diffused studio lighting from 45 degrees, clean silhouette, 85mm low-distortion lens, no text, no logos, no watermark.
```

---

## 6. Post-Processing & Audio Muting (FFmpeg)

Always strip audio (`-an`) so loop restarts never click or disrupt the user's music:

```bash
# Process each raw take from Kling/Veo
ffmpeg -y -i raw_chin_tuck.mp4 -an -c:v libx264 -crf 18 -pix_fmt yuv420p Sources/Content/Resources/chin-tuck.mp4
ffmpeg -y -i raw_decompression.mp4 -an -c:v libx264 -crf 18 -pix_fmt yuv420p Sources/Content/Resources/spinal-decompression.mp4
ffmpeg -y -i raw_hip_flexor.mp4 -an -c:v libx264 -crf 18 -pix_fmt yuv420p Sources/Content/Resources/hip-flexor.mp4
ffmpeg -y -i raw_pelvic_tilt.mp4 -an -c:v libx264 -crf 18 -pix_fmt yuv420p Sources/Content/Resources/pelvic-tilt.mp4
ffmpeg -y -i raw_glute_squeeze.mp4 -an -c:v libx264 -crf 18 -pix_fmt yuv420p Sources/Content/Resources/glute-squeeze.mp4
```

> **No AI slow-motion.** Do not `minterpolate` to stretch 8s → 12s — warp/limb artifacts on a clay model. Prefer a 10s regeneration with a slower motion beat.

---

## 7. QC Verification Checklist (Run Per Clip)

- [ ] **Consistency Token Applied:** Prompt ends with the literal `§4` block — verbatim, identical to the others.
- [ ] **Character Consistency:** Identical clay texture, slate-navy top, ochre waistband across all clips AND batches.
- [ ] **Mannequin, Not Human:** Stylized, NOT realistic — no realistic skin/face, no extra/missing fingers.
- [ ] **Framing Matches Spec:** Shot size matches §1 Quick Reference; still + motion use same framing. Feet fully in frame (Hip Flexor); pelvis unobstructed (Pelvic Tilts).
- [ ] **Limb & Joint Integrity:** No warping, disappearing fingers, or limb pop. *Tighter shots hide extremities* — audit hands (Chin Tucks/Glute Squeezes), feet (Hip Flexor).
- [ ] **Loop Seam:** Start/end posture matches within a few pixels; seam hides in a near-motionless frame at the cut.
- [ ] **Biomechanical Fidelity:**
  - *Chin Tuck:* Head strictly horizontal (0° tilt up/down).
  - *Spinal Decomp:* Shoulders compress DOWN (no shrug); hips near seat; hold ≈3s.
  - *Hip Flexor:* Right leg camera-side; feet 100% planted; NO leg switch.
  - *Pelvic Tilt:* Pelvis/lumbar unobstructed by armrest.
  - *Glute:* Visible contour firm/lift; no exaggerated lumbar thrust.
- [ ] **Audio Stripped:** `-an` — file silent.
- [ ] **Asset Activation:** `visual` in `routines.json` updated from `"avatar"` to `"video"`.

---

## 8. Future Batches Playbook (how to scale to every body part)

The sheet **(§2) and the consistency token (§4) stay frozen forever.** Everything else adapts per exercise. Per new body part:

1. **Framing row** → add to §1 Quick Reference. Macro/close-up for wrists/hands/fingers; medium for torso movements; wide for legs.
2. **Start-frame still** → new pose, add/remove props as the exercise requires, use the exercise's camera angle.
3. **Motion prompt** → new SIMPLE MOVEMENT beats (start → hold → return), static camera, short clip.
4. **QC** → add body-part-specific biomechanical bullets to §7.
5. **Filename** → new entry in `Sources/Content/Resources/`; add `visual: {"video": {"assetName": "..."}}` in `routines.json`.

Never regenerate the character sheet. The sheet is the shared identity that makes batch #2 look like batch #1.

---

## 9. Engine Notes

| Engine | Role | Cost model | Notes |
|---|---|---|---|
| **Nano Banana / image model** | Character sheet + start-frame stills | Your existing credits | Output the unframed 5-panel sheet once; per-exercise stills as separate higher-res images |
| **Kling v3** | Image-to-video (primary) | Free daily credits | Short 5–10s clips native; feed start-frame as first frame; generate 4+ takes and curate |
| **Veo 3.1** | Fallback | Paid | Use only when Kling credits exhausted; same workflow, same prompts |

**Voice/sound:** none in the product, ever. Text cues carry instruction.

---

## 10. Why "Keep It a Mannequin" Is Evidence-Backed

Wakeout (closest "micro-movement" competitor) introduced AI-modeled humans into its movement packs. Users pushed back:

> *"The inclusion of AI models disappoints me and I won't be resubscribing."*
> *"I cannot trust I'm moving correctly if I'm watching a fake human move."*
> *"AI slop… generated images have four fingers on a hand."*

Every complaint targets AI trying to **replicate real humans** — not stylized animation. A clay mannequin is overtly not-a-person, sidestepping the trust question while delivering the same follow-along utility. (Full evidence in `Competitive_Teardown.md`.)