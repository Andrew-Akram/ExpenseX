<div align="center">
<img src="img/app_poster.png" alt="ExpenseX App Poster" width="100%"/>

# ExpenseX
### A production-ready Flutter expense tracking application

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Riverpod](https://img.shields.io/badge/Riverpod-3.x-00BCD4?style=for-the-badge)
![Material 3](https://img.shields.io/badge/Material-3-6750A4?style=for-the-badge&logo=material-design&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Track. Analyse. Save.**

A full-featured personal finance app built with Clean Architecture, Firebase, Riverpod, and Material 3.
</div>

---

## About

ExpenseX is a production-quality Flutter application for personal financial management, built to demonstrate real-world engineering practices rather than a tutorial-style clone. It implements feature-first Clean Architecture, Firebase Firestore for cloud persistence, Riverpod 3 for state management, and a Material 3 design system with full Arabic/RTL localization.

The project was built to show depth across the stack: a proper 3-layer architecture per feature, secure auth (biometric + PIN), real-time cloud sync, data export, and a polished UI with AMOLED dark mode — the kind of structure that scales past a single developer or a single screen.

---

## Features

- **Expense Tracking** — Add, edit, and delete expenses with categories, tags, merchants, notes, and receipt images. Supports Expense, Income, and Transfer types, plus recurring transactions.
- **Wallet Management** — Multiple wallets (Cash, Bank, Credit Card) with real-time balance tracking and inter-wallet transfers.
- **Analytics & Insights** — Weekly, monthly, and yearly breakdowns, category pie charts, 7/30-day spending trends, and local AI-powered spending insights.
- **Bills & Subscriptions** — Recurring bill tracking with due date reminders and paid/unpaid status.
- **Budget Management** — Monthly budgets (global or per category) with real-time usage tracking and alert thresholds.
- **Savings Goals** — Target amounts, deadlines, and visual progress tracking.
- **Security** — Firebase Auth (email/password + Google), local PIN, biometric auth (fingerprint/Face ID), and configurable inactivity auto-lock.
- **Export** — PDF reports with custom date ranges, CSV export, native share sheet.
- **Internationalization** — Full English and Arabic support with complete RTL layout.
- **UI/UX** — Material 3, light mode + true AMOLED dark mode, smooth animations, shimmer loading states.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| Backend | Firebase Firestore |
| Auth | Firebase Auth (Email/Password, Google OAuth), local_auth (biometric) |
| State | Riverpod 3 + flutter_hooks |
| Navigation | GoRouter |
| Local DB | Hive CE |
| Secure Storage | flutter_secure_storage (Keystore / Keychain) |
| Code Gen | freezed + json_serializable |
| Charts | fl_chart |
| Export | pdf, csv |
| Fonts | Google Fonts (Outfit, Inter, Cairo) |

---

## Architecture

Feature-first Clean Architecture, 3 layers per feature:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│            Screens · Widgets · Riverpod Providers            │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│          Entities · Repository Interfaces · Services         │
├─────────────────────────────────────────────────────────────┤
│                       DATA LAYER                             │
│         Firestore Datasources · Models · Repositories        │
└─────────────────────────────────────────────────────────────┘
```

```
UI Widget → watches → Riverpod Provider → calls → Repository Interface
    → implemented by → Repository Impl → calls → Firestore Datasource
    → reads/writes → Firebase Firestore
```

12 self-contained feature modules: `analytics`, `auth`, `bills`, `budget`, `categories`, `dashboard`, `expenses`, `export`, `notifications`, `savings`, `settings`, `wallets` — each with its own `data/domain/presentation` split.

---

## License

Distributed under the MIT License. See `LICENSE` for details.

<div align="center">
Built with Flutter
</div>
