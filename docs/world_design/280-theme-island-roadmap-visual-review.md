# Phase 2G-M13-A2: ThemeIsland Roadmap Visual Review

Stand: 2026-06-06

Status: `Review gestartet / erster Roadmap-Draft brauchbar`

## 1. Zweck

Dieses Dokument prueft die M13-Previews visuell und inhaltlich. Ziel ist nicht,
eine finale ThemeIsland-Roadmap festzulegen, sondern zu klaeren, ob der
Roadmap-Draft als erste Planungsrichtung brauchbar ist.

M13-A2 ist ein reiner Dokumentationsblock. Daraus folgen keine finale
Startinsel, keine ThemeIsland-Umsetzung, keine Implementierungsfreigabe, keine
finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe,
kein Code, keine Spielassets und kein `frame_started`.

## 2. Gepruefte Dateien

Geprueft wurden:

| Datei | Zweck |
| --- | --- |
| `docs/world_design/previews/phase2g_m13_theme_island_roadmap_draft/01_theme_island_roadmap_waves.png` | Roadmap-Wellen fuer Foundation, Expansion 1, Expansion 2, System-Heavy und Sensitive/Special. |
| `docs/world_design/previews/phase2g_m13_theme_island_roadmap_draft/02_early_island_candidate_cards.png` | Early-Kandidatenkarten fuer Zuhause/Alltag, Schule/Lernen und Garten/Natur nah. |
| `docs/world_design/previews/phase2g_m13_theme_island_roadmap_draft/03_roadmap_gate_flow.png` | Gate-Flow von M12-Grundlage ueber M13-Draft zu spaeterer Entscheidung. |
| `docs/world_design/previews/phase2g_m13_theme_island_roadmap_draft/04_risk_and_scope_map.png` | Risiko- und Scope-Einordnung der Roadmap-Wellen. |
| `docs/world_design/previews/phase2g_m13_theme_island_roadmap_draft/README.md` | Zweck, Grenzen und Preview-Kontext. |

## 3. Visuelle Bewertung

| Prueffrage | Bewertung |
| --- | --- |
| Sind die Roadmap-Wellen verstaendlich? | Ja. Foundation, Expansion Wave 1, Expansion Wave 2, System-Heavy Wave und Sensitive/Special Wave sind klar getrennt. |
| Wird klar, dass M13 nur ein Draft ist? | Ja. Die Previews und der Gate-Flow markieren M13 als Planungsstand ohne finale Freigabe. |
| Wird klar, dass Foundation nicht automatisch die finale Startinsel entscheidet? | Ja. Foundation wird als Kandidatenraum dargestellt, nicht als festgelegte Startinsel. |
| Sind Zuhause/Alltag, Schule/Lernen und Garten/Natur nah als Foundation-Kandidaten nachvollziehbar? | Ja. Die drei Kandidaten haben einfache Alltagsvokabeln, klare Container-Flows und geringe Systemkomplexitaet. |
| Wird klar, warum Essen/Restaurant/Cafe, Einkauf/Versorgung und Land/Farm in Expansion Wave 1 liegen? | Ja. Sie sind motivierend und wortschatzstark, brauchen aber mehr Service-, Objekt- und ggf. Produktionsregeln als Foundation. |
| Wird klar, warum Kueste/Meer/Hafen, Natur/Berge/Outdoor und Freizeit/Sport in Expansion Wave 2 liegen? | Ja. Die Welle zeigt hoeheres Motivationspotenzial, aber auch mehr Water-, Activity-, Mobile- und Scope-Risiken. |
| Wird klar, warum Stadt/Dorfzentrum, Reisen/Verkehr, Arbeit/Werkstatt und Technik/Digital als System-Heavy spaeter kommen? | Ja. Die Darstellung macht Connector-, Vehicle-, Process- und Digital-Systembedarf sichtbar. |
| Wird klar, warum Gesundheit, Kultur/Gesellschaft/Verwaltung, Religion, Politik, Gericht, Polizei und Krankenhaus Sensitive/Special bleiben? | Ja. Diese Themen bleiben sichtbar an vertiefte Safety-, UX- und Policy-Regeln gebunden. |
| Sind die Early Candidate Cards verstaendlich? | Ja. Zonen, Container, Beispielwoerter, Risiken und Gates sind kompakt lesbar. |
| Wird klar, dass Zuhause nicht als Pflicht-Hausstart erzwungen werden darf? | Ja. Zuhause/Alltag ist nur ein Foundation-Kandidat und bleibt an Onboarding-Choice gebunden. |
| Wird klar, dass Schule Mobile-/Clutter-Pruefung braucht? | Ja. Kleinteile und Federmappe werden als Mobile-/Clutter-Risiko markiert. |
| Wird klar, dass Garten Growth-/Timer-Fairness braucht? | Ja. Wachstum, Timer und Fairness sind als eigene Gates sichtbar. |
| Ist der Roadmap Gate Flow verstaendlich? | Ja. M12-Grundlage, M13-Draft, Gates und spaetere Implementierungsentscheidung sind sauber getrennt. |
| Wird klar, dass M13 keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe und keinen Code erlaubt? | Ja. Der Gate-Flow und README grenzen diese Punkte explizit ab. |
| Ist die Risk And Scope Map verstaendlich? | Ja. Sie zeigt, warum nicht alle Themen frueh kommen duerfen. |
| Bleiben alle Texte sauber innerhalb von Karten/Rahmen/Panels? | Ja. Die Texte bleiben lesbar und innerhalb der Panels. Einzelne lange Foundation-Bezeichnungen wirken dicht, aber nicht blockierend. |
| Suggerieren die Previews finale UI, Spielassets, finale Roadmap oder Umsetzung? | Nein. Der Stil bleibt Diagramm-/Planungsmaterial. |

## 4. Bewertung Nach Datei

### 4.1 `01_theme_island_roadmap_waves.png`

Die Roadmap-Wellen sind klar lesbar. Die Foundation-Welle wirkt bewusst klein
und kontrolliert, waehrend Expansion, System-Heavy und Sensitive/Special als
spaetere oder staerker gegatete Bereiche erkennbar bleiben. Die Darstellung ist
als Planungsuebersicht brauchbar.

Nicht blockierend: Der Foundation-Titel ist etwas dicht gesetzt, bleibt aber
innerhalb der Karte und ist weiterhin lesbar.

### 4.2 `02_early_island_candidate_cards.png`

Die Karten fuer Zuhause/Alltag, Schule/Lernen und Garten/Natur nah machen gut
sichtbar, warum diese Kandidaten frueh pruefbar sind. Gleichzeitig zeigen sie
die entscheidenden Grenzen: Zuhause darf nicht als Pflichtstart erzwungen
werden, Schule braucht Mobile-/Clutter-Regeln, und Garten braucht
Growth-/Timer-Fairness.

### 4.3 `03_roadmap_gate_flow.png`

Der Gate-Flow ist die wichtigste Freigabe-Sicherung. Er zeigt klar, dass M13 nur
von M12-Grundlagen zu einem Draft fuehrt und erst spaetere Gates eine
Implementierungsentscheidung vorbereiten duerfen. Code, Assets, finale Roadmap,
Runtime-Konfiguration und automatische Wortplatzierung bleiben ausgeschlossen.

### 4.4 `04_risk_and_scope_map.png`

Die Risk And Scope Map ordnet die Wellen verstaendlich nach Risiko und
Systemaufwand. Besonders hilfreich ist die klare Abgrenzung von System-Heavy
und Sensitive/Special. Die Map ist bewusst vereinfacht und fuer interne Planung
brauchbar, aber keine quantitative Risikoanalyse.

### 4.5 `README.md`

Das README beschreibt Zweck, Dateien und Grenzen ausreichend klar. Es stuetzt
die Interpretation als Dokumentations-/Previewmaterial und verhindert, dass die
Previews als finale UI, Spielassets oder Roadmap-Freigabe gelesen werden.

## 5. Entscheidungsempfehlung

Empfehlung: M13 als ersten ThemeIsland Roadmap Draft grundsaetzlich
bestaetigen.

Diese Bestaetigung gilt nur fuer die Planungsrichtung:

- Die Roadmap-Wellen sind verstaendlich.
- Die Early-Kandidaten sind nachvollziehbar.
- Die wichtigsten Risiken und Gates sind sichtbar.
- Die Previews sind als internes Produkt-/Planungsverstaendnis brauchbar.

Nicht daraus ableiten:

- keine finale ThemeIsland-Roadmap,
- keine finale Startinsel,
- keine ThemeIsland-Umsetzung,
- keine Implementierungsfreigabe,
- keine finale Datenstruktur,
- keine Runtime-Konfiguration,
- keine automatische Wortplatzierung,
- keine App-/Assetfreigabe,
- kein `frame_started`.

Naechster sinnvoller reiner Planungsblock: `Phase 2G-M13-B Early Island
Onboarding Choice Review`.

## 6. Bestaetigte Roadmap-Wellen

| Welle | Bestaetigte Kandidaten im Draft | Bewertung |
| --- | --- | --- |
| Foundation / Starter Learning World | Zuhause/Alltag, Schule/Lernen, Garten/Natur nah | Frueh pruefbar, aber nicht als finale Startinsel festgelegt. |
| Expansion Wave 1 | Essen/Restaurant/Cafe, Einkauf/Versorgung, Land/Farm | Gute zweite Welle mit mehr Wortschatz und Motivation, aber zusaetzlichen Objekt-, Service- und Fairness-Gates. |
| Expansion Wave 2 | Kueste/Meer/Hafen, Natur/Berge/Outdoor, Freizeit/Sport | Attraktiv und thematisch stark, aber komplexer durch Water-, Activity-, Mobile- und Scope-Fragen. |
| System-Heavy Wave | Stadt/Dorfzentrum, Reisen/Verkehr, Arbeit/Werkstatt, Technik/Digital | Spaeter, weil Connector-, Vehicle-, Process- und Digital-Systeme eigene Konzepte brauchen. |
| Sensitive / Special Wave | Gesundheit, Kultur/Gesellschaft/Verwaltung, Religion, Politik, Gericht, Polizei, Krankenhaus | Blockiert bis vertiefte Safety-, UX-, Policy- und Darstellungsregeln vorliegen. |

## 7. Sichtbare Risiken

- Der Roadmap-Draft koennte faelschlich als finale Roadmap gelesen werden.
- Foundation koennte faelschlich als finale Startinsel verstanden werden.
- Zuhause/Alltag koennte faelschlich einen Pflicht-Hausstart erzwingen.
- Schule/Lernen hat hohes Kleinteile-, Label- und Tap-Target-Risiko.
- Garten/Natur nah braucht klare Growth-/Timer-/Fairness-Regeln.
- Kueste/Meer/Hafen braucht Water-, Dock- und Mobile-Komplexitaetspruefung.
- Stadt, Reisen/Verkehr, Arbeit und Technik brauchen eigene Systemkonzepte.
- Sensitive/Special-Themen duerfen ohne vertiefte Safety-/UX-/Policy-Regeln
  nicht als Insel, Gebaeude, Symbol oder Asset geplant werden.
- Die Previews sind interne Planungsbilder und keine finale Produkt-UI.

## 8. Offene Folgeblocks

Empfohlene naechste reine Planungs- oder Reviewblocks:

- `Phase 2G-M13-B Early Island Onboarding Choice Review`
- `Phase 2G-M13-C ThemeIsland Capability Sheets`
- `Phase 2G-M13-D Word-to-Island UX Flow`
- `Phase 2G-M13-E Device And Accessibility Preview Plan`
- `Phase 2G-M13-F Container Pagination And Tap Target Rules`
- `Phase 2G-M13-G Sensitive Content Policy Deepening`
- `Phase 2G-M13-H Growth And Timer Fairness Rules`
- `Phase 2G-M13-I Asset Prioritization Scope Gate`

## 9. Stop-Regeln

Aus M13-A2 darf nicht abgeleitet werden:

- keine finale ThemeIsland-Roadmap aus M13-A2,
- keine finale Startinsel aus M13-A2,
- keine Implementierungsfreigabe aus M13-A2,
- keine finale Datenstruktur aus M13-A2,
- keine Runtime-Konfiguration aus M13-A2,
- keine automatische Wortplatzierung aus M13-A2,
- keine ThemeIsland-Umsetzung aus M13-A2,
- keine Assets aus M13-A2,
- keine Foundation-Insel ohne M13-B Onboarding Choice Review,
- keine Foundation-Insel ohne Device-/Accessibility-/Tap-Target-Pruefung,
- keine Garten-/Farm-Wachstumslogik ohne Fairness-/Timer-Regeln,
- keine Kuesten-/Hafeninsel ohne Water-/Dock-/Mobile-Komplexitaetspruefung,
- keine Stadt-/Verkehr-/Technikinsel ohne eigenes Systemkonzept,
- keine Sensitive-/Special-Insel ohne vertiefte Safety-/UX-/Policy-Regeln,
- keine App- oder Assetfreigabe aus M13/M13-A2,
- kein `frame_started` oder Bauzustand aus M13/M13-A2.

## 10. Naechster Erlaubter Schritt

Erlaubt ist nur:

- M13-A2 reviewen,
- M13/M13-A2 dokumentarisch nachbessern,
- M13-B als reinen Onboarding-Choice-Planungsblock starten,
- weitere reine ThemeIsland-/Routing-/Accessibility-/Safety-Planungsbloecke
  starten.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- neue oder veraenderte PNGs,
- finale ThemeIsland-Roadmap,
- finale Startinsel,
- `frame_started`,
- Bauzustaende.
