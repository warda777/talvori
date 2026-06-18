# 435 Citizen Base 01 Style Mini Brief

Status: style_brief_only / documentation_only
Character: `citizen_base_01`
Runtime release: NO
Sprite asset generation: NO
Flame integration: NO

## 1. Ziel

Dieser Mini-Brief beschreibt genau eine neutrale Talvori-Basisfigur:
`citizen_base_01`.

Zweck ist die echte Asset-Produktion fuer den spaeteren
`Firenze Character Motion Lab 2B`. Dieser Slice erzeugt keine Varianten,
keinen Worker, keinen Haendler, kein NPC-System und keine Asset-Dateien.

## 2. Visuelle Richtung

- Freundlich, warm, spielhaft und Talvori-eigen.
- 3/4 top-down / isometric-friendly.
- Auf iPhone im Landscape-Modus lesbar.
- Klare Silhouette: Kopf, Koerper, Arme, Beine.
- Keine realistische Anatomie, aber glaubwuerdige Spielfigur.
- Keine Strichfigur.
- Kein Kreis-Maennchen.
- Kein Puppet-Look.
- Kein Clash-of-Clans-Klon.
- Keine fremde IP und kein erkennbar kopierter fremder Spielstil.

## 3. Form und Proportion

- Kompakter Koerper mit gut lesbarer Grundform.
- Leicht ueberzeichneter Kopf, aber nicht so gross, dass die Fuesse verdeckt
  werden.
- Kurze, lesbare Beine mit klarer Fussposition.
- Arme muessen in Idle und Walk erkennbar bleiben, ohne als Puppet-Glieder zu
  wirken.
- Outfit neutral und einfach.
- Keine ueberladenen Details, keine kleinen Dekorformen, die im City-Zoom
  rauschen.
- Keine Waffen.
- Keine Kampfpose.
- Kein UI-Icon-Charakter; die Figur muss wie eine Person in der Welt wirken.

## 4. Farbrichtung

- Talvori-kompatibel: warm, ruhig, freundlich.
- Ruhige Hauptfarben mit klarer Silhouette.
- Ausreichender Kontrast zur Firenze-Karte und zu warmen Stadt-/Steinfarben.
- Keine zu grellen Clash-/Comic-Farben.
- Keine Neon-Hauptfigur.
- Kleine Akzentfarbe ist erlaubt, wenn sie die Richtungserkennung verbessert.
- Schatten und Outline duerfen helfen, muessen aber weich und spielweltlich
  bleiben.

## 5. Animationsanforderung

- `idle_8dir`: 8 Richtungen x 2 Frames.
- `walk_8dir`: 8 Richtungen x 4 Frames.
- Richtung-Reihenfolge: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`.
- Framegroesse: 96 x 128 px.
- Fussanker: `bottomCenter`, vorgeschlagen `(48, 118)`.
- Hintergrund: transparent.
- Schatten: separat oder stabil gebacken.
- Keine Runtime-Ganzkoerperrotation.
- Die Richtung wird spaeter ueber Direction Buckets gewaehlt.
- Framewechsel duerfen die Fussposition nicht verschieben.

## 6. Erster Produktionsauftrag

Auftrag fuer eine Kuenstlerin, einen Designer oder ein Bild-/Sprite-Tool:

> Erstelle zuerst nur eine Design-Preview von `citizen_base_01` in acht
> Richtungen: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`. Die Figur soll
> freundlich, warm, spielhaft und Talvori-eigen wirken, in 3/4 top-down
> funktionieren und auf einem iPhone-Landscape-City-Screen klar lesbar sein.
> Noch keine Walk-Animation erstellen. Erst muessen Silhouette, Stil,
> Perspektive, Fussanker und Richtungskonsistenz freigegeben werden. Danach
> folgen Idle-Frames und erst danach Walk-Frames.

Produktionsreihenfolge:

1. 8-Richtungs-Design-Preview ohne Walk-Animation.
2. Pruefung von Silhouette, Stil und Perspektive.
3. Pruefung von Fussanker und Schattenanker.
4. `idle_8dir` mit 2 Frames je Richtung.
5. `walk_8dir` mit 4 Frames je Richtung.
6. Contact Sheet und Metadata fuer Asset Intake 2A.2.

## 7. Negative Prompt / Verboten

```text
no stick figure
no ball character
no puppet limbs
no full-body rotation
no copied Clash of Clans style
no realistic human
no weapons
no combat unit
no UI icon character
no oversized head covering the feet
no inconsistent foot anchor
```

Zusaetzlich verboten:

- keine prozedurale Code-Figur,
- keine Fake-Sprite-Attrappe,
- keine fremde IP,
- kein Asset ohne Source-/License-Klaerung.

## 8. Abnahme vor Asset Intake

Vor `Firenze Character Asset Intake 2A.2` muss gelten:

- 8-Richtungs-Design ist freigegeben.
- Fussanker ist sichtbar kontrollierbar.
- Contact Sheet ist lesbar.
- Richtung-Reihenfolge ist eindeutig.
- Figur bleibt in allen Richtungen dieselbe Person.
- Stil passt zu Talvori und wirkt nicht wie kopierte Fremd-IP.
- Keine Integration vor Freigabe.
- 2A.2 startet erst mit echten PNG-Dateien.

## 9. Grenzen

- Keine App-Integration.
- Keine Flame-Character-Implementierung.
- Keine echten Sprite-Assets.
- Keine Dateien unter `assets/images/world/characters/`.
- Keine KI-Bildgenerierung durch Codex.
- Keine prozeduralen Figuren.
- Keine Aenderung an `pubspec.yaml`.
- Keine JSON-/YAML-/YML-Dateien.
- Keine Persistenz.
- Kein Commit.

## 10. Ergebnis

Zentrale Stilentscheidung: `citizen_base_01` wird als warme, freundliche,
neutrale Talvori-Basisfigur im 3/4-top-down Stil produziert, nicht als
realistische Person, nicht als Puppet und nicht als kopierter fremder
Spielstil.

Naechster konkreter Schritt: echte 8-Richtungs-Design-Preview produzieren.
Erst danach duerfen Idle-/Walk-Frames und spaeter `Firenze Character Asset
Intake 2A.2` folgen.

