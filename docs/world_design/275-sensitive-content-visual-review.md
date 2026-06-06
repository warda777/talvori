# Phase 2G-M12-D2: Sensitive Content Visual Review

Stand: 2026-06-06

Status: `visuelle Pruefung gestartet / erste Sensitive-Content-Richtung brauchbar`

## 1. Zweck

Dieses Dokument prueft die M12-D-Previews visuell und inhaltlich. Ziel ist zu
entscheiden, ob die Sensitive Content Representation Rules als erste
Planungsrichtung brauchbar sind oder nachgebessert werden muessen.

M12-D2 ist:

- reiner Dokumentationsblock,
- visuelle und inhaltliche Pruefung von Planungs-Previews,
- keine finale Safety-Implementierung,
- keine Moderations-Implementierung,
- keine finale Datenstruktur,
- keine App-Integration,
- keine ThemeIsland-Umsetzung,
- keine Assetfreigabe,
- keine Freigabe fuer `frame_started`.

## 2. Gepruefte Dateien

- `docs/world_design/previews/phase2g_m12d_sensitive_content_rules/01_sensitive_content_decision_pipeline.png`
- `docs/world_design/previews/phase2g_m12d_sensitive_content_rules/02_sensitive_category_matrix.png`
- `docs/world_design/previews/phase2g_m12d_sensitive_content_rules/03_safe_representation_examples.png`
- `docs/world_design/previews/phase2g_m12d_sensitive_content_rules/04_blocked_until_rules_map.png`
- `docs/world_design/previews/phase2g_m12d_sensitive_content_rules/README.md`

## 3. Visuelle Bewertung

| Prueffrage | Bewertung | Notiz |
| --- | --- | --- |
| Ist die Sensitive Content Decision Pipeline verstaendlich? | Ja | Word Intake, Sensitivity Check, Context/Sense, Safe Representation, User Choice und Safe Result sind klar angeordnet. |
| Wird klar, dass sensible Begriffe zuerst neutral geroutet werden? | Ja | Der Untertitel und die Safe-Representation-Stufe zeigen neutrale Wege vor sichtbarer Platzierung. |
| Wird klar, dass Unsicherheit keine sichtbare Platzierung erzeugt? | Ja | Das zentrale Stop-Gate sagt explizit: uncertainty means no visible placement. |
| Werden Nutzerkontext, Satzkontext und Sense-Auswahl sichtbar? | Ja | Context/Sense und User Choice sind eigene Schritte; die User-controlled Lane ergaenzt Sense Selection und Confirmation. |
| Ist die Sensitive Category Matrix lesbar? | Ja, fuer interne Planung | Die Matrix ist dicht, aber Spalten, Status-Pills und Kategorien bleiben erkennbar. |
| Ist die Matrix zu technisch? | Technisch, aber brauchbar | Sie eignet sich fuer interne Planung, nicht fuer Nutzer-UX. |
| Werden sichere Wege klar genug gezeigt? | Ja | CodexEntry, ContextCard, CompanionDialog, BacklogOnly und RequiresUserChoice sind in Matrix und Blocked-Map sichtbar. |
| Werden blockierte Wege klar genug gezeigt? | Ja | Auto Building, Auto Symbol, Asset Production und Reward Pressure sind in der Blocked-Map eindeutig blockiert. |
| Sind die Beispielkarten verstaendlich? | Ja | `health`, `hospital`, `justice`, `police`, `church`, `fear`, `war` und `death` zeigen sichere Wege und Blocker. |
| Wird klar, dass schwierige Begriffe kein Reward/Deko/Streak-Druck sind? | Ja | Beispielkarten und Shared Rule blockieren Reward Pressure, Deko-Logik und Retention Hook. |
| Wird klar, dass sensible Institutionen keine automatische Assetfreigabe bekommen? | Ja | `hospital`, `police`, `church` und die Blocked-Map verhindern Auto Building, Auto Symbol und Asset Production. |
| Bleiben Texte innerhalb von Karten/Rahmen/Panels? | Ja, mit dichter Matrix-Legende | Hauptinhalte bleiben sauber in ihren Panels. Die Matrix-Legende ist knapp, aber nicht blockierend. |
| Suggerieren die Previews finale UI, Spielassets oder Implementierung? | Nein | README und Footer markieren klar: keine finale UI, keine Safety-/Moderations-Implementierung, keine App-/Assetfreigabe. |

## 4. Bewertung Nach Datei

### `01_sensitive_content_decision_pipeline.png`

Die Pipeline ist klar und gut als Gate lesbar. Besonders wichtig ist die
Trennung zwischen automatischer Analyse, Context/Sense-Pruefung,
Nutzerentscheidung und sicherem Ergebnis. Das zentrale Stop-Gate verhindert,
dass Unsicherheit zu sichtbarer Platzierung fuehrt.

Bewertung: brauchbar.

Risiko: Fuer Nutzer waere die Pipeline zu technisch; fuer interne Planung ist
sie passend.

### `02_sensitive_category_matrix.png`

Die Matrix deckt die wichtigsten Kategorien und Darstellungsarten ab. Codex,
Context, Companion, Backlog, User Choice und Blocked Rules sind gut
unterscheidbar. Die Matrix ist dicht und die Legende unten ist knapp, aber die
Hauptaussage bleibt lesbar.

Bewertung: brauchbar fuer interne Planung.

Risiko: Diese Matrix darf nicht als finale Safety-Policy, Moderationslogik oder
Datenstruktur gelesen werden.

### `03_safe_representation_examples.png`

Die Beispielkarten sind verstaendlich. `health`, `fear`, `war` und `death`
werden nicht als Reward, Deko oder Streak-Druck dargestellt. `hospital`,
`police` und `church` werden als blockiert oder context-/user-choice-pflichtig
behandelt.

Bewertung: brauchbar.

Risiko: Spaeter braucht es mehr Beispiele fuer Politik, Gericht, Identitaet,
Koerper, Katastrophen und medizinische Objekte.

### `04_blocked_until_rules_map.png`

Die Karte trennt erlaubt, blockiert und spaeter mit eigenen Regeln sehr klar.
Allowed Neutral, Blocked Now und Later With Own Rules sind fuer interne
Freigabe-Gates gut geeignet.

Bewertung: brauchbar.

Risiko: `Later with own rules` darf nicht als stille Freigabe gelesen werden.
Es meint spaetere eigene Safety-/UX-/Privacy-Pruefung.

## 5. Entscheidungsempfehlung

Empfehlung:

M12-D als erste Sensitive-Content-Planungsrichtung grundsaetzlich bestaetigen.

Begruendung:

- Die Pipeline macht den sicheren Entscheidungsweg sichtbar.
- Die Matrix ist fuer interne Planung ausreichend lesbar.
- Beispielkarten zeigen sensible Woerter ohne automatische Visualisierung.
- Die Blocked-Map verhindert automatische Gebaeude, Symbole, Assets, Rewards
  und Beratungslogik.
- Die Previews markieren ihre Grenzen klar.

Nicht ableiten:

- keine finale Safety-Implementierung,
- keine Moderations-Implementierung,
- keine finale Datenstruktur,
- keine automatische Visualisierung,
- keine sensible ThemeIsland-Umsetzung,
- keine Gebaeude-, Symbol- oder Assetproduktion,
- keine App-Integration,
- keine Assetfreigabe,
- kein `frame_started`.

## 6. Bestaetigte Sensitive-Content-Regeln

M12-D2 bestaetigt als erste Planungsrichtung:

- Sensible Begriffe werden zuerst neutral geroutet.
- Unsicherheit fuehrt zu Codex, ContextCard, Backlog, NeutralBlueprint,
  RequiresUserChoice oder BlockedUntilRules.
- Sichtbare Platzierung sensibler Begriffe ist kein automatischer Fallback.
- Gesundheit, Angst, Tod, Krieg, Krankheit und Krise duerfen nicht als Reward,
  Deko oder Streak-Druck verwendet werden.
- Krankenhaus, Polizei, Kirche, Politik, Gericht und Verwaltung erhalten keine
  automatische Gebaeude-, Symbol- oder Assetfreigabe.
- Tali/Vori darf sensible Inhalte sanft erklaeren, aber nicht dramatisieren,
  beraten, Druck erzeugen oder Schuldgefuehl ausloesen.
- Medizinische, juristische und politische Beratung bleibt ausgeschlossen.
- Sensitive ThemeIslands bleiben blockiert, bis eigene Safety-/UX-Regeln
  existieren.

## 7. Sichtbare Risiken

- Die Matrix ist intern brauchbar, aber keine Nutzeransicht.
- Die Matrix-Legende ist dicht; spaetere Previews sollten mehr Raum fuer
  Legenden einplanen.
- Politik, Gericht, Identitaet, Koerper, Katastrophen und medizinische Objekte
  brauchen spaeter mehr Beispielkarten.
- Companion-Formulierungen fuer sensible Themen brauchen eigene
  Tonalitaetspruefung.
- Importierte sensible Saetze brauchen eigene Privacy-/Kontextregeln.
- Familien-/Altersmodus bleibt offen.
- M12-D ist keine vollstaendige Safety-Policy.

## 8. Weiterhin Offene Folgeblocks

Weiterhin offen:

- `Phase 2G-M12-E Mobile And Clutter Rules For Small Objects`

Zusaetzlich spaeter sinnvoll:

- neutrale ContextCard-Preview fuer sensible Begriffe,
- Companion-Textregeln fuer sensible Themen,
- Privacy-/Import-Regeln fuer sensible Satzkontexte,
- Safety-/UX-Konzept fuer Gesundheits-, Politik-, Rechts-,
  Religions- und Identitaetsthemen,
- Visual Review fuer sensible ThemeIsland-Blocker, bevor solche Inseln
  ueberhaupt geplant werden.

## 9. Stop-Regeln

Stoppen, wenn:

- aus M12-D2 eine finale Sensitive-Content-Implementierung abgeleitet wird,
- aus M12-D2 eine Moderations-Implementierung abgeleitet wird,
- aus M12-D2 automatische Visualisierung sensibler Begriffe abgeleitet wird,
- aus M12-D2 eine sensible ThemeIsland-Umsetzung abgeleitet wird,
- Gebaeude, Symbole oder Assets fuer sensible Begriffe aus M12-D2 abgeleitet
  werden,
- medizinische, juristische oder politische Beratung im Spielsystem geplant
  wird,
- Retention-Mechaniken mit Angst, Krankheit, Tod, Schuld, Politik oder
  Religion geplant werden,
- Companion-Reaktionen sensible Inhalte dramatisieren oder Druck erzeugen,
- aus M12-D oder M12-D2 App-, Code- oder Assetfreigabe abgeleitet wird.

## 10. Naechster Erlaubter Schritt

Erlaubt:

- M12-D2 reviewen,
- M12-D/M12-D2 bei Bedarf nachbessern,
- M12-E Mobile And Clutter Rules planen.

Weiterhin nicht erlaubt:

- Code,
- App-Integration,
- Tests aendern,
- Spielassets,
- PNG-Aenderungen,
- finale Safety-Implementierung,
- Moderations-Implementierung,
- finale Datenstruktur,
- automatische Visualisierung sensibler Begriffe,
- sensible ThemeIsland-Umsetzung,
- Assetfreigabe,
- `frame_started`.
