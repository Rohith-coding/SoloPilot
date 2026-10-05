# SoloPilot — BACKEND Build Prompt (for Antigravity)

> Save this file in your projects folder (the parent folder, where `solopilot` will be created), open that folder in Antigravity, then tell it: "Read SoloPilot_Backend_Prompt.md and follow it." A second prompt (Frontend) builds the UI in the same repo. This one owns everything that is NOT a screen.

---

## ROLE

You are the backend engineer for **SoloPilot**, a phone-first Flutter app for the iQOO Hackathon 2026. There is **no cloud server**. In this project "backend" means the **on-device services layer** written in Dart: local database, OCR, entity extraction, reminder drafting, smart reply, voice, PDF, notifications, and sample data. The builder is a beginner, so keep code simple, commented, and easy to explain in a pitch.

## PRODUCT IN ONE PARAGRAPH

SoloPilot is a private, on-device AI back-office for freelancers. The user photographs a receipt or approved-work message (or pastes text, or dictates). The app reads it with offline OCR, extracts amount, date and client name, creates an invoice saved locally, tracks Pending / Paid / Overdue, and auto-drafts a polite payment reminder for overdue invoices that the user approves. Currency is Indian rupees (₹). Dates are Indian style (dd/MM/yyyy).

**Hero flow (must never break):** camera/paste → OCR → extract → review → save invoice → overdue reminder drafted → approve. All of it works in **airplane mode**.

## HARD RULES

1. **Everything runs offline on the phone.** No cloud calls, no accounts or login, no real email/bank/payment integrations (sending is simulated by flipping a status).
2. **One flow that works beats ten that half-work.** Build in the priority order below and stop at each "Done when".
3. Every AI feature has a **non-AI fallback** so the demo can't die (Gemma → templates, ML Kit extraction → regex, voice/PDF/notifications failing must never crash the app).
4. Don't add features outside this prompt. No dark mode, settings, roles, or internet-only features.

## TECH STACK

Flutter (Dart), Android only. Packages: `image_picker`, `google_mlkit_text_recognition`, `google_mlkit_entity_extraction`, `google_mlkit_smart_reply`, `flutter_gemma` (added last), `sqflite`, `path`, `provider`, `pdf`, `printing`, `speech_to_text`, `flutter_local_notifications`, `intl`.

## STEP 0 — Before writing code, ask me

Check my machine first (`flutter doctor`, Windows, Android phone vs emulator). Then ask me anything blocking, one short batch of questions. Don't guess about: my Flutter/Android Studio status, whether I have a physical Android phone connected, and the package name/org for `flutter create`. Then give a short plan and wait for my "go".

## STEP 1 — Project setup

1. `flutter create solopilot` (only if the project doesn't already exist; the Frontend prompt may have created it — check first), then `cd solopilot`.
2. `flutter pub add image_picker google_mlkit_text_recognition google_mlkit_entity_extraction google_mlkit_smart_reply sqflite path provider pdf printing speech_to_text flutter_local_notifications intl`
3. Android config, following each package's README for the exact current lines:
   - `AndroidManifest.xml`: `CAMERA`, `RECORD_AUDIO`, `POST_NOTIFICATIONS`.
   - `android/app/build.gradle`: `minSdk` high enough for ML Kit (21 minimum; raise it if any package demands more) and core library desugaring if `flutter_local_notifications` requires it.
4. Create the folder layout:

```
lib/
  main.dart
  models/        client.dart, invoice.dart, draft.dart, extracted_fields.dart
  services/
    app_services.dart       (simple provider/locator exposing every service)
    db_service.dart  ocr_service.dart  extract_service.dart
    draft_service.dart  smart_reply_service.dart  voice_service.dart
    pdf_service.dart  notification_service.dart  sample_data_service.dart
    fakes/                  (in-memory fakes of every service)
  screens/  widgets/        (owned by the Frontend prompt — don't touch)
```

5. Run `flutter run` on the phone/emulator and confirm the starter app works before continuing.

## STEP 2 — THE CONTRACT (build this first, exactly as written)

The Frontend prompt codes against these names. **Do not rename or change signatures without telling me.** Put an abstract class and a real implementation for each service, plus an in-memory fake in `services/fakes/` so the UI can be built immediately.

```dart
// models
class Client   { int? id; String name; String? contact; }
class Invoice  {
  int? id; String clientName; double amount;
  DateTime issued; DateTime due;
  String status;                       // stored: 'pending' | 'paid'
  String get effectiveStatus;          // derived: 'overdue' if pending && due < today
  int get daysOverdue;                 // 0 if not overdue
}
class Draft    {
  int? id; String type;                // 'reminder' | 'reply'
  String text;
  String status;                       // 'draft' | 'approved' | 'sent'
  int? invoiceId;
}
class ExtractedFields { double? amount; DateTime? date; String? clientName; String rawText; }

// services
abstract class OcrService          { Future<String> readTextFromImage(String imagePath); }
abstract class ExtractService      { Future<ExtractedFields> extract(String text); }
abstract class DbService {
  Future<int> insertInvoice(Invoice i);
  Future<List<Invoice>> getInvoices();             // newest first
  Future<Invoice?> getInvoice(int id);
  Future<void> markPaid(int id);
  Future<List<Invoice>> getOverdue();
  Future<int> insertDraft(Draft d);
  Future<void> updateDraft(Draft d);
  Future<List<Draft>> getDrafts({String? status});  // e.g. 'draft' for the Home count
  Future<Draft?> getDraftForInvoice(int invoiceId, String type);
  Future<void> upsertClient(Client c);
}
abstract class DraftService        { Future<String> draftReminder(Invoice i); }  // templates or Gemma, same signature
abstract class SmartReplyService   { Future<List<String>> suggest(String clientMessage); }  // 1–3 replies
abstract class VoiceService {
  Future<bool> init(); Future<void> start(void Function(String text) onText); Future<void> stop();
}
abstract class PdfService          { Future<void> shareInvoicePdf(Invoice i); }  // opens share/print sheet
abstract class NotificationService {
  Future<void> init(void Function() onTap);
  Future<void> showOverdueSummary(int count);
}
abstract class SampleDataService   { Future<void> seedIfEmpty(); Future<void> reset(); }
```

`AppServices` exposes one instance of each (`AppServices.instance.db`, etc.) and has a flag `useFakes` so the UI can run before real services exist. Make it provided through `provider` at the app root.

**Done when:** the contract compiles, fakes return believable data, `flutter analyze` is clean.

## STEP 3 — Build the real services in THIS order

Stop and tell me after each one. Run `flutter analyze` and test on the real phone before moving on. Commit to git after each milestone with a clear message.

**B1 — DB (`sqflite`).** Tables: `clients`, `invoices`, `drafts`. Store `status` as pending/paid only; compute overdue in the model getter. DB must survive app restart. Done when: insert → close app → reopen → still there.

**B2 — OCR + extraction (the hero feature; polish it).**
- `readTextFromImage` with `TextRecognizer(script: latin)`; always `close()` the recognizer.
- `extract()` runs ML Kit `EntityExtractor` (English) and takes the first `money` entity as the amount and the first `dateTime` entity as the date.
- ML Kit does **not** find names. Add heuristics for `clientName`: patterns like "Invoice Ravi…", "To: Name", "Bill to Name", "Dear Name", else the first capitalised line. Leave null if unsure.
- **Regex fallback** when ML Kit finds nothing or fails: ₹ / Rs. / INR amounts with commas (`₹5,000`, `Rs 5000.50`), and dd/MM/yyyy, dd-MM-yyyy, "12 Oct 2026" dates. Prefer the largest amount near words like "total", "amount", "due".
- Never throw to the UI: return `ExtractedFields` with nulls so the user can type values in.
- Entity extraction needs a **one-time model download**. Add `Future<bool> ensureModelsReady()` (in `ExtractService` and `SmartReplyService`) that downloads while online and reports status, so the Frontend can show a "Prepare offline models" step on first launch. Offline use must work afterwards.
- Done when: a real photographed receipt in airplane mode yields amount + date (even roughly), and pasted text does too.

**B3 — Invoice logic + templates (`DraftService`).** `draftReminder(invoice)` returns a polite, human reminder using 3 templates chosen by `daysOverdue` (gentle ≤7 days, firm 8–30, final 30+), with ₹ formatting through `intl`. Done when: an overdue invoice returns good text with no internet.

**B4 — Notifications.** `init`, a high-importance Android channel, runtime permission request (Android 13+), `showOverdueSummary(count)` ("2 invoices overdue — tap to review"), tap callback invokes the callback from `init`. Done when: a notification appears and tapping it opens the app.

**B5 — Sample data.** `seedIfEmpty()` creates 2 clients and ~4 invoices: one clearly overdue (about 12 days late, ₹5,000), one pending, one due soon, one paid, plus one reminder draft. `reset()` wipes and reseeds. This is the backup for a failed live camera.

**B6 — Smart reply.** `suggest()` returns 1–3 short replies via ML Kit Smart Reply; handle empty results, which is common, by falling back to 2–3 canned replies.

**B7 — Voice dictation.** Wrap `speech_to_text`. Request mic permission, stream partial text through `onText`, handle failure gracefully. The recognised text goes through the same `extract()` path (e.g. "Invoice Ravi five thousand rupees due Friday" — add basic parsing of spoken numbers like "five thousand" and weekday names such as "Friday" → next Friday).

**B8 — PDF export.** Build a clean one-page invoice with `pdf` and `printing` (client, amount, issued/due, status, a "Generated on-device by SoloPilot" footer). Works offline.

**B9 — On-device Gemma (LAST, optional).** Add `flutter_gemma` only now. Follow its current README exactly for model download and loading (it changes between versions). Wire it inside `draftReminder` with the prompt: "Write a short, friendly payment reminder to {client} for an invoice of ₹{amount} that is {days} days overdue. Polite, one paragraph." Rules: add a timeout, and on any error or timeout, fall back to the templates from B3 silently. Expose `isGemmaReady` so the UI can show a small "AI-written" label. Done when: it runs in airplane mode after the model is downloaded once.

## QUALITY BAR

- Each service in its own file, one job each, short comments.
- All service methods catch exceptions and return safe defaults; nothing crashes the UI.
- Unit tests for: effectiveStatus/daysOverdue, regex amount/date extraction, template selection, DB round-trip (use `sqflite_common_ffi` if needed).
- Final check: run the full hero flow in **airplane mode** on the real phone and report the result honestly, including anything that didn't work.

## HOW TO WORK WITH ME

- Explain what you're doing in plain language; I'm a beginner and should be able to explain it to judges.
- Give me any manual steps (accept Android licenses, enable USB debugging, grant permissions, download a model) as numbered instructions.
- If a package API differs from what you expect, check its README/pub.dev page rather than guessing.
- Keep the contract stable. If you must change it, list the change so I can pass it to the Frontend work.
