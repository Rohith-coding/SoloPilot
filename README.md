# SoloPilot — Private On-Device AI Back-Office for Freelancers

> **iQOO Hackathon 2026 Submission — Phase 1 (Screening)**  
> Private, on-device AI assistant that handles receipts, invoice tracking, reminders, and payment tracking for Indian freelancers — without sending personal financial data to the cloud.

---

## 🚀 Live Prototype & Links
---

- **Clickable Prototype URL:** stunning-cactus-c00960.netlify.app
- **Demo / Walkthrough Video:** https://youtube.com/shorts/tbnqJS-LSPU?feature=share
- **Hackathon Track:** Productivity

---

## 📌 Problem & Concept

Freelancers and solo professionals in India (designers, tutors, photographers, consultants) struggle with:
1. **Receipt & Expense Chaos:** Messy paper receipts, screenshots, and invoices scattered across WhatsApp and email.
2. **Delayed Invoices & Forgotten Follow-ups:** Chasing clients for payments is uncomfortable and time-consuming.
3. **Privacy Concerns:** Uploading client names, bank details, and personal financial invoices to third-party cloud servers raises serious trust issues.

### The SoloPilot Solution
SoloPilot brings **complete on-device AI intelligence** directly onto the smartphone (leveraging hardware NPU / on-device LLMs & OCR):
- **On-Device Receipt Scanning:** Instant OCR extracts vendor, items, GST, and totals without network requests.
- **Automated Ledger & GST Calculation:** Categorizes expenses and tracks pending vs. collected revenue.
- **Context-Aware Polite Reminders:** On-device AI drafts WhatsApp reminders tailored to relationship tone (gentle, firm, or formal).
- **100% Zero-Cloud Privacy:** Financial data stays locked in local storage (`isar` / SQLite + encrypted vault).

---

## 📱 Prototype Overview (Phase 1)

The Phase 1 prototype is an interactive, standalone web app built to look and behave identically to an on-device mobile app.

### Key Screens & Interactive Flows:
1. **Home / Dashboard:**
   - Quick overview of Monthly Revenue, Pending vs. Paid amounts.
   - Quick action: "Scan Receipt" and "Draft Invoice".
   - Recent transaction feed with visual status badges.
2. **Camera / Scan Screen:**
   - Simulated on-device scanner viewfinder with receipt outline overlay.
   - Live simulated OCR recognition box.
3. **Receipt Review & Parse:**
   - Real-time extraction view showing detected vendor, date, GSTIN, amount breakdown.
   - "Verify & Save to Ledger" flow.
4. **Invoice Management:**
   - Filter invoices by Status: All, Paid, Pending, Overdue.
   - Detailed invoice inspection (Client, line items, bank details).
5. **AI Reminder Generator:**
   - Tone selector: Gentle, Friendly, Firm.
   - AI generated WhatsApp draft ready to copy or send.
   - "Mark as Paid" action that updates ledger balance in real time.

---

## 🛠️ Architecture & Roadmap (Phase 2 Full Build)

| Layer | Technology |
|---|---|
| **Mobile Framework** | Flutter (Dart) — Cross-platform Android / iOS |
| **On-Device OCR** | Google ML Kit Text Recognition (On-device) |
| **Local Inference / AI** | MediaPipe GenAI / On-Device Gemma LLM quantized for mobile NPU |
| **Database** | Isar Database / SQLite with SQLCipher encryption |
| **Export & Sharing** | PDF generation + native WhatsApp / Share Intent |

---

## 📂 Project Structure

```text
solopilot/
├── README.md                  # Project overview, problem statement & submission guide
├── analysis_options.yaml      # Flutter lint configurations
├── pubspec.yaml               # Flutter package configuration (Phase 2 app)
├── lib/                       # Flutter production app source code (Phase 2)
│   └── main.dart
├── test/                      # Unit and integration tests
└── prototype/                 # Interactive Phase 1 Hackathon Deliverables
    ├── index.html             # Standalone interactive phone-frame prototype
    ├── README.md              # Prototype deployment instructions
    ├── DEMO_SCRIPT.md         # 2-3 minute video walkthrough narration script
    └── FIGMA_SPEC.md          # Comprehensive design tokens, screen specs & UI guidelines
```

---
