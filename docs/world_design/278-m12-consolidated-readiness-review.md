# Phase 2G-M12-F: M12 Consolidated Readiness Review

Stand: 2026-06-06

Status: `konsolidierter Review gestartet / M12-Kette als Planungsgrundlage brauchbar`

## 1. Zweck

Dieses Dokument prueft die komplette M12-Planungskette zusammenfassend. Ziel
ist zu entscheiden, ob M12 bis M12-E2 als Grundlage fuer spaetere
World-/ThemeIsland-/Routing-/Plot-/Container-Planung brauchbar ist.

M12-F ist:

- reiner Dokumentationsblock,
- konsolidierter Readiness Review,
- keine finale Implementierungsfreigabe,
- keine finale Datenstruktur,
- keine Runtime-Konfiguration,
- keine App-Integration,
- keine ThemeIsland-Umsetzung,
- keine Assetfreigabe,
- keine Freigabe fuer `frame_started`.

## 2. Gepruefte M12-Kette

Gepruefte Dokumente:

- `docs/world_design/268-theme-island-prioritization.md`
- `docs/world_design/269-theme-island-prioritization-visual-review.md`
- `docs/world_design/270-word-to-island-routing-matrix.md`
- `docs/world_design/271-word-to-island-routing-visual-review.md`
- `docs/world_design/272-plot-capability-derivation.md`
- `docs/world_design/273-plot-capability-visual-review.md`
- `docs/world_design/274-sensitive-content-representation-rules.md`
- `docs/world_design/275-sensitive-content-visual-review.md`
- `docs/world_design/276-mobile-clutter-rules-small-objects.md`
- `docs/world_design/277-mobile-clutter-visual-review.md`

M12-F erzeugt keine neuen Preview-PNGs und veraendert keine bestehenden
Preview-Dateien.

## 3. ThemeIsland-Priorisierung

M12/M12-A2 bestaetigen eine erste Priorisierung als Planungsrichtung.

| Welle | Kandidaten | Readiness-Bewertung |
| --- | --- | --- |
| Early | Zuhause/Alltag, Schule/Lernen, Garten/Natur nah | Als erste Planungsrichtung sinnvoll, weil Wortschatz, Container-Flows und mobile Komplexitaet vergleichsweise kontrollierbar sind. |
| Mid | Kueste/Meer/Hafen, Essen/Restaurant/Cafe, Einkauf/Versorgung, Land/Farm | Stark fuer Motivation und Wortschatz, aber mit hoeherer System-, Clutter-, Water-, Food-, Market-, Farm- oder Mobile-Komplexitaet. |
| Late | Stadt, Verkehr, Arbeit, Technik | Brauchen Connector-/Path-/Vehicle-/Process-/Digital-Object-Regeln und duerfen nicht frueh alles ueberladen. |
| Special/Blocked | Gesundheit, Kultur/Gesellschaft/Verwaltung, Religion, Politik, Gericht, Polizei, Krankenhaus | Bleiben blockiert, bis Sensitive-Content-, Safety-, UX- und Darstellungsregeln tragfaehig sind. |

Bestaetigte Regel:

M12 gibt Orientierung, aber keine finale ThemeIsland-Roadmap und keine
ThemeIsland-Umsetzung frei.

## 4. Word-to-Island Routing

M12-B/M12-B2 bestaetigen Routing als Vorschlagslogik, nicht als
Platzierungsautomatik.

Bestaetigt:

- Routing macht Vorschlaege, keine Zwangsplatzierung.
- Sichtbare Platzierung braucht ThemeIsland, Depth-Ebene, Requirements,
  Kontext/Sense und Nutzerbestaetigung.
- Multi-home-Woerter wie `apple`, `bank` oder `drive` brauchen Satzkontext,
  Nutzerziel oder Sense-Auswahl.
- Verben bleiben Aktion, Sequenz, Dialog oder Quest und werden nicht als
  statisches Objekt erzwungen.
- Gebaeudeteile wie `window` brauchen passenden Gebaeudezustand, Blueprint
  oder Backlog.
- Sensible oder abstrakte Begriffe werden neutral geroutet.
- Codex, Blueprint, Backlog und Future Island Suggestion bleiben sichere
  Fallbacks.

Bestaetigte Regel:

Kein Word-to-Island-Routing darf automatische Wortplatzierung, finale
Datenstruktur oder Runtime-Implementierung ausloesen.

## 5. Plot-Capabilities

M12-C/M12-C2 bestaetigen Plot-Capabilities als Erlaubnisse.

Bestaetigt:

- `allowedFunctions` sind Erlaubnisse, keine Pflichtbelegung.
- `core_plot` bedeutet nicht automatisch `home`.
- `hub_capable_plot` bedeutet nicht automatisch `market`.
- Edge-Plots koennen Randfunktionen tragen, ohne diese automatisch zu bauen.
- Water, Farm, Travel, Vehicle, Digital und Sensitive bleiben gated.
- Early-Plots sollen wenige klare Funktionen tragen.
- Sichtbare Platzierung braucht weiterhin Routing, Requirements und
  Nutzerbestaetigung.

Bestaetigte Regel:

Plot-Capabilities duerfen nicht als finale Plot-Datenstruktur,
Runtime-Konfiguration, Plot-Implementierung oder Assetauftrag gelesen werden.

## 6. Sensitive Content

M12-D/M12-D2 bestaetigen erste neutrale Regeln fuer sensible, abstrakte und
gesellschaftlich heikle Inhalte.

Bestaetigt:

- Keine automatische Visualisierung sensibler Begriffe.
- Keine automatische Gebaeude-, Symbol- oder Assetproduktion fuer sensible
  Begriffe.
- Keine medizinische, juristische oder politische Beratung im Spielsystem.
- Keine Retention-Mechanik mit Angst, Krankheit, Tod, Schuld, Politik oder
  Religion.
- Keine Companion-Reaktion, die sensible Inhalte dramatisiert oder Druck
  erzeugt.
- Standardwege sind CodexEntry, ContextCard, CompanionDialog,
  QuestWithoutSymbol, NeutralBlueprint, BacklogOnly, RequiresUserChoice und
  BlockedUntilRules.
- Gesundheit, Krankenhaus, Polizei, Kirche, Krieg, Tod, Identitaet,
  Gerechtigkeit und Politik brauchen Kontext, Safety und spaetere eigene
  Regeln.

Bestaetigte Regel:

Sensitive Content bleibt ein Gate fuer ThemeIsland-, Plot-, Import-,
Retention-, Companion- und Asset-Entscheidungen.

## 7. Mobile And Clutter

M12-E/M12-E2 bestaetigen erste Regeln fuer kleine Objekte, Deko,
Container-Inhalte, Labels, Tap-Ziele und mobile Clutter-Grenzen.

Bestaetigt:

- `tinyObject` gehoert nicht dauerhaft in `IslandView`.
- Kleine Objekte werden auf die kleinste sinnvolle Depth-Ebene geroutet.
- Container sind Fokusraeume, keine Objektlisten.
- Container zeigen wenige Challenge-Objekte und nur eine aktive Challenge.
- Labels erscheinen nur bei Fokus, Challenge, Feedback oder
  Accessibility-Modus.
- Deko bleibt Hintergrund und darf Lernobjekte nicht verdecken.
- Clutter-Gefahr fuehrt zu Zoom, Container, DetailInteractionView, Codex,
  Blueprint oder Backlog.
- `sensitiveSmallObject` folgt zusaetzlich M12-D.

Bestaetigte Regel:

M12-E/E2 darf nicht als finale Mobile-UI, Runtime-Grenzwert,
Container-Implementierung oder Device-/Accessibility-Entscheidung gelesen
werden.

## 8. Was M12 Solide Geklaert Hat

M12 klaert als Planungsgrundlage:

- eine erste ThemeIsland-Reihenfolge,
- klare Trennung zwischen Orientierung und finaler Roadmap,
- Word-to-Island Routing als Vorschlagssystem,
- Multi-home- und Ambiguity-Regeln,
- Plot-Capabilities als Erlaubnisse statt Rollenlabels,
- Gates fuer Water/Farm/Travel/Vehicle/Digital/Sensitive,
- neutrale Behandlung sensibler Inhalte,
- mobile Clutter-Regeln fuer Kleinteile, Container, Labels und Deko,
- sichere Fallbacks ueber Codex, Blueprint, Backlog und Future Island
  Suggestion,
- dass keine einzelne M12-Schicht Implementierung oder Assetproduktion
  freigibt.

Readiness-Fazit:

Die M12-Kette ist als Grundlage fuer weitere reine Planung brauchbar. Sie ist
noch keine Produktions-, Code-, UI-, Runtime- oder Assetfreigabe.

## 9. Weiterhin Offene Punkte

Offen bleiben:

- finale ThemeIsland-Roadmap,
- konkrete Startwelt-/Onboarding-Entscheidung,
- ThemeIsland-spezifische Capabilities je Insel,
- echte Word-to-Island-Routing-UX,
- Datenmodell-/Schema-Design,
- Runtime-Konfiguration,
- Device-/Mobile-Previews,
- Accessibility-/Label-Modus,
- Container-Pagination,
- Tap-Target- und Fingerabstandsregeln,
- Fairness-/Timer-Regeln fuer Garten/Farm/Wachstum,
- Water-/Dock-/Travel-/Vehicle-Systeme,
- Digital-Object-/UI-Abgrenzung,
- Sensitive-Content Safety-/Privacy-/UX-Policy,
- Companion-Tonalitaet fuer sensible und kleine Objektkontexte,
- Import-Governance fuer private, sensible oder mehrdeutige Saetze,
- Asset-Priorisierung und Scope-Gates.

## 10. Kritische Risiken

Kritisch bleiben:

- M12 koennte faelschlich als finale Roadmap gelesen werden.
- Early ThemeIslands koennten zu frueh als umsetzungsbereit gelten.
- Routing koennte faelschlich automatische Platzierung ausloesen.
- Capabilities koennten wieder als feste Haus-/Markt-/Gartenrollen gelesen
  werden.
- Sensitive Themen koennten ohne Safety-Konzept visualisiert werden.
- Kleinteile koennten Mobile-Ansichten ueberfuellen.
- Clutter-Planungswerte koennten faelschlich als Runtime-Werte uebernommen
  werden.
- Container koennten zu Inventarlisten statt fokussierten Lernraeumen werden.
- Device-, Accessibility- und Tap-Target-Fragen sind noch nicht real geprueft.

## 11. Sinnvolle Naechste Reine Planungsbloecke

Sinnvoll waeren:

- `Phase 2G-M13 ThemeIsland Roadmap Draft`
- `Phase 2G-M13-B Early Island Onboarding Choice Review`
- `Phase 2G-M13-C ThemeIsland Capability Sheets`
- `Phase 2G-M13-D Word-to-Island UX Flow`
- `Phase 2G-M13-E Device And Accessibility Preview Plan`
- `Phase 2G-M13-F Container Pagination And Tap Target Rules`
- `Phase 2G-M13-G Sensitive Content Policy Deepening`
- `Phase 2G-M13-H Growth And Timer Fairness Rules`
- `Phase 2G-M13-I Asset Prioritization Scope Gate`

Diese Folgeblocks bleiben reine Planung, solange keine eigene Freigabe fuer
Code, Assets, Datenstruktur oder Runtime-Konfiguration erteilt wird.

## 12. Entscheidungsempfehlung

Empfehlung:

M12 bis M12-E2 als konsolidierte Planungsgrundlage bestaetigen.

Nicht bestaetigen:

- keine finale ThemeIsland-Roadmap,
- keine ThemeIsland-Umsetzung,
- keine finale Routing-Implementierung,
- keine finale Datenstruktur,
- keine Runtime-Konfiguration,
- keine Plot-Implementierung,
- keine Container-Implementierung,
- keine finale Mobile-UI,
- keine Safety-/Moderations-Implementierung,
- keine App-Integration,
- keine Assetfreigabe,
- kein `frame_started`.

## 13. Stop-Regeln

Stoppen, wenn:

- aus M12-F eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M12-F eine Implementierungsfreigabe abgeleitet wird,
- aus M12-F eine finale Datenstruktur abgeleitet wird,
- aus M12-F Runtime-Konfiguration abgeleitet wird,
- aus M12-F automatische Wortplatzierung abgeleitet wird,
- aus M12-F eine ThemeIsland-Umsetzung abgeleitet wird,
- aus M12-F eine Plot- oder Container-Implementierung abgeleitet wird,
- aus M12-F eine finale Mobile-UI abgeleitet wird,
- aus M12-F eine Safety-/Moderations-Implementierung abgeleitet wird,
- aus M12-F App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M12-F weitergebaut werden.

## 14. Naechster Erlaubter Schritt

Erlaubt:

- M12-F reviewen,
- M12-F bei Bedarf nachbessern,
- einen der M13-Folgeblocks als reinen Planungsblock starten.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests aendern,
- Spielassets,
- PNG-Erzeugung oder PNG-Aenderung,
- finale Datenstruktur,
- Runtime-Konfiguration,
- ThemeIsland-Umsetzung,
- automatische Wortplatzierung,
- Container-Implementierung,
- Assetfreigabe,
- `frame_started`,
- Bauzustaende weiterbauen,
- Commit ohne ausdrueckliche Freigabe.
