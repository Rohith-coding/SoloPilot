# SoloPilot — Figma Design Specification

> Use this to recreate the prototype in Figma, or as a reference for the Flutter build.

---

## Design System

### Colours

| Token | Hex | Usage |
|-------|-----|-------|
| Primary | `#0D9488` | Buttons, links, accents, scan highlights |
| Primary Dark | `#0F766E` | Button hover/pressed |
| Primary Light | `#CCFBF1` | Badges, light backgrounds |
| Accent | `#4F46E5` | Draft icon background, smart reply chips |
| Accent Light | `#E0E7FF` | Smart reply chip background |
| Background | `#F8FAFC` | Screen background |
| Surface | `#FFFFFF` | Cards, modals, inputs |
| Surface Dim | `#F1F5F9` | Hover states, secondary backgrounds |
| Text | `#0F172A` | Primary text |
| Text Secondary | `#64748B` | Labels, descriptions |
| Text Muted | `#94A3B8` | Hints, disabled |
| Border | `#E2E8F0` | Dividers, input borders |
| Danger | `#DC2626` | Destructive actions |
| Success | `#16A34A` | Positive actions |
| Overdue BG | `#FEE2E2` | Overdue chip/card |
| Overdue Text | `#991B1B` | Overdue chip text |
| Paid BG | `#DCFCE7` | Paid chip/card |
| Paid Text | `#166534` | Paid chip text |
| Pending BG | `#F1F5F9` | Pending chip/card |
| Pending Text | `#475569` | Pending chip text |

### Typography

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Display | 28px | 800 | Invoice amount |
| Title Large | 24px | 800 | App title on Home |
| Title | 20px | 700 | Screen titles |
| Body Large | 16px | 700 | Receipt heading |
| Body | 15px | 400/600 | Invoices, inputs, buttons |
| Body Small | 14px | 400 | Descriptions, greeting |
| Caption | 13px | 600 | Labels, filter chips, section titles |
| Overline | 12px | 600 | Badge text, date labels |
| Tiny | 11px | 500/600 | Nav labels, status chips, notification app name |

**Font stack:** System fonts (SF Pro on iOS, Roboto on Android, Segoe UI on Windows).

### Spacing

| Token | Value |
|-------|-------|
| Page padding | 16px |
| Card padding | 16px |
| Card margin | 0 16px 12px |
| Section gap | 12px |
| Button gap | 10px |
| Input gap (label to field) | 6px |
| Between inputs | 14px |

### Radii

| Element | Radius |
|---------|--------|
| Cards | 16px |
| Buttons | 16px |
| Inputs | 8px |
| Chips/Badges | 20px |
| Avatars | 50% (circle) |
| Phone frame (desktop) | 44px |
| Notification icon | 10px |

### Shadows

| Token | Value |
|-------|-------|
| Default | `0 1px 3px rgba(0,0,0,.08), 0 1px 2px rgba(0,0,0,.06)` |
| Large | `0 4px 12px rgba(0,0,0,.1)` |
| Phone frame | `0 20px 60px rgba(0,0,0,.4)` |

### Min Tap Target

48×48px for all interactive elements.

---

## Screens

### 1. Home ("Today")

**Frame:** `Home` (390×844)

**Components:**
- **Status Bar** (44px height)
  - Left: Time (HH:MM, 14px weight 600)
  - Right: Airplane icon (16×16 SVG), Battery icon (16×16 SVG)
- **Greeting Section** (padding 16px)
  - Greeting text (14px, text-secondary)
  - "SoloPilot" title (24px, weight 800)
  - Offline badge (12px, primary-light bg, primary-dark text, pill shape)
- **Summary Card: Drafts** (card component)
  - Icon: 📝 on accent-light background (48×48, radius 14px)
  - Count (22px, weight 700) + "drafts to approve" label
  - Tappable → navigates to Invoices (filtered: Overdue)
- **Summary Card: Overdue** (card component)
  - Icon: ⚠️ on overdue-bg (48×48, radius 14px)
  - Count + "invoices overdue" label
  - Tappable → navigates to Invoices (filtered: Overdue)
- **Action Buttons** (row, 10px gap)
  - "Scan" — btn-primary with QR icon, pulse-glow animation on first run
  - "New invoice" — btn-secondary with plus icon
- **Section Title** "Recent invoices" (13px, uppercase, 1px letter-spacing)
- **Invoice List Items** (repeating)
  - Avatar circle (42px, coloured by name hash, initials)
  - Client name (15px, weight 600) + due date (12px, muted)
  - Amount (15px, weight 700) + status chip

**Interactions:**
- Notification banner slides in from top after 2s (stays 5s)
- Tapping notification → Invoices (Overdue filter)
- Tapping overdue card → Invoices (Overdue filter)
- Tapping drafts card → Invoices (Overdue filter)
- Tapping Scan → Scan screen
- Tapping New Invoice → Review screen (empty)
- Tapping invoice item → Invoice detail

### 2. Scan

**Frame:** `Scan` (390×844)

**Components:**
- **Top Bar** — back arrow (40×40 circle) + "Scan" title
- **Instruction text** (14px, centred, text-secondary)
- **"Take photo" button** — btn-primary, full width, camera icon, pulse-glow
- **Paste section**
  - Label "Paste a client message" (13px, weight 600)
  - Textarea (3 rows, 15px)
  - "Use sample" chip (btn-outline, small) + "Extract" button (btn-primary, small)
- **Smart Reply Chips** (hidden until sample is loaded)
  - 3 chips: accent border, accent-light bg
  - Tapping copies reply text (snackbar confirmation)
- **Divider** "— or —"
- **Dictate button** — btn-secondary, mic icon

**Scan Animation State:**
- Receipt mockup (HTML-drawn, dashed border area)
  - "INVOICE" heading, Client/Service/Date/Total rows
- Green scan line (3px, animated top-to-bottom)
- 3 highlight boxes (primary border, semi-transparent bg) appear after 2s
- Status text: "Capturing…" → "Reading on-device…" → "✓ Found 3 fields"
- Auto-advances to Review after 3.5s

**Mic Animation State:**
- "Listening…" label
- Waveform (20 bars, 4px wide, animated wave)
- Transcript area (typing animation, monospace-ish)
- Auto-advances to Review

### 3. Review

**Frame:** `Review` (390×844)

**Components:**
- **Top Bar** — back arrow + "Review details"
- **Instruction** "You're always in control — edit anything." (14px)
- **Input: Client name** — text input, required
- **Input: Amount (₹)** — number input, required, min 1
- **Input: Issued date** — date input
- **Input: Due date** — date input
- **Collapsible: "Recognised text"** — chevron, monospace content
- **"Create invoice" button** — btn-primary, full width

**Validation:** Client required, amount > 0. Error messages in red (12px) below inputs.

### 4. Invoice Detail

**Frame:** `Invoice` (390×844)

**Components:**
- **Top Bar** — back arrow + "Invoice"
- **Invoice Card** (large, shadow-lg)
  - Header: status chip (centred), amount (28px, weight 800), client name
  - Body: Issued / Due / Invoice # rows
- **Button Row:**
  - "Paid" — btn-success, check icon (hidden if already paid)
  - "PDF" — btn-secondary, download icon
- **"Draft reminder"** — btn-danger, full width, pulse-glow (only if overdue)

**PDF Modal:**
- Bottom sheet (border-radius top 16px)
- Invoice preview with rows, total, "Generated on-device by SoloPilot" footer
- Close button

### 5. Invoices List

**Frame:** `Invoices` (390×844)

**Components:**
- **Top Bar** — "Invoices" title (no back, accessible via bottom nav)
- **Filter Bar** — horizontal scroll, 4 chips: All / ⏳ Pending / ⚠ Overdue / ✓ Paid
  - Active: primary border, primary-light bg
- **Invoice List** — same item component as Home
- **Empty State** — document icon (64px, 50% opacity) + "No invoices here yet"

### 6. Reminder Draft

**Frame:** `Reminder` (390×844)

**Components:**
- **Top Bar** — back arrow + "Payment reminder"
- **Shimmer State** (1.5s)
  - "Writing on-device…" label (centred)
  - 4 shimmer bars (gradient animation)
- **Content State:**
  - "Written by on-device AI" label with check icon (12px, muted)
  - Textarea (7 rows) — message with typing animation
  - Button row: "Edit" (btn-secondary) + "Approve" (btn-primary)
  - "Send (simulated)" — btn-primary, full width (appears after approve)

---

## Navigation Wiring

```
Home
├── Scan button → Scan
├── New Invoice → Review (empty)
├── Overdue card → Invoices (filtered: Overdue)
├── Drafts card → Invoices (filtered: Overdue)
├── Notification banner → Invoices (filtered: Overdue)
└── Invoice item → Invoice Detail

Scan
├── Take Photo → [animation] → Review (pre-filled)
├── Extract (paste) → Review (pre-filled)
├── Mic → [animation] → Review (pre-filled)
└── Back → Home

Review
├── Create Invoice → Invoice Detail
└── Back → Previous screen

Invoice Detail
├── Mark Paid → [updates status in place]
├── Export PDF → [modal]
├── Draft Reminder → Reminder
└── Back → Previous screen

Invoices List
├── Filter chips → [re-render list]
└── Invoice item → Invoice Detail

Reminder
├── Edit → [enables textarea editing]
├── Approve → [shows Send button]
├── Send → [snackbar] → Home (after 1.2s)
└── Back → Previous screen

Bottom Nav: Home | Scan | Invoices (always visible)
```

---

## Animations

| Animation | Duration | Easing |
|-----------|----------|--------|
| Screen transition | 220ms | cubic-bezier(.4,0,.2,1) |
| Scan line | 1.5s loop | ease-in-out |
| Highlight boxes | 300ms | ease |
| Shimmer | 1.5s loop | linear |
| Waveform bars | 1s loop | ease-in-out (staggered 50ms) |
| Typing cursor blink | 600ms loop | step |
| Notification banner | 400ms | cubic-bezier(.4,0,.2,1) |
| Modal slide-up | 300ms | cubic-bezier(.4,0,.2,1) |
| Pulse glow | 2s loop | ease-in-out |
| Button press | 150ms | ease |
| Snackbar | 300ms | ease |

---

## Status Chips

| Status | Background | Text Colour | Icon | Label |
|--------|-----------|-------------|------|-------|
| Pending | `#F1F5F9` | `#475569` | ⏳ | Pending |
| Paid | `#DCFCE7` | `#166534` | ✓ | Paid |
| Overdue | `#FEE2E2` | `#991B1B` | ⚠ | Overdue |

Each chip always shows icon + text (never colour alone).

---

## Sample Data

| Client | Amount | Due Date | Status |
|--------|--------|----------|--------|
| Ravi Kumar | ₹5,000 | 12 days ago | Overdue |
| Meera Studios | ₹18,500 | 3 days ago | Overdue |
| Anita Rao | ₹7,200 | 5 days from now | Pending |
| Karthik Photography | ₹12,000 | (paid) | Paid |

All dates computed relative to today.
