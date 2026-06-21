# Unity Prototype Foundation Readiness Plan

Status: `docs_only` / `g1_readiness_plan` / `no_unity_project` /
`no_code` / `no_assets` / `no_commit`

Stand: 2026-06-21

## 1. Ziel

Dieser Slice bereitet G1 aus
`443-p02-vertical-slice-and-online-foundation-roadmap.md` vor:

```text
G1: Unity Prototype Foundation
Required Outcome: Separate Unity 6 URP project/repo boots locally with version
policy and build target.
Opens: Environment kit intake.
```

Dieses Dokument erzeugt kein Unity-Projekt, keinen App-Code, keinen
Flutter-/Dart-/C#-Code und keine Assets. Es definiert nur die sichere
Vorbereitung fuer den separaten Unity-P02-Prototyp.

## 2. Grundlage

Fuehrend:

- `AGENTS.md`
- `442-talvori-unity-modular-district-platform-decision.md`
- `443-p02-vertical-slice-and-online-foundation-roadmap.md`
- `336-documentation-map-and-slice-reading-rules.md`
- `328-talvori-learning-game-readiness-todo-checklist.md`
- `370-asset-family-and-export-spec.md`

Lokale Preflight-Beobachtung in diesem Slice:

- Git-Status zeigte nur die erwarteten untracked Legacy-Bereiche
  `lib/features/world/local_world/ui/widgets/previews/talvori_explorer/` und
  `macos/`.
- Dokumentnummer `444` war frei.
- Unity wurde in den geprueften Standardpfaden nicht nachgewiesen:
  `/Applications/Unity/Hub/Editor` existierte nicht und `/Applications` zeigte
  keinen offensichtlichen Unity-Eintrag. Das ist kein harter Fehler fuer diesen
  Docs-Slice, aber eine manuelle G1-Voraussetzung.

## 3. Projekt-/Repo-Entscheidung

Empfehlung: eigenes Repo `talvori_game_unity`, als Sibling neben dem Flutter
Foundation Repo.

Empfohlener lokaler Zielpfad:

```text
/Users/andreaswarda/Documents/Dev/talvori_game_unity/
```

| Option | Bewertung | Vorteile | Nachteile | Empfehlung |
| --- | --- | --- | --- | --- |
| Separates Repo `talvori_game_unity` | Beste Option fuer G1 | Saubere Unity-History, eigener `.gitignore`, Git LFS ohne Flutter-Risiko, klare Runtime-Grenze, getrennte Build-/Library-/Cache-Last. | Cross-Repo-Doku/Handoff muss bewusst bleiben. | YES |
| Separater lokaler Ordner ohne eigenes Repo | Brauchbar nur fuer sehr kurzen lokalen Smoke-Test | Schnell, kein Flutter-Repo-Risiko. | Keine robuste Versionierung, kein nachvollziehbarer LFS-/Branch-/Commit-Pfad. | Nur als Wegwerf-Vortest |
| Monorepo-Unterordner im Flutter-Repo | Nicht empfohlen | Eine gemeinsame Historie und einfache lokale Sichtbarkeit. | Unity `Library`, `Temp`, grosse Binaries, LFS und Build-Artefakte koennen die Foundation Build verschmutzen; Scope-Grenze wird unscharf. | NO |

G1 sollte erst als Implementation Slice starten, wenn Andreas die separate
Repo-/Ordnerentscheidung bestaetigt.

## 4. Unity Foundation Voraussetzungen

### Unity-Version

- Ziel: Unity 6 URP.
- Die genaue Editor-Version muss beim G1-Start aus Unity Hub oder dem
  installierten Editor abgelesen und im Unity-Projekt gepinnt werden.
- Empfehlung: eine Unity-6-LTS-Version verwenden und nicht innerhalb des P02
  Proofs zwischen Minor-Versionen wechseln.
- Spaeter zu dokumentieren:
  `ProjectSettings/ProjectVersion.txt`, Unity Hub Version, installierte Module.

### Unity Hub / Editor Readiness

Vor G1 muss Andreas lokal pruefen:

- Unity Hub installiert und startbar,
- Unity 6 Editor installiert,
- URP-Template oder URP-Paket verfuegbar,
- macOS Build Support verfuegbar,
- iOS Build Support installiert oder als spaeteres Modul nachinstallierbar,
- Xcode vorhanden und fuer spaetere iOS-Builds akzeptiert.

Der erste Build-Zieltest ist macOS. iPhone/iOS folgt spaeter, sobald der G1
macOS Smoke-Test stabil ist.

### URP

G1 nutzt ein Unity 6 URP-Projekt oder ein 3D-Projekt mit sauber eingerichteter
URP Render Pipeline. Keine HDRP- oder Built-in-Pipeline-Experimente fuer P02.

### Git / LFS / Ignore

Das Unity-Repo braucht vor dem ersten Commit:

- Unity `.gitignore`,
- Git LFS fuer grosse und binaere Asset-Typen,
- klare Regel: `Library/`, `Temp/`, `Obj/`, `Build/`, `Builds/`, `Logs/`,
  `UserSettings/` und Cache-Verzeichnisse nicht committen.

Empfohlene LFS-Kandidaten:

- `*.fbx`
- `*.glb`
- `*.gltf`
- `*.blend`
- `*.png`
- `*.psd`
- `*.tif`
- `*.tiff`
- `*.exr`
- `*.wav`
- `*.mp3`
- `*.mp4`
- grosse Unity Packages, falls spaeter genutzt

G1 ist nicht bestanden, wenn grosse Unity-Generated-Ordner oder lokale Cache-
Dateien im Git sichtbar werden.

## 5. Minimaler G1-Prototyp

G1 soll nur beweisen, dass der Unity-Prototyp sauber bootet und lokal baubar
ist.

Mindestumfang:

- separates Unity-6-URP-Projekt/Repo,
- eine leere Unity-Szene, z. B. `P02_G1_Foundation`,
- feste isometrische Kamera, orthographic oder kontrolliert perspektivisch,
- einfache Bodenflaeche,
- NavMesh-ready Flaeche ohne finalen District,
- Platzhalter-Capsule als Explorer-Proxy,
- einfaches Licht-Setup,
- keine Produktionstexturen,
- keine Meshy-/Explorer-/Kit-Assets,
- macOS Build als erster Smoke-Test.

Nicht Teil von G1:

- P02-District-Assembly,
- Environment-Kit-Import,
- Explorer-Import,
- Adventure Creator,
- Addressables,
- Backend,
- Online,
- Chat,
- iPhone-Build als Pflicht.

G1 gilt als geoeffnet, wenn der Implementierungs-Slice diese Grundlagen bauen
darf. G1 gilt erst als bestanden, wenn das separate Unity-Projekt lokal bootet,
die Testszene oeffnet und ein macOS Build erzeugt.

## 6. Explorer-Import-Vorbereitung

Die vorhandenen Meshy-/Rigging-Dateien bleiben nur Referenz. In diesem Slice
wird nichts importiert.

Bekannte lokale Referenzpfade:

```text
_incoming_character_assets/talvori_character_explorer_v1/talvori_character_explorer_meshy_apose_source_v1.glb
_incoming_character_assets/talvori_character_explorer_v1/apose_rigging_tests/talvori_character_explorer_meshy_apose_lod_120k.glb
_incoming_character_assets/talvori_character_explorer_v1/apose_rigging_tests/Meshy_AI_biped 2/Meshy_AI_biped_Character_output.fbx
_incoming_character_assets/talvori_character_explorer_v1/apose_rigging_tests/Meshy_AI_biped 2/Meshy_AI_biped_Animation_Idle_9_withSkin.fbx
_incoming_character_assets/talvori_character_explorer_v1/apose_rigging_tests/Meshy_AI_biped 2/Meshy_AI_biped_Animation_walking_2_inplace_withSkin.fbx
```

Wahrscheinliche spaetere Primaerlinie:

- fuer visuelle/scale QA: `talvori_character_explorer_meshy_apose_lod_120k.glb`,
- fuer Rig/Animation-Import: `Meshy_AI_biped 2` mit
  `Character_output.fbx`, `Idle_9_withSkin.fbx` und
  `walking_2_inplace_withSkin.fbx`.

Spaetere Unity-QA-Punkte:

- Lizenz/Provenance,
- Import-Scale,
- Pivot/Fusspunkt,
- Material-/Texture-Zuweisung,
- Animator/Rig-Kompatibilitaet,
- Idle/Walk in-place,
- keine Root-Motion als Standardbewegung,
- LOD/Tris/Mobile-Budget,
- Collider/CharacterController-Proxy,
- Silhouette und Kamera-Lesbarkeit.

## 7. Environment-Kit Intake Vorbereitung

G2 darf erst nach G1 starten. G1 kann aber die Intake-Kriterien vorbereiten.

Kit-Kriterien aus `443` und `370`:

| Kriterium | Muss spaeter geprueft werden |
| --- | --- |
| Lizenz / Provenance | Quelle, Lizenz, kommerzielle Nutzbarkeit, Attribution, Autor, Version, Exportdatum. |
| Unity-Kompatibilitaet | Unity 6, URP-Materialien, Import ohne kaputte Shader. |
| Stilfit | Talvori Neo-Renaissance / Magical Renaissance, warmes Firenze, keine moderne Asphalt-/Auto-/Sci-Fi-Stadt. |
| Demo-Szene | Kit sollte eine pruefbare Demo-/Example-Szene oder klare Prefab-Struktur haben. |
| Mobile-Performance | Tris, Draw Calls, Materialanzahl, Texturaufloesungen, LODs oder klare Reduktionsoptionen. |
| Units / Scale | Plausible Meter-/Unity-Unit-Skala, Explorer- und District-kompatibel. |
| Pivot / Origin | Boden- und Platzierungspivots sinnvoll. |
| Colliders | Collider vorhanden oder sauber nachruestbar; keine automatische Navigation aus sichtbarer Art. |
| Prefabs | Wiederverwendbare Module fuer Strasse, Fassade, Treppe, Curb, Plaza, Props. |
| Texturbudget | Atlas, Trim Sheet oder klare Materialfamilien statt unkontrollierter Einzeltexturen. |
| Addressables Readiness | Spaetere Labels fuer District, Kit, Variant, Prop und QA-Status moeglich. |

Kit-Quellen duerfen erst nach Lizenz-/Provenance-Check in den Unity-Prototyp.

## 8. Codex-/Andreas-Rollen und Risikoentscheidung

Codex darf in einem spaeteren Unity-G1-Implementation-Slice sinnvoll
automatisieren:

- Repo-/Projektstruktur vorschlagen,
- `.gitignore` und LFS-Regeln vorbereiten,
- technische Checklisten erstellen,
- Unity-Projektdateien nur nach expliziter G1-Freigabe erzeugen,
- einfache Testszene/Platzhalter nur im separaten Unity-Repo anlegen,
- Build-/QA-Checklisten und lokale Commands dokumentieren,
- spaeter Editor-Scripts fuer Import/QA schreiben, wenn ein Unity-Slice das
  ausdruecklich erlaubt.

Andreas muss manuell pruefen oder freigeben:

- Unity Hub / Editor Installation,
- genaue Unity-6-Version,
- separate Repo-/Remote-Entscheidung,
- macOS/iOS Module,
- Unity-Lizenz/Login/Hub-Zustand,
- Environment-Kit-Auswahl,
- Asset-Lizenz-/Store-Nutzungsrechte,
- visuelle Qualitaet im Unity Editor,
- Build auf echter Zielhardware.

Erst nach G1 oeffnen:

- Environment-Kit-Import,
- Explorer-Import,
- P02-Blockout,
- Adventure Creator Test,
- Addressables,
- Online-Provider-Vergleich,
- Chat/Social.

## 9. G1-Ready-Checkliste

Vor dem naechsten Implementation-Slice:

- [ ] Andreas bestaetigt Repo-Option, empfohlen `talvori_game_unity`.
- [ ] Unity Hub und Unity 6 Editor sind lokal installiert und startbar.
- [ ] Ziel-Unity-Version ist notiert.
- [ ] macOS Build Support ist verfuegbar.
- [ ] iOS Build Support ist als spaeteres Modul geplant.
- [ ] Git LFS ist fuer das neue Repo vorgesehen.
- [ ] Unity `.gitignore` ist Pflicht im neuen Repo.
- [ ] Keine Assets werden im G1-Slice importiert.
- [ ] G1-Scope ist auf leere Szene, Kamera, Boden, NavMesh-ready Flaeche,
  Capsule-Proxy und macOS Build begrenzt.

## 10. Entscheidung

G1 kann nach diesem Docs-Slice als enger Implementation-Slice vorbereitet
werden, aber ist noch nicht bestanden.

Empfohlene naechste Aufgabe:

```text
Talvori Unity Prototype Foundation Implementation 2C
```

Nur starten, wenn Andreas bestaetigt:

- separates Repo `talvori_game_unity`,
- lokale Unity-6-Installation,
- kein Asset-Import,
- G1-Minimum wie oben.
