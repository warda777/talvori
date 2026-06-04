# Phase 2G: Frame Started Plan

Stand: 2026-06-04

Dieses Dokument startet Phase 2G als reinen Planungsblock fuer
`frame_started` / Rohbau.

Fuehrende Dokumente:

- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`
- `docs/world_design/234-asset-production-and-buildable-island-templates.md`
- `docs/world_design/239-world-scale-and-dimension-rules.md`
- `docs/world_design/240-private-island-state-system.md`
- `docs/world_design/241-build-feedback-animation-and-sound.md`
- `docs/world_design/242-foundation-complete-plan.md`

## 1. Ziel Von Phase 2G

Phase 2G plant den naechsten Bauzustand nach `foundation_complete`:
`frame_started` / Rohbau.

Ziel ist nur Planung:

- definieren, was `frame_started` visuell bedeutet,
- Abgrenzung zu `foundation_complete` und spaeterem Haus klaeren,
- Asset-Scope und UX-Scope festlegen,
- technische Grenzen und Stop-Regeln dokumentieren,
- naechsten erlaubten Schritt nach diesem Planungsblock bestimmen.

Nicht-Ziel:

- kein Code,
- kein Asset,
- keine App-Integration,
- keine Tests,
- keine Persistenz,
- keine Supabase Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine Reward Bridge,
- keine Ressourcenlogik,
- keine produktive Bau-/Lernlogik.

## 2. Research-Gate-Entscheidung

Fuer diesen Planungsblock reichen die vorhandenen research-informierten Regeln
aus:

- `234` definiert Production Gates, Asset-Pipeline und buildable Templates.
- `239` definiert Scale, Footprints und Island-View-Groessenlogik.
- `240` trennt `BuildAreaState`, `PlacedWorldItemState`, Expansion, Interior
  und ObjectDetail.
- `241` definiert Game-Feel, Nutzerfuehrung, Feedback, Abstand und
  Sound-/FX-Grenzen.
- `242` definiert die Abgrenzung von `foundation_complete` zu Rohbau/Gebaeude.

Entscheidung fuer diesen Block:

- Keine neue grosse Recherche in diesem Planungsblock.
- Vor Asset-Erzeugung fuer `frame_started` soll ein kurzer fokussierter
  Research-/Referenzcheck dokumentiert werden, weil `frame_started` erstmals
  vertikale Gebaeudeteile und Silhouette einfuehrt.
- Der naechste Schritt nach diesem Dokument ist daher ein Asset-Prompt- und
  Freigabeblock mit kurzem Research-Gate, nicht Code.

## 3. Definition Von `frame_started`

`frame_started` ist der erste sichtbare Rohbauzustand auf dem fertigen
Fundament.

Er bedeutet:

- erste tragende Struktur ist erkennbar,
- Bau wirkt begonnen, aber klar unfertig,
- das Fundament bekommt Hoehe und Richtung,
- spaeterer Ausbau zu `frame_complete` und `building_level_1` bleibt moeglich.

Er bedeutet nicht:

- fertiges Haus,
- bewohnbares Gebaeude,
- fertige Huette,
- Innenraum,
- Deko- oder Komfortzustand,
- `PlacedWorldItemState`.

## 4. Abgrenzung Zu `foundation_complete`

`foundation_complete`:

- ist ein sauberer, vollstaendiger Sockel,
- bleibt flach und bodennah,
- traegt spaeter den Rohbau,
- enthaelt keine Waende, Stuetze, Dachform oder Gebaeude-Silhouette.

`frame_started`:

- steht auf `foundation_complete`,
- fuegt erste vertikale oder halbvertikale Rohbau-Elemente hinzu,
- zeigt klare Unfertigkeit,
- darf erste Stuetze, Pfosten, Rahmen oder Wandansaetze zeigen,
- bleibt offen und nicht bewohnbar.

## 5. Abgrenzung Zu `building_level_1`

`building_level_1` ist spaeter ein erstes nutzbares Gebaeude.

`frame_started` darf noch nicht wirken wie:

- fertige Huette,
- fertiges kleines Haus,
- rundum geschlossene Waende,
- fertiges Dach,
- fertige Tuer-/Fenster-Optik,
- bewohnbarer Zustand.

Der Nutzer soll verstehen:

> Das Haus entsteht, aber es ist noch Rohbau.

## 6. Visuelles Ziel Fuer `frame_started`

Erlaubt:

- erste Holz-/Stein-/Lehm-Grundstruktur,
- einzelne Stuetzen oder Pfosten,
- einfache Wandansaetze oder Rahmen,
- sichtbare unfertige Konstruktion,
- offene Struktur,
- klarer Rohbaucharakter,
- leichte Materialbindung an Waldlichtung, Stein, Erde und Holz,
- kleine Hoehe, die im Island View lesbar ist,
- genug Zurueckhaltung fuer spaeteres `frame_complete` und
  `building_level_1`.

Nicht erlaubt:

- fertiges Haus,
- fertige Waende rundherum,
- fertiges Dach,
- fertige Tuer oder fertige Fenster,
- Moebel,
- Innenraum,
- Deko wie Laternen, Kamin, Blumenbeete oder Garten als fertiges
  Gebaeudegefuehl,
- moderne Plattform- oder UI-Optik,
- zu grosser Massstab im Vergleich zur Insel,
- Blockierung von Hof, Weg, Docking, Expansion oder Randzonen,
- Kategorie-Symbole oder feste Themenbindung.

## 7. State-Reihenfolge

Geplante lokale Reihenfolge:

```text
empty -> foundation_started -> foundation_complete -> frame_started
```

Regeln:

- `frame_started` bleibt `BuildAreaState` / Overlay.
- `frame_started` ist noch kein `PlacedWorldItem`.
- Keine Expansion.
- Kein Interior.
- Kein ObjectDetail.
- Kein produktives Bau-/Lernsystem.
- Kein echtes Ressourcen- oder Reward-System.

## 8. Asset-Scope

Geplant fuer spaeteren Asset-Block:

- `frame_started` als transparentes Overlay,
- gleicher Canvas wie Base und Fundament-Overlays: `1536 x 1024`,
- gleiche 2.5D/isometrische Perspektive,
- sitzt auf derselben `main_build_area`,
- ersetzt visuell `foundation_complete` als aktueller BuildArea-Zustand,
- wird nicht dauerhaft mit `foundation_started` oder `foundation_complete`
  gestapelt,
- keine Full-State-Replacement-Insel,
- kein PlacedItem-System.

Noch nicht erzeugen:

- `frame_started.png`,
- `frame_complete.png`,
- `building_level_1.png`,
- Innenraumassets,
- Dekoassets,
- Sound- oder FX-Assets.

Moeglicher spaeterer Zielpfad:

```text
assets/images/world/buildable_islands/forest_clearing/frame_started.png
```

Der Pfad ist erst verbindlich, wenn der Asset-Prompt-/Freigabeblock ihn
bestaetigt.

## 9. UX-Scope

Phase 2G uebernimmt die UX-Regeln aus Phase 2F:

- Nutzerfuehrung durch kurzen Text plus Fokus/Glow.
- Keine doppelte Bestaetigung, solange keine Kosten, Ressourcen, Risiko oder
  Auswahl existieren.
- Direkter Tap darf den naechsten lokalen Mock-State ausloesen.
- Keine grosse Snackbar, wenn In-World-Label und sichtbarer Zustandswechsel
  reichen.
- Labels und Hinweise brauchen sichtbaren Abstand zu Bauobjekt,
  Fokusrahmen/Glow, Buttons und Hinweisboxen.
- Der Nutzer darf nicht raten muessen, was als naechstes passiert.

Vorschlag fuer Text vor der Aktion:

```text
Tippe auf das fertige Fundament, um den Rohbau zu beginnen.
```

Dieser Text ist passend, weil er:

- den aktuellen Zustand benennt,
- die naechste Aktion erklaert,
- kurz bleibt,
- keine technischen Begriffe wie `frame_started` nutzt.

Vorschlag fuer In-World-Label nach der Aktion:

```text
Rohbau begonnen
```

Dieser Text ist passend, weil er den neuen Zustand bestaetigt, ohne ein
fertiges Haus zu versprechen.

## 10. Feedback-Scope

Geplante Feedback-ID fuer spaeter:

```text
build.frame.started
```

Erlaubt in einem spaeteren engen Mock-Slice:

- kurzer Fokus auf `foundation_complete`,
- Fade-/Scale-Einblendung von `frame_started`,
- kleines In-World-Label `Rohbau begonnen`,
- vorbereitete Feedback-ID.

Nicht erlaubt:

- echte Sounddateien,
- Audio-/Sound-Implementierung,
- neue FX-Schicht,
- Partikel-Engine,
- Ressourcenanimation,
- Reward Bridge.

## 11. Technische Grenzen

Phase 2G-Planung erlaubt keine Implementierung.

Weiterhin blockiert:

- Flutter-/Dart-Code,
- App-Integration,
- Asset-Erzeugung,
- PNG-Aenderungen,
- Tests,
- Supabase Writes,
- Persistenz,
- SQLite-/SRS-/`word_progress`-Aenderungen,
- Reward Bridge,
- Ressourcenlogik,
- Sound-/FX-Schicht,
- Expansion,
- PlacedItems,
- Interiors/ObjectDetail,
- produktive Bau-/Lernlogik.

## 12. Template- und Metadatenfolge

Wenn ein `frame_started`-Asset spaeter erzeugt und vorgeprueft wird, muss
`assets/images/world/buildable_islands/forest_clearing/template.md`
ergaenzt werden:

- `assetPaths.frame_started`,
- `frameStartedOverlayAnchor`,
- `frameStartedOverlayScale`,
- sichtbare Bounds,
- Preview-/Device-Check,
- Freigabeentscheidung,
- `phase2GCodeAllowed` nur fuer einen explizit freigegebenen lokalen
  Mock-Slice.

Keine dieser Metadaten wird in diesem Planungsblock final geschaetzt.

## 13. Stop-Regeln

Stoppen, wenn:

- `frame_started` wie fertiges Haus wirkt,
- fertige Waende rundherum, fertiges Dach, Tuer/Fenster oder bewohnbare Optik
  enthalten sind,
- `frame_started` als `PlacedWorldItem` geplant wird,
- Expansion, Interior oder ObjectDetail hineinrutschen,
- das Asset zu gross fuer Insel, Hof, Weg oder Expansion wirkt,
- UI/Marker/Plattform-Optik entsteht,
- Kategorie hart eingebaut wird,
- direkte Tap-Aktion ohne sichtbare Nutzerfuehrung geplant wird,
- Abstandsregeln zwischen Bauobjekt, Fokus und Label nicht beachtet werden,
- Code, Asset-Erzeugung oder Tests in diesem Planungsblock begonnen werden.

## 14. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- klar ist, was `frame_started` visuell bedeutet,
- `frame_started` klar von `foundation_complete` abgegrenzt ist,
- `frame_started` klar von `building_level_1` abgegrenzt ist,
- State-Reihenfolge und `BuildAreaState`-Grenze definiert sind,
- kein `PlacedWorldItem`, keine Expansion, kein Interior und kein
  ObjectDetail vorweggenommen wird,
- UX-Regeln aus Phase 2F uebernommen sind,
- Asset-Scope und Stop-Regeln fuer einen spaeteren Asset-Prompt ableitbar sind,
- Phase 2G-Code und Asset-Erzeugung weiterhin blockiert bleiben.

## 15. Naechster Erlaubter Schritt

Nach diesem Planungsblock ist der naechste erlaubte Schritt:

- Asset-Prompt-/Freigabeblock fuer `frame_started`,
- mit kurzem fokussiertem Professional Game Development Research Gate,
- ohne Code,
- ohne App-Integration,
- ohne Persistenz/Supabase/SRS/Reward/Ressourcenlogik.

Phase-2G-Code bleibt blockiert, bis:

- `frame_started`-Asset erzeugt,
- lokal vorgeprueft,
- in `template.md` dokumentiert,
- auf Geraet geprueft,
- formal fuer einen engen lokalen Mock-Slice freigegeben wurde.

## 16. Offene Fragen

- Welche konkrete Materialmischung wirkt fuer die Waldlichtung am besten:
  Holzrahmen, Stein/Holz-Mix oder Lehm/Holz?
- Wie hoch darf der erste Rohbau sein, ohne die Insel zu dominieren?
- Soll `frame_started` eher ein neutrales Haus/Huetten-Frame bleiben oder
  bereits leichte Varianten fuer spaetere Kategorien vorbereiten?
- Reicht ein transparentes Overlay fuer `frame_started`, oder muss nach der
  ersten Device-Pruefung eine alternative Asset-Strategie geprueft werden?
