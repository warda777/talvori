# Citizen Base 01 Design Preview Intake Review

Status: documentation_intake_only
Runtime asset import: NO
Sprite sheet approval: NO
Flame integration: NO
Motion Lab approval: NO

## 1. Gepruefte Grundlagen

- `docs/world_design/433-talvori-base-character-asset-spec-v1.md`
- `docs/world_design/434-citizen-base-01-asset-production-plan.md`
- `docs/world_design/435-citizen-base-01-style-mini-brief.md`
- `docs/world_design/previews/firenze_character_foundation_2a/citizen_base_01_sprite_sheet_layout.png`
- `docs/world_design/previews/citizen_base_01_asset_production_plan/citizen_base_01_asset_production_flow.png`

## 2. Aufgenommene Dokumentationskandidaten

| Datei | Rolle | Dimension | SHA-256 |
| --- | --- | ---: | --- |
| `citizen_base_01_male_8dir_design_preview.png` | Primaerer Design-Preview-Kandidat fuer `citizen_base_01` | 1448 x 1086 | `bd0ddcddb084af61b823cf263a42034ea9e53f294019ea345acbc633fa68125b` |
| `citizen_base_02_female_8dir_style_reference.png` | Style-Family-Reference fuer spaetere Varianten | 1448 x 1086 | `1cc734c51122feaf9c188b263a1f1d77d960676f053974455e67693209ead81` |

Beide Dateien wurden nur nach
`docs/world_design/previews/citizen_base_01_design_preview_intake/`
kopiert. Es wurden keine Dateien unter `assets/` erzeugt.

## 3. Primaerkandidat: citizen_base_01_male

Entscheidung:

```text
citizen_base_01_male: PASS
```

Der Kandidat ist als 8-Richtungs-Design-Preview fuer die naechste
Idle-Produktionsvorbereitung freigegeben. Diese Freigabe ist keine
Sprite-Sheet-, Runtime-, Flame- oder Asset-Import-Freigabe.

| Kriterium | Review |
| --- | --- |
| 8 Richtungen vorhanden | PASS: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW` sind sichtbar. |
| Richtung-Reihenfolge | PASS: row-major entspricht `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`. |
| Erwachsener Eindruck | PASS: wirkt erwachsen, nicht chibi/kindlich. |
| Talvori-eigener Stil | PASS mit Hinweis: warme Fantasy-/Stadtbuerger-Richtung passt grundsaetzlich, muss aber in der Sprite-Produktion weniger heroisch und weniger ueberladen werden. |
| Kein kopierter Clash-/Fremd-IP-Stil | PASS fuer Design-Intake: keine direkte Fremd-IP erkennbar; vor Asset-Import bleibt Source-/License-Klaerung Pflicht. |
| Keine Strich-/Kreis-/Puppet-Figur | PASS. |
| Klare Silhouette | PASS: Kopf, Koerper, Arme, Beine und Fussstand sind lesbar. |
| Fuesse sichtbar | PASS: Fuesse sind in allen Ansichten sichtbar. |
| Fussanker kontrollierbar | PASS fuer Design-Preview: untere Fusslinie ist grundsaetzlich kontrollierbar; exakter `bottomCenter`-Anker muss in Sprite-/Idle-Produktion nachgewiesen werden. |
| Ost-/West-Profil | PASS: E/W zeigen Nase und Profilebene klar. |
| iPhone-Lesbarkeit plausibel | PASS mit Risiko: Silhouette ist lesbar, aber Guertel, Taschen, Schmucklinien und kleine Akzente sind fuer 96 x 128 Frames wahrscheinlich zu detailreich. |

Erkannte Fix-Hinweise vor Idle-/Frame-Produktion:

- Detaildichte reduzieren: weniger Taschen, Guertel, Schnallen und Mini-Ornamente.
- Outfit etwas neutraler halten, damit `citizen_base_01` nicht zu sehr wie ein
  Helden-/Abenteurer-Unit wirkt.
- Fuss-/Sohlenlinie pro Richtung fuer `bottomCenter` klar markieren.
- Source-/License-Status vor 2A.2 dokumentieren.
- Kontaktbogen fuer echte Frames muss transparenten Hintergrund und
  reproduzierbare Framegrenzen pruefbar machen.

## 4. Style-Reference: citizen_base_02_female_reference

Entscheidung:

```text
citizen_base_02_female_reference: STYLE_REFERENCE_PASS
```

Die weibliche Figur wird nur als Style-Family-Reference dokumentiert. Sie ist
kein Runtime-Asset, keine Freigabe fuer Variantenproduktion und kein Startpunkt
fuer NPCs. Varianten bleiben durch die Living World Production Sequence Rule
gesperrt, bis die Basisfigur freigegeben ist.

| Kriterium | Review |
| --- | --- |
| 8 Richtungen vorhanden | PASS: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW` sind sichtbar. |
| Richtung-Reihenfolge | PASS: row-major entspricht `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`. |
| Erwachsener Eindruck | PASS: wirkt erwachsen, nicht chibi/kindlich. |
| Gleiche Stilfamilie | PASS: Formensprache, Materialfarben, Proportionen und Outfit-Prinzip passen zum maennlichen Kandidaten. |
| Kein kopierter Clash-/Fremd-IP-Stil | PASS fuer Style-Reference-Intake: keine direkte Fremd-IP erkennbar; Source-/License-Klaerung bleibt vor jeder Asset-Nutzung Pflicht. |
| Keine Strich-/Kreis-/Puppet-Figur | PASS. |
| Klare Silhouette | PASS: Kopf, Koerper, Arme, Beine und Fussstand sind lesbar. |
| Fuesse sichtbar | PASS. |
| Fussanker kontrollierbar | PASS fuer Design-Reference; kein Runtime- oder Frame-Freigabestatus. |
| Ost-/West-Profil | PASS: E/W zeigen Nase und Profilebene klar. |
| iPhone-Lesbarkeit plausibel | PASS mit demselben Detailrisiko wie beim maennlichen Kandidaten. |

Abgrenzung:

- Keine Variantenproduktion vor Freigabe von `citizen_base_01`.
- Keine Ableitung von `citizen_base_02`-Sprite-Sheets aus diesem Slice.
- Keine App-/Flame-/Runtime-Nutzung.

## 5. Intake-Entscheidung

```text
citizen_base_01_male: PASS
citizen_base_02_female_reference: STYLE_REFERENCE_PASS
```

Der maennliche Design-Kandidat darf als Grundlage fuer einen engen
Idle-Produktionsvorbereitungs-Slice dienen. Die weibliche Referenz wird nur als
Style-Family-Reference fuer spaetere Varianten gespeichert.

## 6. Grenzen

- Kein `assets/`-Import.
- Keine echten Sprite-Sheets.
- Keine Flame-Integration.
- Kein Motion Lab.
- Keine Animation.
- Keine App-Integration.
- Keine JSON-/YAML-/YML-Dateien.
- Keine Persistenz.
- Kein Commit.

## 7. Naechster Schritt

Naechster enger Slice:

```text
Firenze Character Idle Design/Frame Production Prep 2A.3
```

Ziel des naechsten Slices sollte sein, aus dem freigegebenen maennlichen
8-Richtungs-Design eine klare Idle-Produktionsvorbereitung abzuleiten:
Framegrenzen, Fussanker, Transparenzanforderung, Kontaktbogen und
Source-/License-Metadata. Noch kein Motion Lab vor Asset Intake PASS.
