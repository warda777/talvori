# Phase 2G-M13-B2: Early Island Onboarding Choice Visual Review

Stand: 2026-06-06

Status: `Review gestartet / Hybrid als erste Planungsrichtung brauchbar`

## 1. Zweck

Dieses Dokument prueft die M13-B-Previews visuell und inhaltlich. Ziel ist zu
entscheiden, ob der Hybrid-Onboarding-Choice-Ansatz als erste Planungsrichtung
brauchbar ist oder nachgebessert werden muss.

M13-B2 ist ein reiner Dokumentationsblock. Daraus folgen keine finale
Onboarding-UI, keine finale Startinsel, keine Onboarding-Implementierung, keine
ThemeIsland-Umsetzung, keine finale Datenstruktur, keine Runtime-Konfiguration,
keine App-/Assetfreigabe, kein Code, keine Spielassets und kein
`frame_started`.

## 2. Gepruefte Dateien

| Datei | Zweck |
| --- | --- |
| `docs/world_design/previews/phase2g_m13b_early_island_onboarding_choice/01_onboarding_choice_flow.png` | Reversibler Flow von Welcome ueber Tali/Vori-Erklaerung, Foundation-Wahl, Empfehlung, Bestaetigung und Safe Backlog. |
| `docs/world_design/previews/phase2g_m13b_early_island_onboarding_choice/02_foundation_choice_cards.png` | Vergleich der drei Foundation-Kandidaten Zuhause/Alltag, Schule/Lernen und Garten/Natur nah. |
| `docs/world_design/previews/phase2g_m13b_early_island_onboarding_choice/03_onboarding_variant_comparison.png` | Vergleich von Single recommended start, Three-card choice, Question-based routing, Starter test flow und Hybrid. |
| `docs/world_design/previews/phase2g_m13b_early_island_onboarding_choice/04_no_forced_start_guardrails.png` | Guardrails gegen Pflichtstart, Lock-in, Premium-Druck, automatische Platzierung und Umsetzung. |
| `docs/world_design/previews/phase2g_m13b_early_island_onboarding_choice/README.md` | Zweck, Dateien, Prueffazit, Grenzen und Nicht-Freigaben. |

## 3. Visuelle Bewertung

| Prueffrage | Bewertung |
| --- | --- |
| Ist der Onboarding Choice Flow verstaendlich? | Ja. Die Abfolge Welcome -> Tali/Vori -> Nutzerwahl -> Empfehlung -> Bestaetigung -> Safe Backlog ist klar. |
| Wird klar, dass die erste Wahl reversibel ist? | Ja. `Confirm or change later`, `Later change allowed` und `No hidden lock-in` machen die Reversibilitaet sichtbar. |
| Wird klar, dass die Wahl ein Lernfokus ist und keine finale Startinsel? | Ja. Die Karten sind als Kandidaten markiert und die Preview betont `not a final start island`. |
| Wird klar, dass Tali/Vori nur kurz erklaert und nicht draengt? | Ja. Tali/Vori ist als kurzer Erklaerschritt dargestellt, nicht als druckmachender Entscheider. |
| Sind die Foundation Choice Cards verstaendlich? | Ja. Vorteil, Risiko, Gate, Beispielwoerter und erste Container sind pro Kandidat gut lesbar. |
| Wird Zuhause/Alltag als Option dargestellt und nicht als Pflicht-Hausstart? | Ja. Die Karte markiert Zuhause als freiwillige Option und benennt das Pflicht-Hausstart-Risiko. |
| Wird Schule/Lernen ausreichend freundlich dargestellt oder wirkt es zu schulisch? | Ausreichend fuer Planung. Die Karte wirkt sachlich, aber nicht wie Arbeitsblatt. Emotionale Darstellung bleibt als spaeteres Gate sichtbar. |
| Wird Garten/Natur nah attraktiv, aber ohne manipulative Growth-/Timer-Versprechen dargestellt? | Ja. Growth ist als Metapher sichtbar, Timer/Fairness bleiben als Gate blockiert. |
| Ist der Variantenvergleich verstaendlich? | Ja. Matrix und Bewertungschips sind lesbar und fuer interne Planung brauchbar. |
| Ist die Empfehlung `Hybrid` visuell nachvollziehbar? | Ja. Hybrid kombiniert hohe Agency, Klarheit, Emotion und Mobile-Eignung mit begrenztem Scope. |
| Wird klar, dass `Single recommended start` riskanter ist? | Ja. `forced path` und niedrige Agency machen das Risiko sichtbar. |
| Wird klar, dass `Three-card choice` Agency gibt, aber einfach bleiben muss? | Ja. Hohe Agency und `choice load` sind nebeneinander sichtbar. |
| Wird klar, dass `Question-based routing` persoenlicher, aber komplexer ist? | Ja. Emotion ist hoch, UX-Komplexitaet bleibt markiert. |
| Wird klar, dass `Starter test flow` spaeter interessant, aber fuer den ersten Pass zu schwer ist? | Ja. Die Matrix zeigt hoehere Scope-Last und `upfront work`. |
| Sind die No-Forced-Start-Guardrails klar? | Ja. Die sechs Guardrail-Karten und der rote Block zeigen klare Grenzen. |
| Werden Pflicht-Hausstart, irreversible Erstwahl, Premium-Druck, automatische Platzierung und finale Umsetzung blockiert? | Ja. Alle Punkte sind sichtbar blockiert. |
| Bleiben alle Texte sauber innerhalb von Karten/Rahmen/Panels? | Ja. Die Texte bleiben innerhalb der Panels und wirken nicht abgeschnitten. |
| Suggerieren die Previews finale UI, Spielassets, finale Startinsel, Implementierung oder Assetfreigabe? | Nein. Der Stil bleibt Diagramm-/Planungsmaterial. |

## 4. Bewertung Nach Datei

### 4.1 `01_onboarding_choice_flow.png`

Der Flow ist als erster Onboarding-Choice-Ablauf gut verstaendlich. Er zeigt
einen ruhigen Einstieg, eine kurze Tali/Vori-Erklaerung, Nutzerwahl,
Empfehlung, reversible Bestaetigung und Safe Backlog. Besonders wichtig ist,
dass nicht passende Woerter nicht falsch platziert werden, sondern sicher in
Codex, Blueprint oder Backlog landen.

### 4.2 `02_foundation_choice_cards.png`

Die Karten trennen die drei Foundation-Kandidaten klar. Zuhause / Alltag wirkt
vertraut, aber nicht verpflichtend. Schule / Lernen bleibt als Lernfokus
nachvollziehbar, braucht aber spaeter eine emotionalere Darstellung und echte
Mobile-/Clutter-Pruefung. Garten / Natur nah wirkt freundlich und wachstumsnah,
ohne Timer oder Retention-Druck zu versprechen.

### 4.3 `03_onboarding_variant_comparison.png`

Der Variantenvergleich ist fuer interne Planung brauchbar. Die visuelle
Empfehlung fuer Hybrid ist nachvollziehbar, weil Hybrid die Vorteile von
kurzer Companion-Frage, Kartenwahl und Reversibilitaet kombiniert. Die Matrix
macht zugleich sichtbar, warum Single recommended start zu schnell wie ein
Pflichtpfad wirken kann und warum Starter test flow fuer den ersten Pass zu
aufwendig ist.

### 4.4 `04_no_forced_start_guardrails.png`

Die Guardrails sind klar und stark genug. Sie verhindern, dass M13-B als
Startinsel-Freigabe, Implementierungsfreigabe oder Premium-Onboarding gelesen
wird. Die rote Sperrzeile am Ende ist hilfreich, weil sie finale Startinsel,
Onboarding-Implementierung, Assets, Runtime-Konfiguration und `frame_started`
sichtbar blockiert.

### 4.5 `README.md`

Das README grenzt Zweck, Dateien und Nicht-Freigaben ausreichend ab. Es
bestaetigt den Hybrid-Ansatz nur als Planungsrichtung und verhindert, dass die
Previews als finale Onboarding-UI, Spielassets oder App-/Assetfreigabe gelesen
werden.

## 5. Entscheidungsempfehlung

Empfehlung: M13-B grundsaetzlich als erste Onboarding-Choice-
Planungsrichtung bestaetigen.

Hybrid wird als erste Planungsrichtung bestaetigt:

- kurze Tali/Vori-Frage,
- drei Foundation-Karten,
- Nutzer bestaetigt,
- Auswahl bleibt spaeter aenderbar,
- unpassende Woerter gehen sicher in Codex, Blueprint oder Backlog.

Diese Bestaetigung ist keine finale UI- oder Implementierungsfreigabe.

Nicht daraus ableiten:

- keine finale Onboarding-UI,
- keine finale Startinsel,
- keine Onboarding-Implementierung,
- keine ThemeIsland-Umsetzung,
- keine finale Datenstruktur,
- keine Runtime-Konfiguration,
- keine automatische Wortplatzierung,
- keine App-/Assetfreigabe,
- kein `frame_started`.

M13-C ThemeIsland Capability Sheets und M13-D Word-to-Island UX Flow bleiben
offen.

## 6. Bestaetigte Onboarding-Choice-Regeln

- Die erste Wahl ist ein persoenlicher Lernfokus, keine finale Startinsel.
- Die erste Wahl muss spaeter aenderbar bleiben.
- Zuhause / Alltag ist eine Option, kein Pflicht-Hausstart.
- Tali/Vori darf kurz erklaeren, aber nicht draengen.
- Die Auswahl zeigt nur wenige Foundation-Optionen, nicht die ganze Roadmap.
- Kein Premium- oder Paywall-Druck im Start-Onboarding.
- Keine automatische Wortplatzierung aus der Auswahl.
- Unpassende Woerter bleiben sicher in Codex, Blueprint oder Backlog.
- Garten / Growth braucht Fairness-/Timer-Regeln vor jeder Umsetzung.
- Foundation-Inseln brauchen spaeter echte Device-/Accessibility-/Tap-Target-
  Pruefung.

## 7. Sichtbare Risiken

- Hybrid koennte spaeter zu viel Copy enthalten, wenn die Karten nicht sehr
  knapp bleiben.
- Schule / Lernen braucht staerkere emotionale Produktwirkung, damit es nicht
  wie Pflichtschule wirkt.
- Zuhause / Alltag bleibt riskant, wenn spaeter doch ein Pflicht-Hausstart
  daraus gemacht wird.
- Garten / Natur nah braucht klare Fairness-/Timer-Regeln, bevor Wachstum als
  Mechanik geplant wird.
- Fragebasiertes Routing darf Nutzerziele nicht ueberinterpretieren.
- Reversibilitaet muss spaeter produktseitig sichtbar und einfach sein.
- Device-/Accessibility-/Tap-Target-Pruefung bleibt offen.

## 8. Offene Folgeblocks

Empfohlene naechste reine Planungs- oder Reviewblocks:

- `Phase 2G-M13-C ThemeIsland Capability Sheets`
- `Phase 2G-M13-D Word-to-Island UX Flow`
- `Phase 2G-M13-E Device And Accessibility Preview Plan`
- `Phase 2G-M13-F Container Pagination And Tap Target Rules`
- `Phase 2G-M13-H Growth And Timer Fairness Rules`

## 9. Stop-Regeln

Aus M13-B2 darf nicht abgeleitet werden:

- keine finale Onboarding-UI aus M13-B2,
- keine finale Startinsel aus M13-B2,
- keine Onboarding-Implementierung aus M13-B2,
- keine ThemeIsland-Umsetzung aus M13-B2,
- keine finale Datenstruktur aus M13-B2,
- keine Runtime-Konfiguration aus M13-B2,
- keine automatische Wortplatzierung aus M13-B2,
- keine Assets aus M13-B2,
- keine irreversible Erstwahl,
- kein Pflicht-Hausstart,
- kein Premium-/Paywall-Druck im Start-Onboarding,
- keine Garten-/Growth-Mechanik ohne Fairness-/Timer-Regeln,
- keine Foundation-Insel ohne echte Device-/Accessibility-/Tap-Target-
  Pruefung,
- keine App- oder Assetfreigabe aus M13-B/M13-B2,
- kein `frame_started` oder Bauzustand aus M13-B/M13-B2.

## 10. Naechster Erlaubter Schritt

Erlaubt ist nur:

- M13-B2 reviewen,
- M13-B/M13-B2 dokumentarisch nachbessern,
- M13-C ThemeIsland Capability Sheets als reinen Planungsblock starten,
- M13-D Word-to-Island UX Flow als reinen Planungsblock starten,
- Device-/Accessibility-/Tap-Target-Pruefung planen.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNG-Aenderungen,
- finale Onboarding-UI,
- finale Startinsel,
- ThemeIsland-Umsetzung,
- Runtime-Konfiguration,
- `frame_started`,
- Bauzustaende.
