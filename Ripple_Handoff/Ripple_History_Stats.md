# Ripple — Verlauf und Statistik

**Dokumenttyp:** Screen-Spec  
**Empfänger:** Grok Build  
**Version:** 1.4 — 1. September 2026
**1.4:** Korrigiert die Position der History-Primäraktion: im offenen iPad-Split am Detail, im kompakten Stack am Kalender-Root; der Sidebar-Toggle wird aus der Masterspalte entfernt.
**1.3:** Verankert die History-Aktion in der oberen Tabbar-Nähe, öffnet für neue Einträge die benutzerdefinierte Mengen-Sheet und hält die iPad-Kalenderspalte offen.
**1.2:** Vereinheitlicht die Stats-Oberfläche als GlassCard-Layout, setzt den History-Start auf heute und ergänzt eine dezente iPad-Trennlinie.
**Gehört zu:** `Ripple_PRD.md`. Hero/Animation bleibt in `Ripple_Hero_Motion.md`.

Zwei getrennte Screens, zwei Tab-Einträge. Kein kombinierter „Insights“-Screen.

---

## 1. Navigation

iPhone Tab Bar, vier Tabs:

| Tab | SF Symbol | Screen |
|---|---|---|
| Heute | `drop.fill` | Today (unverändert) |
| Verlauf | `calendar` | `HistoryCalendarView` |
| Statistik | `chart.bar.xaxis` | `StatsView` |
| Einstellungen | `gearshape` | Settings |

Kein Segmented Control, das beide mischt.  
Zurück-Button nur innerhalb von Pushes (Tagesdetail), nicht auf den Tab-Roots.

iPad: `NavigationSplitView`.

- Tab Verlauf: links Monatsraster, rechts `DayDetailView`; heute ist beim Öffnen vorausgewählt, daher gibt es keinen initialen „Tag wählen“-Zustand.
- Tab Statistik: eine Spalte, Charts volle Breite.
- Beide iPad-Spalten verwenden durchgehend den Foam-Hintergrund; die systemseitige Sidebar-Farbfläche darf keine zweite Tönung einführen.
- Beim Öffnen von Verlauf ist der heutige Tag vorausgewählt. Eine manuelle Tagesauswahl bleibt bestehen; der Zustand „Tag wählen“ ist kein initialer Zustand.
- Zwischen Master- und Detailspalte liegt eine dezente vertikale Trennlinie in Deep mit niedriger Opazität.
- Die Kalender-Masterspalte bleibt auf iPad geöffnet; ein systemseitiger Schließen-/Sidebar-Toggle wird nicht angeboten.
- Die primäre „+“-Aktion liegt im oberen Toolbar-Bereich neben der Tabbar. Im offenen iPad-Split gehört sie zur Detailspalte; im kompakten Stack gehört sie zum Kalender-Root. Sie ist nur für den heutigen ausgewählten Tag sichtbar und öffnet die Custom-Amount-Sheet.
- Die obere Tabbar trägt den Screen-Kontext. Auf iPad werden keine zusätzlichen Root-Navigationstitel für Verlauf/History oder Statistik/Stats angezeigt; ein Tagesdatum im Detail bleibt sichtbar.

Watch / tvOS / Widget: kein Kalender, keine Stats-Charts. Watch zeigt höchstens die letzten Einträge des Tages unter dem Plus.

---

## 2. Verlauf — Kalender wie Activity

Vorbild: Fitness-/Activity-App, Monatsraster mit **einem Ring pro Tag**. Keine Listen-First-Ansicht.

### 2.1 Layout

```
HistoryCalendarView
  NavigationStack
    HorizontalPager {
      VStack {
        monthHeader        // „August 2026“  < >
        weekdayRow         // locale: M T W T F S S
        LazyVGrid(7 columns) { dayCell }
      }
    }
    .navigationDestination(item: $selectedDay) { DayDetailView(day:) }
```

- Hintergrund Foam `#E8F4F6`
- Titel: Wortmarke weglassen. Auf iPhone NavigationTitle `Verlauf` / `History`; auf iPad kein zusätzlicher Root-Titel, weil die obere Tabbar den Kontext trägt
- Primäre Aktion: ein „+“ im oberen Toolbar-Bereich. Im iPad-Split erscheint es am Detail-Screen; bei kompakter Navigation erscheint es am Kalender-Screen und nicht am gepushten Detail-Screen. Das „+“ öffnet `CustomAmountSheet` zur Eingabe/Stepper-Auswahl einer Menge; die Buchung läuft über denselben `LogIntake`-Pfad wie Today. Für vergangene Tage gibt es keine Add-Aktion.
- Monat per Chevron und horizontalem Swipe. Der vollständige Monatsinhalt — Header, Wochentage und Raster — liegt in einem seitenbreiten horizontalen `ScrollView` mit nativer, auf genau eine Seite begrenzter Paging-Semantik (`scrollTargetLayout` / `scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))`). Der Pager enthält ausschließlich die lückenlose Monatsfolge vom Monat des ersten nicht gelöschten Wassereintrags bis zum aktuellen Monat; ohne Eintrag zeigt er nur den aktuellen Monat. Jede Seite besitzt mit ihrem normalisierten Monatsanfang eine stabile Identität. Sichtbare Seiten werden während oder nach einer Geste weder wiederverwendet noch auf eine künstliche Mittelseite zurückgesetzt. `visibleMonth` wird auf das tatsächlich eingerastete Ziel gesetzt. Die Chevrons liegen im Monats-Header, steuern denselben Pager und sind an den beiden Grenzen deaktiviert.
- Wochen starten laut `Calendar.current.firstWeekday`
- Leere Zellen vor dem 1. und nach dem letzten Tag des Monats: unsichtbar, nicht tappable

### 2.2 Day Cell (Ring)

Durchmesser **36 pt** auf iPhone und iPad. Auf iPad bleibt die Master-Spalte kompakt genug, damit 7 Spalten ohne Überlauf sitzen.

```
ZStack {
  Circle().stroke(deep.opacity(0.12), lineWidth: 3)     // Track
  Circle()
    .trim(from: 0, to: progress)                        // 0…1 = consumed/goal des Tages
    .stroke(ringColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
    .rotationEffect(.degrees(-90))
  Text(dayNumber)                                       // "28"
    .font(.footnote.monospacedDigit())
    .foregroundStyle(numberColor)
}
```

| Zustand | Ring | Zahl | Tap |
|---|---|---|---|
| Zukunft | Track only, 12 % Opacity | 30 % Opacity | nein |
| Kein Eintrag, Vergangenheit | Track only | Deep 60 % | ja, Detail leer + CTA |
| Teilweise (`0 < p < 1`) | Lagoon-Bogen | Deep | ja |
| Ziel erreicht (`p ≥ 1`) | voller Aqua-Ring, Bogen darf über 1 nicht weiterlaufen — Cap 1.0 | Deep, semibold | ja |
| Heute | wie Stand + 1,5 pt Deep-Punkt unter dem Ring | Deep bold | ja |
| Ausgewählter Tag (iPad) | extra 2 pt Lagoon-Halo | — | — |

`progress = min(1, consumed / max(goal, 1))`.  
Ziel ist das **an dem Tag gültige** Goal (historisch, nicht das aktuelle Profil-Goal über alles stülpen). Fehlt ein Snapshot, Fallback: heutiges Profil-Goal.

Kein Mini-Glas in der Zelle. Kein zweiter Ring. Keine Streak-Flammen.

Reduce Motion: `trim` ohne Animation beim Monatswechsel; der native Monats-Pager wechselt ohne Animation; Monatwechsel: Opacity, kein Flip.

### 2.3 Daten

Use Case `ObserveMonth(year:month:)` → `[DaySummary]`.

```
DaySummary
  date: Date              // startOfDay
  consumedMl: Int
  goalMl: Int
  entryCount: Int
  hitGoal: Bool
```

CloudKit/SwiftData: Query `Intake` im Monatsintervall, aggregieren auf dem ModelActor, nicht in der View.

Monatswechsel darf nicht die Today-Query blockieren.

---

## 3. Tagesdetail

Push auf iPhone, rechte Spalte auf iPad. Nicht als Card-Overlay über dem ganzen Kalender (Activity nutzt Push/Sheet — hier: **Push**, damit Edit-Platz da ist).

```
DayDetailView
  header: Wochentag + Datum
  hero: „1 250 ml“  /  „Ziel 2 000 ml“  /  „62 %“
  caption: „noch 750 ml“ oder „Ziel erreicht“
  List of IntakeRow
  toolbar: ggf. „+“ loggt auf **dieses** Datum (nicht zwingend auf now — nur wenn selectedDay == today; sonst kein Plus, Einträge der Vergangenheit nur edit/delete)
```

### IntakeRow

- Zeit `15:08`
- Menge `250 ml`
- Behälter `Glas`
- Source klein: `App` / `Siri` / `Widget` / `Watch` / `Health`
- Swipe trailing: Delete
- Tap: Edit-Sheet Menge + Behälter + Zeit

Leerer Tag: Illustration weglassen. Text `Keine Einträge` + wenn heute: Button `+ 250 ml`.

Undo nach Delete: Snackbar wie Today, 5 s.

VoiceOver Zelle: „28. August, 1.250 Milliliter von 2.000, Ziel erreicht.“  
VoiceOver Row: „250 Milliliter, Glas, 15 Uhr 8, Widget.“

---

## 4. Statistik

Eigener Screen, kein Kalender.

Die Oberfläche verwendet ein eigenes Ripple-Kartenlayout auf Foam: Periodensteuerung, Kennzahlen, jeder Chart und die Highlights liegen in wiederverwendbaren `GlassCard`-Flächen. Keine systemseitige Form- oder Listenfläche und keine ungekarteten Chart-Blöcke. Die Karten bleiben ruhig und funktional: 20-pt-Radius, RippleUI-Abstände, Deep/Lagoon/Aqua und dezente interne Trennlinien.

```
StatsView
  NavigationStack
    ScrollView {
      periodPicker          // Segment: Woche | Monat | Jahr
      summaryRow            // 3 Zahlen
      chartGoalVsActual     // Balken
      chartHitRate          // Linie oder Balken 0–100 %
      chartDaypart          // Wann getrunken
      chartContainer        // Behälter-Anteil
      highlights            // Best day, Durchschnitt, leere Tage
    }
    .navigationTitle("Statistik")       // iPhone; auf iPad trägt die obere Tabbar den Kontext
```

Periode:

- Woche = aktuelle ISO-Woche, Chevron auf Nachbarwochen
- Monat = aktueller Monat
- Jahr = aktuelles Jahr, 12 Balken

### 4.1 Summary Row

Drei Kacheln, gleiche Breite:

| Kachel | Woche | Monat | Jahr |
|---|---|---|---|
| Ø / Tag | Mittel der Tage mit *oder* ohne Nullen: **inkl. Tage ohne Eintrag** | gleich | gleich |
| Ziel erreicht | `hitDays / daysElapsed` | gleich | gleich |
| Total | Summe ml | Summe | Summe |

Zahlen `monospacedDigit()`, Einheit neben der Zahl.  
Kein dritter Ring.

### 4.2 Chart: Ist vs Ziel

Swift Charts.

- X: Tag (Woche), Tag (Monat), Monat (Jahr)
- Y: ml
- Bar: `consumedMl`, Fill Aqua
- RuleMark oder zweite dünne Bar: `goalMl`, Lagoon 40 %
- Annotation nur bei Tap auf eine Bar (Overlay: Datum + ml + %)
- Leere Tage: Bar Höhe 0, Kategorie trotzdem da

Höhe 180 pt. Kein 3D, kein Gradient-Spiel.

### 4.3 Chart: Zielquote

- Linie oder Bar `hitGoal ? 1 : 0` aggregiert:
  - Woche: 7 Punkte 0/1
  - Monat: pro Tag 0/1
  - Jahr: pro Monat `hitDays/days`
- Y 0…100 %, Domain fest

### 4.4 Chart: Tageszeit

Vier Buckets, immer dieselben:

| Bucket | Intervall |
|---|---|
| Morgen | 05–11 |
| Mittag | 11–14 |
| Nachmittag | 14–18 |
| Abend | 18–05 |

Gestapelt oder vier Balken, Anteil an der Periode in ml.  
Kein Heatmap-Grid in v1.

### 4.5 Chart: Behälter

Horizontal Bar je Container (Glas / Tasse / Flasche / Custom / Unbekannt).  
Anteil an Total. Max 6 Zeilen, Rest = „Sonstiges“.

### 4.6 Highlights

Liste, keine Cards mit Illustrationen:

- Bester Tag: Datum + ml
- Schwächster abgeschlossener Tag (nur Vergangenheit, consumed > 0)
- Tage ohne Eintrag in der Periode
- Längste Serie Ziel erreicht **nur anzeigen, wenn ≥ 2**. Kein Streak-System, keine Notifications daran. Reine Zahl.

Leere App: alle Charts mit Zero-State-Text `Noch keine Daten für diese Periode.` Kein Fake-Chart.

### 4.7 Daten

`ObserveStats(range:)` auf dem ModelActor.

```
StatsSnapshot
  range: DateInterval
  daily: [DaySummary]
  byDaypart: [Daypart: Int]
  byContainer: [UUID?: Int]
  bestDay: DaySummary?
  currentHitRun: Int
```

Eine Query, View mapped auf Charts. Kein HealthKit als Quelle für Stats — Store bleibt Source of Truth.

---

## 5. Copy

DE / EN, wie restliche App.

| DE | EN |
|---|---|
| Verlauf | History |
| Statistik | Stats |
| Ziel erreicht | Goal reached |
| Noch {n} ml | {n} ml left |
| Keine Einträge | No entries |
| Woche / Monat / Jahr | Week / Month / Year |
| Ø pro Tag | Avg / day |
| Noch keine Daten für diese Periode. | No data for this period. |

Einheiten folgen Settings (ml / fl oz). Charts skalieren Achsen mit.

---

## 6. Was nicht gebaut wird

- Kombinierter Verlauf+Chart-Screen
- Activity-ähnliche Move/Exercise/Stand-Dreierringe
- Heatmap-Kalender (GitHub-Style)
- Streak-Badges, Share-Card, PDF-Report
- Vergleich mit „Nutzer wie du“
- Edit des Tagesziels rückwirkend in v1 (Goal am Tag = damaliges Profil, Snapshot wenn vorhanden)

---

## 7. Abnahme

- [ ] Vier Tabs, Verlauf und Statistik getrennt
- [ ] Verlauf = Monatsraster, ein Ring pro Tag, Cap bei 100 %
- [ ] Zukunft nicht tappable, Heute markiert
- [ ] Tap → DayDetail mit Liste, Delete, Edit
- [ ] Statistik: Periode Woche/Monat/Jahr, vier Charts + Summary, Swift Charts
- [ ] Leere Periode: Zero-State, keine Crash-Domain
- [ ] Reduce Motion: keine Ring-Spin-Intros
- [ ] VoiceOver nennt Datum, Menge, Zielstatus

Grok Build implementiert diesen Vertrag plus Domain-Use-Cases `ObserveMonth` und `ObserveStats`.
