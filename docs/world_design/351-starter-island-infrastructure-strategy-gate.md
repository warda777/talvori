# M16-BA: Starter Island Infrastructure Strategy Gate

Stand: 2026-06-09

Status: `Dokumentations-/Strategie-Slice / keine Implementierung`

## 1. Zweck

M16-BA legt vor weiteren UI-, Wheel-, BuildChoice- oder Spielmoment-Code-Slices
die grobe Infrastruktur der ersten Talvori-Starter-Insel fachlich fest.

Ziel ist eine belastbare Strategie fuer:

- Gelaende,
- Wasser,
- Wege,
- Hoehen,
- freie Bau-/Plot-Slots,
- Startslots,
- Erweiterungsslots,
- Kategorie-Templates,
- Varianten,
- Muenzen-/Unlock-Prinzipien,
- Grenzen zwischen fixer Infrastruktur und nutzergewaehlter Gestaltung.

M16-BA definiert keine finale Grafik, keinen Art Style, keine Assets, keine
Runtime-Konfiguration und keine Persistenz. Der Slice ist ein Gate fuer
kommende Planungs- und Implementierungs-Prompts, nicht die Umsetzung selbst.

## 2. Non-Goals und Stop-Regeln

M16-BA erzeugt nicht:

- keine Implementierung,
- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine neue Seite,
- keine Tests,
- keine Widget-Tests,
- keine Screenshots als Repo-Artefakte,
- keine Persistenz,
- keine Supabase Writes,
- keine lokalen DB-Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- kein Build-Wheel-Code,
- keine Assets,
- keine Asset-Dateien unter `assets/`,
- kein BuildState,
- kein `frame_started`,
- keine Bauzustaende,
- keine Economy-Implementierung,
- keine Muenzen-Implementierung,
- keine Produktivmechanik-Freigabe.

## 3. Gelesene interne Grundlagen

| Dokument | Beitrag fuer M16-BA |
| --- | --- |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrendes M16-T-Dashboard und neue Infra-IDs. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere- und Prompt-Regeln fuer kuenftige Slices. |
| `345-play-first-learning-experience-doctrine.md` | Play-First, Island-First und UI-Muster muessen jeden Weltmoment tragen. |
| `350-interaction-pattern-decision-matrix.md` | UI- und Spielaufbau-Entscheidungen brauchen Pattern- und Research-Abgleich. |
| `338-world-loop-plot-family-and-buildchoice-gate.md` | WorldCandidate, Plot Family und BuildChoice bleiben Candidates, kein Build. |
| `339-theme-island-resizing-and-remaining-world-rules-gate.md` | Capability ist Erlaubnis, keine Pflichtbelegung; Resizing bleibt Gate. |
| `318-theme-island-plot-capacity-and-build-wheel-plan.md` | Thema -> Plotbedarf -> Groessenmix -> Slot-Auswahl -> spaeteres Wheel. |
| `320-global-theme-island-plot-capacity-matrix.md` | Kategorien brauchen verschiedene Kapazitaetsprofile; Dorf ist nur Beispiel. |
| `272-plot-capability-derivation.md` | Plot-Capabilities sind Moeglichkeiten, keine automatische Platzierung. |
| `337-mobile-density-accessibility-and-depth-planning-gate.md` | Mobile-Dichte, Landmarken-vor-Kleinteilen und Container/Depth-Grenzen. |

## 4. Grundsatz

Die Starter-Insel braucht eine feste, glaubwuerdige Grund-Infrastruktur und
gleichzeitig kreative freie Gestaltung.

Verbindliche Regeln:

- Die Insel hat feste Orientierung: Kuestenrand, Wasser, Hoehen, Hauptwege,
  Startbereich und Landmarken.
- Nutzer gestalten freie Slots kreativ.
- Kategorien sind Templates, keine einmaligen Belegungen.
- Eine Kategorie kann mehrfach vorkommen, z. B. `Zuhause am Ufer` und
  `Zuhause im Wald`.
- Terrain beeinflusst spaeter Varianten, blockiert aber Kategorien nicht hart.
- Fixe Infrastruktur darf Orientierung geben, aber nicht bevormunden.
- Slot + Kategorie erzeugt nur einen lokalen Candidate oder Varianten-Namen.
- Kein Slot, keine Kategorie und keine Variante erzeugt BuildState,
  Placement, Asset, Persistenz oder `frame_started`.

Kurzform:

```text
Feste Inselgrundlage
-> freie Slots
-> wiederverwendbare Kategorie-Templates
-> lokale Variante
-> Preview/Candidate
-> spaeteres Gate fuer BuildChoice, Persistenz und Assets
```

## 5. Benchmark-/Research-Check nach M16-AX

M16-BA fuehrt den kurzen Benchmark-/Research-Check aus `350` durch. Das ist
kein neues Deep Research und keine Mechanikfreigabe, sondern ein Pattern-Check
fuer die Infrastrukturentscheidung.

| Geprueftes Muster | Beobachtetes Prinzip | Talvori uebernimmt | Talvori uebernimmt nicht |
| --- | --- | --- | --- |
| Clash of Clans / Supercell Base-Aufbau | Feste Basisflaeche, sichtbarer Fortschritt, langfristige Planung, klare Slots. | Orientierung durch Grundlayout, sichtbare Erweiterungsflaechen, kleine Entscheidungen. | Timer, War Pressure, Pay-to-Win, Ressourcenknappheit als Druck, irreversible Upgrades im MVP. |
| Mobile Hub-/Regionen-Karten | Weltkarten geben Orientierung ueber Regionen, Wege und gesperrte Bereiche. | Start-Hub, Hauptwege, spaeter sichtbare Erweiterungsbereiche, klare Landmarks. | Zwangspfade, Event-FOMO, Progression durch Pflichtlogins. |
| RPG-/Action-/Crafting Showcase und Werkbank | Grosse Entscheidungen brauchen Vergleich, Preview und wenige klare Aktionen. | BuildChoice spaeter als Showcase/Werkbank statt Mini-Wheel, wenn visuelle Auswahl gross wird. | Produktive Crafting-/Economy-Systeme, Materialgrind, komplexe Inventare im MVP. |
| Inventar-/Codex-Muster | Sammlung und Detailwissen gehoeren in eigene lesbare Raeume. | Codex/Container fuer Tiefe und kleine Objekte. | TinyObjects als Massenobjekte auf der Insel. |
| Insel-/Weltkarten mit Unlock-Bereichen | Gesperrte Zonen koennen Neugier erzeugen, wenn sie ruhig und erreichbar wirken. | 4-6 sichtbare Erweiterungsslots, Bruecken/Wege als spaetere Gate-Ideen. | Drucksprache, Countdown, Verlustangst, Kaufdruck. |

Entscheidung:

- Gewaehltes Muster: feste Weltkarte + freie Slots + spaeteres Showcase fuer
  grosse BuildChoice-Entscheidungen.
- Bewusst verworfen: komplett freie Terrainbearbeitung im MVP, hart
  vorgegebene Kategorien pro Slot, Drag als Standardflow, grosse Fenster fuer
  kleine Slot-Kategorieauswahl, Economy-/Timer-/Pay-to-Win-Aufbau.
- Vorbildlogik: erfolgreiche Spiele geben zuerst eine lesbare Weltstruktur,
  dann kleine Entscheidungen und spaeter groessere Vergleichsraeume.
- Talvori-Filter: Die Struktur muss Spielgefuehl und Neugier tragen, aber
  Lernen, Safety, Mobile-Dichte und Reversibility duerfen nicht darunter leiden.

## 6. Infrastruktur-Ebenen

| Ebene | Zweck | Beispiele | Erlaubt | Blockiert |
| --- | --- | --- | --- | --- |
| Base Terrain Layer | Glaubwuerdige Inselgrundlage und Orientierung. | Inselrand, Kueste, Hoehen, Wasser, Hauptwege. | feste MVP-Grundform planen. | freie Terrainbearbeitung, Terrain-Persistenz. |
| Free Slot Layer | Kreative freie Flaechen fuer spaetere Weltmomente. | Startslots, Erweiterungsslots, ruhige Randplaetze. | Slot antippen, Kategorie waehlen als Preview. | Slot = gebautes Grundstueck. |
| Category Template Layer | Wiederverwendbare inhaltliche Familien. | Zuhause, Garten, Markt, Werkstatt, Lager, Wissen. | mehrfach nutzbare Templates. | Kategorie als einmalige Belegung. |
| Variant Layer | Slot + Kategorie erzeugt eine lokale Lesart. | Markt am Ufer, Garten am Wasser, Zuhause im Wald. | Variantenname, Preview, Context. | Asset, BuildState, Persistenz. |
| Unlock Layer | Spaetere Neugier- und Progressionsraeume. | Bruecke, neuer Slot, neue Inselkante. | fachliche Unlock-Idee. | Economy-Code, Timer, Paywall, Druck. |
| BuildChoice Layer | Spaeterer visueller Vergleich konkreter Optionen. | Gebaeude, Stil, Companion-Ort, Biome-Auswahl. | eigenes Gate und Showcase/Werkbank-Muster. | In M16-BA bauen oder speichern. |
| BuildState/Persistenz Layer | Produktiver Weltzustand. | saved world, ownership, frame state. | blockiert bis eigenes Gate. | jede Nebenbei-Freigabe. |

## 7. Starter-Insel-Grundform

Empfohlene MVP-Grundform:

- zusammenhaengende Insel,
- Kueste aussen,
- ein Fluss, Wasserarm oder Wasserband als starke Landmarke,
- zentraler Start-/Hub-Bereich,
- 1 bis 2 Hauptwege,
- 2 bis 3 Nebenwege,
- sichtbare Hoehen-, Wald-, Wasser- und Randzonen,
- einige freie Startslots nahe Hub und Weg,
- einige sichtbare, aber noch gesperrte Erweiterungsslots,
- keine komplett freie Terrain-Bearbeitung im MVP.

Lesart:

Die Insel soll wie ein kleiner Spielraum wirken, nicht wie eine Liste von
Grundstuecken. Wege, Wasser und Hoehen tragen Orientierung. Freie Slots tragen
Nutzerfreiheit. Kategorie-Templates tragen Bedeutung.

## 8. Fixe Infrastruktur vs. Nutzerfreiheit

| Element | MVP-Lesart | Nutzerfreiheit | Blockiert |
| --- | --- | --- | --- |
| Kueste | fix | keine freie Kuestenbearbeitung im MVP | Terrain-Editor |
| Hauptfluss / Wasserarm | fix | Varianten koennen sich auf Wasser beziehen | freie Flusskonstruktion |
| Hauptwege | teilweise fix | spaeter optionale Verbindungen moeglich | produktiver Pfadbau |
| Nebenwege | vorgeplant, spaeter erweiterbar | Unlock/Bridge-Gate spaeter | Pflichtpfade |
| Bruecken | spaeter freischaltbar | Bridge Candidate nach Gate | Economy-/Timer-Freigabe |
| Freie Slots | nutzerwaehlbar | Kategorie frei waehlen | Slot als festes Gebaeude |
| Kategorie | nutzerwaehlbar | Kategorie mehrfach verwendbar | harte Terrain-Blockade |
| Variante | aus Slot + Kategorie abgeleitet | Name/Preview aenderbar | Asset/BuildState |
| Gebaeude / BuildChoice | spaeterer Showcase-/BuildChoice-Gate | Auswahl und Vergleich nach Gate | Build in diesem Slice |
| Terrain-Modifikation | nach MVP | eigenes Gate | MVP-Terraineditor |

## 9. Slot-Strategie

Empfehlung fuer die erste Starter-Insel:

| Slotgruppe | Anzahl | Zustand | Zweck |
| --- | --- | --- | --- |
| Sichtbare freie Slots gesamt | 8 bis 12 | sichtbar als freie Flaechen | Insel wirkt offen, aber nicht leer. |
| Sofort nutzbare Startslots | 4 bis 6 | frei waehlbar | schnelle kreative Wahl ohne Ueberforderung. |
| Sichtbare Erweiterungsslots | 4 bis 6 | ruhig gesperrt oder angedeutet | Neugier und Zukunft ohne Druck. |
| Spaetere Inselbereiche | offen | nicht im MVP bedienbar | Raum fuer Nach-MVP-Expansion. |

Begruendung:

- Mobile-Dichte: Mehr als 8-12 sichtbare freie Slots wird auf kleinen Phones
  schnell unlesbar.
- Neugier: Gesperrte Erweiterungsslots zeigen Zukunft, ohne sofortige
  Entscheidung zu verlangen.
- Progression: 4-6 Startslots reichen fuer erste Spielmomente und Varianten.
- Ueberforderungsschutz: Nutzer sollen frei waehlen, aber nicht eine ganze
  Stadt planen muessen.
- Play-First: Die Insel bleibt ein Spielbrett mit sichtbaren Orten, kein
  Tabellen-Editor.

## 10. Kategorien / Templates

Startkategorien:

| Template | Zweck | Beispielvarianten | Blockiert |
| --- | --- | --- | --- |
| Zuhause | Alltag, Ruhe, persoenliche Orientierung. | Zuhause am Ufer, Zuhause im Wald, Zuhause zentral. | Pflicht-Hausstart, gebautes Haus. |
| Garten | Natur, Pflanzen, ruhige Aussenmomente. | Garten am Wasser, Waldgarten, Huegelgarten. | Growth-/Timerdruck. |
| Markt | Versorgung, Begegnung, kleine Entscheidungen. | Markt zentral, Markt am Ufer, Waldstand. | Economy, Kaufdruck. |
| Werkstatt | Machen, Tools, Action-/Craft-Idee. | Werkstatt am Rand, Bootswerkstatt, Waldwerkbank. | Crafting-System, Produktion. |
| Lager/Container | kleine Objekte auffindbar machen. | Tasche am Hub, Kiste am Ufer, Lager am Rand. | Inventar-Dump, TinyObject-Wolke. |
| Wissen | Lernen, Bibliothek, Denkraum. | Wissen am Huegel, Lernplatz zentral, Uferlektion. | Schule/Test als Pflichtgefuehl. |
| Codex | Sammlung, Kontext, Erklaerung. | Codex-Ort, stilles Archiv, Kontext-Schild. | Textwand, Persistenz. |
| Safe/Later/Backlog | sichere Ausgaenge und sensible Rueckzugsraeume. | Rueckzugsort am Rand, Later-Lichtung. | sensitive Retention, Druck. |
| Ufer/Wasser | Wasser, Fluss, Kueste, Bewegungs-/Kontextmomente. | Uferplatz, Wasserweg, kleiner Steg. | Wasser-/Bootssystem ohne Gate. |

Optionale spaetere Kategorien:

- Hafen,
- Turm,
- Arena/Challenge,
- Kueche,
- Labor/Werkbank,
- Wald/Naturpfad.

Template-Regeln:

- Kategorien sind mehrfach nutzbar.
- Kategorie ist Template, nicht Gebaeude.
- Slot + Kategorie erzeugt eine Variante.
- Kategorie erzeugt kein fertiges Gebaeude.
- Kategorie erzeugt keinen BuildState.
- Kategorie erzeugt keine Persistenz.
- Kategorie erzeugt kein Asset.
- Kategorie darf durch Terrain beschrieben, aber nicht hart blockiert werden.

## 11. Variantenlogik

Varianten sind Namen, Lesarten oder Preview-Hinweise. Sie sind keine Assets,
keine Bauzustaende und keine Persistenz.

| Slot + Kategorie | Lokale Variante | Bedeutung | Blockiert |
| --- | --- | --- | --- |
| Zuhause + Ufer | Kuestenhaus / Hausboot-Idee | Zuhause mit Wassernaehe. | gebautes Haus, Bootssystem. |
| Zuhause + Wald | Waldhaus | ruhige Alltagsvariante. | Pflicht-Zuhause. |
| Markt + Ufer | Hafenmarkt | Versorgung trifft Wasser. | Commerce-System. |
| Markt + Zentrum | Dorfmarkt | zentraler Treffpunkt. | Economy. |
| Werkstatt + Rand | Aussenwerkstatt | Machen am Rand, weniger Dichte. | Produktion. |
| Werkstatt + Wasser | Bootswerkstatt | Wassernahe Werkstatt-Idee. | Bootsbau-System. |
| Garten + Fluss | Ufergarten | Natur und Wasser. | Growth-/Timerlogik. |
| Wissen + Huegel | Turm/Bibliothek-Idee | Ueberblick und Lernen. | Lerngebauede als Pflicht. |
| Safe + Rand | Rueckzugsort | ruhiger Later-/Backlog-Ort. | sensitive Retention. |

Formel:

```text
freier Slot + Kategorie-Template + Terrain-Hinweis
= lokaler Variantenname
= Candidate / Preview
!= Build
```

## 12. Wege und Fluesse

Verbindliche Regeln:

- Fluesse, Wasser und Kuesten sind im MVP Teil der Grund-Infrastruktur.
- Nutzer baut Fluesse nicht frei im MVP.
- Wege dienen Orientierung, Questfuehrung und spaeterer Unlock-Logik.
- Wege duerfen keine Pflichtpfade erzeugen.
- Nutzer kann spaeter vielleicht Bruecken, Pfade oder Verbindungen
  freischalten.
- Pfadbau, Brueckenbau und Wasserlogik brauchen eigene Gates.
- Wege und Wasser duerfen Varianten beeinflussen, aber keine Kategorie hart
  verbieten.

Beispiele:

- `Markt am Ufer` ist erlaubt als lokaler Candidate.
- `Zuhause am Wasser` ist erlaubt als lokaler Candidate.
- `Werkstatt am Rand` ist erlaubt als lokaler Candidate.
- Kein Beispiel erzeugt Bauzustand, Asset, Economy oder Persistenz.

## 13. Muenzen / Unlocks

M16-BA definiert Muenzen und Unlocks nur fachlich.

Moegliche spaetere Unlock-Ziele:

- freie Slots,
- Bruecken,
- kleine Wege,
- neue Inselzonen,
- neue Kategorie-Templates,
- Showcase-/BuildChoice-Vergleiche.

Pflichtgrenzen:

- Keine echte Economy-Implementierung.
- Keine Muenzen-Implementierung in M16-BA.
- Keine Pay-to-Win-Logik.
- Kein Kaufen von Lernen.
- Kein Timer.
- Kein FOMO.
- Kein Druck.
- Kein Social-/Competition-Vorteil.
- Unlocks muessen durch Spiel/Lernen motivieren, aber nicht erzwingen.
- Muenzen im MVP hoechstens als lokale Preview-Waehrung oder noch gar nicht.

Sichere MVP-Lesart:

```text
Lernen und Spielmomente koennen spaeter Moeglichkeiten oeffnen.
Sie kaufen, bauen oder speichern in diesem Gate nichts.
```

## 14. Baugrundstuecke nach Terrain/Zone

Terrain ist Variantenlogik, nicht Kategorieverbot.

| Zone | Geeignete Varianten | Moegliche Kategorien | Regel | Clutter-/Mobile-Hinweis |
| --- | --- | --- | --- | --- |
| Zentrum | Dorfmarkt, Hub-Zuhause, Lernplatz, Lagerpunkt. | alle Startkategorien. | zentral wirkt sichtbar und sozial. | wenige Labels, keine Marktware-Masse. |
| Ufer | Hafenmarkt, Ufergarten, Wasserwissen, Zuhause am Wasser. | alle Startkategorien. | Wasser beschreibt Variante, blockiert nicht. | Wasserlabels knapp halten. |
| Wald | Waldhaus, Naturgarten, ruhige Werkstatt, Safe-Lichtung. | alle Startkategorien. | Wald bringt Ruhe/Naturton. | keine Deko-Baumwolke. |
| Huegel | Wissensturm-Idee, Aussichtsgarten, Codex-Ort. | alle Startkategorien. | Hoehe signalisiert Ueberblick. | keine kleinen Hoehenlabels. |
| Rand | Aussenwerkstatt, Safe-Ort, Lager, Gartenrand. | alle Startkategorien. | Rand eignet sich fuer Ruhe/Expansion. | nicht zu weit vom Tap-Fokus. |
| Ruhiger Bereich | Codex, Safe, Wissen, Garten. | alle Startkategorien. | ruhige Variante, kein Zwang. | Overlays sparsam. |
| Wassernahe Flaeche | Ufermarkt, Bootswerkstatt-Idee, Ufergarten. | alle Startkategorien. | Wasser beeinflusst Name und Stimmung. | keine Boot-/Hafen-Mechanik ohne Gate. |

## 15. Was vor weiterem Code feststehen muss

Vor weiteren Starter-Island-, Wheel-, BuildChoice- oder Spielmoment-Code-Slices
muss ein Prompt beantworten:

- Welche Start-Insel-Grundform gilt?
- Wie viele Slots sind sichtbar?
- Wie viele Slots sind sofort nutzbar?
- Wie viele Slots sind nur spaeter sichtbar/freischaltbar?
- Welche Kategorie-Templates sind im Scope?
- Wie entsteht die Variantenlogik?
- Welche Infrastruktur ist fix?
- Welche Infrastruktur ist nutzerveraenderbar?
- Wird Terrain veraendert oder nur ein Slot genutzt?
- Gibt es ein Unlock-Prinzip ohne Economy-Code?
- Welche UI-Muster pro Aktion werden verwendet?
- Ist die Entscheidung MVP, nach MVP oder blockiert?

Wenn diese Fragen nicht beantwortet sind, bleibt der naechste Slice ein
Planungs-/Audit-Slice und darf keine Implementierung freigeben.

## 16. M16-T-ID-Entscheidung

| ID | Entscheidung |
| --- | --- |
| `M16T-INFRA-001` | `[x]` Starter Island Infrastructure Strategy ist in M16-BA dokumentiert. |
| `M16T-INFRA-002` | `[x]` Fixe vs. player-editable Infrastruktur ist getrennt. |
| `M16T-INFRA-003` | `[x]` Startslot-/Unlock-Strategie ist mit 8-12 sichtbaren, 4-6 sofort nutzbaren und 4-6 spaeteren Slots festgelegt. |
| `M16T-INFRA-004` | `[x]` Kategorie-Templates und Terrain-Varianten sind als wiederverwendbare, nicht-persistente Candidates definiert. |
| `M16T-INFRA-005` | `[x]` Wege, Fluesse und Bruecken sind als Grund-Infrastruktur bzw. spaetere Gates eingeordnet. |
| `M16T-INFRA-006` | `[x]` Muenzen-/Unlock-Strategie ist fachlich dokumentiert, ohne Economy-Code freizugeben. |

## 17. Updates fuer kuenftige Dokumentenlandkarte

`336-documentation-map-and-slice-reading-rules.md` muss M16-BA als
Pflichtlektuere fuer World/Island/Plot/UI/BuildChoice-Slices aufnehmen.

Kuenftige Prompts muessen beantworten:

- Welche Infrastruktur-Ebene wird beruehrt?
- Ist es fixe Infrastruktur, freier Slot, Kategorie-Template, Variante,
  Unlock oder BuildChoice?
- Wird Terrain veraendert oder nur ein Slot genutzt?
- Ist es MVP, nach MVP oder blockiert?

## 18. Entscheidung

M16-BA empfiehlt als naechste Grundlage:

- eine zusammenhaengende Starter-Insel mit Kueste, Fluss/Wasserarm,
  zentralem Hub, Hauptwegen, Nebenwegen, Hoehen-/Wald-/Wasserzonen,
- 8-12 sichtbare freie Slots,
- 4-6 sofort nutzbare Slots,
- 4-6 ruhig sichtbare Erweiterungsslots,
- Kategorien als mehrfach nutzbare Templates,
- Terrain nur als Variantenlogik,
- Muenzen/Unlocks nur fachlich und druckfrei,
- BuildChoice erst spaeter als eigenes Gate mit passendem UI-Muster,
- BuildState/Persistenz/Assets weiter blockiert.

Damit entsteht eine Spielbrett-Grundlage fuer Talvori Welt, ohne den Nutzer
in feste Kategorien, Pflichtbauten oder technische Editorlogik zu druecken.
