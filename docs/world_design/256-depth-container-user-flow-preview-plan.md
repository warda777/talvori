# Phase 2G-M9: Depth Container User Flow Preview Plan

Stand: 2026-06-06

Status: `Planungs- und Visualisierungsblock gestartet`

Dieses Dokument plant und bewertet eine erste vereinfachte Nutzer-/
Produktansicht fuer den Depth-/Container-Flow. Es ist kein technisches QA-
Diagramm fuer Anchors und keine App-UI-Spezifikation.

Es wurden keine Flutter-/Dart-Dateien, keine App-Integration, keine Tests,
keine Spielassets, keine PNGs im Asset-Ordner, kein finales Inselbild, kein
`frame_started` und keine Bauzustaende geaendert.

Fuehrende Grundlagen:

- `docs/world_design/255-world-depth-gameplay-retention-research.md`
- `docs/world_design/254-capability-greybox-visual-review.md`
- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`

## 1. Ziel

M9 beantwortet die Nutzerfrage:

```text
Wie erlebt der Nutzer das Lernen, wenn er von einem Bereich in ein Objekt
hineinzoomt, einen Container oeffnet und dort eine kleine Lern-Challenge
loest?
```

Die Preview soll zeigen:

- einen ruhigen Einstieg in eine Innen- oder Bereichsansicht,
- einen klaren Container-Fokus,
- eine kleine Lerninteraktion,
- ein sichtbares Feedback,
- einen Reward Moment,
- ein naechstes Ziel.

Die Preview soll nicht zeigen:

- finale App-Screens,
- finale UI-Komponenten,
- Spielassets,
- technische Anchor-Vollansicht,
- Bauzustandsfreigabe,
- Codefreigabe.

## 2. Beispiel-Flow

Erster Beispiel-Flow:

```text
Haus/Kueche -> Schublade -> Besteck
```

Ablauf:

1. Nutzer sieht Kueche oder Kuechenbereich.
2. Nutzer tippt auf Schublade.
3. Schublade zoomt oder fokussiert.
4. Schublade oeffnet sich.
5. Darin liegen Loeffel, Gabel und Messer.
6. Nutzer loest Mini-Challenge:
   - Wort hoeren oder sehen,
   - richtiges Besteck antippen oder zuordnen,
   - kurzes Feedback erhalten.
7. Nach Erfolg:
   - Objekt wird gesammelt oder sichtbar markiert,
   - Schublade bekommt Fortschrittsstatus,
   - Tali/Vori reagiert kurz,
   - naechstes kleines Ziel wird vorgeschlagen.

## 3. Nutzerflow Fachlich

| Schritt | Nutzererlebnis | Nutzerhandlung | Systemreaktion | Zweck |
| --- | --- | --- | --- | --- |
| Einstieg | Nutzer sieht einen ruhigen Kuechenbereich. | Blick orientieren. | Schublade ist als interaktiver Fokus erkennbar. | Container-Einstieg ohne Ueberladung. |
| Fokus | Schublade ist als naechster Schritt sichtbar. | Schublade antippen. | Kamera/Fokus wechselt naeher an die Schublade. | Depth-Wechsel vorbereiten. |
| Oeffnen | Schublade oeffnet sich. | keine zweite Bestaetigung. | ContainerOpenView zeigt wenige Objekte. | Kleine Woerter sichtbar machen, ohne Island View zu ueberladen. |
| Challenge | Wort oder Audio erscheint. | Nutzer tippt passendes Besteck an oder ordnet zu. | Richtige/unsichere Antwort bekommt klares Feedback. | Lernen statt Museum. |
| Reward | Erfolg ist kurz sichtbar. | Fortschritt wahrnehmen. | Objekt markiert, Container-Fortschritt steigt, Tali/Vori reagiert. | Dopamin-Moment ohne Druck. |
| Naechstes Ziel | Nutzer sieht eine kleine Folgeempfehlung. | Optional weiterlernen. | Naechster Container oder naechstes Wortset wird vorgeschlagen. | Retention und naechster sinnvoller Schritt. |

## 4. UX-Regeln

- Die Nutzeransicht bleibt ruhiger als die technische M7-B-Greybox.
- Wenige Labels sind erlaubt, aber keine technische Datenmodell-Vollansicht.
- Container reduzieren visuelle Ueberladung.
- Kleine Objekte werden erst in passender Tiefe sichtbar.
- Die Challenge ist Teil des Flows; eine reine Objektliste reicht nicht.
- Feedback muss kurz, klar und nicht strafend sein.
- Der Reward Moment zeigt Fortschritt, nicht Druck.
- Tali/Vori darf ermutigen, aber nicht hetzen.
- Das naechste Ziel bleibt optional.

## 5. Geplante Preview-Dateien

M9 erzeugt Dokumentations-/Preview-Dateien unter:

```text
docs/world_design/previews/phase2g_m9_depth_container_user_flow/
```

Dateien:

| Datei | Zweck |
| --- | --- |
| `01_depth_flow_storyboard.png` | Storyboard mit 5 bis 7 Panels fuer Kueche, Schublade, Container, Challenge, Feedback und naechstes Ziel. |
| `02_depth_level_stack.png` | Ebenenmodell von `IslandView` bis `DetailInteractionView` mit markiertem Beispielpfad. |
| `03_interaction_reward_loop.png` | Nutzerloop von Entdecken bis naechstes Ziel. |
| `README.md` | Zweck, Dateien, Prueffazit, Grenzen und Blocker. |

Diese Dateien sind:

- Dokumentationsmaterial,
- keine Spielassets,
- keine finale Kunst,
- keine App-UI,
- keine Codefreigabe,
- keine Assetfreigabe.

## 6. Pruefkriterien

Die M9-Preview ist brauchbar, wenn:

- der Ablauf ohne technische Spezialbegriffe verstaendlich ist,
- klar wird, dass der Nutzer eine Schublade oeffnet,
- klar wird, dass kleine Objekte erst in der Container-Ebene erscheinen,
- die Mini-Challenge sichtbar Bestandteil des Flows ist,
- das Feedback und der Reward Moment erkennbar sind,
- die Ansicht nicht wie ein Museum ohne Aufgabe wirkt,
- die Ansicht nicht wie finale App-UI oder finales Spielasset wirkt,
- der Flow ruhig genug fuer Mobile gedacht werden kann,
- keine Asset- oder Codefreigabe daraus abgeleitet wird.

## 7. Sichtbare Risiken

- Die Preview kann zu schematisch wirken und noch keine emotionale Atmosphaere
  transportieren.
- Die Challenge muss spaeter konkreter werden: Audio, Text, Drag-and-drop oder
  Tap-Auswahl sind noch offen.
- Die Kueche ist ein Beispiel, aber noch keine freigegebene Interior-
  Architektur.
- Tali/Vori-Reaktion ist nur als Produktmoment geplant, nicht als
  Companion-Implementierung.
- Weitere Flows wie Schule/Federmappe oder Hafen/Bootskajute muessen spaeter
  separat geprueft werden.

## 8. Naechster Erlaubter Schritt

Nach M9 ist erlaubt:

- M9-Previews visuell pruefen,
- Flow bestaetigen oder nachbessern,
- weitere Beispiel-Flows planen, z. B. Schule/Federmappe oder
  Hafen/Bootskajute,
- eine vereinfachte Nutzer-/Produktansicht weiter ausarbeiten.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNGs im Asset-Ordner,
- finales Inselbild,
- `frame_started`,
- Bauzustaende,
- produktive Bau-/Lernlogik,
- Persistenz,
- Supabase,
- Reward Bridge.

## 9. Stop-Regeln

Stoppen, wenn:

- Depth-/Container-Logik ohne visuelle Nutzerflow-Pruefung weiter geplant wird,
- eine Container-Ansicht als reine Objektliste ohne Challenge geplant wird,
- die Nutzeransicht zu viele technische Labels zeigt,
- eine Mini-Challenge kein klares Feedback und keinen Reward Moment hat,
- aus M9 eine Spielasset- oder Codefreigabe abgeleitet wird,
- eine Preview wie finale App-UI oder finales Inselbild gelesen wird.
