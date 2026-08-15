# Synapse Health App — Flutter Conversion Context

> Source of truth for converting the existing **Figma Make → React + TypeScript** design export
> into a **Flutter** mobile app, then building its backend.
> Last updated: 2026-06-23.

---

## 1. What this app is

**Synapse** is a **K-12 school health management** mobile app for the **UAE market** (adapted from a US
version). It is **bilingual Arabic (RTL, primary) / English (LTR)** and targets iOS + Android (the
React export renders a single phone-width column, `max-width: 393px` — iPhone 16 Pro frame).

Core domains: student medication administration, clinic visits, emergency consent, allergen/Halal
cafeteria alerts, student pickup/security, bus tracking, counseling, school administration, and
clinical oversight by a school physician (a UAE DHA mandate).

## 2. Current state of the repo (what we are converting FROM)

| Property | Value |
|---|---|
| Framework | React 18 + TypeScript, Vite, React Router 7 (`createBrowserRouter`) |
| Styling | Tailwind CSS v4 + inline styles; shadcn/ui (Radix) component library |
| Icons | `lucide-react` |
| i18n | `i18next` + `react-i18next`, but **mostly unused** — see §6 |
| Nature | **UI-only prototype.** No backend, no real auth, no data layer. All data is hardcoded mock arrays inside each screen. |
| Size | 168 component files, ~33,500 LOC, ~130 screens across 12 roles |

Key files:
- `src/app/routes.tsx` — the entire route map (single source for screen inventory).
- `src/app/App.tsx` — wraps router in `LanguageProvider` + global `RamadanBanner`, constrains to 393px.
- `src/context/LanguageContext.tsx` — `language` ('ar'|'en'), `isRTL`, `toggleLanguage` (simulated reboot), persists to `localStorage`.
- `src/tokens/colors.ts`, `src/tokens/uae.ts` — design + locale tokens (see §5).
- `src/app/components/ui/*` — 45 shadcn/ui primitives (button, card, dialog, sheet, tabs, …).
- `src/app/components/*Layout.tsx` — per-role shells with a bottom tab bar + `<Outlet/>`.
- `Synapse_UAE_Antigravity_Implementation_Plan.md` — prior planning doc (describes the US→UAE adaptation; treats target as React Native). Useful domain reference, **not** the Flutter plan.

## 3. Roles & screen inventory (12 roles)

Routes are grouped per role. Each role (except auth/system) has a `*Layout` shell with a bottom nav.

| Role | Base route | Layout | Key screens |
|---|---|---|---|
| **Auth flow** | `/splash`, `/login`, `/verify`, `/biometric`, `/agreement`, `/signature` | none | Splash, Login, 2FA, Biometric, Confidentiality, E-Signature |
| **Nurse** | `/nurse/*` | `NurseLayout` | Dashboard, Daily Doses, Medications (+add 3-step wizard, dose confirm/conflict, low supply), Clinic visits (+new, emergency photo/consent/escalation), Students (+health profile), Document review/viewer, Cafeteria alert, Reports (+generate/preview), Settings, Notifications |
| **Parent (new app)** | `/parent/app/*` | `ParentAppLayout` | Home, Clinic history, Medication log, Docs, Chat (+chatbot), emergency consent response, report/suspend home dose, authorized persons, QR code, bus live tracking, profile/notification settings |
| **Parent onboarding** | `/parent/onboarding/*` | none | School code, confirm child, emergency consent, privacy agreement, document upload, authorized pickups, complete, not-active |
| **Parent (legacy)** | `/parent/*` | `ParentLayout` | Dashboard, Medications, Notifications (older portal, kept) |
| **Teacher** | `/teacher/*` | `TeacherLayout` | Dashboard, Attendance, Health considerations, Clinic referral, Student release, Weather restriction, Activity exemptions, Notifications, Settings |
| **Cafeteria** | `/cafeteria/*` | `CafeteriaLayout` | Allergen dashboard, allergen detail, realtime alert, delivery history, empty state, settings (Halal compliance layer) |
| **Security Guard** | `/security/*` | `SecurityGuardLayout` | Pickup queue, QR scanner, manual verification, authorized confirmation, history, settings |
| **Bus Driver** | `/bus/*` | `BusDriverLayout` | Route overview, student boarding/deboarding, early dismissal, history, settings |
| **Counselor** | `/counselor/*` (+ full-screen tag/report) | `CounselorLayout` | Dashboard, students, reports, settings; tag entry, student tags history, generate report, report preview |
| **Secretary** | `/secretary/*` (+ import/compose) | `SecretaryLayout` | Dashboard, student list, messages inbox, chatbot queue, settings; import students, compose message |
| **Principal** | `/principal/*` (+ many full-screen) | `PrincipalLayout` | Dashboard, staff mgmt (+add/edit), permission matrix, health analytics, weather advisory, audit log, SMS wallet, after-hours access, annual report, student promotion, school setup, legal documents |
| **Physician** | `/physician/*` | `PhysicianLayout` | Dashboard, protocol review, clinical escalation inbox, report co-signature, schedule config, settings |
| **Vice Principal** | `/vice-principal/*` (+ full-screen) | `VicePrincipalLayout` | Dashboard, analytics, clinic readiness, equipment checklist, messages, settings; permissions |
| **System states** | `/system/*` | none | After-hours lock, weather advisory, consent pending, session expiry, simulator, Ramadan mode |

`/` renders `SynapseNavigationMap` — a dev index linking every screen (not a product screen).

## 4. Navigation architecture

- Nested routes: each role layout is a parent route with child routes rendered into `<Outlet/>`.
- Layouts render a **fixed bottom tab bar** (`height 83px`, safe-area padding). Tab order **reverses in RTL**.
- "Full-screen" flows (wizards, scanners, previews) are **siblings** of the layout route (no bottom nav).
- Deep-link params used: `:id`, `:staffId`, `:personId`.
- → Flutter mapping: `go_router` with `ShellRoute` per role for the bottom-nav screens, top-level routes for full-screen flows.

## 5. Design system / tokens

Colors (`src/tokens/colors.ts`):
`primary #2563EB`, `secondary #06B6D4`, `accent #10B981`, `background #F8FAFC`, `surface #FFFFFF`,
`textPrimary #0F172A`, `textSecondary #64748B`, `error #DC2626`, `warning #F59E0B`, `border #E2E8F0`,
`uaeGreen #006C35`, `physicianTeal #0D9488`, `halalGreen #15803D`.

UAE tokens (`src/tokens/uae.ts`): ambulance `998`, police `999`, date `DD/MM/YYYY`, currency `AED`/`درهم`,
7 emirates (en/ar), license authorities `DHA / DoH Abu Dhabi / MOHAP`, curricula list.

Layout conventions seen in components:
- Page bg `#F8FAFC`, cards `#FFFFFF` w/ `1px #E2E8F0` border, radius `xl` (12px).
- Status bar spacer `44px`, top app bar `56px`, bottom nav `83px`, min tap target `44px`.
- RTL handled per-component via `isRTL` ternaries (border side swaps, `rotate-180` on chevrons, reversed flex).
- → Flutter mapping: a `SynapseColors` + `SynapseTheme` (Material 3 `ThemeData`), `Directionality` driven by locale, reusable `SynapseScaffold`/`SynapseCard`/`SynapseBottomNav` widgets. Icons → `lucide_icons` package (or Material equivalents).

## 6. Internationalization (important nuance)

- An `i18next` setup exists (`src/i18n/{en,ar}.ts`) but only ~100 keys are defined and it is **largely
  not wired in** — most screens **hardcode bilingual strings inline** as `isRTL ? 'عربي' : 'English'`.
- This means translation strings must be **extracted from each component** during conversion, not just
  lifted from the i18n files.
- → Flutter mapping: `flutter_localizations` + ARB files (or `easy_localization`); `TextDirection`
  from locale; persist locale (was `localStorage` → `shared_preferences`).

## 7. Backend (to be built — does not exist yet)

The React export has **no backend**. Phase 2 of this engagement builds it. Domain entities implied by
the screens: Schools, Users/Roles (RBAC, 12 roles), Students, Guardians/Authorized persons, Medications
& Protocols (physician approval workflow), Doses/Administration logs, Clinic visits, Emergency consents,
Documents (uploads + expiry), Allergens/Meals/Halal certs, Pickups (QR), Bus routes & boarding events,
Counselor tags/reports, Notifications (push/SMS/WhatsApp), Audit log, Weather advisories. Compliance
context: UAE PDPL, DHA, mandatory health insurance.

## 8. Conversion strategy (proposed)

1. **Scaffold** Flutter app: theme, colors, localization (en/ar + RTL), routing shell, shared widgets,
   mock-data layer mirroring current hardcoded arrays.
2. **Port screens role-by-role**, starting with one vertical slice (recommend **Auth → Nurse**) to
   validate the pattern, then fan out.
3. **Backend**: design API/data model, stand up services, then replace the mock-data layer with real
   API calls behind a repository interface.

Open decisions are tracked with the user (state management, backend stack, scope/phasing, fidelity).

## 9. Open questions for the user

See conversation — pending answers on: state management, backend stack, MVP scope vs. all 12 roles,
and design fidelity (pixel-exact vs. idiomatic Material 3).
