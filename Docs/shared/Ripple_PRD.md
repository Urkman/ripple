# Ripple — Product Requirements Document

**Dokumenttyp:** Implementierungs-PRD (Single Source of Truth)
**Empfänger:** Grok Build (Implementation)
**Produkt:** Ripple – Water Tracker
**Version:** 2.0.4 — 9. September 2026
**Last verified:** 2026-09-09
**Lizenz:** MIT
**Sprache UI:** Deutsch + Englisch (String Catalogs)
**Code-Sprache:** English identifiers, German + English copy

Dieses eine Dokument ist die einzige versionierte Produkt-, Screen- und Bewegungs-Spezifikation. Es ersetzt alle vorherigen Teilstände und ist vollständig genug, um das Projekt ohne Chat-Kontext zu bauen. Wo Konzept-Screenshots vom Generator abweichen, gilt der Fließtext.

**Plattform-Hinweis:** Dieses PRD wird an das unabhängige Android-Projekt
weitergegeben. Produktumfang, Screens, Flows, Domänenregeln, Zustände und
Motion-Verträge gelten für beide Apps. Swift-, SwiftUI-, Apple- und Xcode-
Anweisungen beschreiben ausschließlich die iOS-Referenzimplementierung; das
Android-Projekt folgt zusätzlich `Android/ANDROID_ARCHITECTURE.md`,
`Android/ANDROID_UI_SPEC.md` und seinem eigenen `AGENTS.md`.

---

## 0. Auftrag an Grok Build

Baue eine **Open-Source-App** namens Ripple ausschließlich in **Swift 6 + SwiftUI**.

1. Folge der Architektur in Abschnitt 4 ohne Abweichung.
2. Implementiere den Scope von v1.0 vollständig (Abschnitt 3).
3. Keine Third-Party-Dependencies.
4. Keine Accounts, keine Werbung, keine IAP, keine Analytics.
5. HealthKit gehört zu v1.0. Eine Live Activity gehört bewusst nicht zu v1.0; Widgets, Control Center, Watch, Siri und Benachrichtigungen decken die schnellen Logs ab.
6. UI folgt Abschnitt 13, Abschnitt 14 und den detaillierten Verträgen in Abschnitt 22. Die aktuellen iOS-Captures in `screens/ios/` sind Referenz, nicht Pixel-Gesetz.
7. Liefere ein Xcode-Workspace inkl. Packages, das auf einem echten Gerät startet. CloudKit-Container und App Group als Platzhalter + README-Anleitung.
8. Domain- und Data-Tests müssen ohne App-Target laufen.

Wenn etwas unklar ist: die strengere, kleinere Variante wählen und die
Entscheidung in diesem PRD oder im Architektur-Dokument der betroffenen
Plattform dokumentieren. Nicht den Scope erweitern.

---

## 1. Produkt

**Name:** Ripple
**Store-Name:** Ripple – Water Tracker
**Tagline:** Hydration, die dir folgt.
**Bundle-ID-Schema:** `de.stefansturm.ripple` (Team-ID später ersetzen)
**App Group:** `group.de.stefansturm.ripple`
**iCloud Container:** `iCloud.de.stefansturm.ripple`
**GitHub:** Open Source, MIT. Contributor nutzen eigene IDs (`.xcconfig.example`).

Ripple ist ein Hydration-Tracker für alle Apple-Geräte. Wasser loggt man dort, wo man gerade ist (Widget, Watch, Siri, Control Center). Die App ist der ruhige Ort für Stand, Verlauf und Einstellungen.

Positionierung: erwachsen, systemweit, offen. Kein Lama, keine Gießpflanze, keine Paywall.

### 1.1 Erfolgsdefinition

- Ein Wassereintrag ist in unter zwei Sekunden von mindestens fünf Systemflächen möglich.
- Ein Watch-Log erscheint auf iPhone-Widget und Mac nach CloudKit-Sync.
- Repo ist für Dritte in unter 30 Minuten startbar.
- Architektur bleibt in Packages sichtbar und testbar.

### 1.2 Stimme

Duzen, kurze Sätze, keine medizinische Beratung.
Erfolg: „+250 ml – schöner Ripple.“
Ziel erreicht: „Heute im Fluss.“
Leer: „Noch still – erster Schluck?“
Siri: „Alles klar, 250 Milliliter sind drin. Noch 1,1 Liter bis zum Ziel.“

---

## 2. Nicht-Ziele (nicht bauen)

- Eigenes Backend, Accounts, Analytics-SDKs, Crash-Uploader
- Werbung, Abo, In-App-Kauf
- Android / Web / Kotlin Multiplatform
- UIKit- oder AppKit-Views außer Systemzwang
- TCA, VIPER, globale Coordinator-Religion
- Pflanzen-Pets, Charaktere, Bestenlisten, Social
- Kalorien, Koffein, Makros
- Medizinische Diagnosen
- Familien-Sharing / Shared CloudKit Zones
- iMessage / Share Extension
- CarPlay (nur wenn ohne Extra-Komplexität; sonst weglassen)
- Getränke-Hydrationsfaktoren, Wetterziel, Streaks (v1.1)
- Mehr als DE + EN in v1

---

## 3. Scope v1.0

| ID | Feature | Pflicht |
|---|---|---|
| F01 | Log Intake (ml/oz, Source, Timestamp) | P0 |
| F02 | Quick Add über gespeicherte Behälter | P0 |
| F03 | Tagesziel manuell oder berechnet | P0 |
| F04 | Today-Fortschritt (Pegel, Rest, Pacing) | P0 |
| F05 | History: Tag/Woche/Monat, Edit/Delete | P0 |
| F06 | Einheiten ml und fl oz | P0 |
| F07 | SwiftData + CloudKit + App Group | P0 |
| F08 | Widgets interaktiv (Small, Medium, Lock Screen, StandBy) | P0 |
| F09 | App Intents + App Shortcuts DE/EN | P0 |
| F10 | watchOS App + mind. 2 Komplikationen | P0 |
| F11 | Control Center + Action Button | P0 |
| F12 | Erinnerungen ohne Spam | P0 |
| F13 | Onboarding | P0 |
| F14 | Settings inkl. Sync-Status und Export CSV/JSON | P0 |
| F15 | Design System RippleUI | P0 |
| F16 | Accessibility (VoiceOver, Dynamic Type, Reduce Motion) | P0 |
| F17 | HealthKit Dietary Water write + optionale Workouts | P0 |
| F19 | Mac Sidebar + Tastatur + optionale Menu Bar | P0 |
| F20 | tvOS Ambient-Gerüst | P0 (minimal) |
| F21 | visionOS Fenster-Gerüst | P0 (minimal) |

v1.1 (nicht jetzt): Getränkearten mit Faktor, WeatherKit-Ziel, Streaks, Household-Zone, Workout-aware Activity.

---

## 4. Architektur (verbindlich)

**Name:** Feature-first Clean MVVM
**State:** `@Observable` (kein `ObservableObject`)
**Concurrency:** Swift 6, Strict Concurrency, `@ModelActor` für Writes
**DI:** Protokolle + Composition Root, keine Service-Locator-Singletons außer dem Container-Factory

### 4.1 Prinzip

> Eine Domain, viele Adapter.
> Features besitzen Screens, nicht Regeln.
> Apple-Frameworks tragen Sync, Intents und UI — der Code trägt die Grenzen.

### 4.2 Schichten

```
Apps + Extensions          Composition Root, Szenen
RippleFeatures             Views + @Observable ViewModels
RippleUI                   Tokens, Komponenten, Motion
RippleIntentsCore          AppIntent-Adapter
RippleDomain               Entities, Use Cases, Protocols
RippleData                 SwiftData, CloudKit, HealthKit, Notifications
```

| Schicht | Darf | Darf nicht |
|---|---|---|
| Domain | Use Cases, Goal-Formel, Units | import SwiftUI, SwiftData, CloudKit, HealthKit, WidgetKit |
| Data | Persistenz, Mapping, Projektionen | View-Layout, Siri-Dialoge |
| IntentsCore | Systemvertrag, Phrasen | eigene Mengenlogik |
| UI | Look & Motion | SwiftData `@Query` Writes, HKHealthStore |
| Features | VM orchestriert Use Cases | CKRecord, HKHealthStore direkt |
| Apps | verdrahten | Business-ifs nach Source |

### 4.3 Verboten

- `@Query` direkt zum Schreiben von Intakes in Views
- Zweite Wahrheit in UserDefaults (höchstens Wegwerf-Cache für Widget-Placeholder)
- `LogIntake`-Logik kopiert in Widget/Intent
- HealthKit als Source of Truth
- `#if os()` in ViewModels oder Use Cases

### 4.4 Log-Fluss

```
Widget | Control | Siri | Watch | Button | Notification
                              │
                              ▼
                 LogIntake.run(amount:source:date:)
                              │
                              ▼
              IntakeRepository.save  →  SwiftData App Group
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼
   Widget.reload      HealthProjection.write
          │
          ▼
   NotificationScheduler.reschedule()
```

HealthKit-Fehler rollen den Log **nicht** zurück. Health ist Projektion.

Undo = `UndoLastIntake` auf den letzten eigenen Eintrag, nicht verteilter Stack.

### 4.5 ViewModel-Vertrag

```swift
@MainActor
@Observable
final class TodayViewModel {
    var snapshot: TodaySnapshot
    var motion: RippleMotionPhase
    func addDefault() async
    func add(container: Container) async
    func add(milliliters: Int) async
    func undo() async
}
```

Views enthalten keine Use-Case-Logik. Animation beobachtet `snapshot`, schreibt nicht in den Store.

Navigation ist plattformlokal (Tab / Split / Watch-Page). Kein app-weiter Router.

---

## 5. Repository-Struktur

```
Ripple.xcworkspace
  Apps/
    RippleiOS/
    RipplewatchOS/
    RipplemacOS/
    RippletvOS/
    RipplevisionOS/
  Extensions/
    RippleWidgets/          // WidgetKit UI
  Packages/
    RippleDomain/
    RippleData/
    RippleIntentsCore/
    RippleUI/
    RippleFeatures/
  Tests/                    // oder Package-Tests
  Docs/
    shared/
      Ripple_PRD.md
      IOS_ARCHITECTURE.md
      Android/
      screens/ios/               current iOS evidence captures
    CONTRIBUTING.md
  Config/
    Ripple.xcconfig.example
  README.md
```

Xcode: Multiplatform wo sinnvoll, separate App-Targets für Watch/TV/Vision. Shared capabilities: iCloud, App Groups, Background Modes (remote notifications), HealthKit (iOS/watchOS), Push (für CloudKit).

`Ripple.xcconfig.example` enthält:

```
DEVELOPMENT_TEAM =
PRODUCT_BUNDLE_IDENTIFIER = de.stefansturm.ripple
RIPPLE_APP_GROUP = group.de.stefansturm.ripple
RIPPLE_ICLOUD_CONTAINER = iCloud.de.stefansturm.ripple
```

README erklärt: eigenen Container anlegen, IDs ersetzen, Signing, CloudKit Schema deployen.

---

## 6. Domain

### 6.1 Wertetypen

```swift
enum VolumeUnit: String, Sendable, Codable { case milliliters, fluidOunces }

struct Milliliters: Sendable, Hashable, Codable {
    var value: Int  // immer ganzzahlig speichern
}

enum IntakeSource: String, Sendable, Codable {
    case app, widget, intent, watch, control, notification, health
}

enum Beverage: String, Sendable, Codable {
    case water  // v1 nur Wasser; Enum offen für v1.1
}

struct TodaySnapshot: Sendable {
    var date: Date
    var consumed: Milliliters
    var goal: Milliliters
    var remaining: Milliliters
    var percent: Double        // 0...1+
    var entries: [Intake]
    var unit: VolumeUnit
}
```

Einheiten: intern immer Milliliter. UI rechnet über `UnitConverter`.

### 6.2 Persistente Konzepte (Domain, nicht SwiftData)

- `Intake`: id (UUID), date, amountMl, beverage, source, containerId?, note?, isDeleted
- `Container`: id, name, amountMl, isDefault, sort, symbolName
- `GoalSettings`: mode (manual / calculated), manualGoalMl, updatedAt
- `Profile`: preferredUnit, bodyMassKg?, activityLevel, wakeTime, sleepTime, remindersEnabled, healthReadWorkoutsEnabled
- `ReminderRule`: enabled, start, end, intervalMinutes, afterLastSipMinutes

### 6.3 Use Cases (einzige Schreib-API)

| Use Case | Verantwortung |
|---|---|
| `LogIntake` | speichern, Projektionen anstoßen |
| `UndoLastIntake` | letzten nicht gelöschten eigenen Eintrag soft-deleten |
| `EditIntake` | Menge/Zeit ändern |
| `DeleteIntake` | soft delete |
| `ObserveToday` | Snapshot für Datum |
| `ObserveHistory` | Range |
| `UpdateGoal` | manuell oder recalc |
| `CalculateGoal` | Formel |
| `UpdateProfile` | |
| `RequestHealthReadAccess` | explizite Health-Leseerlaubnis und aktuelles Gewicht lesen |
| `RequestHealthWaterWrite` | explizite Health-Schreiberlaubnis für Dietary Water |
| `RequestNotificationAuthorization` | explizite System-Erlaubnis für Erinnerungen |
| `UpsertContainer` / `DeleteContainer` | |
| `ExportData` | CSV + JSON |
| `RescheduleReminders` | via Port |

Ports (Protokolle in Domain):

```swift
protocol IntakeRepository: Sendable { ... }
protocol SettingsRepository: Sendable { ... }
protocol WidgetReloading: Sendable { func reload() async }
protocol HealthProjecting: Sendable { func project(intake: Intake) async }
protocol ReminderScheduling: Sendable { func reschedule(rule: ReminderRule, lastSip: Date?) async }
protocol HealthAuthorizing: Sendable {
  func requestBodyMassRead() async -> Bool
  func latestBodyMassKg() async -> Double?
  func requestWaterWrite() async -> Bool
  func requestWorkoutRead() async -> Bool
}
protocol NotificationAuthorizing: Sendable {
  func status() async -> NotificationAuthorizationStatus
  func requestAuthorization() async -> NotificationAuthorizationStatus
}
```

### 6.4 Ziel-Formel

- Ohne Gewicht: Default **2000 ml**, jederzeit überschreibbar.
- Mit Gewicht: `kg * 33` ml, gerundet auf 50 ml.
- Aktivität (nur wenn Profil es sagt): +350 ml je 30 min moderater Belastung aus **heute gelesenen Workouts** (Health, opt-in) oder manuellem Aktivitätslevel (sedentary 0 / moderate +350 / high +700).
- Schwangerschaft/Stillzeit: nur manuelle Zuschläge, Copy: keine medizinische Beratung.
- Wetter: nicht in v1.
- Immer manuell übersteuerbar.

Pacing (Anzeige): Restmenge / verbleibende Wachstunden zwischen wake und sleep. Kein Alarm daraus ableiten außer der Reminder-Regel.

---

## 7. Data / CloudKit / App Group

### 7.1 SwiftData Models

Ein Store, viele Prozesse. `ModelConfiguration(groupContainer: .identifier(appGroup), cloudKitDatabase: .automatic)`.

CloudKit-kompatibel:

- keine Unique Constraints
- Beziehungen optional
- alle Attribute mit Defaults
- `Intake.isDeleted` statt hartem Delete (Sync)

Felder analog Domain + `createdAt`, `updatedAt`.

`SharedContainer.make()` in RippleData:

1. Versuch App Group + CloudKit
2. Fallback App Group lokal
3. Fallback in-memory für Tests/Previews
Fehler sichtbar über `SyncStatus` (account, importing, failed, unavailable).

### 7.2 Writes

`@ModelActor actor IntakeStore` für alle Writes aus App, Widget, Intent, Watch.

Nach jedem Write:

1. `WidgetCenter.shared.reloadAllTimelines()`
2. Health projection
3. Reminder reschedule

### 7.3 Konflikte

Intakes sind append-only + soft delete, UUID als Identität. Last-Writer-Wins auf Feldebene. GoalSettings: `updatedAt` gewinnt.

### 7.4 Debug vs Release

Getrennte App Groups dokumentieren (`group.de.stefansturm.ripple.debug` optional). CloudKit Development vs Production in README.

---

## 8. HealthKit (v1.0)

**Quelle der Wahrheit:** SwiftData.
**Health:** Projektion.

### Schreiben

Nach jedem erfolgreichen Log:

- Type: `HKQuantityTypeIdentifier.dietaryWater`
- Unit: liter (Health) aus ml
- Date: Intake.date
- Metadata: `app.ripple.intakeUUID` = Intake.id.uuidString, `app.ripple.source` = source.rawValue

### Lesen

Nur mit **expliziter** Erlaubnis und nur für den konkreten Zweck: das
aktuellste Körpergewicht (`bodyMass`) für die persönliche Zielberechnung.
Wenn der Nutzer zustimmt, wird der Wert als lokaler `Profile.bodyMassKg`
Snapshot übernommen und über die bestehende Ziel-Formel berechnet. Das
Lesen von Workouts für den Goal-Boost bleibt ein getrenntes, optionales
Opt-in in Settings. Ablehnung oder fehlende Daten sind gültige Zustände; es
gibt kein stilles Re-Prompt. HealthKit darf bei Read-Rechten nicht als
"abgelehnt" interpretiert werden, nur weil eine Abfrage keine Daten liefert.

### Dedup

Nie denselben UUID zweimal schreiben. Undo/Delete: korrespondierende HK-Sample löschen, wenn Authorization es erlaubt; sonst ignorieren.

### UI

Onboarding: Körpergewicht aus Health explizit anbieten, Health schreiben als
separate optionale Aktion anbieten. Settings: Health schreiben / Workouts
lesen getrennt. App bleibt ohne Health voll nutzbar.

Privacy Nutrition Label: Health (Dietary Water, optional Workouts). Kein Tracking.

Watch: HealthKit nur wenn Target es hergibt; iPhone darf die Projektion führen, Watch-Logs erreichen Health über denselben Use Case sobald der Prozess schreiben darf. Bevorzugt: Projection im Prozess, der `LogIntake` ausführt, wenn Health verfügbar, sonst nach Sync auf iPhone nachziehen (Metadata UUID verhindert Duplikate).

---

## 9. Live Activity

Ripple nutzt bewusst keine Live Activity und keine Dynamic-Island-Wasseranzeige. Live Activities sind für zeitlich begrenzte, laufende Ereignisse gedacht und dürfen deshalb nicht die dauerhafte Tagesansicht eines Wasser-Trackers ersetzen. Die interaktiven Widgets bleiben die primäre schnelle Anzeige und Log-Fläche.

---

## 10. App Intents, Shortcuts, Siri

Datei in `RippleIntentsCore`, von App **und** Extension importiert.

Pflicht-Intents:

| Intent | Parameter | Ergebnis |
|---|---|---|
| `LogWaterIntent` | amount (ml oder oz), optional ContainerEntity | Dialog + Snapshot |
| `UndoLastIntakeIntent` | — | Dialog |
| `GetTodayProgressIntent` | — | remaining, percent, goal |
| `SetDailyGoalIntent` | amount | Dialog |
| `OpenTodayIntent` | — | öffnet App |
| `OpenHistoryIntent` | — | öffnet App |

`AppShortcutsProvider` Phrasen DE und EN, Beispiele:

- „Logge Wasser in Ripple“
- „Ripple, 300 Milliliter“
- „Wie viel Wasser noch heute in Ripple?“
- „Nimm den letzten Schluck in Ripple zurück“
- “Log water in Ripple”
- “How much water left today in Ripple?”

Spotlight zeigt die App Shortcuts. Keine SiriKit-Altlasten.

---

## 11. Widgets und Controls

Familien:

- `systemSmall`: Ring + Prozent, Tap öffnet oder +Default wenn interaktiv
- `systemMedium`: Pegel/Ring, Zahl, Buttons +250 / Default / +500 (bzw. oz-Äquivalent)
- `accessoryCircular`, `accessoryRectangular`, `accessoryInline` für Lock Screen + Watch
- StandBy tauglich (dunkel, große Zahl)

Interaktion nur über dieselben App Intents.

Control Center: `ControlWidget` „+ Standardmenge“. Action Button / Camera Control dieselbe Control.

Konfiguration: optional Default-Menge, sonst Profil-Default.

Watch Smart Stack: Relevanz nachmittags/abends höher, wenn Ziel offen (`RelevanceConfiguration` soweit OS es hergibt, sonst Timeline + Relevance).

---

## 12. Plattformen und Screens

Mindestversionen: aktuelles OS zum Bauzeitpunkt (iOS 26 / watchOS 26 / macOS 26 / tvOS 26 / visionOS 26). Nicht künstlich auf iOS 17 zurückgehen.

### 12.1 iPhone

Tabs: **Heute | Verlauf | Stats | Einstellungen**.
Heute: siehe Abschnitt 14 und den detaillierten Today-Hero-Vertrag in Abschnitt 22.1.
Verlauf: kalender-first Monatsraster mit einem Ring pro Tag, horizontalem Monats-Pager und Tagesdetail mit Edit/Delete/Restore.
Stats: eigener Perioden-/Chart-Screen gemäß Abschnitt 22.2; kein kombinierter Insights-Screen.
Settings: Profil, Einheiten, Behälter-CRUD, Erinnerungen, Health-Status, Sync-Status, Export, Über, Quelle/Lizenz.

### 12.2 iPad

Adaptive Plattform-Komposition statt geschrumpftem iPhone-Layout. History verwendet einen eigenen Kalender-/Tagesdetail-Split, Stats bleibt der eigenständige Perioden-/Chart-Screen, und Today folgt den Portrait-/Landscape-Kompositionen aus Abschnitt 22.1. Multiwindow bleibt erlaubt.

### 12.3 Apple Watch

Die Watch-App hat drei horizontale Seiten: **Heute | Verlauf | Statistik**. Heute ist eine vollflächige, flache Wasserstand-Darstellung ohne Ring oder Glas und bietet eine einzelne `+`-Aktion. Sie öffnet das Mengen-Sheet mit drei vorkonfigurierten Mengen; die Crown passt den aktuellen Wert in 10-ml-Schritten an und macht ihn bei einer Änderung zu einer eigenen Menge ohne Behälter-ID. Ein separater `+`-Modusschalter ist nicht nötig. Erst die Bestätigung im Sheet schreibt über denselben `LogIntake`-Use-Case mit Quelle `watch`; eine Auswahl allein schreibt nicht. Zum Verwerfen gibt es nur das systemseitige `×` oben, keinen zusätzlichen Cancel-Button. Verlauf und Statistik verwenden jeweils einen lokalen Navigationsstapel für ihr scrollbares Titelverhalten; Heute bleibt für das vollflächige Wasserfeld ohne Navigationsstapel. Die Watch-App bevorzugt die dunkle OLED-Darstellung. Watch und Komplikationen bleiben ohne Tilt und ohne Oberflächenreaktion; die Wasserfläche bleibt statisch.

Verlauf zeigt die letzten sieben vergangenen bzw. heutigen lokalen Kalendertage als kompakte Liste, sortiert neu nach alt. Ein Tap öffnet ein Tagesdetail mit Summe, Ziel und Einträgen. Einzelne Einträge können dort per Wischaktion über den bestehenden `DeleteIntake`-Use-Case soft-deleted und über eine kurze Undo-Aktion wiederhergestellt werden; Bearbeiten und Hinzufügen bleiben auf iPhone/iPad. Statistik zeigt die aktuelle ISO-Woche mit Durchschnitt pro vergangenem Tag, Zieltreffern, Gesamtmenge und genau einem kompakten Swift-Charts-Diagramm. Kein Monatskalender und kein Perioden-Picker auf der Watch.

Komplikationen bleiben fokussiert: circular ring, rectangular remaining. Sie übernehmen nicht die Watch-App-Seiten oder deren Chart.
Ultra Action Button: +Default wenn konfigurierbar.

### 12.4 Mac

Sidebar. Commands: ⌘N Default-Log, ⌘Z Undo, ⌘1/2/3 Behälter.
Settings-Szene.
Menu Bar Extra optional in v1: Fortschritt + +Default.

### 12.5 tvOS

Ambient: großer Pegel, Siri Remote Fokus auf +250 / +500 / +750. Kein Fein-Editing.

### 12.6 visionOS

Fenster + Glass. Die systemseitige adaptive Glass-Fläche füllt das resizable Fenster; es gibt kein zusätzliches schwarzes Innenpanel. Das Fenster bleibt resizable, darf aber nicht kleiner als die definierte Mindestfläche von 720 × 440 pt werden (`windowResizability(.contentMinSize)`). Ein führendes, vertikales Ornament bietet die lokale Navigation **Today | History | Stats | Settings** als SF-Symbol-Icons mit vollständigen Accessibility-Labels; die Log-Aktionen (gespeicherte Behälter + Custom amount) liegen gesammelt im unteren Ornament. Das Ornament bleibt innerhalb der verfügbaren Fensterbreite und scrollt bei kleinen Größen horizontal. Kein zusätzlicher Inline-Log-Button und keine separate Default-Mengen-Aktion, die einen gespeicherten Behälter dupliziert. History und Stats verwenden ihre bestehenden Feature-Screens und Datenverträge. Kein Immersive Space und kein app-weiter Router. Widgets pinnbar, wenn Target Widget-Extension mitnimmt.

---

## 13. Design System (`RippleUI`)

### 13.1 Farbe

| Token | Light | Rolle |
|---|---|---|
| `color.water.deep` | `#0B3D4A` | Text, Icon-Grund |
| `color.water.lagoon` | `#1A7A8C` | Primary |
| `color.water.aqua` | `#4FB3C6` | Fortschritt |
| `color.water.foam` | `#E6F3F5` | Flächen |
| `color.success` | Lagoon | Ziel erreicht |
| `color.danger` | System Red entsättigt | Löschen |

Dark: Deep heller lesbar, Aqua leuchtet, Surfaces kühles Anthrazit.
Widget muss `fullColor`, `accented`, `vibrant` überleben.

### 13.2 Typo, Raum, Form

- Nur System San Francisco.
- Display-Zahl: large, tabular lining.
- Skala: display, title, body, callout, caption → `Font.TextStyle`.
- 4-pt-Grid. Radius: 12 controls, 20 cards, 28 hero.
- Material: `ultraThinMaterial` sparsam. Keine schweren Drop Shadows.

### 13.3 Komponenten

`LogButton`, `QuickAddCluster`, `AmountStepper`, `ContainerChip`, `DayHeader`, `RemainingLabel`, `IntakeRow`, `SyncStatusView`, `EmptyState`, `GlassCard`, `GlassShape`, `WaterFill`, `PourStreamShape`, `DayRing`.

Jede Komponente: Preview Light/Dark, Dynamic Type XXXL, Reduce Motion, Watch-Canvas.

### 13.4 Motion-Tokens

| Token | Wert |
|---|---|
| `ripple.duration.quick` | 0,28 s |
| `ripple.duration.hero` | 0,40–0,70 s aktiver Pour |
| `ripple.spring.snappy` | response 0,28 / damping 0,85 |
| `ripple.spring.liquid` | response 0,55 / damping 0,72 |
| `ripple.level.rise` | Strahldauer + 0,14 s Fade, linear, kein Overshoot |
| `ripple.coalesce` | neues Delta an laufende Welle |
| `ripple.undo` | 0,45 s rückwärts |

Idle bleibt ohne Wasseranimation. Reduce Motion: kein Strahl, keine Oberflächenreaktion, keine Neigung; Pegel-Kreuzblende 0,20 s.

---

## 14. iPhone Heute + Add-Animation (verbindlich, SwiftUI-baubar)

**Keine lineare Progress Bar. Kein fotorealistisches Wasser, kein 3D-Glas, kein Mesh-Shader.** Die verbindliche Geometrie, Wasseroberfläche, Tilt-, Pour-, Coalescing-, Reduce-Motion- und Widget-Regel steht in Abschnitt 22.1 dieses PRD.

Die aktuelle iPhone-Komposition ist:

```
TodayView
  header: "Ripple" + lokales Datum
  RippleHeroView              // stilisiertes 2D-Glas, Level + Readout
  RemainingLabel              // Rest + Ziel
  confirmation                // nur nach Log, dann Fade
  QuickAddCluster             // gespeicherte Behälter
  Custom amount               // untere primäre Aktion
  TabView: Heute | Verlauf | Stats | Einstellungen
```

Die Zahlen im Hero zeigen Menge, Einheit und Prozent. Die Oberfläche ist im
Idle flach. Es gibt keine Recent-Liste, keine Motivationskarte und keinen
zusätzlichen Last-entry-Block. Die drei Quick-Add-Aktionen verwenden die
gespeicherten Behälter; die Custom-Amount-Aktion öffnet die Mengeneingabe.

Für VoiceOver werden Menge, Ziel, Rest, Prozent und Quelle vollständig
angesagt. Der gemeinsame `LogIntake`-Use-Case bleibt die einzige Schreib-API.
Widget und Komplikationen verwenden das Glas statisch ohne Tilt, Strahl oder
Oberflächenreaktion.

---

## 15. Onboarding, Erinnerungen, Export

### Onboarding (6 Seiten)

1. Willkommen und Ripple-Metapher
2. Einheit ml oder fl oz (Locale-Default)
3. Apple Health: Gewicht lesen und geloggtes Wasser schreiben, optional
4. Tagesziel: Health-Gewicht verwenden oder Gewicht manuell eingeben
5. Standard-Behälter für Quick Add
6. Erinnerungen erklären und Benachrichtigungen explizit anfordern

Health- und Benachrichtigungszugriff bleiben optionale, wiederherstellbare
Zustände. Die systemseitige Permission-Fläche folgt erst auf die erklärende
Onboarding-Seite; Ablehnung blockiert das Loggen nicht. Nach Abschluss öffnet
die App den Today-Tab.

### Erinnerungen

Fenster wake…sleep. Intervall nach letzter Sip (`afterLastSip`, Default 120 min). Keine Notification in Sleep. Keine Starre-Alle-2h-Schleife ohne Bezug zum letzten Log. Notification Action: +Default → `LogIntake`.

Die Permission wird erst nach einer erklärenden Onboarding-Fläche und einem
expliziten Button über `UNUserNotificationCenter.requestAuthorization`
angefordert. `ReminderScheduler` fragt nie implizit nach Permission; er entfernt
und plant nur Requests, wenn der aktuelle Authorization-Status das erlaubt.

Focus Filter: Erinnerungen in Fokuszeiten dämpfen, wenn ohne großen Aufwand machbar; sonst Settings-Pause.

### Export

Settings: JSON (voll) und CSV (Datum, ml, source). Teilen über ShareLink.

---

## 16. App Icon und Marke

Icon: Tropfen + 2–3 konzentrische Ringe auf Deep-nach-Lagoon-Verlauf. Kein Text, kein Glas, kein Häkchen. Watch: nur Tropfen + ein Ring.

Platzhalter in v1: SF Symbol `drop.fill` auf Lagoon reicht, solange Assets-Katalog die Größen füllt. Finales Render kann später ersetzt werden.

---

## 17. Qualität

- VoiceOver auf Today, Log, History, Settings
- Dynamic Type bis AX5; Hero darf schrumpfen, Zahl nicht abschneiden
- Reduce Motion, Increase Contrast, Bold Text
- Haptics abschaltbar
- String Catalogs `de`, `en`
- Locale für Datum und Einheiten
- Privacy Manifest
- Kein Tracking

Tests (müssen grün sein):

- Goal-Formel, Unit-Conversion, Pacing
- Log / Undo / Soft Delete
- Intent `perform()` gegen Fake-Repository
- Health-Metadata-UUID verhindert Doppel-Write (Unit mit Fake HK)
- In-Memory ModelContainer CRUD

CI: `xcodebuild test` Domain + Data (+ iOS-Unit soweit Simulator).

---

## 18. Implementation Order (für Grok Build)

Nicht umdrehen.

0. Workspace, Packages, xcconfig.example, and the versioned architecture documents
1. Domain + In-Memory Fakes + Tests
2. SwiftData Models + SharedContainer + Tests
3. iOS Today + Settings + Onboarding (ohne CloudKit-Zwang)
4. RippleUI Hero + Animation inkl. Reduce Motion
5. CloudKit Capabilities + SyncStatus
6. App Intents + Shortcuts
7. Widgets + Controls
8. watchOS App + Komplikationen
9. HealthKit Projection
10. History + Charts + Export
11. Reminders
12. Mac
13. tvOS + visionOS Gerüst
14. A11y-Pass, DE/EN, README, Privacy Manifest

---

## 19. Definition of Done v1.0

- [ ] Log, Undo, Today, History, Stats, Settings, Onboarding auf iPhone und iPad
- [ ] watchOS-App mit Today, History, Stats, Default-/Custom-Log, Day Detail mit Entry-Delete/Undo und ≥1 Komplikation
- [ ] Mac-App mit Sidebar und Tastaturkürzeln
- [ ] Interaktives Medium-Widget und Lock-Screen-Accessory
- [ ] App Intents + Shortcuts DE/EN
- [ ] Control Center Control
- [ ] SwiftData + App Group + CloudKit, sichtbarer Sync-Status
- [ ] HealthKit Dietary Water + optionale Workouts, App ohne Health voll nutzbar
- [ ] RippleUI Tokens + Hero-Animation + Reduce Motion
- [ ] Domain- und Data-Tests grün
- [ ] README startet das Projekt (Container/App Group dokumentiert)
- [ ] VoiceOver-Pass Today + Log
- [ ] String Catalogs EN/DE
- [ ] Keine Third-Party-Dependencies

---

## 20. Offene Defaults (nicht nachfragen, so entscheiden)

| Frage | Default |
|---|---|
| Bundle-ID | `de.stefansturm.ripple` |
| Display-Name | Ripple |
| Default-Ziel | 2000 ml |
| Default-Behälter | 250 / 200 / 500 ml |
| Default-After-Last-Sip | 120 min |
| Health | schreiben anbieten, Workouts extra opt-in |
| tvOS/visionOS | Gerüst, nicht pixelperfekt
| Icon | SF-Drop-Platzhalter + Asset-Vorlage |
| Tests | Swift Testing wo möglich |

---

## 21. Architekturzusammenfassung

- Feature-first Clean MVVM, `@Observable`, Use Cases als einzige Schreib-API,
  keine TCA-Pflicht.
- Ein SwiftData-Store, App Group, CloudKit automatic, ModelActor-Writes und
  CloudKit-kompatibles Schema.
- Health ist Projektion von SwiftData, UUID in Metadata; Fehler blockieren
  Logs nicht.
- Ripple nutzt keine Live Activity; interaktive Widgets und Control Center
  sind die schnellen Systemflächen.

---

## 22. Detaillierte UI-, History- und Bewegungsverträge

Dieser Abschnitt enthält die früher getrennten Hero- sowie History/Stats-
Spezifikationen. Er ist zusammen mit dem restlichen PRD verbindlich. Die
Die aktuellen iOS-Captures in `screens/ios/` sind Referenz für Richtung und
Zustand, aber kein Pixelgesetz; bei einem Widerspruch gilt der Text dieses PRD.

### 22.1 Today-Hero und Add-Animation

Der Today-Hero ist ein stilisiertes **2D-Trinkglas (Tumbler)**. Der Füllstand
ist eine **ebene Wasseroberfläche** im Glas. Im Idle gibt es **keine**
Sinus-Welle und keine Timeline-Schleife. Neigt man das iPhone oder iPad,
läuft das Wasser in die Richtung der projizierten Schwerkraft. Beim Loggen
fließt ein **kurzer, schmaler Wasserstrahl** von oberhalb des Glases zur
Oberfläche. Breite, Kontaktvertiefung und Fließdauer folgen dezent der Menge.
Der Pegel steigt bereits während des Eingießens. Beim Ende des Strahls laufen
zwei Oberflächenkämme zu den Wänden, werden einmal schwächer reflektiert und
kommen innerhalb von 0,90 s vollständig zur Ruhe. Es gibt keinen einzelnen
Symboltropfen und keine darüber gezeichneten Ellipsen.

#### 22.1.1 Today-Komposition auf iPhone

Von oben nach unten, Light Mode, Hintergrund `#E8F4F6`:

1. Navigationsleiste: Wortmarke `Ripple` (`#0B3D4A`) + Datum inline.
2. **Hero-Glas** zentriert und ohne ScrollView; es nutzt den verbleibenden
   Platz zwischen Navigationsleiste und den unteren Aktionen, skaliert bei
   kleiner Höhe herunter und behält das Seitenverhältnis von etwa 200 × 280 pt.
3. Caption `noch {rest} ml · Ziel {goal} ml`.
4. Confirm-Zeile nur nach einem Log, dann Fade.
5. Drei Chips: Glas 250 / Tasse 200 / Flasche 500.
6. Primary-Pille `Eigene Menge` / `Custom amount`; sie öffnet die Eingabe
   einer Trinkmenge und bleibt als untere Aktion oberhalb der Tab Bar sichtbar.
7. Tab Bar: Heute | Verlauf | Stats | Einstellungen.

Farben: Deep `#0B3D4A`, Lagoon `#1A7A8C`, Aqua `#4FB3C6`, Foam `#E8F4F6`.
Zahlen verwenden San Francisco und `monospacedDigit()`; kein `1°500`.

Das Readout sitzt als ruhige, leicht transluzente Frontglas-Schicht innerhalb
des Glases. Die Schicht erhält eine zurückhaltende helle Kante und eine weiche
vertikale Glasreflexion. Sie ist kein zusätzlicher Fortschrittsindikator und
verdeckt die Wasseroberfläche nicht vollständig. Menge mit Einheit bleibt
oben, Prozent unten; beide bleiben über dem Strahl und folgen den
Accessibility-Vorgaben.

#### 22.1.2 Today-Komposition auf iPad

Das iPad nutzt die zusätzliche Breite nur im Landscape für eine ruhige
Zwei-Spalten-Komposition:

- oben steht das Status-Label mit verbleibender Menge und Ziel;
- in der Mitte links steht ein zentrierter, begrenzter Hero mit unverändertem
  Seitenverhältnis und derselben Motion; er darf bis etwa 240 × 336 pt groß
  werden und wächst nicht bis zur verfügbaren Höhe;
- in der Mitte rechts stehen die drei Behälter-Aktionen als flache Buttons
  ohne `GlassCard` oder einzelne Glas-Karten;
- unten bleibt die Primary-Pille `Eigene Menge` / `Custom amount` als CTA im
  Safe-Area-Inset;
- die obere iPad-Tabbar ist der Kontext für den Tab. Ein zusätzlicher
  Today-Titel, eine Wortmarke oder ein Datum in der Navigation werden auf
  iPad nicht angezeigt.

Im Portrait verwendet das iPad die vertikale Today-Komposition. Der Hero
bleibt auf etwa 280 × 392 pt begrenzt, damit er nicht den gesamten
verbleibenden Platz füllt; Status-Label, flache Behälter-Aktionen und CTA
bleiben in ihrer bisherigen Reihenfolge. Auch im Portrait gibt es für iPad
keine einzelnen Glas-Karten um die Aktionen.

#### 22.1.3 View-Hierarchie und Zuständigkeit

```text
RippleHeroView(consumedMl:goalMl:addedMl?:phase:)
  ZStack {
    PourStreamView(addedMl:progress:) // nur während Add
    WaterFill(level:tilt:pourDepth:ripplePosition:rippleAmplitude:)
      .clipShape(GlassShape())
    GlassShape().stroke(Color.lagoon, lineWidth: 3)
    VStack {
      Text(consumedMl).font(.largeTitle.monospacedDigit())
      Text("ml")
      Text(percent)
    }
  }
```

`RippleHeroView` kennt keinen Store. Die View erhält `consumedMl`, `goalMl`
und optional die in der aktiven Eingießserie summierte Menge `addedMl` für
Strahlbreite, Kontaktvertiefung und Dauer. `LogButton` ruft ausschließlich
den Use Case `LogIntake` auf; die View beobachtet den neuen Stand.

#### 22.1.4 GlassShape

2D-Tumbler, kein Stiel, kein fotorealistisches Glas:

- Rim-Breite ungefähr **1,35 ×** Bodenbreite;
- Boden leicht gerundet;
- Wände gerade und nach oben geöffnet;
- Vorderkante des Rands als flacher Bogen.

Pfad-Reihenfolge: Boden links → Boden rechts → rechte Wand hoch → Rim-Bogen
→ linke Wand runter → schließen. Der Innenraum ist derselbe Pfad 3 pt nach
innen (Stroke-Breite), damit die Welle nicht über den Strich läuft.

Die Unterkante des sichtbaren Strahls verwendet für jeden Pegel denselben
inneren `GlassMetrics`-Inset wie `WaterFill` (`GlassMetrics.strokeWidth`).
Sie endet an der oberen Kante des vorderen Fill-Layers (`thickness = 0`) in
der Glasmitte; die äußere Rim-Geometrie darf nicht als Kontaktpunkt verwendet
werden. So bleibt der Strahl auch bei Retargeting und kleinen Füllständen ohne
Lücke mit der Wasseroberfläche verbunden.

`level = 0` sitzt auf dem Innen-Boden. `level = 1` sitzt an der **unteren**
Rim-Kante, nicht am obersten Pixel der View. Ein echter Stand oberhalb des
Tagesziels darf visuell bis 1,05 dargestellt werden; die Add-Animation
überschwingt den Store-Pegel nicht.

#### 22.1.5 WaterFill: Ebene und Neigung

Kein `TimelineView` im Idle. In Ruhe ist die Oberfläche eben und senkrecht
zur projizierten Schwerkraft. Nur Gerätebewegung und Eingießen regen
vorübergehende Oberflächenbewegung an.

Die Oberfläche wird in Tangenten-/Normalenkoordinaten aufgebaut. Dadurch
funktionieren auch 90° und umgedrehte Geräte ohne `tan`-Singularität. Eine
gedämpfte, ungerade Oberflächenverformung erzeugt beim Kippen einen Wellenberg
und ein Wellental und kommt nach der Bewegung vollständig zur Ruhe.

Die gefüllte Fläche wird gegen das innere Glas geschnitten. Ihre Lage wird so
bestimmt, dass die Fläche dem aufrechten Store-Pegel entspricht (numerische
Toleranz <0,1 %). Bei Neigung darf sich die Höhe in der Mitte ändern. Wasser
bleibt enthalten, auch seitlich oder kopfüber; es gibt kein visuelles
Verschütten und keine Änderung der geloggten Menge. Das ist eine geschlossene
2D-Näherung, keine Fluid-Simulation.

Es gibt zwei Aqua-Schichten mit Opazitäten 0,88 / 0,50 und 3 pt
Oberflächendicke; weiterhin wird `GlassShape` als Clip verwendet. Bei
`level == 0` gibt es keinen Fill und keinen Schimmer. Der Strahl endet an der
tatsächlichen Wasseroberfläche unter seiner Mitte, auch während Neigung und
Schwappen.

#### 22.1.6 Schwerkraft und gedämpftes Schwappen

Core Motion gilt nur für iPhone und iPad, wenn die App im Vordergrund und
Today sichtbar ist. Die Geräte-Gravitation wird in die tatsächliche
Interface-Ausrichtung transformiert, auch bei Rotationssperre. Der Zielwinkel
ist `atan2(-gravityRight, gravityDown)` ohne 16°-Cap; Winkelübergänge nehmen
den kürzesten Weg über ±π.

Der ungefähr 60-Hz-Sensortakt verwendet die tatsächliche Zeitdifferenz und
begrenzt Integrationsschritte. Eine gedämpfte Feder (Eigenfrequenz 12 rad/s,
Dämpfungsgrad 0,48) folgt dem Zielwinkel. Änderungen regen zusätzlich eine
begrenzte Oberflächenverformung an (Eigenfrequenz 10 rad/s,
Dämpfungsgrad 0,18, maximale Amplitude 6 % der Glasbreite). Sensorrauschen
unter 0,002 rad regt keine Bewegung an. Ohne neue Bewegung fällt die
Verformung auf exakt null; es gibt keine autonome Idle-Schleife, Partikel oder
SPH.

Beim Zurückstellen aufrecht ist der Zielwinkel null nur ein neues Gleichgewicht,
kein Stoppsignal. Geschwindigkeit und Oberflächenverformung bleiben erhalten.
Nach einer normalen Rückbewegung von 45° in 0,25–1,0 s laufen mindestens zwei
sichtbar abnehmende Schwingungen weiter; noch 0,5–1,5 s nach dem Anhalten
sind Kämme sichtbar. Danach ist die Oberfläche vollständig ruhig. Ein Wechsel
der Interface-Ausrichtung dreht Winkel und vorheriges Ziel in das neue
Koordinatensystem, ohne Geschwindigkeiten oder Schwappen zurückzusetzen.

Face-up (`|gravity.z| > 0.92`) setzt Winkel, Geschwindigkeit und Schwappen
sofort auf null. Simulator, Mac, tvOS, visionOS, Watch, Widget und Reduce
Motion setzen Winkel und Schwappen auf null. Lifecycle stoppt Updates beim
Verlassen von Today, im Hintergrund und bei Reduce Motion; alte Callbacks
dürfen nach Stop/Neustart keine Bewegung wieder einschalten.

#### 22.1.7 Einmalige Reaktion während und nach dem Eingießen

| Zustand | Oberfläche | `tilt` |
|---|---|---|
| Idle | alle Add-Parameter 0, Fläche eben | folgt Gerät |
| Strahlkontakt | mittige Vertiefung 5…9 pt nach Menge, zwei Schultern ca. 30 % davon | folgt Gerät weiter |
| Strahlende, 0–0,38 s | zwei Kämme laufen von der Mitte bis nahe an die Wände | folgt Gerät weiter |
| Reflexion, 0,38–0,66 s | 60 ms Umkehr an der Wand, dann 220 ms Rückweg mit höchstens 36 % Stärke | folgt Gerät weiter |
| Settle, 0,66–0,90 s | Restamplitude → 0, danach wieder vollständig eben | folgt Gerät weiter |
| Reduce Motion | keine Vertiefung, keine Kämme | 0 |

Die Vertiefung bleibt während des Strahls stabil, ohne Loop oder Flattern. Beim
Strahlende fällt sie in 0,16 s ab, während das Kamm-Paar nach außen läuft. An
den Wänden bleibt die Position für eine 60-ms-Umkehr stehen; erst nach dem
Vorzeichenwechsel läuft die höchstens 36 % starke Reflexion 220 ms nach innen.
Nach insgesamt 0,90 s liegt die Amplitude exakt bei 0. Neue Taps stapeln keine
zweite unabhängige Welle; der aktive Strahl wird verlängert und sein Ziel
aktualisiert.

Beim ersten Kontakt startet eine gemeinsame, frameweise abgetastete
`pourProgress`-Uhr bei 0. Diese Uhr steuert gleichzeitig den linearen
Pegelanstieg und den Strahl-Fade. Die Laufzeit ist exakt
`levelRiseDuration(for:)`: aktive Strahldauer plus 0,14 s Ausblenden. Der
Pegel erreicht den echten Store-Zielwert erst, wenn der Strahl vollständig
verschwunden ist. Es gibt beim Pegel weder Spring noch Overshoot; die
Restbewegung kommt ausschließlich aus der einmaligen Oberflächenreaktion.

Weitere Taps aktualisieren das Ziel derselben laufenden Uhr. Der aktuell
dargestellte Pegel wird als neuer Startwert übernommen, `pourProgress` beginnt
für die neue Serienmenge wieder bei 0, und Strahl- sowie Pegeldauer werden ab
dem letzten Tap neu berechnet. Der Strahl bleibt durchgehend sichtbar; es
entsteht kein zweiter Pegel- oder Zeitpfad.

Widget und Watch-Komplikation zeigen keinen Strahl und keine
Oberflächenreaktion, sondern eine statische ebene Fläche.

#### 22.1.8 Wasserstrahl und Mengenabbildung

Beim Add zeichnet `PourStreamShape` keinen einzelnen Tropfen, sondern einen
schmalen, leicht nach unten verjüngten Wasserstrahl in Aqua mit einer
zurückhaltenden hellen Innenkante. Keine Quelle, Flasche oder Partikel werden
dargestellt; der Strahl kommt aus dem oberen Rand des Hero-Bereichs und bleibt
unter den Zahlen.

```swift
func amountT(for addedMl: Int) -> CGFloat {
    min(1, max(0, (CGFloat(addedMl) - 50) / 700))
}

func pourWidth(for addedMl: Int) -> CGFloat {
    7 + 5 * amountT(for: addedMl)       // 7…12 pt
}

func pourDuration(for addedMl: Int) -> TimeInterval {
    0.40 + 0.30 * amountT(for: addedMl) // 0,40…0,70 s
}

func levelRiseDuration(for addedMl: Int) -> TimeInterval {
    pourDuration(for: addedMl) + 0.14    // Kontakt bis Strahl vollständig weg
}
```

Die Kontaktvertiefung skaliert über denselben Clamp von 5…9 pt. Die Breite
bleibt bewusst subtil; die echte Milliliterzahl bestimmt den Pegelanstieg.
Bei einer aktiven Tap-Serie ist `addedMl` die Summe dieser Serie. Weitere Taps
verbreitern den bestehenden Strahl höchstens bis zum Cap, verlängern ihn ab
dem letzten Tap und aktualisieren denselben Zielpegel.

- Start X: Glasmitte.
- Start Y: `glass.minY - 32 pt`; der Strahl beginnt sichtbar oberhalb des Rims.
- In 0,14 s wächst der Strahl mit `easeOut` bis zur aktuellen Wasserlinie.
- Danach bleibt er für `pourDuration` sichtbar; der lineare Pegelanstieg läuft
  gleichzeitig.
- Am Ende verjüngt er sich in 0,14 s auf 35 % und blendet aus. Dieselbe
  `pourProgress`-Uhr lässt den Pegel weitersteigen und erreicht sein Ziel mit
  Opacity 0. Der Strahl zieht sich nicht nach oben zurück.
- Z-Order: hinter Wasser-Fill und Glas-Stroke, unter den Zahlen. Der
  eingetauchte Teil wird vom Fill aufgenommen statt als separate Linie darüber
  zu liegen.
- Kein seitliches Wobble, keine Teilchen, keine Unterbrechungs-Loop.

Reduce Motion verwendet keinen Wasserstrahl.

#### 22.1.9 Oberflächenbewegung und Add-Timeline

Im Today-Hero gibt es keine `RippleEllipses`. Die Energie bleibt in der
echten Oberkante des `WaterFill`:

1. Strahlkontakt: mittige Vertiefung mit zwei flachen Schultern.
2. Strahlende: zwei symmetrische Kämme laufen in 0,38 s nach außen.
3. Einmalige Reflexion: 0,06 s Vorzeichenwechsel an der Wand, danach 0,22 s
   Rückweg bei höchstens 36 % Amplitude.
4. Settle: in 0,24 s auf exakt 0; danach bleibt die Fläche bis zum nächsten
   Add eben.

Die Reaktion ist an die Wassermenge gekoppelt, wird bei einem flachen
Füllstand unter 15 % auf 4 pt begrenzt und an Rim/Boden geclippt. Neue Taps
ersetzen beziehungsweise verlängern die aktive Reaktion; Profile werden nie
additiv gestapelt.

Beispiel für +250 ml, 1250 → 1500 bei Ziel 2000:

| Zeit | Bild | Store |
|---|---|---|
| 0–140 ms | Button scale 0,96, Haptic `.success`; Strahl wächst von 32 pt über dem Rim bis zur Wasserlinie | `LogIntake` committed |
| 140–626 ms | +250-ml-Strahl fließt; linearer Pegelanstieg, Zahlenrolle und mittige Vertiefung beginnen beim Kontakt | — |
| 626–766 ms | Strahl verjüngt sich und blendet aus; Pegel erreicht exakt bei 766 ms sein Store-Ziel | UI-Zeilen wechseln zum Store |
| 626–1006 ms | Auslaufende Kämme erreichen nahe der Wände ihre größte Entfernung | — |
| 1006–1286 ms | Eine deutlich kleinere Reflexion läuft zurück | — |
| 1286–1526 ms | Restbewegung → 0; Confirm `+250 ml · schöner Ripple.` | UI = Store |
| 1,5–2,8 s | Confirm fade | — |

Drei schnelle Taps erzeugen drei Store-Einträge, aber einen durchgehenden
Strahl, einen fortlaufend linear retargeteten Pegelanstieg und eine
abschließende Oberflächenreaktion auf den Endpegel. Die aktive Serienmenge
bestimmt Breite, Dauer und Kontaktstärke; jedes einzelne Log bleibt eine
eigene Store-Zeile.

Undo setzt den `level` in 0,45 s zurück und startet keinen Strahl und keine
Oberflächenreaktion.

#### 22.1.10 Today-Copy, Accessibility und andere Flächen

- Caption Idle: `noch 750 ml · Ziel 2 000 ml`.
- Confirm: `+{menge} ml · schöner Ripple.`.
- VoiceOver Hero: „1.250 Milliliter von 2.000. 62 Prozent. Noch 750 Milliliter.“
- Button: `Eigene Menge` / `Custom amount`; öffnet die Eingabe einer Menge.
- Widget: dasselbe `GlassShape` und eine ebene Fläche, ohne Core Motion, Strahl,
  Ringe oder Oberflächenbewegung; Zahl und Pegel aktualisieren sich statisch.
- Dark Mode: dieselben Shapes, kühle anthrazitfarbene Surfaces, etwas helleres
  Aqua und lesbarer Stroke; kein separates Dark-Layout.

#### 22.1.11 Today-Verbote und Abnahme

Verboten sind `ProgressView` oder lineare/Kreis-Progress-Bars als Hauptstand,
fotorealistisches Wasser, Caustics, Partikel, SPH, Idle-Sinus, autonome
Idle-Wellen, visuelles Verschütten, ein einzelner Symboltropfen als
Mengenmetapher, Regen aus mehreren Tropfen, mengenunabhängige Strahlbreite
oder -dauer, Pegel-Spring oder -Overshoot während eines aktiven Strahls,
SpriteKit, Metal, Lottie, Video und zusätzliche Hero-Tabs oder
Motivationskarten.

Die Abnahme muss mindestens bestätigen:

- Idle ist eben und ohne Welle; Face-up ist waagerecht.
- Kippen folgt der Schwerkraft auch bei 45°, 90° und kopfüber, ohne sichtbares
  Verschütten oder Mengenänderung.
- Beim Zurückstellen laufen mindestens zwei sichtbar abnehmende Schwingungen
  nach und die Oberfläche wird vollständig ruhig.
- Reduce Motion und Simulator bleiben waagerecht und verwenden keinen Strahl.
- Zahlen bleiben im Idle und während des Strahls lesbar.
- Der Strahl startet 32 pt über dem Glas und erreicht die Wasserlinie in 0,14 s.
- Unterschiedliche Mengen ändern Breite, Dauer und Kontaktstärke subtil; der
  Pegel folgt der echten Milliliterzahl.
- Der Pegel erreicht sein Ziel exakt mit dem vollständigen Ausblenden des
  Strahls, ohne Spring oder Overshoot.
- Kontaktvertiefung, Kamm-Paar, einmalige Reflexion und Settle dauern wie
  spezifiziert; keine separaten Ellipsen oder Einzel-Tropfen.
- Coalescing erzeugt einen durchgehenden Strahl, einen Zielpegel und eine
  abschließende Reaktion.
- Widget und Komplikationen bleiben ohne Strahl und Oberflächenbewegung.

### 22.2 History und Stats

History und Stats sind zwei getrennte Screens und zwei getrennte Tab-Einträge.
Es gibt keinen kombinierten „Insights“-Screen.

#### 22.2.1 Navigation

Das iPhone verwendet vier Tabs:

| Tab | Symbol | Screen |
|---|---|---|
| Heute | `drop.fill` | Today |
| Verlauf | `calendar` | `HistoryCalendarView` |
| Statistik | `chart.bar.xaxis` | `StatsView` |
| Einstellungen | `gearshape` | Settings |

Kein Segmented Control mischt History und Stats. Ein Zurück-Button erscheint
nur innerhalb von Push-Navigationen wie dem Tagesdetail, nicht auf den
Tab-Roots.

Das iPad verwendet für History einen eigenen Zwei-Pane-Screen mit plain
`HStack`; die Paneele werden nicht von `NavigationStack` oder
`NavigationSplitView` umschlossen. Links liegt das Monatsraster, rechts
`DayDetailView`. Heute ist beim Öffnen vorausgewählt, daher gibt es keinen
initialen „Tag wählen“-Zustand. Stats bleibt eine eigene Spalte mit Charts in
voller Breite.

Beide iPad-Paneele verwenden den Foam-Hintergrund ohne systemseitige
Sidebar-Farbfläche oder Sidebar-Controller. Zwischen Master und Detail liegt
eine dezente vertikale Trennlinie. Die Kalender-Masterspalte bleibt immer
sichtbar. Die primäre „+“-Aktion liegt im oberen Bereich neben der Tabbar; im
iPad-Detailpaneel wird sie direkt vom plain-HStack-Screen gerendert, im
kompakten Stack am Kalender-Root. Sie öffnet die Custom-Amount-Sheet und ist
nur für den heutigen ausgewählten Tag sichtbar.

VisionOS verwendet die systemseitige adaptive Glass-Fläche ohne zusätzliches
schwarzes Innenpanel. Ein führendes vertikales Ornament navigiert zu Today,
History, Stats und Settings und zeigt nur Symbole mit vollständigen
Accessibility-Labels. Alle Log-Aktionen liegen im unteren Ornament:
gespeicherte Behälter und `Custom amount`. Es gibt keinen zusätzlichen
Inline-Log-Button, keine doppelte Default-Mengen-Aktion, keinen Immersive
Space und keinen app-weiten Router.

Die Watch-App verwendet keinen Monatskalender und keinen Perioden-Picker. Ihre
History-Seite zeigt sieben lokale Kalendertage (heute und die sechs vorherigen)
neu nach alt. Ein Tap öffnet das Tagesdetail; einzelne Einträge können dort
per Wischaktion gelöscht und über eine kurze Undo-Aktion wiederhergestellt
werden. Die Watch-Stats-Seite zeigt ausschließlich die aktuelle ISO-Woche mit
Durchschnitt pro vergangenem Tag, Zieltreffern, Gesamtmenge und einem
kompakten Swift-Charts-Diagramm. History und Stats verwenden lokale
NavigationStacks, Today bleibt vollflächig ohne Navigationsstapel. Die Watch
verwendet standardmäßig eine dunkle OLED-Oberfläche.

Komplikationen und Widgets bleiben fokussiert und verwenden weder Kalender
noch Stats-Charts. tvOS und Widget behalten ihre bestehenden Einschränkungen.

#### 22.2.2 History: Activity-artiges Monatsraster

History ist eine kalender-first Ansicht wie Activity/Fitness, mit **einem Ring
pro Tag** und keiner Listen-First-Ansicht.

```text
HistoryCalendarView
  iPhone: HistoryPhoneScreen
    NavigationStack {
      HorizontalPager {
        VStack {
          monthHeader      // „August 2026“  < >
          weekdayRow       // locale: M T W T F S S
          LazyVGrid(7 columns) { dayCell }
        }
      }
      .navigationDestination(item: $selectedDay) { DayDetailView(day:) }
    }
  iPad: HistoryPadScreen
    HStack(spacing: 0) {
      calendarPane
      Divider()
      detailPane
    }
```

- Hintergrund Foam `#E8F4F6`.
- Auf iPhone lautet der Navigationstitel `Verlauf` / `History`; auf iPad
  trägt die obere Tabbar den Kontext und es gibt keinen zusätzlichen Root-Titel.
- Die primäre Aktion ist ein „+“ neben der Tabbar. Im kompakten Stack gehört
  sie zum Kalender-Root und nicht zum gepushten Detail. Auf iPad wird sie im
  Detailpaneel gerendert. Sie öffnet `CustomAmountSheet` und nutzt denselben
  `LogIntake`-Pfad wie Today. Für vergangene Tage gibt es keine Add-Aktion.
- Der Monat ist per Chevron und horizontalem Swipe navigierbar. Der
  vollständige Monatsinhalt — Header, Wochentage und Raster — liegt in einem
  seitenbreiten horizontalen Pager mit nativer, auf genau eine Seite
  begrenzter Paging-Semantik. Der Pager enthält nur die lückenlose
  Monatsfolge vom Monat des ersten nicht gelöschten Eintrags bis zum aktuellen
  Monat; ohne Eintrag zeigt er nur den aktuellen Monat.
- Jede Seite besitzt mit ihrem normalisierten Monatsanfang eine stabile
  Identität. Sichtbare Seiten werden während oder nach einer Geste weder
  wiederverwendet noch auf eine künstliche Mittelseite zurückgesetzt.
  `visibleMonth` wird auf das tatsächlich eingerastete Ziel gesetzt.
- Die Chevrons liegen im Monats-Header, steuern denselben Pager und sind an
  den Grenzen deaktiviert.
- Wochen starten gemäß `Calendar.current.firstWeekday`.
- Leere Zellen vor dem ersten und nach dem letzten Tag sind unsichtbar und
  nicht tappable.

#### 22.2.3 History: Day Cell

Der Ringdurchmesser beträgt auf iPhone und iPad 36 pt. Die Master-Spalte bleibt
auf iPad kompakt genug, damit sieben Spalten ohne Überlauf sitzen.

```text
ZStack {
  Circle().stroke(deep.opacity(0.12), lineWidth: 3)     // Track
  Circle()
    .trim(from: 0, to: progress)                        // 0…1
    .stroke(ringColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
    .rotationEffect(.degrees(-90))
  Text(dayNumber).font(.footnote.monospacedDigit())
}
```

| Zustand | Ring | Zahl | Tap |
|---|---|---|---|
| Zukunft | Track only, 12 % Opacity | 30 % Opacity | nein |
| Kein Eintrag, Vergangenheit | Track only | Deep 60 % | ja, leeres Detail + CTA |
| Teilweise (`0 < p < 1`) | Lagoon-Bogen | Deep | ja |
| Ziel erreicht (`p ≥ 1`) | voller Aqua-Ring, Cap 1.0 | Deep, semibold | ja |
| Heute | wie Stand + 1,5 pt Deep-Punkt unter dem Ring | Deep bold | ja |
| Ausgewählter Tag (iPad) | zusätzlicher 2 pt Lagoon-Halo | — | — |

`progress = min(1, consumed / max(goal, 1))`.

Das Ziel ist das an dem Tag gültige Goal. Das aktuelle Profil-Goal darf nicht
über historische Tage gestülpt werden. Fehlt ein Snapshot, wird das heutige
Profil-Goal als Fallback verwendet. Es gibt kein Mini-Glas, keinen zweiten
Ring und keine Streak-Flamme. Reduce Motion animiert den Ring beim
Monatswechsel nicht; der native Pager wechselt ohne Flip.

`ObserveMonth(year:month:)` liefert `[DaySummary]`:

```text
DaySummary
  date: Date              // startOfDay
  consumedMl: Int
  goalMl: Int
  entryCount: Int
  hitGoal: Bool
```

Die Monatsabfrage aggregiert `Intake` im Monatsintervall auf dem ModelActor
und blockiert nicht die Today-Abfrage.

#### 22.2.4 Tagesdetail

Auf iPhone wird das Tagesdetail gepusht, auf iPad in der rechten Spalte
angezeigt. Es ist kein Card-Overlay über dem Kalender.

```text
DayDetailView
  header: Wochentag + Datum
  hero: „1 250 ml“ / „Ziel 2 000 ml“ / „62 %“
  caption: „noch 750 ml“ oder „Ziel erreicht“
  entriesHeader: „Entries“
  primary action: nur heute; auf iPad „+“ rechts in derselben Überschriftszeile
  List of IntakeRow
```

`IntakeRow` zeigt Zeit (`15:08`), Menge, Behälter und die Quelle (`App`,
`Siri`, `Widget`, `Watch`, `Health`). Swipe trailing löscht über den
`DeleteIntake`-Use-Case; Tap öffnet eine Edit-Sheet für Menge, Behälter und
Zeit. Das „+“ ist auf iPhone nicht am gepushten Detail sichtbar. Vergangene
Einträge bleiben editierbar und löschbar.

Ein leerer Tag zeigt `Keine Einträge` / `No entries` und nur für heute einen
Button `+ 250 ml`. Nach Delete erscheint eine 5-Sekunden-Undo-Aktion.

VoiceOver nennt für die Zelle Datum, Menge, Zielstatus und für die Zeile Menge,
Behälter, Zeit und Quelle.

#### 22.2.5 Stats

Stats ist ein eigener Screen ohne Kalender. Er verwendet ein eigenes
Ripple-Kartenlayout auf Foam: Periodensteuerung, Kennzahlen, jeder Chart und
Highlights liegen in wiederverwendbaren `GlassCard`-Flächen. Keine
systemseitige Form- oder Listenfläche, keine ungekarteten Chart-Blöcke und
kein dritter Ring.

```text
StatsView
  NavigationStack
    ScrollView {
      periodPicker          // Woche | Monat | Jahr
      summaryRow            // 3 Zahlen
      chartGoalVsActual
      chartHitRate
      chartDaypart
      chartContainer
      highlights
    }
```

Auf iPhone erscheint der Navigationstitel `Statistik`; auf iPad trägt die
obere Tabbar den Kontext.

Perioden:

- Woche = aktuelle ISO-Woche mit Nachbarwochen;
- Monat = aktueller oder ausgewählter Kalendermonat;
- Jahr = aktuelles Jahr mit zwölf Monatskategorien.

Die Summary enthält drei gleich breite Kacheln:

| Kachel | Woche | Monat | Jahr |
|---|---|---|---|
| Ø / Tag | Mittel der Tage inklusive Tage ohne Eintrag | gleich | gleich |
| Ziel erreicht | `hitDays / daysElapsed` | gleich | gleich |
| Total | Summe ml | Summe | Summe |

Zahlen verwenden `monospacedDigit()` und zeigen die Einheit neben der Zahl.

Die vier Chart-Familien sind:

1. **Ist vs. Ziel:** Swift Charts; X Tag (Woche/Monat) oder Monat (Jahr), Y
   ml, Aqua-Balken für `consumedMl`, Lagoon-Referenz für `goalMl`, leere Tage
   mit Höhe 0.
2. **Zielquote:** Linie oder Balken von 0–100 %. Woche und Monat zeigen
   Tageswerte, Jahr aggregiert `hitDays / days` pro Monat.
3. **Tageszeit:** vier feste Buckets Morgen 05–11, Mittag 11–14,
   Nachmittag 14–18 und Abend 18–05; Darstellung als gestapelte oder vier
   einzelne Balken nach ml-Anteil.
4. **Behälter:** horizontaler Balken je Behälter (Glas, Tasse, Flasche,
   Custom, Unbekannt), maximal sechs Zeilen; der Rest heißt `Sonstiges`.

Chart-Höhe beträgt 180 pt. Kein 3D und kein dekoratives Gradientenspiel.
Annotationen erscheinen nur nach Tap auf einen Balken. Leere Tage bleiben als
Kategorie vorhanden. Jede Chart-Ansicht hat eine Textzusammenfassung und einen
VoiceOver-Wertzugriff.

Highlights:

- bester Tag: Datum + ml;
- schwächster abgeschlossener Tag, nur Vergangenheit und `consumed > 0`;
- Tage ohne Eintrag in der Periode;
- längste Serie mit Zielerreichung nur ab einer Länge von 2, ohne Streak-
  Produkt oder Benachrichtigungen.

Leere Perioden zeigen in allen Charts `Noch keine Daten für diese Periode.` /
`No data for this period.` und niemals künstliche Balken.

`ObserveStats(range:)` liefert ein `StatsSnapshot` mit `range`, `daily`,
`byDaypart`, `byContainer`, `bestDay` und `currentHitRun`. Eine Query wird auf
dem ModelActor ausgeführt und von der View nur auf Charts abgebildet.
HealthKit ist nicht die Stats-Quelle; SwiftData bleibt Source of Truth.

#### 22.2.6 History/Stats-Copy und Ausschlüsse

| Deutsch | English |
|---|---|
| Verlauf | History |
| Statistik | Stats |
| Ziel erreicht | Goal reached |
| Noch {n} ml | {n} ml left |
| Keine Einträge | No entries |
| Woche / Monat / Jahr | Week / Month / Year |
| Ø pro Tag | Avg / day |
| Noch keine Daten für diese Periode. | No data for this period. |

Einheiten folgen den Settings (ml / fl oz), Charts skalieren ihre Achsen.

Nicht gebaut werden ein kombinierter Verlauf+Chart-Screen, Activity-artige
Move/Exercise/Stand-Dreierringe, ein GitHub-Heatmap-Kalender, Streak-Badges,
Share-Cards, PDF-Reports, Vergleiche mit anderen Nutzern und rückwirkende
Änderungen des Tagesziels in v1.

Abnahme:

- vier Tabs, Verlauf und Statistik getrennt;
- Verlauf als Monatsraster mit einem Ring pro Tag und Cap bei 100 %;
- Zukunft nicht tappable, heute markiert;
- Tap öffnet Day Detail mit Liste, Delete, Edit und Restore;
- Stats mit Woche/Monat/Jahr, vier Charts und Summary;
- leere Perioden zeigen einen Zero-State ohne Crash-Domain;
- Reduce Motion verwendet keine Ring-Spin-Intros;
- VoiceOver nennt Datum, Menge und Zielstatus.

## 23. Dokumenthistorie

Die Versionsnummer dieses PRD ist die einzige normative Produktversionsnummer.
Änderungen an Architektur, Daten, Plattformen, Screens, Flows oder Motion
werden in diesem Dokument ergänzt und hier mit einem neuen Eintrag vermerkt.
Die Historie ist unveränderlich; neue Einträge werden unten angefügt.

| Version | Datum | Änderung | Auswirkung |
|---|---|---|---|
| 1.5.0 | 2026-09-08 | Letzter Stand vor der Konsolidierung: aktuelle vier iPhone-Roots, Today ohne Recent-Liste, sechsseitiges Onboarding und Watch-Flows. | Diente als gemeinsame Produktbasis für die Android-Paritätsarbeit. |
| 2.0.0 | 2026-09-08 | PRD, Hero-Motion-Spec und History/Stats-Spec zu diesem einzigen versionierten Produktvertrag zusammengeführt; detaillierte Today-, History-, Day-Detail- und Stats-Verträge ergänzt. | Es gibt nur noch ein maßgebliches Produkt-PRD. Android- und Apple-Implementierungen lesen dieselbe Produktquelle; Plattformausdrücke bleiben in den jeweiligen Architektur/UI-Dokumenten. |
| 2.0.1 | 2026-09-08 | Das gemeinsame PRD und seine Produktreferenzbilder nach `Docs/shared/` verschoben; plattformspezifische Architektur bleibt bei der jeweiligen App. | Beide unabhängigen Projekte lesen denselben Produktvertrag, ohne die iOS- oder Android-Implementierung an das jeweils andere Projekt zu koppeln. |
| 2.0.2 | 2026-09-08 | Den vollständigen Android-Portierungshandoff mit iOS-Architekturkontext, Android-Verträgen und Bildreferenzen unter `Docs/shared/` gebündelt. | Das Android-Projekt erhält alle benötigten Spezifikationen und visuellen Referenzen aus einem übertragbaren Dokumentenpaket. |
| 2.0.3 | 2026-09-08 | Den Plattformumfang des gemeinsamen PRD explizit von den iOS-spezifischen Implementierungsanweisungen getrennt. | Android-Agenten verwenden das PRD für Produktverträge und die Android-Dokumente für native Umsetzung, ohne Swift-Anweisungen fehlzuinterpretieren. |
| 2.0.4 | 2026-09-09 | Die redundanten Today-Konzeptbilder entfernt; der PRD verweist nur noch auf die aktuellen iOS-Captures und den verbindlichen Text-/Motion-Vertrag. | Der gemeinsame Handoff enthält weniger veraltbare Referenzdateien, ohne die visuellen Android-Layouts oder aktuellen iOS-Evidence-Captures zu verlieren. |

*Ende PRD 2.0.4. Implementiere die Reihenfolge aus Abschnitt 19 und prüfe die Definition of Done aus Abschnitt 20.*
