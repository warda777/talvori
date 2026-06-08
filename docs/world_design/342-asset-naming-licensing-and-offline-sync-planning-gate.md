# M16-AH: Asset Naming, Licensing And Offline Sync Planning Gate

Stand: 2026-06-08

Status: `Dokumentations-/Visual-Slice gestartet / keine Implementierung`

## 1. Zweck und Non-Goals

M16-AH schliesst die letzten offenen normalen M16-T-Items fuer Asset-
Lizenz-/Quelle-/Benennung-Regeln und Offline-/Sync-Konfliktregeln. Der Slice
bereitet keine Asset-Pipeline und keine Sync-Implementierung vor. Er definiert
nur, welche Regeln spaeter vor echten Asset- oder Daten-/Sync-Slices gelesen
und eingehalten werden muessen.

Non-Goals:

- keine Implementierung,
- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine Tests oder Widget-Tests,
- keine Screenshots als Repo-Artefakte,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- kein Build-Wheel-Code,
- keine Assets oder Asset-Dateien unter `assets/`,
- kein Build-State,
- kein `frame_started`,
- keine Bauzustaende,
- keine echte Asset-Pipeline,
- keine Sync-Implementierung.

## 2. Gepruefte Grundlage

| Dokument | Bedeutung fuer M16-AH |
| --- | --- |
| `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-ID-, Dashboard- und Gate-Liste. |
| `docs/world_design/336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere- und Output-Regeln fuer Asset-, Data- und Visual-Slices. |
| `docs/world_design/341-broad-learning-game-benchmark-research-gate.md` | Research-/Metrics-/Social-Gates bleiben ohne Runtime-Freigabe. |
| `docs/world_design/339-theme-island-resizing-and-remaining-world-rules-gate.md` | Sensitive-safe Asset-Regeln, TinyObject-Container-Regeln und Resizing-Stop-Regeln. |
| `docs/world_design/338-world-loop-plot-family-and-buildchoice-gate.md` | BuildChoice bleibt Candidate/Preview, nicht Asset, Placement, Persistenz oder BuildState. |
| `docs/world_design/337-mobile-density-accessibility-and-depth-planning-gate.md` | Mobile-/Clutter- und Container-/Depth-Regeln fuer spaetere Asset- und Sync-Entscheidungen. |
| `docs/world_design/335-learning-states-and-srs-boundary-gate.md` | Lernzustaende, SRS und `word_progress` bleiben strikt von Sync-/UI-Entscheidungen getrennt. |
| `docs/world_design/333-minimal-semantic-profile-and-routing-priority-gate.md` | Safety, Sense, Word Type, Clutter und Confidence stehen vor World/Asset/Reward. |
| `docs/world_design/334-companion-and-sensitive-return-safety-gate.md` | Sensitive Inhalte duerfen nicht dramatisiert, belohnt oder als Retention-Trigger genutzt werden. |
| `docs/world_design/326-scalable-word-semantics-architecture-plan.md` | 20.000+ Woerter brauchen Profile, Queues und Fallbacks statt 20.000 sichtbare Objekte. |
| `docs/world_design/327-talvori-learning-game-logic-readiness-review.md` | Produktive Systeme brauchen eigene Datenmodell-, Persistenz-, Asset- und App-Gates. |
| `docs/world_design/289-asset-prioritization-scope-gate.md` | Assetproduktion folgt geprueften Produktentscheidungen, nie Taxonomy-Fuelle. |
| `assets/images/world/buildable_islands/forest_clearing/template.md` | Waldlichtung bleibt Starter-/Testform ohne neue Asset-/Appfreigabe und ohne `frame_started`. |

## 3. Betroffene M16-T-IDs

| ID | M16-AH Entscheidung | Grund |
| --- | --- | --- |
| `M16T-ASSET-004` | `[x]` | Lizenz-, Quellen-, Benennungs- und Review-Regeln fuer spaetere Asset-Slices sind als Planung dokumentiert. |
| `M16T-DATA-004` | `[x]` | Offline-/Sync-Konflikttypen und sichere Konfliktaufloesung fuer lokale und remote Entscheidungen sind fachlich dokumentiert. |

Diese Entscheidungen geben keine Asset-Dateien, keine Persistenz und keine
Sync-Implementierung frei.

## 4. Asset-Lizenz-/Quelle-/Benennung-Regeln

Pflichtregeln fuer spaetere Asset-Slices:

- Keine Assets ohne eigenes Asset-Gate.
- Keine automatische Asset-Ableitung aus Wort, Semantik, Plot, Capability,
  Word Outcome, BuildChoice, Review Queue, Reward oder ThemeIsland.
- Jede spaetere Asset-Datei braucht Quelle, Lizenzstatus, Zweck, Scope und
  Review.
- Ein Asset darf keine fehlende UX-, Safety-, Mobile-, Persistence- oder
  Build-Entscheidung ersetzen.
- Sensitive-safe Asset-Regeln bleiben Pflicht: sensitive Inhalte erzeugen
  keine Deko, keinen Reward, keine Symbolpflicht und keine dramatisierende
  Visualisierung.
- Keine fremden oder unklar lizenzierten Bilder.
- Keine Screenshots als Asset-Ersatz.
- `frame_started` und weitere Bauzustaende bleiben blockiert, bis ein eigenes
  Build-State-/Asset-Gate sie ausdruecklich freigibt.

### 4.1 Asset-Artefakt-Typen

| Typ | Ort | Zweck | Darf als Spielasset gelten? | Gate |
| --- | --- | --- | --- | --- |
| Dokumentationsvisual | `docs/world_design/previews/` | Regeln, Flows, Reviews, Entscheidungsmodelle erklaeren. | Nein | Dokumentations-/Visual-QA-Regel |
| Preview-Diagramm | `docs/world_design/previews/` | Planung visualisieren, keine App-UI. | Nein | Visual-Slice |
| Placeholder | spaeter nur nach Gate | Technische oder visuelle Platzhalter pruefen. | Nein, bis Asset-Gate | Placeholder-/Asset-Gate |
| Prototyp-Asset | spaeter nur nach Gate | Eng begrenzte lokale Prototype-Visualisierung. | Nur im freigegebenen Prototype-Scope | Asset-/Prototype-Gate |
| Production Asset | spaeter nur nach Gate | Nutzer sichtbare Produktgrafik. | Ja, aber erst nach Freigabe | Asset-, Legal-, Mobile-, A11y- und Product-Gate |

Dokumentationsvisuals bleiben Dokumentationsmaterial. Sie sind keine
App-Screens, keine Screenshots, keine Spielassets und keine Dateien unter
`assets/`.

## 5. Asset-Naming-Regeln als Planung

Spaetere echte Asset-Dateien sollen vorab pruefbare Namen tragen. M16-AH legt
nur eine Planungsrichtung fest, keine finale Asset-Pipeline.

Regeln:

- `snake_case`.
- Keine Leerzeichen.
- Keine uneindeutigen Namen wie `final.png`, `new.png`, `test.png`,
  `image.png` oder `asset2.png`.
- Name beschreibt mindestens Thema, Familie, Zustand und Variante, wenn diese
  Informationen vorhanden sind.
- Dokumentationsvisuals und App-Assets bleiben klar getrennt.
- Versions- oder Variantenangaben nur nach einer spaeteren Regel, nicht als
  improvisierte Dateinamen.
- Sensitive-safe Namen duerfen nicht dramatisieren oder stigmatisieren.
- Keine echten Dateien unter `assets/` in M16-AH.

Planungsbeispiele, keine Assetfreigabe:

| Kontext | Besserer Namensstil | Blockierter Namensstil |
| --- | --- | --- |
| Dokumentationsvisual | `asset_scope_naming_rules.png` | `final.png` |
| Spaeteres Theme-Asset | `village_dwelling_idle_variant_a.png` | `house.png` ohne Quelle/Scope |
| Spaeteres State-Asset | `forest_clearing_foundation_complete_v1.png` | `frame_started.png` ohne Gate |
| Sensitive-safe Symbol | `context_card_sensitive_neutral_v1.png` nach Gate | `police_reward_icon.png` |

## 6. Asset-Review-Checkliste

Jeder spaetere echte Asset-Slice muss mindestens pruefen:

| Frage | Muss erfuellt sein? | Stop-Regel |
| --- | --- | --- |
| Quelle bekannt? | ja | Keine unklare Herkunft. |
| Lizenzstatus geklaert? | ja | Keine fremden/unklar lizenzierten Bilder. |
| Verwendung erlaubt? | ja | Kein Asset ohne erlaubten Nutzungszweck. |
| Zweck und Scope klar? | ja | Kein Asset ersetzt offene Produktentscheidung. |
| Sensitive-safe? | ja, falls relevant | Keine Deko, kein Reward, keine Dramatisierung. |
| Mobile-lesbar? | ja | Kein winziges Pflichtobjekt in IslandView. |
| Passt zum Talvori-Stil? | ja | Kein Stilbruch durch zufaellige Bildquelle. |
| Kein Auto-Asset aus Wort? | ja | Semantik erzeugt Candidate/Fallback, kein Bild. |
| Dateiname korrekt? | ja | `snake_case`, eindeutiger Zweck, keine Testnamen. |
| Pfad korrekt? | ja | Docs-Preview bleibt unter `docs/`, App-Asset erst nach Gate unter `assets/`. |
| Visual-QA bestanden? | ja | Text/Labels/Rahmen duerfen nicht ueberlappen. |
| Keine Build-/Persistenzfreigabe? | ja | Asset-Slice erzeugt nicht automatisch Runtime-State. |

## 7. Offline-/Sync-Konfliktregeln

Offline-first bleibt fuer Talvori strategisch wichtig, ist aber in M16-AH nicht
freigegeben. Dieses Gate beschreibt nur fachliche Konfliktregeln.

Pflichtregeln:

- Lokale Entscheidungen koennen spaeter mit Cloud-/Remote-Zustand kollidieren.
- Konflikte duerfen keine Lernstaende, SRS, `word_progress` oder
  Weltentscheidungen beschaedigen.
- Konflikte muessen erklaerbar und reversibel bleiben.
- Sensitive/Safety gewinnt bei Konflikten.
- User Choice gewinnt nicht gegen Safety.
- Later, Backlog, CodexOnly, ContextCard, Hide oder SensitiveGated sind sichere
  Fallbacks.
- Keine Sync-, DB-, Supabase- oder lokale Persistenz-Implementierung aus
  diesem Gate ableiten.
- Kein Sync-Ereignis erzeugt automatische Weltplatzierung, BuildState,
  `frame_started`, Asset, Reward oder SRS-/`word_progress`-Write.

## 8. Konflikttypen

| Konflikt | Risiko | Sicherer Umgang |
| --- | --- | --- |
| Wort wurde offline geuebt | SRS/`word_progress` koennte still kollidieren. | Kein Write ohne eigenes SRS-/Migration-Gate; Konflikt erklaeren. |
| Semantik wurde offline geaendert | Bedeutung/Outcome kann auf anderem Geraet anders sein. | NeedsUserChoice, ContextCard oder Backlog. |
| Review-Entscheidung wurde offline getroffen | Mehrere Geraete koennen unterschiedliche Ausgaenge haben. | Entscheidung anzeigen, aenderbar halten, kein stilles Ueberschreiben. |
| Nutzer waehlt spaeter anderes Outcome | Alte Welt-/Review-Entscheidung koennte falsch wirken. | Reversibility/Change erlauben, keine irreversible Weltentscheidung. |
| Sensitive-Reclassification nach Sync | Sichtbare Darstellung koennte nicht mehr sicher sein. | Sensitive/Safety blockiert Darstellung sofort; Later/Hide/ContextCard. |
| ThemeIsland-Resizing nach Sync | Inselgroesse/Slots koennen unterschiedlich sein. | Resizing als Planungs-/Review-Konflikt, keine automatische Neubelegung. |
| BuildChoice Candidate wurde geaendert | Kandidat koennte nicht mehr passend sein. | Candidate in Review/Backlog, kein BuildState. |
| Asset/Blueprint nicht mehr gueltig | Lizenz, Scope oder Semantik passt nicht mehr. | Asset blockieren, Blueprint zurueck in Review/Backlog. |
| Mehrere Geraete widersprechen sich | Nutzervertrauen leidet. | Transparent erklaeren, sichere Fallbacks anbieten. |
| Remote-Daten sind aelter/neuer | Zeitstempel allein koennte falsche Entscheidung treffen. | Zeit ist Signal, nicht alleinige Wahrheit; Safety und User-Intent pruefen. |

## 9. Sichere Konfliktaufloesung

Verbindliche Reihenfolge fuer spaetere Konfliktmodelle:

```text
Safety / Sensitive
-> Datenintegritaet / kein SRS-Schaden
-> Context / Sense
-> User-visible Decision History
-> Reversibility / Undo
-> Safe Default
-> spaeteres Review oder eigener Data Gate
```

Prinzipien:

- Keine automatische irreversible Entscheidung.
- Keine automatische Weltplatzierung.
- Kein BuildState aus Sync.
- Kein `frame_started` aus Sync.
- Kein Asset aus Sync.
- Kein SRS-/`word_progress`-Write ohne eigenes Gate.
- Bei Konflikt zuerst Safe Default.
- Nutzerentscheidung wird erklaert, nicht still ueberschrieben.
- Konflikt kann in Review, Backlog, ContextCard, CodexOnly, Later oder Hide
  gehen.
- Sensitive/Safety kann sichtbare Darstellung sofort blockieren.
- User Choice darf Safety nicht ueberstimmen.

## 10. Beispiele

| Beispiel | Moeglicher Konflikt | Sicherer AH-Ausgang |
| --- | --- | --- |
| `Schluessel` als `ContainerItem` auf Geraet A, `CodexOnly` auf Geraet B | TinyObject wurde unterschiedlich eingeordnet. | `NeedsUserChoice` oder `ContainerItem`/`CodexOnly` als erklaerte Fallbacks, keine IslandView-Platzierung. |
| `Bank` mit anderer Bedeutung auf zwei Geraeten | Sitzbank/Geldinstitut/Flussufer. | Sense-Konflikt in `ContextCard` oder Review; keine Default-Welt. |
| `Angst` wird nachtraeglich `SensitiveGated` | Emotion/sensitive Reclassification. | Sichtbare Darstellung blockieren; CodexOnly, ContextCard, Hide oder Later. |
| `Garage` wechselt Plot-Familie | Zuhause, Verkehr oder Stadt moeglich. | BuildChoice Candidate zurueck in Review/Backlog, kein BuildState. |
| Nutzer ignoriert Review offline | Remote erwartet Entscheidung. | Later bleibt gueltig, keine negative Lernwirkung. |
| ThemeIsland wurde offline erweitert | Remote kennt Slots noch nicht. | Resizing-Konflikt erklaeren, keine automatische Neubelegung/Migration. |
| Spaeteres Asset fehlt oder Lizenz unklar | Blueprint/Asset-Kandidat ist nicht mehr verwendbar. | Asset blockieren, Ersatz erst nach Asset-Gate. |
| Lokaler Lernstand kollidiert mit Remote-Daten | SRS/`word_progress` koennte beschaedigt werden. | Kein Merge ohne SRS-/Migration-Gate; Konflikt parken. |

## 11. World-/Asset-/Sync-Regelkarte

| Begriff | Sicherer Status | Blockiert bleibt |
| --- | --- | --- |
| Word Outcome | Candidate, Fallback oder Review-Signal | Placement, Asset, BuildState |
| Semantic Profile | Konzept/Signal | finale Datenstruktur, DB Write |
| Asset Naming | spaetere Regel | echte Datei unter `assets/` |
| Asset Source/License | spaetere Pflichtpruefung | unklare Herkunft |
| Documentation Visual | Docs-Material | Spielasset oder Screenshot-Ersatz |
| Offline Decision | spaeter erklaerbarer Konflikt | stilles Ueberschreiben |
| Sync Conflict | Review/Backlog/Later/ContextCard | automatische irreversible Entscheidung |
| Sensitive Reclassification | Safety gewinnt | User Choice als Override |
| BuildChoice Candidate | reversible Moeglichkeit | BuildState, `frame_started`, Persistenz |

## 12. Update fuer M16-T

M16-AH aktualisiert `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`:

- `M16T-ASSET-004` wird auf `[x]` gesetzt, weil Naming, Quellen,
  Lizenzen und Review fuer spaetere Assets dokumentiert sind.
- `M16T-DATA-004` wird auf `[x]` gesetzt, weil Konfliktloesung fuer lokale
  und remote Entscheidungen dokumentiert ist.
- Das Dashboard wird auf den neuen Stand aktualisiert.
- Es bleiben keine normalen offenen `[ ]` M16-T-Items. Blockierte,
  teilweise erledigte und ausgelagerte Gates bleiben bewusst bestehen.

## 13. Dokumentationsvisualisierungen

M16-AH erzeugt Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_ah_asset_sync_planning/`

Geplante Visuals:

- `asset_scope_naming_rules.png` und `.svg`
- `asset_review_checklist.png` und `.svg`
- `offline_sync_conflict_map.png` und `.svg`
- `safe_conflict_resolution_flow.png` und `.svg`
- `remaining_open_items_closure.png` und `.svg`
- optional `00_contact_sheet.png` und `.svg`

Diese Visuals sind Dokumentationsmaterial, keine App-Screens, keine
Screenshots, keine Spielassets und keine Dateien unter `assets/`.

Visual-QA:

- Text bleibt vollstaendig in Karten/Rahmen/Panels.
- Keine Woerter laufen aus Rahmen.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder
  Legenden.
- Contact Sheet ist vollstaendig lesbar, falls erzeugt.
- Keine abgeschnittenen Inhalte.
- SVG-Dateien sind XML-parsebar.

## 14. Stop-Regeln

M16-AH gibt nicht frei:

- App-Integration,
- Route,
- Flutter-/Dart-Codeaenderung,
- Persistenz,
- Supabase/local DB Writes,
- SRS-/`word_progress`-Aenderung,
- automatische Wortplatzierung,
- Build-Wheel-Code,
- Assets oder Asset-Dateien unter `assets/`,
- Build-State,
- `frame_started`,
- Bauzustaende,
- Screenshots als Repo-Artefakte,
- Tests oder Widget-Tests,
- Sync-Implementierung,
- Asset-Pipeline.
