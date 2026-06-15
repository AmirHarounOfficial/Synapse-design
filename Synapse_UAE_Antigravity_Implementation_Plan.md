# Synapse — UAE Market Implementation Plan
## Instructions for Antigravity IDE
### Version 1.0 · June 2026 · Confidential

---

> **Context for Antigravity:**
> You are working on **Synapse** — a React Native mobile app (iOS + Android) for K-12 school health management. The design files are available locally from Figma. The codebase is being adapted from the **US market version** to the **UAE market version**. This document is your single source of truth. Follow the execution order strictly. Do not begin a later phase before the earlier one is complete and tested.

---

## Table of Contents

1. [Project Snapshot](#1-project-snapshot)
2. [Execution Order](#2-execution-order)
3. [Phase 0 — Foundation & Tokens](#3-phase-0--foundation--tokens)
4. [Phase 1 — RTL Layout System](#4-phase-1--rtl-layout-system)
5. [Phase 2 — Component Library Updates](#5-phase-2--component-library-updates)
6. [Phase 3 — New: Physician Role (6 screens)](#6-phase-3--new-physician-role-6-screens)
7. [Phase 4 — Nurse Role Changes (7 screens)](#7-phase-4--nurse-role-changes-7-screens)
8. [Phase 5 — Cafeteria Role — Halal Layer (3 screens)](#8-phase-5--cafeteria-role--halal-layer-3-screens)
9. [Phase 6 — Parent Role Changes (5 screens)](#9-phase-6--parent-role-changes-5-screens)
10. [Phase 7 — Auth Flow Changes (3 screens)](#10-phase-7--auth-flow-changes-3-screens)
11. [Phase 8 — Principal & System States (5 screens)](#11-phase-8--principal--system-states-5-screens)
12. [Phase 9 — All Remaining Roles (batch)](#12-phase-9--all-remaining-roles-batch)
13. [Phase 10 — Global Field & Form Changes](#13-phase-10--global-field--form-changes)
14. [Phase 11 — Navigation & Flow Wiring](#14-phase-11--navigation--flow-wiring)
15. [Phase 12 — QA Checklist](#15-phase-12--qa-checklist)
16. [Screen Count Reference](#16-screen-count-reference)

---

## 1. Project Snapshot

| Property | Value |
|---|---|
| App name | Synapse |
| Framework | React Native (iOS + Android) |
| Design source | Figma — local export |
| From | US market (119 screens, 11 roles) |
| To | UAE market (130 screens, 12 roles) |
| New screens | +11 (Physician role ×6, Ramadan state ×1, HASANA widget ×1, others ×3) |
| Modified screens | 38 |
| RTL-only changes | 70 (layout mirror, no logic change) |
| New role | School Physician (UAE DHA mandate) |
| Primary language | Arabic (RTL) with English (LTR) bilingual toggle |

### Color Tokens (unchanged from US)

```js
// tokens/colors.ts
export const colors = {
  primary:       '#2563EB',  // Deep Medical Blue — CTAs, active states
  secondary:     '#06B6D4',  // Calm Cyan — secondary actions
  accent:        '#10B981',  // Emerald Green — success, safe, confirmed
  background:    '#F8FAFC',  // Soft Cloud — page background
  surface:       '#FFFFFF',  // White — cards, sheets, modals
  textPrimary:   '#0F172A',  // Slate 900 — headings, labels
  textSecondary: '#64748B',  // Slate 500 — subtitles, placeholders
  error:         '#DC2626',  // Medical Red — errors, critical alerts
  warning:       '#F59E0B',  // Amber — warnings, pending states
  border:        '#E2E8F0',  // Slate 200 — dividers, card borders
  // UAE additions
  uaeGreen:      '#006C35',  // UAE flag green — compliance badges only
  physicianTeal: '#0D9488',  // Physician role color (new role)
  halalGreen:    '#15803D',  // Halal badge color
}
```

### New UAE Design Tokens

```js
// tokens/uae.ts  — ADD THIS FILE
export const uaeTokens = {
  // Emergency numbers
  ambulanceNumber:    '998',
  policeNumber:       '999',
  // Date/currency
  dateFormat:         'DD/MM/YYYY',
  currencySymbol:     'AED',
  currencySymbolAr:   'درهم',
  // Geography
  emirates: [
    { en: 'Dubai',           ar: 'دبي' },
    { en: 'Abu Dhabi',       ar: 'أبوظبي' },
    { en: 'Sharjah',         ar: 'الشارقة' },
    { en: 'Ras Al Khaimah',  ar: 'رأس الخيمة' },
    { en: 'Ajman',           ar: 'عجمان' },
    { en: 'Fujairah',        ar: 'الفجيرة' },
    { en: 'Umm Al Quwain',   ar: 'أم القيوين' },
  ],
  // License authorities
  licenseAuthorities: ['DHA', 'DoH Abu Dhabi', 'MOHAP'],
  // Curricula
  curricula: ['UAE MoE', 'British', 'American', 'Indian', 'IB', 'Other'],
}
```

---

## 2. Execution Order

> **Antigravity: follow this order exactly. Do not start phase N+1 before phase N passes its own QA gate.**

```
Phase 0  → Foundation & tokens (30 min)
Phase 1  → RTL layout system (2–3 hrs)
Phase 2  → Component library updates (2 hrs)
Phase 3  → Physician role — 6 new screens (4 hrs)
Phase 4  → Nurse role changes — 7 screens (2 hrs)
Phase 5  → Cafeteria Halal layer — 3 screens (1 hr)
Phase 6  → Parent role changes — 5 screens (1.5 hrs)
Phase 7  → Auth flow changes — 3 screens (1 hr)
Phase 8  → Principal & system states — 5 screens (2 hrs)
Phase 9  → All remaining roles — batch (1.5 hrs)
Phase 10 → Global field & form changes (1 hr)
Phase 11 → Navigation & flow wiring (1 hr)
Phase 12 → QA checklist & sign-off (1 hr)
```

**Total estimated: ~20 hours of implementation work**

---

## 3. Phase 0 — Foundation & Tokens

### 3.1 Files to create

```
src/
  tokens/
    uae.ts              ← NEW — add UAE-specific tokens (see Section 1)
    colors.ts           ← UPDATE — add uaeGreen, physicianTeal, halalGreen
  i18n/
    ar.ts               ← NEW — Arabic translation strings (all app text)
    en.ts               ← NEW — English strings (extract from existing hardcoded strings)
    i18n.config.ts      ← NEW — language detection + switching logic
  utils/
    dateFormatter.ts    ← UPDATE — support DD/MM/YYYY and Hijri dual display
    phoneValidator.ts   ← UPDATE — add UAE phone format (+971 5X XXX XXXX)
    eidValidator.ts     ← NEW — Emirates ID validation (784-YYYY-XXXXXXX-X, 15 digits)
    currencyFormatter.ts← UPDATE — support AED alongside existing USD
```

### 3.2 i18n setup

```ts
// src/i18n/i18n.config.ts
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import ar from './ar';
import en from './en';

i18n.use(initReactI18next).init({
  resources: { ar: { translation: ar }, en: { translation: en } },
  lng: 'en',           // default
  fallbackLng: 'en',
  interpolation: { escapeValue: false },
});

export default i18n;
```

### 3.3 Language context

```ts
// src/context/LanguageContext.tsx
// Provides: language ('ar' | 'en'), isRTL (boolean), toggleLanguage()
// isRTL = language === 'ar'
// Persist selection to AsyncStorage
// On change: call i18n.changeLanguage() + update RN I18nManager.forceRTL(isRTL)
// NOTE: forceRTL requires app restart on native — show "App will restart" dialog
```

### 3.4 Date formatter updates

```ts
// src/utils/dateFormatter.ts

// ADD: Hijri date display
// Use: intl-tel-input or hijri-date library
// Output format: "١٥ ذو القعدة ١٤٤٥" in Arabic, "15 Dhu al-Qi'dah 1445" in English

export function formatDateDual(date: Date, lang: 'ar' | 'en'): { gregorian: string; hijri: string } {
  const gregorian = format(date, 'DD/MM/YYYY');  // always DD/MM/YYYY (not US format)
  const hijri = toHijri(date, lang);
  return { gregorian, hijri };
}
```

### 3.5 Emirates ID validator

```ts
// src/utils/eidValidator.ts
// Format: 784-YYYY-XXXXXXX-X
// Total: 15 digits excluding dashes
// First 3 digits always: 784 (UAE country code)

export function validateEID(eid: string): boolean {
  const stripped = eid.replace(/-/g, '');
  return /^784\d{12}$/.test(stripped);
}

export function formatEID(raw: string): string {
  // Auto-format as user types: 784-YYYY-XXXXXXX-X
  const digits = raw.replace(/\D/g, '').slice(0, 15);
  if (digits.length <= 3)  return digits;
  if (digits.length <= 7)  return `${digits.slice(0,3)}-${digits.slice(3)}`;
  if (digits.length <= 14) return `${digits.slice(0,3)}-${digits.slice(3,7)}-${digits.slice(7)}`;
  return `${digits.slice(0,3)}-${digits.slice(3,7)}-${digits.slice(7,14)}-${digits.slice(14)}`;
}
```

**Phase 0 QA Gate:** All tokens importable. i18n switches `en ↔ ar` without crash. Date formats correctly. EID validator passes test cases: `784-2001-1234567-1` ✓, `123-0000-0000000-0` ✗.

---

## 4. Phase 1 — RTL Layout System

### 4.1 Strategy

> **Antigravity:** Do NOT individually flip every component. Instead, establish a layout wrapper that applies RTL directional styles automatically based on `isRTL` from LanguageContext. Then sweep every screen once to ensure it uses this wrapper.

### 4.2 RTL layout wrapper

```tsx
// src/components/layout/DirectionalView.tsx
import { View, StyleSheet } from 'react-native';
import { useLanguage } from '../../context/LanguageContext';

interface Props {
  children: React.ReactNode;
  style?: object;
}

export function DirectionalView({ children, style }: Props) {
  const { isRTL } = useLanguage();
  return (
    <View style={[styles.base, isRTL && styles.rtl, style]}>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  base: { flexDirection: 'row' },
  rtl:  { flexDirection: 'row-reverse' },
});
```

### 4.3 RTL-aware text component

```tsx
// src/components/typography/AppText.tsx
// Wraps RN Text with automatic textAlign based on isRTL
// Arabic text: textAlign: 'right', writingDirection: 'rtl'
// English text: textAlign: 'left', writingDirection: 'ltr'
// Usage: <AppText>Any string</AppText> — auto-detects language
```

### 4.4 Elements that must mirror in RTL

| Element | LTR | RTL |
|---|---|---|
| Back navigation arrow | `←` (chevron-left) | `→` (chevron-right) |
| Progress bars | Fill left → right | Fill right → left |
| List row chevrons | `›` right side | `‹` left side |
| Info box accent border | Left border | Right border |
| Card icon position | Left of text | Right of text |
| Form label position | Above, left-aligned | Above, right-aligned |
| Toast slide-in direction | Slide from right | Slide from left |
| Bottom tab bar order | Home tab leftmost | Home tab rightmost |
| Swipe-to-delete gesture | Swipe left | Swipe right |
| Step indicators | Left → Right | Right → Left |
| Horizontal scroll start | Left | Right |

### 4.5 Bottom tab bar RTL

```tsx
// All tab bars: when isRTL, reverse the tab order array before rendering
// Home tab must always be at the reading-start edge (right in RTL, left in LTR)
// Do NOT just flip the visual — reverse the actual tab array so Home is first in RTL

const tabs = isRTL ? [...originalTabs].reverse() : originalTabs;
```

### 4.6 Info box / banner component RTL

```tsx
// src/components/ui/InfoBanner.tsx
// UPDATE: borderLeftWidth → borderRightWidth when isRTL
// This applies to ALL banner, note, and alert box components

const bannerStyle = {
  borderLeftWidth:  isRTL ? 0 : 3,
  borderRightWidth: isRTL ? 3 : 0,
  borderLeftColor:  isRTL ? 'transparent' : accentColor,
  borderRightColor: isRTL ? accentColor : 'transparent',
};
```

**Phase 1 QA Gate:** Toggle language to Arabic. Open Home screen. Verify: back arrow points right, bottom tabs reverse order, all text right-aligned, info box border is on right. No layout overflow or clipped text.

---

## 5. Phase 2 — Component Library Updates

### 5.1 New components to build

#### 5.1.1 Halal Badge

```tsx
// src/components/badges/HalalBadge.tsx
// Shape: pill (border-radius: 100)
// Background: #F0FDF4 (green tint)
// Border: 1px #15803D
// Text: "حلال ✓" (Arabic) or "Halal ✓" (English) — use i18n
// Icon: crescent moon or checkmark (Heroicons outline)
// Size: small (10px, 24px height) | medium (12px, 28px height)
```

#### 5.1.2 Non-Halal Alert Badge

```tsx
// src/components/badges/NonHalalBadge.tsx
// Same shape as HalalBadge
// Background: #FEF2F2 (red tint)
// Border: 1px #DC2626
// Text: "غير حلال ⚠" (Arabic) or "Non-Halal ⚠" (English)
// Icon: X circle outline
```

#### 5.1.3 Hijri Date Chip

```tsx
// src/components/ui/HijriDateChip.tsx
// Shown below Gregorian dates throughout the app
// Style: small pill, #F8FAFC background, #64748B text, 11px
// Content: Hijri date string from dateFormatter.formatDateDual()
// Arabic mode: Arabic-Indic numerals (١٢٣) + Arabic month name
// English mode: English numerals + transliterated Arabic month name
// Usage: <HijriDateChip date={someDate} /> — self-contained, no props needed beyond date
```

#### 5.1.4 WhatsApp Notification Toggle Row

```tsx
// src/components/notifications/WhatsAppToggleRow.tsx
// Used in ALL notification settings screens
// Layout: WhatsApp logo (green icon, 24px) + "WhatsApp" label + "Recommended for UAE" badge + Toggle
// "Recommended for UAE" badge: small pill, #ECFEFF bg, #0E7490 text, "UAE" flag emoji prefix
// Behavior: same as existing Push/SMS toggle rows
// Position: insert as THIRD option after Push and SMS in every notification section
```

#### 5.1.5 UAE Pass E-Signature Option

```tsx
// src/components/auth/UAEPassSignOption.tsx
// Shown in e-signature screens as an alternative to drawn signature
// Layout: "Or sign with" label + UAE Pass logo placeholder (rectangular, blue) + "UAE Pass e-signature" text + outlined button
// Button: "Sign with UAE Pass" — secondary outlined, #2563EB border
// NOTE: UAE Pass API integration is a future phase — for now, button shows "Coming soon" toast
// Do NOT build a non-functional dead end — use the toast approach
```

#### 5.1.6 Physician Approval Status Card

```tsx
// src/components/clinical/PhysicianApprovalCard.tsx
// Two states:
// APPROVED: green card (bg #F0FDF4, border #15803D)
//   Content: "✓ Approved by [Dr. Name] · [License#] · [DD/MM/YYYY] at [HH:MM:SS]"
//   Footer: lock icon + "This record is permanent and cannot be modified"
// PENDING: amber card (bg #FFFBEB, border #F59E0B)  
//   Content: "⏳ Awaiting physician approval"
//   Subtext: "Medication cannot be administered until approved by the on-duty physician"
//   Action: "Notify physician" teal outlined button
```

#### 5.1.7 HASANA Sync Status Widget

```tsx
// src/components/dashboard/HasanaSyncWidget.tsx
// Visibility: only rendered for schools with emirate === 'Dubai'
// States:
//   SYNCED:  green chip "DHA HASANA · Synced ✓ · [timestamp]"
//   PENDING: amber chip "HASANA sync pending" + "Retry" link
//   FAILED:  red chip "HASANA sync failed — check connection" + "Retry" link
// Used on: Secretary Dashboard (SE-01), Principal Dashboard (M-01)
```

#### 5.1.8 Emirate Selector

```tsx
// src/components/forms/EmirateSelector.tsx
// Replaces all US State dropdowns
// Data source: uaeTokens.emirates (7 items)
// Display: bilingual — "Dubai · دبي" format in dropdown items
// Selected state: shows both EN and AR names
// Used on: Student registration, Staff profile, School settings
```

#### 5.1.9 License Authority Selector

```tsx
// src/components/forms/LicenseAuthoritySelector.tsx
// Three options: DHA / DoH Abu Dhabi / MOHAP
// Auto-selects based on school's configured emirate:
//   Dubai → DHA (default, editable)
//   Abu Dhabi → DoH Abu Dhabi (default, editable)
//   Others → MOHAP (default, editable)
// Shows compliance note below selection:
//   "This staff member must hold a valid [Authority] license to perform clinical actions"
```

### 5.2 Modified components

#### 5.2.1 Emergency Call Button

```tsx
// src/components/ui/EmergencyCallButton.tsx
// CHANGE: hardcoded '911' → uaeTokens.ambulanceNumber ('998')
// Label: "Call Ambulance 998" (EN) / "اتصل بالإسعاف 998" (AR)
// Icon: UAE Red Crescent icon (add to icon set) or generic ambulance icon
// Search codebase for any hardcoded '911' strings — replace all
```

#### 5.2.2 Status Bar / Date Display

```tsx
// Any component rendering dates:
// Change format from MM/DD/YYYY → DD/MM/YYYY globally
// Add <HijriDateChip /> below any full date display (not inline timestamps)
// Full dates: appointment cards, report headers, profile pages
// Inline timestamps (HH:MM AM/PM): no change needed
```

#### 5.2.3 Allergen Chip Grid

```tsx
// src/components/cafeteria/AllergenChipGrid.tsx
// CHANGE: render order update
// NEW ORDER:
//   ROW 1 (Religious/Legal — highest priority, red chips):
//     NonHalalBadge | "Pork/pork-derived" | "Alcohol-derived"
//   ROW 2 (FDA allergens, existing chips, unchanged):
//     Peanuts | Tree Nuts | Dairy | Eggs | Wheat | Soy | Sesame | Fish | Shellfish
// Each chip label: bilingual (EN top, AR below in 10px)
// Visual separator between row 1 and row 2: thin divider with label "Dietary requirements" (row 1) and "Allergens" (row 2)
```

**Phase 2 QA Gate:** All 9 new components render in both Arabic and English modes. HalalBadge shows correct color and text per language. EmergencyCallButton shows 998. AllergenChipGrid shows religious restrictions above FDA allergens.

---

## 6. Phase 3 — New: Physician Role (6 screens)

> **Antigravity:** This is an entirely new role. Create a new navigation stack: `PhysicianStack`. The physician does not share a tab bar with any other role. Role is identified by `user.role === 'physician'` in the auth response.

### Navigation stack

```
PhysicianStack/
  PH-01  PhysicianDashboardScreen
  PH-02  MedicationProtocolReviewScreen
  PH-03  ClinicalEscalationInboxScreen
  PH-04  ReportCoSignatureScreen
  PH-05  ScheduleConfigScreen
  PH-06  PhysicianSettingsScreen
```

**Tab bar:** Home (`PH-01`) | Protocols (`PH-02`) | Escalations (`PH-03`) | Settings (`PH-06`)

**Tab bar accent color:** `colors.physicianTeal` (`#0D9488`)

---

### PH-01 — Physician Dashboard

**File:** `screens/physician/PhysicianDashboardScreen.tsx`

**Layout (top → bottom):**

1. **Top app bar:** `"Dr. [lastName]"` left · teal avatar (initials "DR") right → taps to `PH-06`
2. **On-site status card** (white, 12px radius, 1px border):
   - Row of 7 day chips (S M T W T F S) — active days filled `physicianTeal`, today highlighted with ring
   - If today is on-site: `"On-site · Until 3:00 PM"` green chip
   - If today is off-site: `"On-call: +971 50 XXX XXXX"` amber chip
3. **Review queue section** (`"Awaiting your approval"` header + count badge):
   - Each pending protocol: compact card → `PH-02` on tap
   - Empty state: `"No protocols pending review"` + green checkmark
4. **Escalations section** (`"Active escalations"` header):
   - Emergency cases: red-border cards → `PH-03` on tap
   - Empty state: `"No active escalations"`
5. **Reports to co-sign section:**
   - Reports submitted by nurse → `PH-04` on tap
   - Empty state: `"No reports pending co-signature"`
6. **Bottom tab bar:** Home (active) | Protocols | Escalations | Settings

---

### PH-02 — Medication Protocol Review

**File:** `screens/physician/MedicationProtocolReviewScreen.tsx`

**Route params:** `{ studentId, medicationId, proposedBy: nurseId }`

**Layout:**
1. **Top app bar:** back `←` (RTL: `→`) · `"Protocol Review"` · student name subtitle
2. **FERPA-equiv notice** (UAE PDPL): blue info banner — _"Physician approval is required before this medication can be administered per DHA/HRS/HPSD/ST-22."_
3. **Student card:** avatar + name + grade + school
4. **Nurse's proposal card** (white, 12px radius, 1px border):
   - Medication name (20px, 500 weight)
   - Dose + frequency chips
   - Scheduled times
   - Physician order doc thumbnail + `"View document"` link
   - Locked footer: `"Proposed by [Nurse Name] · [License#] · [DD/MM/YYYY]"` + lock icon
5. **Physician action section:**
   - `"Approve as proposed"` → teal primary button
   - `"Approve with modification"` → secondary; expands inline edit fields (dose, time, duration)
   - `"Request more info"` → outlined; opens text field with send action
   - `"Decline"` → red outlined; mandatory reason field required before submit
6. **Digital approval signature** (appears after any positive action):
   - PIN entry or Face ID prompt
   - On success: stamps immutable record → `"Approved by Dr. [Name] · DHA MD-XXXX · [DD/MM/YYYY] at [HH:MM:SS]"`
   - Navigate back to `PH-01` after stamp

**Business logic:**
```
if (action === 'approve' || action === 'approveWithModification') {
  → POST /api/medications/{id}/physician-approval
  → body: { physicianId, licenseNumber, action, modifications?, timestamp }
  → response updates medication.physicianApprovalStatus = 'approved'
  → triggers push notification to nurse: "Dr. [Name] approved [MedName] for [Student]"
}
```

---

### PH-03 — Clinical Escalation Inbox

**File:** `screens/physician/ClinicalEscalationInboxScreen.tsx`

**Layout:**
1. **Top app bar:** `"Escalations"` + red badge count
2. **Off-site amber banner** (visible when physician is off-site today):
   _"You are currently on-call. Respond to escalations within 10 minutes."_
3. **Active escalations section** (sorted by time — oldest first):
   Each item is a red-border card:
   - Student name + severity chip (Moderate / Severe / Critical)
   - Nurse's incident description (truncated, 2 lines)
   - Incident photo thumbnail (tap to expand)
   - Time elapsed badge: `"8 min ago"` — turns red if > 8 min
   - **Action buttons:**
     - `"Authorize emergency transport"` → red primary → confirmation dialog → POST approval
     - `"Authorize first aid at clinic"` → amber outlined → confirmation → POST approval
     - `"Request parent contact first"` → secondary → note field → POST note
4. **Resolved today section** (collapsed by default): list of resolved escalations with green chips

**Confirmation dialog spec:**
```
Title: "Authorize Emergency Action"
Body:  "You are authorizing: [action description] for [Student Name].
       This is logged permanently under your DHA license [MD-XXXX]."
Buttons: Cancel (secondary) | Authorize (red primary)
```

---

### PH-04 — Report Co-Signature

**File:** `screens/physician/ReportCoSignatureScreen.tsx`

**Route params:** `{ reportId, nurseId }`

**Layout:**
1. **Top app bar:** back · `"Report Co-Signature"`
2. **Report metadata card:** type + date range + nurse name + nurse license
3. **Scrollable PDF preview** (use `react-native-pdf` or WebView with PDF URL)
4. **Physician review notes** (optional text field, 80px min height)
5. **Signature section:**
   - Nurse signature block (locked, green): `"Signed: [Nurse Name] · [RN-XXXX] · [date]"`
   - Physician signature area:
     - If not signed: signature pad (canvas) + UAE Pass button (shows "Coming soon" toast)
     - `"Add my co-signature"` teal primary button → PIN/Face ID → immutable stamp
   - After co-sign: both signatures locked, `"Export PDF"` + `"Submit to Principal"` actions appear

---

### PH-05 — Schedule Configuration

**File:** `screens/physician/ScheduleConfigScreen.tsx`

**Layout:**
1. **Top app bar:** back · `"My Schedule"`
2. **On-site days** (7-day toggle row: S M T W T F S):
   - Active days fill `physicianTeal`
   - Below: `"DHA requires minimum 3 on-site days per week"` info notice
   - Counter: `"3 of 7 days selected ✓"` green chip (amber/red if < 3)
3. **Per-day time config** (visible for each active day):
   - Arrival time picker + Departure time picker
4. **On-call config section:**
   - On-call phone: UAE format input (+971)
   - On-call hours: time range picker
   - Response SLA: `"Within 10 minutes (DHA requirement)"` locked amber chip — cannot edit
5. **Backup physician section:**
   - Name + license number + phone fields
   - `"Add backup"` button
6. **`"Save schedule"`** teal primary → confirmation including DHA 3-day check

---

### PH-06 — Physician Settings

**File:** `screens/physician/PhysicianSettingsScreen.tsx`

**Layout:** Standard settings list pattern (same as other role settings) with these sections:

1. **Profile:** teal avatar 64px + name + `"School Physician"` teal chip + specialty + school
2. **UAE License section:**
   - License authority: `LicenseAuthoritySelector` component
   - License number (read-only after registration) — `MD-XXXX` format
   - Expiry date — with status chip: green (>90d) / amber (30–90d) / red (<30d)
   - `"Update license"` link → document upload flow
3. **Notifications** (all locked except last):
   - New protocol to review — ON, locked
   - Emergency escalations — ON, locked
   - Report awaiting co-signature — ON, editable
   - Schedule reminder (day before on-site) — ON, editable
4. **Confidentiality:** Signed date + `"View"` link → agreement sheet (UAE Medical Law ref)
5. **Sign out** — red, confirmation dialog

---

## 7. Phase 4 — Nurse Role Changes (7 screens)

> **Antigravity:** Do not rebuild these screens. Open each existing screen file and apply the listed changes only.

---

### N-01 Dashboard — changes

**File:** `screens/nurse/DashboardScreen.tsx`

```
CHANGE 1 — Add physician queue card
  Location: below stats row, above Quick Actions
  Component: white card, amber left border (right in RTL), amber bg tint
  Content: "⏳ Awaiting physician approval: [count] protocol(s)"
  Action button: "Review with physician" — amber outlined → navigate to N-03 filtered
  Visibility: show only if pendingPhysicianApprovals > 0

CHANGE 2 — Emergency button
  Find: EmergencyCallButton or any hardcoded '911'
  Replace with: EmergencyCallButton component (shows '998')
  Label update: "طوارئ · Emergency" (bilingual)

CHANGE 3 — Weather advisory banner
  Add: "Haboob (عاصفة رملية)" as a selectable advisory type
  Update source label: "UAE NCM" instead of any existing weather source label
  No change to visual style of banner
```

---

### N-04 Medication Detail — changes

**File:** `screens/nurse/MedicationDetailScreen.tsx`

```
CHANGE 1 — Add PhysicianApprovalCard component
  Location: between medication header card and supply counter
  Use: <PhysicianApprovalCard status={medication.physicianApprovalStatus}
                               approvedBy={medication.physicianApproval} />
  When status === 'pending': disable the "Mark as Given" button (opacity 0.4, onPress → toast "Awaiting physician approval")
  When status === 'approved': enable "Mark as Given" button normally

CHANGE 2 — Dose log
  No change — timestamps already include seconds (HH:MM:SS) ✓
```

---

### N-06 Add Medication Step 2 — changes

**File:** `screens/nurse/AddMedicationStep2Screen.tsx`

```
CHANGE 1 — Physician on-duty context
  Add below student selector: small info chip
  Content: "Physician on duty: Dr. [name] · On-site until [time]"
  Data: fetch from /api/school/physician/today
  If physician is off-site: "Physician on-call: Dr. [name]" amber chip

CHANGE 2 — Submit button
  Change: "Next: Confirm" → "Submit for physician review"
  Dialog on tap:
    Title: "Submit for Physician Review"
    Body: "This medication protocol will be sent to [Dr. Name] for approval. It cannot be administered until approved."
    Buttons: Cancel | Submit (teal primary)
```

---

### N-16 Emergency Consent — changes

**File:** `screens/nurse/EmergencyConsentScreen.tsx`

```
CHANGE 1 — Emergency call button
  Find: any '911' reference or existing call button
  Replace with: EmergencyCallButton ('998')
  Add UAE Red Crescent icon if available in icon set

CHANGE 2 — Add physician escalation button
  Below the existing emergency call button:
  New secondary outlined button (teal): "Contact on-call physician"
  On tap: call physician's on-call number from PH-05 config
  Fetch: GET /api/school/physician/oncall → { phone }
```

---

### N-19 Student Health Profile — changes

**File:** `screens/nurse/StudentHealthProfileScreen.tsx`

```
CHANGE 1 — Identity fields
  Remove: SSN / Social Security Number field
  Add: Emirates ID (EID) field
    Label: "Emirates ID" / "الهوية الإماراتية"
    Display: formatted 784-XXXX-XXXXXXX-X
    Validation: eidValidator.validateEID()

CHANGE 2 — Date of birth
  Existing: Gregorian DOB display
  Add below: <HijriDateChip date={student.dateOfBirth} />

CHANGE 3 — Insurance section
  Remove: US insurance fields (provider, group#, member ID)
  Add UAE insurance fields:
    - Insurer name (text input)
    - Policy number (text input)
    - Card expiry (MM/YYYY picker)
    - Upload insurance card (document upload slot, same pattern as other doc uploads)
  Label: "UAE Health Insurance" / "التأمين الصحي الإماراتي"

CHANGE 4 — Curriculum field
  Add: Curriculum dropdown using CurriculumSelector component
  Options: uaeTokens.curricula
  Used to determine grade label display throughout app
```

---

### N-22 Cafeteria Alert Sender — changes

**File:** `screens/nurse/CafeteriaAlertSenderScreen.tsx`

```
CHANGE — AllergenChipGrid rendering order
  Use updated AllergenChipGrid component from Phase 2
  Religious/legal restrictions now render FIRST (non-Halal, pork, alcohol)
  FDA allergens render below with Arabic bilingual labels
  Preview section: cafeteria preview shows Arabic labels alongside English
```

---

### N-23 Generate Report — changes

**File:** `screens/nurse/GenerateReportScreen.tsx`

```
CHANGE — Co-signature toggle
  Add to "Include sections" area:
  Toggle row: "Submit for physician co-signature after generation"
  Default: ON
  Subtitle: "Report will be sent to on-duty physician for dual-sign before finalizing"
  When ON and report is generated:
    → POST /api/reports/{id}/submit-for-cosign
    → Nurse sees: "Report submitted · Awaiting physician co-signature"
    → Physician sees item in PH-04 queue
```

---

## 8. Phase 5 — Cafeteria Role — Halal Layer (3 screens)

---

### C-01 Allergen Dashboard — changes

**File:** `screens/cafeteria/AllergenDashboardScreen.tsx`

```
CHANGE 1 — Halal status banner
  Location: pinned below top app bar, above daily alert list
  Component: new full-width card, green left border (right in RTL)
  SYNCED state: "All meals today are Halal-certified ✓" — green text + HalalBadge
  WARNING state: "⚠ Non-Halal item detected" — red border, red text
  Data: GET /api/school/cafeteria/halal-status/today

CHANGE 2 — Daily acknowledgment
  Existing: single "I have reviewed today's allergen list" checkbox
  Add: second separate checkbox: "I confirm all meals today are Halal-certified"
  Both must be checked to enable the "Acknowledge" submit button
  In Arabic: "أؤكد أن جميع الوجبات اليوم متوافقة مع الشريعة الإسلامية (حلال)"

CHANGE 3 — Student restriction cards
  Use updated AllergenChipGrid (Phase 2) — Halal chips render first, prominently
```

---

### C-02 Allergen Detail — changes

**File:** `screens/cafeteria/AllergenDetailScreen.tsx`

```
CHANGE — Add Halal section at top
  Before allergen list, add:
  Card (green or red based on student's Halal restriction):
    "Halal status: Certified ✓" — green card with HalalBadge
    OR "Non-Halal restriction active" — red card with NonHalalBadge
    Sub-line: "Parent-confirmed restriction: Yes" — locked, 12px gray
  
  If special Halal meal is configured:
    Section: "Special meal preparation"
    Content: meal description in Arabic + English
    Note: "Approved by parent on [date]" — locked line
```

---

### C-06 Cafeteria Settings — changes

**File:** `screens/cafeteria/CafeteriaSettingsScreen.tsx`

```
CHANGE — Add Halal compliance section
  Location: after Notifications section, before Data & Privacy
  Section header: "Halal Compliance" / "الامتثال لمتطلبات الحلال"
  
  Row 1: Halal certification status
    Display: "Certified · Expires: [DD/MM/YYYY]" green chip
    Tap: opens certificate image viewer
    If expired/missing: red chip "Certification required" + "Upload" action
  
  Row 2: Daily Halal acknowledgment
    Toggle: ON — LOCKED (cannot disable)
    Lock tap explanation: "The daily Halal acknowledgment cannot be disabled. 
    All cafeteria staff must confirm Halal compliance before meal service."
  
  Row 3: Certification renewal reminder
    Toggle: ON, editable
    Sub: "Remind 30 days before certificate expiry"
```

---

## 9. Phase 6 — Parent Role Changes (5 screens)

---

### P-01 School Code Entry — changes

**File:** `screens/parent/SchoolCodeEntryScreen.tsx`

```
CHANGE — Language toggle
  Add language toggle "عربي | English" at the very top (below Synapse logo)
  Style: pill shape, #E2E8F0 bg, active language in #2563EB
  On toggle: switch i18n language + RTL layout immediately
  In Arabic mode: heading "إعداد الملف الصحي لطفلك", input placeholder "أدخل رمز الدعوة"
```

---

### P-03 Emergency Medical Consent — changes

**File:** `screens/parent/EmergencyMedicalConsentScreen.tsx`

```
CHANGE 1 — Legal references
  Replace: FERPA / US law citations in consent text
  With: UAE Federal Law No. 4/2016 (Medical Liability) + UAE emergency care protocols
  Replace: "Call 911" → "Call ambulance 998"
  Add: UAE health insurance authorization clause

CHANGE 2 — Language
  Arabic consent text appears FIRST (RTL, primary)
  English below in collapsible section: "English translation (reference only)" with chevron
  Arabic version is the legally binding copy — add "(النص العربي هو المرجع القانوني)" note at top
```

---

### P-04 Privacy Agreement — changes

**File:** `screens/parent/PrivacyAgreementScreen.tsx`

```
CHANGE — Legal references
  Replace: all FERPA references with UAE PDPL (المرسوم بقانون رقم 45/2021)
  Add sections:
    1. Data subject rights (PDPL Article 7): access, correction, deletion, objection
    2. DPO contact: "Data Protection Officer: dpo@synapse.ae"
    3. Data residency clause: "All data is stored exclusively within the United Arab Emirates"
  Arabic text primary, English secondary (same pattern as P-03)
```

---

### P-16 Notification Settings — changes

**File:** `screens/parent/NotificationSettingsScreen.tsx`

```
CHANGE 1 — Add WhatsApp channel
  In every notification category (Clinic, Medications, Documents, Emergency):
  Add third toggle row using WhatsAppToggleRow component
  Position: after Push, after SMS, before email
  "Recommended for UAE" badge visible on all WhatsApp rows

CHANGE 2 — Emergency alerts lock
  Emergency: Push ON (locked) + SMS ON (locked) + WhatsApp ON (locked)
  All three channels locked for emergency — cannot disable any
  Tooltip when tapping lock: "Emergency alerts are sent via all channels to ensure you are reached immediately."
```

---

### P-22 Parent Profile & Settings — changes

**File:** `screens/parent/ParentProfileScreen.tsx`

```
CHANGE 1 — Insurance fields (replace US with UAE)
  Remove: US insurance provider, group number, member ID
  Add:
    - "Health insurer name" / "اسم شركة التأمين" — text input
    - "Policy number" / "رقم الوثيقة" — text input
    - "Card expiry" / "انتهاء صلاحية البطاقة" — MM/YYYY picker
    - "Upload insurance card" / "رفع بطاقة التأمين" — doc upload slot
  Note below section: "UAE health insurance is mandatory for all Dubai residents 
  (Law No. 11/2013)" / "التأمين الصحي إلزامي لجميع المقيمين في دبي (قانون رقم 11/2013)"

CHANGE 2 — Parent EID field
  Add to profile fields: "Emirates ID (EID)" with eidValidator validation

CHANGE 3 — Curriculum per child
  In linked children section, each child card adds:
  "Curriculum: [UAE MoE / British / American / Indian / IB]" — small gray label
  Tappable → CurriculumSelector component

CHANGE 4 — Legal section
  Replace: "FERPA rights" section
  With: "PDPL rights" section — three rows:
    - "Request data access" → submit access request form
    - "Request data correction" → submit correction request form
    - "Request data deletion" → submit deletion request (with retention warning dialog)
```

---

## 10. Phase 7 — Auth Flow Changes (3 screens)

---

### Auth-05 Confidentiality Agreement — changes

**File:** `screens/auth/ConfidentialityAgreementScreen.tsx`

```
CHANGE 1 — Language toggle at top
  Same "عربي | English" pill toggle pattern as P-01
  Arabic = primary, legally binding
  English = reference translation (collapsed, "Show" button)

CHANGE 2 — Legal text content
  Replace all FERPA/COPPA/HIPAA references
  Use UAE-specific content per user's role:
    Clinical roles (Nurse, Physician): UAE PDPL + UAE Medical Liability Law No. 4/2016
    Admin roles (Secretary, Principal): UAE PDPL + UAE Labour Law No. 33/2021
    All roles: reference UAE Data Office (مكتب حماية البيانات الإماراتي)

CHANGE 3 — DPO contact line
  Add at bottom of agreement text (above scroll gate):
  "Data Protection Officer | مسؤول حماية البيانات: dpo@synapse.ae"
  Style: 12px, #64748B, lock icon
```

---

### Auth-06 E-Signature — changes

**File:** `screens/auth/ESignatureScreen.tsx`

```
CHANGE 1 — UAE Pass option
  Add UAEPassSignOption component below the signature pad
  "Or sign with" label + UAE Pass button
  Current behavior: shows "Coming soon" toast (API integration is Phase 2)

CHANGE 2 — Timestamp format
  Change: MM/DD/YYYY → DD/MM/YYYY
  Format: "Signed: 19/05/2026 at 09:14"

CHANGE 3 — Legal reference line
  Add below timestamp:
  "هذا التوقيع ملزم قانونياً بموجب قانون المعاملات الإلكترونية الإماراتي رقم 46/2021"
  Style: 12px, #64748B, RTL text
```

---

### Login — changes

**File:** `screens/auth/LoginScreen.tsx`

```
CHANGE — Language toggle
  Add "عربي | English" pill toggle below Synapse logo
  On tap: switches i18n + RTL immediately for all auth screens
  In Arabic mode: all labels, placeholders, and error messages in Arabic
  Persist language choice to AsyncStorage (remembered for future sessions)
```

---

## 11. Phase 8 — Principal & System States (5 screens)

---

### M-03 Add Staff — changes

**File:** `screens/principal/AddStaffScreen.tsx`

```
CHANGE — UAE license fields (for Nurse and Physician roles)
  After role selection, if role is 'nurse' or 'physician':
  
  Show: LicenseAuthoritySelector component
  Show: License number field (format validation per authority)
  Show: License expiry date picker
  Show: Specialty field (Physician only): General Practitioner / Pediatrician / Other
  
  Compliance notice (amber info box):
  "This staff member must hold a valid [Authority] license to perform clinical 
  actions in [Emirate] schools. Their license is verified on first login."
```

---

### M-05 Health Analytics — changes

**File:** `screens/principal/HealthAnalyticsScreen.tsx`

```
CHANGE 1 — Weather condition types
  Add "Haboob / عاصفة رملية (Sandstorm)" as a selectable condition in weather correlation chart
  Style: same as existing AQI condition type — brown/orange color

CHANGE 2 — Seasonal markers on visit chart
  Add vertical amber line on Ramadan dates (calculated from Hijri calendar)
  Label: "رمضان · Ramadan" — bilingual, 11px

CHANGE 3 — Source labels
  Change: any existing weather source label → "UAE NCM (المركز الوطني للأرصاد)"
```

---

### M-06 Weather Advisory — changes

**File:** `screens/principal/WeatherAdvisoryScreen.tsx`

```
CHANGE 1 — Advisory types
  Add "Haboob (Sandstorm) / عاصفة رملية" as a first-class type
  Color: #92400E (brown) for chip + border
  Icon: sand/wind icon from icon set

CHANGE 2 — Source
  Change source attribution → "UAE NCM (المركز الوطني للأرصاد)" with logo placeholder

CHANGE 3 — WhatsApp distribution
  In "Send to" section, add WhatsApp toggle alongside push and SMS
  Uses WhatsAppToggleRow component
```

---

### M-13 Legal Documents — changes

**File:** `screens/principal/LegalDocumentsScreen.tsx`

```
CHANGE 1 — Replace FERPA documents with UAE equivalents
  Remove: "FERPA Data Processing Agreement"
  Add: "UAE PDPL Data Processing Agreement (DPA) · المرسوم بقانون رقم 45/2021"
  
  Remove: "FERPA School Official Designation"
  Add: "UAE PDPL Controller-Processor Designation"
  
  Add new rows:
    "HASANA Integration Authorization" — visible only if school.emirate === 'Dubai'
      Status chip: Connected / Not connected + "Connect" button if not connected
    "DPO Registration Certificate" — upload slot
      Sub: "Data Protection Officer registration with UAE Data Office"

CHANGE 2 — Emirate context
  Add at top of screen: "This school is in: [Emirate]" — read-only chip
  Documents shown and required change based on emirate
```

---

### SYS-05 — NEW: Ramadan Mode Active (new system state screen)

**File:** `screens/system/RamadanModeScreen.tsx` (new file)

**Visibility logic:**
```ts
// This is NOT a full-screen — it is a PERSISTENT BANNER component
// rendered on top of every screen during Ramadan

// src/components/system/RamadanBanner.tsx
// Show when: hijriCalendar.isRamadan(today) === true
// Dismiss: per-session only (AsyncStorage with session key, not permanent)
// After dismiss: collapses to a small crescent moon pill (24px, bottom-left corner)
//               tapping the pill re-expands the banner
```

**Banner layout:**
```
Background: #FFFBEB (amber tint), 1px #F59E0B border
Left icon: crescent moon (RTL: right icon)
Content column:
  "رمضان كريم · Ramadan Mubarak" — bilingual, 14px 500
  "Modified school hours: 08:00 AM – 1:30 PM" — 12px #64748B
  "Check medication dose timings" link → N-11 Daily Dose View
Right: × dismiss button (44×44px touch target)
```

**Integration points:**
```
- Render RamadanBanner inside the root navigator layout (above all screens)
- Cafeteria screens: override morning banner text to "Modified meal service during Ramadan"
- SC-02 Counselor Tag Entry: show "Ramadan fatigue" tag during Ramadan period
```

---

## 12. Phase 9 — All Remaining Roles (batch)

### 9.1 Secretary changes

**SE-01 Dashboard** (`screens/secretary/SecretaryDashboardScreen.tsx`):
```
ADD: HasanaSyncWidget component (Phase 2)
Visibility: school.emirate === 'Dubai' only
Position: below pending tasks widget
```

**SE-03 Import Students** (`screens/secretary/ImportStudentsScreen.tsx`):
```
UPDATE: Excel template columns
  Remove: SSN column
  Add: Emirates ID (EID) column — format 784-YYYY-XXXXXXX-X
  Add: Emirate column (7 values from uaeTokens.emirates)
  Add: Curriculum column (uaeTokens.curricula)
  Add: UAE Health Insurer column (text)
  Add: Insurance Policy Number column (text)

UPDATE: Validation rules
  EID validation: eidValidator.validateEID()
  Error messages: bilingual AR + EN
```

### 9.2 Counselor changes

**SC-02 Tag Entry** (`screens/counselor/TagEntryScreen.tsx`):
```
UPDATE: All psychosocial tag chip labels → bilingual
  Format: "Sensory overload" top line + "حمل حسي" below in 10px

ADD: Ramadan fatigue tag (conditional)
  Chip: "Ramadan fatigue · إجهاد رمضان" — amber chip
  Visibility: only shown when hijriCalendar.isRamadan(today) === true
  Group: add "Seasonal" group header above this chip when visible

UPDATE: Environmental context auto-capture
  When isRamadan: append { type: 'ramadan_period', label: 'رمضان · Ramadan' } to context tags
```

### 9.3 All Settings screens (all roles)

Apply to: Nurse / Teacher / Cafeteria / Secretary / Counselor / Security / Bus / VP settings screens:

```
1. CONFIDENTIALITY AGREEMENT REFERENCE
   Replace: any US law citation
   With: UAE PDPL (المرسوم بقانون رقم 45/2021) for all roles
         UAE Medical Liability Law No. 4/2016 for clinical roles (Nurse, Physician, Counselor)

2. ACCESS LEVEL DESCRIPTION
   Existing "My data access level" chip: add Arabic translation below English text

3. SIGN OUT DIALOG
   Change from English-only to bilingual:
   Title: "تسجيل الخروج · Sign out?"
   Buttons: "إلغاء · Cancel" | "تسجيل الخروج · Sign out"

4. UAE LICENSE SECTION (clinical roles only: Nurse, Physician, Counselor)
   Add section between Notifications and Data & Privacy:
     - License authority: LicenseAuthoritySelector (read-only display)
     - License number: display only
     - Expiry: with status chip (green/amber/red)
     - "Update license" → document upload
```

### 9.4 Security Guard, Bus Driver — RTL only

```
No functional changes.
RTL layout applies via DirectionalView wrapper (Phase 1).
Student names render in the language stored in student.preferredDisplayLanguage.
QR scan flow: unchanged.
Route names and stop labels: may be bilingual depending on school data — no code change needed.
```

---

## 13. Phase 10 — Global Field & Form Changes

### 10.1 Global string replacements

> **Antigravity:** Run a codebase-wide search for each of these strings and apply the replacement.

| Find | Replace | Scope |
|---|---|---|
| `'911'` | `uaeTokens.ambulanceNumber` (`'998'`) | All files |
| `'9-1-1'` | `'9-9-8'` | All files |
| `'MM/DD/YYYY'` | `'DD/MM/YYYY'` | All files |
| `'SSN'` / `'Social Security'` | `'Emirates ID (EID)'` | All files |
| `'ZIP'` / `'ZIP code'` | `'PO Box / Area Code'` | All files |
| `'USD'` / `'$'` (in UI strings only, not code logic) | `'AED'` / `'درهم'` | UI string files only |
| `'FERPA'` (in UI strings) | `'UAE PDPL'` | UI string files only |
| `'State'` (in address context) | `'Emirate'` | Form components |

### 10.2 Phone number validation

```ts
// src/utils/phoneValidator.ts — ADD UAE validation

export function validateUAEPhone(phone: string): boolean {
  // UAE mobile: +971 5X XXX XXXX (or 05X XXX XXXX local)
  // UAE landline: +971 X XXX XXXX
  const stripped = phone.replace(/[\s\-\(\)]/g, '');
  return /^(\+971|00971|0)(5[024568]\d{7}|[234679]\d{7})$/.test(stripped);
}

export function formatUAEPhone(raw: string): string {
  // Auto-format as user types
  // Output: +971 50 123 4567
}
```

### 10.3 Date format enforcement

```ts
// src/utils/dateFormatter.ts — UPDATE

// Remove: any MM/DD/YYYY formatting
// Standard: DD/MM/YYYY everywhere
// Timestamps (HH:MM:SS): unchanged
// Long format: "19 May 2026" (EN) / "١٩ مايو ٢٠٢٦" (AR) — for report headers
// Hijri alongside: wherever a full date is shown on a dedicated date field (not inline timestamps)
```

---

## 14. Phase 11 — Navigation & Flow Wiring

### 11.1 New navigation connections

```
PH-01 Dashboard → PH-02 (tap protocol card)
PH-01 Dashboard → PH-03 (tap escalation card)
PH-01 Dashboard → PH-04 (tap report card)
PH-01 Avatar → PH-06 Settings
PH-02 Protocol approved → back to PH-01 (queue item removed)
PH-03 Escalation authorized → N-16 (nurse sees "Physician authorized" status update)
PH-04 Co-signed → N-24 Report Preview (dual signatures visible)

N-04 Medication Detail → [if physician pending] physician's PH-01 (deep link notification only)
N-06 Step 2 → [on submit] → PH-02 (physician receives queue item) → N-03 (nurse back to list)
N-23 Generate Report → [with co-sign ON] → PH-04 (physician queue) → N-24 (after co-sign)
```

### 11.2 Auth role routing — update

```ts
// src/navigation/RoleRouter.tsx — UPDATE

// Add new case for physician role
switch (user.role) {
  case 'nurse':      return <NurseStack />;
  case 'physician':  return <PhysicianStack />;  // ← NEW
  case 'teacher':    return <TeacherStack />;
  case 'cafeteria':  return <CafeteriaStack />;
  case 'security':   return <SecurityStack />;
  case 'driver':     return <DriverStack />;
  case 'parent':     return <ParentStack />;
  case 'counselor':  return <CounselorStack />;
  case 'secretary':  return <SecretaryStack />;
  case 'principal':  return <PrincipalStack />;
  case 'vice':       return <VicePrincipalStack />;
  default:           return <ErrorScreen />;
}
```

### 11.3 Ramadan banner global integration

```tsx
// src/navigation/RootNavigator.tsx — UPDATE

// Inside the root navigator render, wrap with RamadanBanner:
<>
  <RamadanBanner />   {/* renders on all screens when isRamadan */}
  <NavigationContainer>
    {/* existing nav */}
  </NavigationContainer>
</>
```

---

## 15. Phase 12 — QA Checklist

> **Antigravity:** Run through every item before marking implementation complete.

### 15.1 UAE token checks

- [ ] Emergency number: `998` appears on all emergency buttons and screens — no `911` anywhere in UI strings
- [ ] Dates: `DD/MM/YYYY` throughout — no `MM/DD/YYYY` anywhere
- [ ] Currency: `AED` / `درهم` — no `$` or `USD` in UI strings
- [ ] ID field: `Emirates ID (EID)` label — no `SSN` or `Social Security` in UI strings
- [ ] Geography: Emirate dropdown (7 items) — no US states in any address form
- [ ] WhatsApp toggle row: appears in every notification settings screen

### 15.2 RTL layout checks (test in Arabic mode)

- [ ] Back arrows point RIGHT (`→`) — not left
- [ ] Progress bars fill from RIGHT to LEFT
- [ ] All body text is right-aligned
- [ ] List row chevrons point LEFT (`‹`)
- [ ] Info box / banner accent borders are on the RIGHT side
- [ ] Form labels right-aligned above inputs
- [ ] Bottom tab bars: Home tab is rightmost
- [ ] Toast notifications slide in from left (not right)
- [ ] No text overflow or clipping in Arabic (Arabic text is wider — check all chips and buttons)
- [ ] Arabic numerals option: Eastern Arabic (٠١٢٣) renders correctly in Hijri date chip

### 15.3 Physician role checks

- [ ] PH-01 through PH-06 screens exist and are reachable from Role Router
- [ ] N-04: `"Mark as Given"` button disabled (opacity 0.4) when physician approval is pending
- [ ] N-06 Step 2: submits for physician review — does NOT directly add medication
- [ ] N-16: shows `"Call 998"` and `"Contact physician"` buttons — no `"911"`
- [ ] N-23: `"Submit for co-signature"` toggle present and routes to PH-04 when ON
- [ ] PH-02 approval stamps an immutable record with physician name + license + timestamp (HH:MM:SS)
- [ ] PH-03 escalation cards show time elapsed — badge turns red if > 8 min no response

### 15.4 Halal compliance checks

- [ ] C-01: Non-Halal chips render FIRST in all allergen displays — above FDA allergens
- [ ] C-01: Morning acknowledgment requires BOTH allergen ✓ AND Halal ✓ checkboxes
- [ ] C-02: Halal status card appears at TOP of detail screen (before allergen list)
- [ ] C-06: Daily Halal acknowledgment toggle is LOCKED ON — cannot be disabled
- [ ] N-22: Cafeteria alert sender shows Non-Halal / Pork / Alcohol chips in row 1

### 15.5 Parent flow checks

- [ ] P-03: consent text references UAE law — no FERPA, no US law citations
- [ ] P-04: privacy agreement references PDPL — has DPO contact, data residency clause
- [ ] P-16: WhatsApp toggle appears in all notification categories — emergency WhatsApp locked ON
- [ ] P-22: UAE insurance fields present, US fields removed, PDPL rights section present

### 15.6 Accessibility (unchanged requirements — still enforced)

- [ ] All Arabic text minimum 14px (Arabic requires slightly larger than Latin equivalent)
- [ ] Status chips: icon + label (never color alone) — applies in both languages
- [ ] All touch targets: minimum 44×44px — especially important for RTL-flipped elements
- [ ] Focus rings visible on all interactive elements
- [ ] Error states: red border + icon + message text (never icon or color alone)
- [ ] Halal badge: always has both icon AND text (not color alone)
- [ ] Contrast ratios: unchanged from US spec — WCAG 2.1 AA minimum

### 15.7 Sign-off gate

Before marking Phase 12 complete:

```
□ All 130 screens render without crash in both AR and EN modes
□ All 12 roles route correctly from Role Router
□ Physician approval chain tested end-to-end:
    N-06 submit → PH-02 review → approve → N-04 enabled → N-08 confirm
□ Ramadan banner appears when isRamadan=true, dismisses per session, re-expands on crescent tap
□ HASANA sync widget renders for Dubai schools only, hidden for other emirates
□ UAE Pass button in Auth-06 shows "Coming soon" toast (not a dead-end crash)
□ No hardcoded '911', 'SSN', '$', 'MM/DD/YYYY', 'US States' strings remaining in UI layer
```

---

## 16. Screen Count Reference

| Figma Page | US Screens | UAE Screens | Changes |
|---|---|---|---|
| Auth Flow | 7 | 7 | 3 modified |
| 🩺 Physician (new) | — | 6 | 6 new |
| Nurse | 25 | 25 | 7 modified |
| Teacher | 9 | 9 | RTL only |
| Cafeteria | 6 | 6 | 3 modified |
| Security + Bus | 10 | 10 | RTL only |
| Parent | 22 | 22 | 5 modified |
| Counselor | 7 | 7 | 2 modified |
| Secretary | 7 | 7 | 2 modified |
| Principal | 14 | 14 | 4 modified |
| Vice Principal | 7 | 7 | 1 modified |
| System States | 4 | 5 | +1 Ramadan mode |
| **Total** | **119** | **130** | **+11 new · 38 modified · 70 RTL-only** |

---

## Appendix A — API Endpoints to Add (UAE-specific)

```
GET  /api/school/physician/today
     → { name, licenseNumber, emirate, isOnSite, onCallPhone, onSiteUntil }

POST /api/medications/{id}/physician-approval
     → body: { physicianId, action, modifications?, reason?, timestamp }

GET  /api/school/cafeteria/halal-status/today
     → { isHalalCertified, certExpiry, nonHalalAlertActive }

GET  /api/school/hasana/sync-status
     → { lastSync, status: 'synced'|'pending'|'failed', emirate }
     → only returns data if school.emirate === 'Dubai'

GET  /api/school/calendar/ramadan
     → { isRamadanActive, ramadanStart, ramadanEnd, modifiedHours }
     → calculated server-side from Hijri calendar

POST /api/reports/{id}/submit-for-cosign
     → routes report to physician's PH-04 queue

GET  /api/parent/{id}/pdpl-rights-requests
     → returns submitted access/correction/deletion requests
POST /api/parent/{id}/pdpl-rights-requests
     → body: { type: 'access'|'correction'|'deletion', details }
```

---

## Appendix B — Libraries to Add

```json
{
  "dependencies": {
    "i18next": "^23.x",
    "react-i18next": "^14.x",
    "hijri-converter": "^2.x",
    "react-native-pdf": "^6.x",
    "react-native-phone-input": "^1.x"
  }
}
```

> **Antigravity note on `i18next`:** If the existing codebase already uses a different i18n library, adapt the language context pattern to that library instead. The key requirement is: `isRTL` boolean available globally, `t('key')` function for all UI strings, and `language` switchable at runtime without app restart (except for RTL layout flip which requires restart on native — show dialog).

---

*End of implementation plan · Synapse UAE Market · v1.0 · June 2026*
*Questions → route to product owner before proceeding*
