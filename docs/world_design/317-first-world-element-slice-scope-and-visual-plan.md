# M16-A: First World Element Slice Scope And Visual Plan

Stand: 2026-06-07

Status: `Scope-/Visual-Plan gestartet / keine Code- oder Assetfreigabe`

## 1. Ziel

M16-A definiert den ersten moeglichen sichtbaren Welt-/Bau-Element-Slice nach
dem Foundation-Choice-Harness. Der Block soll schneller in Richtung sichtbare
Welt kommen, ohne die Architektur zu gefaehrden.

Kernfrage:

> Was ist das kleinste sichtbare Welt-Element, das als naechster Schritt
> sinnvoll waere, ohne Code, App-Integration, Assets, Persistenz,
> automatische Wortplatzierung oder `frame_started` freizugeben?

M16-A ist nur Scope- und Visualplanung. Es ist kein Flutter-/Dart-Code, keine
App-Integration, keine Runtime-Konfiguration, keine Persistenz, keine
Assetfreigabe und kein Bauzustand.

## 2. Fuehrende Grundlage

Fuehrend fuer M16-A sind:

- `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md`,
- `docs/world_design/253-capability-greybox-plan.md`,
- `docs/world_design/254-capability-greybox-visual-review.md`,
- `docs/world_design/270-word-to-island-routing-matrix.md`,
- `docs/world_design/271-word-to-island-routing-visual-review.md`,
- `docs/world_design/272-plot-capability-derivation.md`,
- `docs/world_design/273-plot-capability-visual-review.md`,
- `docs/world_design/289-asset-prioritization-scope-gate.md`,
- `docs/world_design/290-m13-consolidated-readiness-review.md`,
- `docs/world_design/296-implementation-candidate-gate.md`,
- `lib/features/world/local_world/ui/widgets/foundation_choice_preview.dart`,
- `lib/features/world/local_world/ui/widgets/foundation_choice_preview_harness.dart`,
- `lib/features/world/local_world/ui/widgets/foundation_choice_preview_harness_main.dart`.

## 3. Kandidatenbewertung

| Kandidat | Nutzen | Risiko | Architektur-Auswirkung | Mobile-Risiko | Assets noetig? | Spaeter klein genug? | `frame_started`? | Empfehlung |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Neutraler Plot-Marker | zeigt einen moeglichen Bau-/Lernplatz sichtbar | kann zu technisch wirken | gering, wenn lokal und ohne Datenmodell | niedrig, einfache Form | nein | ja | nein | bester naechster Kandidat |
| Foundation-Fokus-Indikator | verbindet Fokuswahl mit spaeteren Vorschlaegen | wirkt wie Onboarding/Fokus-System | mittel, weil Fokuszustand misslesen werden kann | niedrig | nein | ja, aber nicht als Bau-Slice | nein | nicht Kandidat 1 |
| Lokale Build-Preview-Flaeche | zeigt, wo spaeter etwas entstehen koennte | kann wie Bauzustand wirken | niedrig bis mittel | niedrig bis mittel | nein | ja, wenn abstrakt | nein, wenn neutral | zweitbester Kandidat |
| Grundstueck-/Bauplatz-Karte | antippbarer Bauplatz wirkt produktnah | wirkt schnell wie Integration/Bau-Menue | mittel bis hoch | mittel | nein | moeglich, aber riskanter | nein | spaeteres Gate |
| Debug-/Greybox-Element fuer Plot/Anchor | technisch sauber fuer Architektur | fuer Nutzer trocken | niedrig | niedrig | nein | ja | nein | gut fuer Review, nicht erster Wow |

## 4. Entscheidungsempfehlung

Empfohlener naechster Code-Slice:

`Neutraler Plot-Marker` als lokaler, isolierter visueller Welt-Element-Slice.

Der Marker sollte spaeter nur zeigen:

- Hier ist ein moeglicher Bau-/Lernplatz.
- Der Platz ist neutral und nicht als Haus, Garten, Markt oder Gebaeude
  festgelegt.
- Es gibt keine Auswahl aus einem Bau-Menue.
- Es gibt keinen Bauzustand.
- Es gibt keine Persistenz, keine Runtime-Konfiguration und keine Assets.
- Es gibt keine automatische Wortplatzierung.
- `frame_started` bleibt blockiert.

Bewusst nicht Kandidat 1:

- Foundation Choice: Sie ist kein Bau-Menue. Sie gehoert spaeter eher in den
  Einstieg, Tali/Vori-Erklaerung oder Fokuswechsel.
- Echte Gebaeude: zu frueh, weil Asset-, Plot-, Anchor-, Device- und
  Build-State-Gates fehlen.
- `frame_started`: bleibt blockiert, weil Masterlayout, Plot-Typen, Anchors,
  Sockets, Footprints und Asset-Gates weiterhin fehlen.
- Grundstueck-/Bauplatz-Karte: zu produktnah fuer den ersten sichtbaren
  Welt-Element-Code-Slice.

## 5. Erlaubter Spaeterer Minimal-Scope

Ein spaeterer Code-Slice duerfte hoechstens:

- einen neutralen lokalen Plot-Marker oder eine lokale Build-Preview-Flaeche
  zeigen,
- als isolierter lokaler Preview-/Harness-Slice entstehen,
- keine App-Route erzeugen,
- keine Home-/Onboarding-/World-Routing-Integration erzeugen,
- keine produktive Navigation erzeugen,
- keine Persistenz oder Runtime-Konfiguration erzeugen,
- keine Assets oder Asset-Dateien unter `assets/` erzeugen,
- keine automatische Wortplatzierung erzeugen,
- keinen Build-State und kein `frame_started` erzeugen.

## 6. Dokumentationsvisualisierungen

M16-A ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_a_first_world_element_slice/`

Geplante Visuals:

- `01_first_world_element_candidate_map.png`,
- `02_recommended_next_slice_flow.png`,
- `03_allowed_vs_blocked_world_element_scope.png`,
- optional `00_contact_sheet.png`.

Diese PNGs sind Dokumentationspreviews. Sie sind keine App-Screens, keine
Screenshots, keine finalen UI-PNGs, keine Spielassets und keine Asset-Dateien
unter `assets/`.

## 7. Beschleunigte M16-Arbeitsweise

Ab M16 sollen keine unnoetigen Mehrfach-Gates mehr entstehen. Der schnellere,
aber weiterhin sichere Ablauf:

1. Kleiner Scope.
2. Visuelle Uebersicht.
3. Code-Slice nur nach klarer Freigabe.
4. Direkter Code-/Scope-Check.
5. Commit nur nach erfolgreichem Check und ausdruecklichem Wunsch.

Architektur-Schutz bleibt:

- keine Persistenz ohne eigenes Gate,
- keine Assets ohne eigenes Gate,
- keine automatische Wortplatzierung ohne eigenes Gate,
- kein `frame_started`,
- keine App-Integration ohne eigenes Gate.

## 8. Stop-Regeln

Aus M16-A folgt ausdruecklich:

- Kein Flutter-/Dart-Code.
- Keine App-Integration.
- Keine Tests und keine Widget-Tests.
- Keine Screenshots.
- Keine Runtime-Konfiguration.
- Keine Persistenz.
- Keine Supabase Writes.
- Keine lokalen DB-Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine Reward Bridge.
- Keine automatische Wortplatzierung.
- Keine neuen Spielassets.
- Keine Asset-Dateien unter `assets/`.
- Kein finales Inselbild.
- Kein `frame_started`.
- Keine Bauzustaende.

## 9. Ergebnis

M16-A empfiehlt als naechsten moeglichen Code-Slice einen neutralen Plot-Marker.
Er ist sichtbar naeher an Talvori Welt als Foundation Choice, bleibt aber klein,
lokal, assetlos und ohne Architekturbruch.

Die lokale Build-Preview-Flaeche ist der zweitbeste Kandidat, sollte aber nur
als abstrakte Flaeche ohne Bauzustand formuliert werden. Foundation Choice
bleibt Fokus-/Einstiegslogik und wird nicht als Bau-Menue behandelt.
