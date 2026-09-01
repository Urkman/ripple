# Ripple — Hero, Stand und Add-Animation

**Dokumenttyp:** Implementierungsspec nur für Today-Hero  
**Empfänger:** Grok Build  
**Version:** 2.1 — 1. September 2026
**2.1:** Vergrößert den begrenzten Portrait-Hero auf etwa 280 × 392 pt; die Landscape-Komposition bleibt unverändert.
**2.0:** Präzisiert die iPad-Ausrichtung: Zwei Spalten gibt es nur im Landscape; Portrait behält die vertikale Heute-Komposition mit kleinerem Hero, Status oben und CTA unten.
**1.9:** Ergänzt die eigenständige iPad-Komposition mit begrenztem Hero und seitlichem Aktionsbereich; die Hero-Geometrie und die Eingießbewegung bleiben unverändert.
**1.8:** Verankert das Readout in einer ruhigen Frontglas-Schicht und koppelt das Strahlende an dieselbe innere Wasseroberkante wie der Fill.  
**1.7:** Führt eine gemeinsame, frameweise abgetastete `pourProgress`-Zeitbasis für Pegel und Strahl-Fade ein; neue Taps retargeten ab dem aktuell dargestellten Pegel.  
**1.6:** Koppelt den Pegelanstieg exakt an die sichtbare Strahldauer vom ersten Kontakt bis zum vollständigen Ausblenden; der Pegel steigt linear und ohne Overshoot.  
**1.5:** Ersetzt den einzelnen Tropfen und die gezeichneten Einschlagringe durch einen kurzen Wasserstrahl mit kontinuierlichem Pegelanstieg und einer einmaligen, gedämpften Oberflächenreaktion.  
**1.4:** Ersetzt die Tropfenverformung und die vollbreite Sinuswelle aus 1.3 durch einen formstabilen Tropfen und eine lokale Einschlagdelle.  
**1.3:** Der Tropfen verformt sich dezent im Fall und geht beim Kontakt kontinuierlich in den ersten Ring über.  
**1.1:** Tropfen startet über dem Glas, Flug 0,42–0,58 s.  
**1.2:** Keine Idle-Welle. Wasseroberfläche ist eben und folgt der Geräteneigung (Core Motion).  
**Gehört zu:** `Ripple_PRD.md` (Architektur, Daten, Intents). Bei Widerspruch zu Screens gilt dieser Text.

Dieses Dokument beschreibt **ausschließlich**, wie der aktuelle Tagesstand aussieht und wie Wasser-Hinzufügen animiert wird. Keine Progress Bar. Kein 3D. Kein SpriteKit, Metal oder Video.

Referenzbilder liegen in `screens/`.

---

## 1. Was gebaut wird

Ein stilisiertes **2D-Trinkglas (Tumbler)**. Der Füllstand ist eine **ebene Wasseroberfläche** im Glas. Im Idle gibt es **keine** Sinus-Welle und keine Timeline-Loop. Neigt man das iPhone, läuft das Wasser in diese Richtung (Core Motion). Beim Loggen fließt ein **kurzer, schmaler Wasserstrahl** von oberhalb des Glases zur Oberfläche. Breite, Kontaktvertiefung und Fließdauer folgen dezent der Menge. Der Pegel steigt bereits während des Eingießens. Beim Ende des Strahls laufen zwei Oberflächenkämme zu den Wänden, werden einmal schwächer reflektiert und kommen innerhalb von 0,90 s vollständig zur Ruhe. Es gibt keinen einzelnen Symboltropfen und keine darüber gezeichneten Ellipsen.

![Idle](screens/20-1-today-idle.jpg)

![Add](screens/20-2-add-tap.jpg)

![Settled](screens/20-4-after-log.jpg)

---

## 2. Screen-Komposition (iPhone Heute)

Von oben nach unten, Light Mode, Hintergrund `#E8F4F6`:

1. Navigationsleiste: Wortmarke `Ripple` (`#0B3D4A`) + Datum inline  
2. **Hero-Glas** zentriert und ohne ScrollView; es nutzt den verbleibenden Platz zwischen Navigationsleiste und den unteren Aktionen, skaliert bei kleiner Höhe herunter und behält das Seitenverhältnis von etwa 200 × 280 pt bei
3. Caption `noch {rest} ml · Ziel {goal} ml`  
4. Confirm-Zeile nur nach einem Log, dann Fade  
5. Drei Chips: Glas 250 / Tasse 200 / Flasche 500  
6. Primary-Pille `Eigene Menge` / `Custom amount`, öffnet die Eingabe einer Trinkmenge und bleibt als untere Aktion oberhalb der Tab Bar sichtbar  
7. Tab Bar: Heute | Verlauf | Stats | Einstellungen  

Farben: Deep `#0B3D4A`, Lagoon `#1A7A8C`, Aqua `#4FB3C6`, Foam `#E8F4F6`.  
Zahlen: San Francisco, `monospacedDigit()`, kein `1°500`.

Das Readout sitzt als ruhige, leicht transluzente Frontglas-Schicht innerhalb des Glases. Die Schicht bekommt eine sehr zurückhaltende helle Kante und eine weiche, vertikale Glasreflexion; sie ist kein zusätzlicher Fortschrittsindikator und verdeckt die Wasseroberfläche nicht vollständig. Menge mit Einheit bleibt oben, Prozent unten, beide bleiben über dem Strahl und folgen den bestehenden Text- und Accessibility-Vorgaben.

### 2.1 Screen-Komposition (iPad Heute)

Das iPad nutzt die zusätzliche Breite nur im Landscape für eine ruhige Zwei-Spalten-Komposition:

- oben steht das Status-Label mit verbleibender Menge und Ziel
- in der Mitte links ein zentrierter, begrenzter Hero mit unverändertem Seitenverhältnis und derselben Motion; er darf bis etwa 240 × 336 pt groß werden und wächst nicht bis zur verfügbaren Höhe
- in der Mitte rechts stehen die drei Behälter-Aktionen als flache Buttons ohne `GlassCard` oder einzelne Glas-Karten
- unten bleibt die Primary-Pille `Eigene Menge` / `Custom amount` als CTA im Safe-Area-Inset
- die obere iPad-Tabbar ist der Kontext für den Tab. Ein zusätzlicher Today-Screen-Titel, eine Wortmarke oder ein Datum in der Navigation werden auf iPad nicht angezeigt

Im Portrait verwendet das iPad die vertikale Heute-Komposition aus Abschnitt 2. Der Hero bleibt dabei auf etwa 280 × 392 pt begrenzt, damit er nicht den gesamten verbleibenden Platz füllt; Status-Label, flache Behälter-Aktionen und CTA bleiben in ihrer bisherigen Reihenfolge. Auch im Portrait gibt es für iPad keine einzelnen Glas-Karten um die Aktionen. iPhone verwendet weiterhin die Komposition aus Abschnitt 2.

---

## 3. View-Hierarchie

```
RippleHeroView(consumedMl:goalMl:addedMl?:phase:)
  ZStack {
    PourStreamView(addedMl:progress:) // hinter dem Fill, nur während Add
    WaterFill(level:tilt:pourDepth:ripplePosition:rippleAmplitude:)
      .clipShape(GlassShape())
    GlassShape()
      .stroke(Color.lagoon, lineWidth: 3)
    VStack {
      Text(consumedMl).font(.largeTitle.monospacedDigit())
      Text("ml")
      Text(percent)
    }
  }
```

`RippleHeroView` kennt keinen Store. Es bekommt `consumedMl`, `goalMl` und optional die in der aktiven Eingießserie summierte Menge `addedMl` (für Strahlbreite, Kontaktvertiefung und Dauer). `LogButton` ruft nur den Use Case `LogIntake` auf; die View beobachtet den neuen Stand.

---

## 4. GlassShape

2D-Tumbler, kein Stiel, kein fotorealistisches Glas.

- Rim-Breite ≈ **1,35 ×** Bodenbreite  
- Boden leicht gerundet  
- Wände gerade, nach oben geöffnet  
- Vorderkante des Rands als flacher Bogen  

Pfad-Reihenfolge: Boden links → Boden rechts → rechte Wand hoch → Rim-Bogen → linke Wand runter → schließen.

Innenraum = derselbe Pfad, 3 pt nach innen (Stroke-Breite), damit die Welle nicht über den Strich läuft.

Die Unterkante des sichtbaren Strahls verwendet für jeden Pegel denselben inneren `GlassMetrics`-Inset wie `WaterFill` (`GlassMetrics.strokeWidth`). Sie endet an der oberen Kante des vorderen Fill-Layers (`thickness = 0`) in der Glasmitte; die äußere Rim-Geometrie darf nicht als Kontaktpunkt verwendet werden. Dadurch bleibt der Strahl auch bei Retargeting und kleinen Füllständen ohne Lücke mit der Wasseroberfläche verbunden.

`level = 0` sitzt auf dem Innen-Boden.  
`level = 1` sitzt an der **unteren** Rim-Kante (nicht am obersten Pixel der View).  
`level` darf einen echten Stand oberhalb des Tagesziels visuell bis 1,05 darstellen. Die Add-Animation selbst überschwingt den Store-Pegel nicht.

---

## 5. WaterFill — Ebene + Neigung, keine Idle-Welle

Kein `TimelineView` im Idle. Die Oberfläche ist eine **gerade Linie** durch die Glasmitte auf Höhe `levelY`. Die Linie kippt mit der Schwerkraft.

### 5.1 Oberfläche

```
y(x) = levelY
     + (x - midX) * tan(tilt)
     + pourProfile(x, depth)                         // nur während Eingießen
     + travellingPair(x, position, amplitude)       // einmaliges Auslaufen
```

Pfad: links auf y(left) → Linie/leicht gekräuselt nach rechts → rechte untere Innenecke → links unten → schließen.

`pourProfile` ist eine glatte, symmetrische Vertiefung unter dem Strahl mit zwei flachen Schultern. `travellingPair` besteht aus zwei Gauß-Kämmen, die von der Mitte zu den Wänden laufen. Es ist ausdrücklich **keine Sinuswelle** und hat keine freie oder wiederholte Phase.

Zwei Schichten, gleiche Neigung und dieselbe einmalige Oberflächenreaktion:

- Fill A: Aqua `#4FB3C6`, Opacity 0,88  
- Fill B: Aqua, Opacity 0,50, `levelY` um +3 pt (nur Dicke, kein Wellengang)

Immer `.clipShape(GlassShape())`.

`level == 0`: kein Fill, auch kein Schimmer am Boden.

### 5.2 Neigung (Core Motion)

Nur iPhone und iPad, App im Vordergrund, Today sichtbar.

```
CMMotionManager.deviceMotion
  gravity im Gerätekoordinatensystem
  raw = gravity.x          // Portrait: links negativ, rechts positiv
  tiltTarget = clamp(raw, -0.55, 0.55) * maxTilt
  maxTilt = 16°            // visuell, nicht 90°
```

Tiefpass, ~30 Hz:

```
tilt += (tiltTarget - tilt) * 0.18
```

Kein Spring auf `tilt` — sonst schwappt es nach. Volumen bleibt eine Näherung: `levelY` in der **Glasmitte** ist der Store-Pegel. Wir lösen keine Fluid-Gleichung.

Klemmen, damit die Linie im Clip bleibt:

- linke und rechte y-Werte dürfen den Innen-Boden nicht unterschreiten und den Rim nicht überschreiten  
- wenn eine Seite den Boden erreicht, wird die andere Seite höher — `levelY` in der Mitte bleibt

Liegt das Gerät flach (Face-up, `|gravity.z| > 0.92`): `tiltTarget = 0`.  
Simulator / Mac / tvOS / visionOS / Watch: `tilt = 0`, Oberfläche waagerecht.  
Reduce Motion oder Motion-Permission egal (Gravity braucht keine Permission): bei Reduce Motion trotzdem `tilt = 0`.

Lifecycle: `startDeviceMotionUpdates` in `onAppear` der Today-View, `stop` in `onDisappear`. Eine Instanz, nicht pro Frame neu.

### 5.3 Einmalige Reaktion während und nach dem Eingießen

| Zustand | Oberfläche | `tilt` |
|---|---|---|
| Idle | alle Add-Parameter **0**, Fläche eben | folgt Gerät |
| Strahlkontakt | mittige Vertiefung 5…9 pt nach Menge, zwei Schultern ca. 30 % davon | folgt Gerät weiter |
| Strahlende, 0–0,38 s | zwei Kämme laufen von der Mitte bis nahe an die Wände | folgt Gerät weiter |
| Reflexion, 0,38–0,66 s | 60 ms Umkehr an der Wand, dann 220 ms Rückweg mit höchstens 36 % Stärke | folgt Gerät weiter |
| Settle, 0,66–0,90 s | Restamplitude → 0, danach wieder vollständig eben | folgt Gerät weiter |
| Reduce Motion | keine Vertiefung, keine Kämme | 0 |

Die Vertiefung bleibt während des Strahls stabil, ohne Loop oder Flattern. Beim Strahlende fällt sie in 0,16 s ab, während das Kamm-Paar nach außen läuft. An den Wänden bleibt die Position für eine 60-ms-Umkehr stehen; erst nach dem Vorzeichenwechsel läuft die höchstens 36 % starke Reflexion 220 ms nach innen. Nach insgesamt 0,90 s liegt die Amplitude exakt bei 0. Auch bei neuen Taps wird nie eine zweite unabhängige Welle gestapelt; der aktive Strahl wird verlängert und sein Ziel aktualisiert.

Beim ersten Kontakt startet eine gemeinsame, frameweise abgetastete `pourProgress`-Uhr bei 0. Diese Uhr steuert gleichzeitig den linearen Pegelanstieg und den Strahl-Fade. Die Laufzeit ist exakt `levelRiseDuration(for:)`: aktive Strahldauer plus 0,14 s Ausblenden. Damit erreicht der Pegel den echten Store-Zielwert erst in dem Moment, in dem der Strahl vollständig verschwunden ist. Es gibt beim Pegel weder Spring noch Overshoot; die natürliche Restbewegung kommt ausschließlich aus der einmaligen Oberflächenreaktion.

Weitere Taps aktualisieren das Ziel derselben laufenden Uhr. Der aktuell dargestellte Pegel wird als neuer Startwert übernommen, `pourProgress` beginnt für die neue Serienmenge wieder bei 0, und Strahldauer sowie Pegeldauer werden ab dem letzten Tap neu berechnet. Der Strahl bleibt dabei durchgehend sichtbar; es entsteht kein zweiter Pegel- oder Zeitpfad.

Widget und Watch-Komplikation: **kein** Strahl und keine Oberflächenreaktion. Statische ebene Fläche.

---

## 6. Wasserstrahl — Menge wird als Eingießen lesbar

Der Hero verwendet beim Add **keinen einzelnen Tropfen**. `PourStreamShape` zeichnet einen schmalen, leicht nach unten verjüngten Wasserstrahl in Aqua mit einer zurückhaltenden hellen Innenkante. Keine Quelle, Flasche oder Partikel werden dargestellt; der Strahl kommt aus dem oberen Rand des Hero-Bereichs und bleibt unter den Zahlen.

### Menge, Breite und Dauer

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

Die Kontaktvertiefung skaliert über denselben Clamp von 5…9 pt. Die Breite bleibt bewusst subtil; die echte Milliliterzahl bestimmt den Pegelanstieg. Bei einer aktiven Tap-Serie ist `addedMl` die Summe dieser Serie. Weitere Taps verbreitern den bestehenden Strahl höchstens bis zum Cap, verlängern ihn ab dem letzten Tap und aktualisieren denselben Zielpegel.

### Aufbau und Ende

- **Start X:** Glasmitte  
- **Start Y:** `glass.minY - 32 pt`; der Strahl beginnt sichtbar oberhalb des Rims  
- In 0,14 s wächst der Strahl mit `easeOut` bis zur aktuellen Wasserlinie  
- Danach bleibt er für `pourDuration` sichtbar; der lineare Pegelanstieg läuft gleichzeitig  
- Am Ende verjüngt der Strahl sich in 0,14 s auf 35 % und blendet aus; dieselbe `pourProgress`-Uhr lässt den Pegel in dieser Zeit weitersteigen und erreicht sein Ziel mit Opacity 0. Der Strahl zieht sich nicht nach oben zurück  
- Z-Order: hinter dem Wasser-Fill und dem Glas-Stroke, unter den Zahlen. Der eingetauchte Teil wird damit vom Fill aufgenommen statt als separate Linie darüberzuliegen  
- Kein seitliches Wobble, keine Teilchen, keine Unterbrechungs-Loop

Reduce Motion: **kein Wasserstrahl**.

---

## 7. Oberflächenbewegung statt gezeichneter Ringe

Im Today-Hero gibt es keine `RippleEllipses`. Die Energie bleibt in der echten Oberkante des `WaterFill`:

1. Strahlkontakt: mittige Vertiefung mit zwei flachen Schultern.  
2. Strahlende: zwei symmetrische Kämme laufen in 0,38 s nach außen.  
3. Einmalige Reflexion: 0,06 s Vorzeichenwechsel an der Wand, danach 0,22 s Rückweg bei höchstens 36 % Amplitude.  
4. Settle: in 0,24 s auf exakt 0; danach bleibt die Fläche bis zum nächsten Add eben.

Die Reaktion ist an die Wassermenge gekoppelt, wird bei einem flachen Füllstand unter 15 % auf 4 pt begrenzt und an Rim/Boden geclippt. Neue Taps ersetzen beziehungsweise verlängern die aktive Reaktion; Oberflächenprofile werden nie additiv gestapelt.

Widget und Komplikationen zeigen weder Strahl noch Ringe noch Oberflächenwelle.

---

## 8. Timeline eines Adds

Beispiel +250 ml, 1250 → 1500 bei Ziel 2000.

| Zeit | Bild | Store |
|---|---|---|
| 0–140 ms | Button scale 0,96, Haptic `.success`. Strahl wächst von **32 pt über dem Rim** bis zur Wasserlinie | `LogIntake` committed |
| 140–626 ms | +250-ml-Strahl fließt; linearer Pegelanstieg, Zahlenrolle und mittige Vertiefung beginnen beim Kontakt | — |
| 626–766 ms | Strahl verjüngt sich und blendet aus; der Pegel steigt weiter und erreicht exakt bei 766 ms sein Store-Ziel. Vertiefung löst sich, Oberflächenkämme laufen bereits nach außen | UI-Zeilen wechseln zum Store |
| 626–1006 ms | Auslaufende Kämme erreichen nahe der Wände ihre größte Entfernung | — |
| 1006–1286 ms | Eine deutlich kleinere Reflexion läuft zurück | — |
| 1286–1526 ms | Restbewegung → 0; Confirm `+250 ml · schöner Ripple.` | UI = Store |
| 1,5–2,8 s | Confirm fade | — |

Drei schnelle Taps: drei Einträge im Store, **ein durchgehender Strahl**, ein fortlaufend linear retargeteter Pegelanstieg und eine abschließende Oberflächenreaktion auf den Endpegel. Die aktive Serienmenge bestimmt Breite, Dauer und Kontaktstärke; jedes einzelne Log bleibt eine eigene Store-Zeile.

Undo: `level` in 0,45 s zurück, kein Strahl und keine Oberflächenreaktion.

---

## 9. Copy, A11y, andere Flächen

- Caption Idle: `noch 750 ml · Ziel 2 000 ml`  
- Confirm: `+{menge} ml · schöner Ripple.`  
- VoiceOver Hero: „1.250 Milliliter von 2.000. 62 Prozent. Noch 750 Milliliter.“  
- Button: „Eigene Menge“ / „Custom amount“; öffnet die Eingabe einer Menge

Widget: dasselbe `GlassShape` + ebene Fläche, **ohne** Core Motion, **ohne** Strahl, Ringe oder Oberflächenbewegung. Zahl und Pegel aktualisieren sich statisch.

Dark Mode: dieselben Shapes, Surfaces kühles Anthrazit, Aqua etwas heller, Stroke lesbar. Kein separates Dark-Layout.

---

## 10. Explizit verboten

- `ProgressView` / lineare oder Kreis-Progress-Bar als Hauptstand  
- Fotorealistisches Wasser, Caustics, Partikel-Engine, SPH / Fluid-Solver  
- Idle-Sinus, `TimelineView(.animation)` nur fürs Wasser, Dauerkräuseln  
- Neigung über 16° oder ungedämpftes `gravity.x` (zittert)  
- Einzelner Symboltropfen als Metapher für eine ganze Trinkmenge  
- Mehrere Tropfen oder Partikel als „Regen“  
- Strahlbreite oder -dauer unabhängig von der Menge  
- Pegel-Spring oder Pegel-Overshoot während eines aktiven Strahls  
- SpriteKit, Metal, Lottie, Video  
- Extra-Tabs, Wolkenhintergrund, Motivations-Cards im Hero  

---

## 11. Abnahme

- [ ] Idle: ebene Fläche, **keine** Welle. Auf dem Tisch (Face-up) waagerecht  
- [ ] Gerät nach links/rechts kippen: Wasser läuft sichtbar diese Seite hoch, Mitte bleibt der Store-Pegel  
- [ ] Reduce Motion und Simulator: Fläche bleibt waagerecht  
- [ ] Idle: Zahl und Prozent im Glas lesbar  
- [ ] Strahl beginnt **sichtbar über** dem Glas (32 pt über dem Rim) und erreicht die Oberfläche in 0,14 s  
- [ ] +250 und +500 unterscheiden sich subtil in Strahlbreite, Fließdauer und Kontaktstärke  
- [ ] Pegel beginnt beim Kontakt zu steigen und folgt der echten Milliliterzahl, nicht der Strahlbreite  
- [ ] Während des Strahls: klare mittige Vertiefung und flache Schultern, kein Flattern  
- [ ] Danach laufen zwei Kämme sichtbar nach außen, reflektieren genau einmal schwächer und sind nach 0,90 s eben  
- [ ] Keine separaten Ellipsen und kein einzelner Tropfen im Today-Hero  
- [ ] Reduce Motion: kein Strahl, keine Oberflächenreaktion, Pegel-Crossfade in 0,2 s  
- [ ] Coalesce: ein durchgehender Strahl, ein Zielpegel, eine abschließende Reaktion  
- [ ] Widget und Komplikationen kommen ohne Strahl und Oberflächenbewegung aus

Grok Build implementiert nur diesen Vertrag plus `Ripple_PRD.md` für den Rest der App.
