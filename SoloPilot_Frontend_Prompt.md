# SoloPilot — FRONTEND Build Prompt (for Antigravity)

> Save this file in the same projects folder as the backend prompt, open that folder in Antigravity, then tell it: "Read SoloPilot_Frontend_Prompt.md and follow it." A second prompt (Backend) builds the on-device services in the same repo. This one owns everything the user sees and taps.

---

## ROLE

You are the frontend engineer for **SoloPilot**, a phone-first Flutter app for the iQOO Hackathon 2026. You build the screens, navigation, widgets and look-and-feel. You do **not** write OCR, database, AI or notification logic. You call the services defined in the contract below. The builder is a beginner, so keep code simple, commented, and easy to explain.

## PRODUCT IN ONE PARAGRAPH

SoloPilot is a private, on-device AI back-office for freelancers (designers, tutors, photographers, consultants). The user photographs a receipt or approved-work message (or pastes text, or dictates), the app reads it on the phone, creates an invoice, tracks Pending / Paid / Overdue, and drafts a polite payment reminder for overdue invoices that the user approves. Currency is Indian rupees (₹), dates are dd MMM yyyy.

**The pitch is privacy and on-device AI**, shown by running the whole flow in airplane mode. The UI must make that visible and feel fast, calm, and trustworthy.

**Hero flow (must be flawless):** Home → Scan → Review → Invoice → Reminder → Approve.

## HARD RULES

1. **Offline only.** No network calls, no login/sign-up, no accounts, no real email/bank integrations ("Send" is simulated).
2. **One flow that works beats ten that half-work.** Build in the order below and stop at each "Done when".
3. No dead ends: every screen has a clear next action and a way back.
4. Out of scope: dark mode, settings screens, multiple roles, localisation. Don't add them.
5. Never call a service directly from a widget's `build`; call from event handlers/`initState`, and always show loading and error states.

## TECH STACK

Flutter (Dart), Android, Material 3, `provider` for state, `intl` for money/date formatting. Services come from `AppServices.instance` (see the contract). Plain `Navigator.push` navigation is fine.

## STEP 0 — Before writing code, ask me

Check my machine (`flutter doctor`, Windows, physical phone vs emulator). Then ask me, in one short batch, anything blocking. Things I want you to confirm with me: the app name/logo text, whether I have a brand colour preference (otherwise choose one), and the package name for `flutter create`. Then give a short plan and wait for my "go".

## STEP 1 — Setup

1. If the project doesn't exist, run `flutter create solopilot` and `cd solopilot`. (The Backend prompt may have already created it — check first. Never overwrite its files; you own `lib/screens/`, `lib/widgets/`, `lib/theme/`, and the UI parts of `main.dart`.)
2. Make sure these packages are present (add only what's missing): `provider intl image_picker`.
3. Confirm `flutter run` shows an app on the phone/emulator.

## THE CONTRACT (the backend provides this; code against it)

If the real services aren't ready yet, use `AppServices.instance.useFakes = true` and the in-memory fakes in `lib/services/fakes/`. **Do not rename or change these signatures.** If you need something extra, tell me so I can add it to the Backend work.

```dart
class Invoice  { int? id; String clientName; double amount; DateTime issued, due;
                 String status;            // 'pending' | 'paid'
                 String get effectiveStatus;  // 'pending' | 'paid' | 'overdue'
                 int get daysOverdue; }
class Draft    { int? id; String type; String text; String status; int? invoiceId; } // status: draft|approved|sent
class ExtractedFields { double? amount; DateTime? date; String? clientName; String rawText; }

OcrService.readTextFromImage(path) -> String
ExtractService.extract(text) -> ExtractedFields      ExtractService.ensureModelsReady() -> bool
DbService: insertInvoice, getInvoices, getInvoice, markPaid, getOverdue,
           insertDraft, updateDraft, getDrafts({status}), getDraftForInvoice(invoiceId, type)
DraftService.draftReminder(invoice) -> String        // templates or Gemma, UI doesn't care
SmartReplyService.suggest(clientMessage) -> List<String>
VoiceService: init(), start(onText), stop()
PdfService.shareInvoicePdf(invoice)
NotificationService (UI only needs the tap callback to open the Invoices list)
SampleDataService: seedIfEmpty(), reset()
```

## DESIGN DIRECTION

- Material 3, one calm seed colour (trustworthy teal or indigo), generous spacing, rounded cards, large tap targets (phone-first, one-handed).
- Status colours are fixed: **Pending = grey, Paid = green, Overdue = red**, shown as coloured chips with an icon, never colour alone.
- A small, persistent **"On-device • Works offline"** badge (lock or chip icon) on Home and Scan. This is the visual proof of the pitch.
- Friendly empty states ("No invoices yet — scan one!"), loading spinners for OCR/extract/draft, and clear error text with a retry.
- Use ₹ with Indian digit grouping (`NumberFormat.currency(locale: 'en_IN', symbol: '₹')`).
- Keep widgets in `lib/widgets/`: `InvoiceCard`, `StatusChip`, `SummaryCard`, `OfflineBadge`, `PrimaryActionButton`, `EmptyState`.

## STEP 2 — Build in this order

Commit to git after each milestone. After each, run `flutter analyze`, run on the real phone, and tell me what I should tap to verify.

**F0 — Skeleton (on fakes).** App theme, the 6 screens with navigation between them, the shared widgets, and `AppServices` provided at the root. Everything shows fake data. Done when: I can tap through all 6 screens and see fake invoices.

**The 6 screens**

1. **Home ("Today").** Greeting, two `SummaryCard`s ("X drafts to approve", "Y invoices overdue", real counts from `getDrafts(status:'draft')` and `getOverdue()`), two big buttons *Scan* and *New invoice*, a short "recent invoices" list, and the offline badge. Tapping the overdue card opens the Invoices list filtered to overdue.
2. **Scan / Capture.** Large "Take photo" button (`image_picker`, camera), a "Paste a client message" text field with an "Extract" button (this is the live-camera backup path), and a mic button for dictation (nice-to-have, see F5). Show a progress state while OCR + extraction run, then go to Review. On first launch show a one-time "Prepare offline models" card that calls `ensureModelsReady()` and shows done/failed status.
3. **Review.** Shows what the AI found as **editable** fields: client name, amount, issued date (default today), due date (default +14 days, date picker). Show the raw recognised text in a collapsible panel. Empty/null fields stay blank for the user to type; frame it as "You're always in control". Primary button: "Create invoice". Validate amount > 0 and non-empty client.
4. **Invoice.** The created invoice as a clean card (client, amount, dates, status chip). Buttons: **Mark as paid**, **Export PDF** (nice-to-have), and for overdue invoices **Draft reminder**. Updates immediately after actions.
5. **Invoices list.** Every invoice as an `InvoiceCard` with status chip, newest first, filter chips (All / Pending / Overdue / Paid), pull-to-refresh, "Mark as paid" quick action, empty state.
6. **Reminder draft.** Shows the reminder text from `draftReminder(invoice)` in an editable text box, a loading state while it generates, and buttons **Edit**, **Approve**, **Send (simulated)**. Approve saves the draft with status `approved`; Send sets `sent`, shows a confirmation ("Reminder sent — simulated, nothing left your phone") and returns Home with updated counts.

**F1 — Hero flow, real services.** Switch `useFakes` off for OCR + extraction + DB (as the Backend work lands). Wire Scan → Review → Create invoice → Invoice. Done when: photographing a real receipt fills Review and "Create invoice" saves it to the list.

**F2 — Tracker.** Invoices list and Home counts read from the real DB; Mark as paid works; overdue chips are correct; data survives restarting the app. Done when: create → list → mark paid → restart app → still correct.

**F3 — Reminder loop.** Overdue invoice → Reminder screen → edit → Approve → Send → Home counts update. Done when: the loop completes with visible feedback and no internet.

**F4 — Notifications glue.** Tapping the overdue notification opens the Invoices list filtered to overdue. Show an in-app banner on Home if overdue invoices exist ("2 invoices overdue — review"). Trigger `showOverdueSummary(count)` from Home when overdue count > 0 (once per app session, not repeatedly).

**F5 — Nice-to-haves, only if F0–F4 are solid.**
- **Voice:** press-and-hold mic on Scan; live transcript text; on release, send text through `extract()` into Review.
- **PDF:** "Export PDF" button calls `shareInvoicePdf`.
- **Smart reply:** when the user pastes a client message, show 1–3 tappable suggestion chips under the field ("Suggested replies"); tapping copies the text.
- **AI label:** if the Backend exposes `isGemmaReady`, show a small "Written by on-device AI" label on the Reminder screen.

**F6 — Polish and demo-proofing.** A hidden-but-easy way to load/reset sample data (long-press the app title → `SampleDataService.reset()`), consistent loading/empty/error states, no dead ends, smooth transitions, screen stays awake during OCR. Run the full hero flow in **airplane mode** on the phone and report honestly what broke. Then freeze features.

## QUALITY BAR

- Widgets small and reusable; no 500-line screen files. Each screen has a short comment saying what it does.
- Handle null/empty service results without crashing.
- Add at least a few widget tests (StatusChip colours, Review validation, Invoices list filter).
- `flutter analyze` clean; no hard-coded sample data left in screens after F1.
- Accessibility basics: semantic labels on icon buttons, minimum 48dp tap targets, text readable at 1.3× font scale.

## HOW TO WORK WITH ME

- Explain choices in plain language; I'm a beginner and need to describe this to judges.
- Give manual steps as numbered instructions (enable USB debugging, grant permissions, etc.).
- Show me what to tap to verify each milestone.
- If a package API differs from what you expect, read its pub.dev/README instead of guessing.
- If something needs a service change, tell me exactly what to add to the Backend work rather than working around it.
