# Phase 2G-M10-B2: Challenge Interaction Visual Review

Stand: 2026-06-06

Status: `visuelle Pruefung gestartet / erste Empfehlung brauchbar`

Dieses Dokument prueft die M10-B-Previews visuell. Es entscheidet nicht ueber
Implementierung, finale UI, Spielassets, App-Integration, `frame_started` oder
ein allgemeines Challenge-System fuer alle Themen.

## 1. Ziel

M10-B hat Challenge-Arten fuer den Depth-/Container-Flow verglichen und eine
erste Empfehlung vorbereitet:

```text
MVP: Tap-Auswahl
Early: Audio + Tap
Later: Matching / Sortieren
Advanced: Mini-Sequenzen
```

M10-B2 prueft, ob diese Empfehlung in den Preview-Dateien visuell
nachvollziehbar ist und als erste Prototype-Richtung dokumentarisch brauchbar
ist.

## 2. Gepruefte Dateien

- `docs/world_design/previews/phase2g_m10b_challenge_interaction_comparison/01_challenge_type_matrix.png`
- `docs/world_design/previews/phase2g_m10b_challenge_interaction_comparison/02_kitchen_challenge_variants.png`
- `docs/world_design/previews/phase2g_m10b_challenge_interaction_comparison/03_recommended_challenge_progression.png`
- `docs/world_design/previews/phase2g_m10b_challenge_interaction_comparison/README.md`

## 3. Visuelle Pruefung

| Prueffrage | Bewertung |
| --- | --- |
| Ist die Matrix verstaendlich genug? | Ja, fuer interne Planung. Die Kriterien, Challenge-Arten und Ampelbewertung sind lesbar. |
| Ist sie zu dicht oder fuer interne Planung brauchbar? | Sie ist dicht und eher technisch, aber fuer ein internes Vergleichs-/Reviewbild brauchbar. Fuer Nutzer oder Produktkommunikation waere sie zu voll. |
| Wird klar, warum Tap-Auswahl fuer den ersten Prototype empfohlen wird? | Ja. Tap-Auswahl ist in Matrix, Variantenbild und Progressionsbild als schnell, klar, mobile-freundlich und MVP-tauglich markiert. |
| Wird klar, warum Audio + Tap erst zweite Stufe ist? | Ja. Audio + Tap wird als lernstark gezeigt, aber mit Silent-Mode- und Accessibility-Fallback als Voraussetzung. |
| Wird klar, warum Drag-and-drop riskanter ist? | Ja. Drag-and-drop ist sichtbar als spielerisch, aber riskant wegen Mobile-Zielgroessen, Motorik und Drop-Fehlern markiert. |
| Wird klar, warum Sortieren/Matching spaeter sinnvoll sind? | Ja. Beide werden als wertvolle spaetere Varianten gezeigt, aber nicht als erster Erfolgsmoment. |
| Wird klar, warum Mini-Sequenzen eher fuer Aktionen geeignet sind? | Ja. Die Progressionsgrafik setzt Mini-Sequenzen in Advanced und beschreibt sie fuer Handlungsketten wie `open -> take -> use`. |
| Sind Mobile-Bedienbarkeit und Accessibility ausreichend als Risiken markiert? | Ja. Mobile wird besonders bei Drag-and-drop markiert, Accessibility/Silent Mode besonders bei Audio + Tap. |
| Wird keine finale Challenge-Art-Freigabe suggeriert? | Ja. Die Previews nennen klar `not implementation approval` und die README blockiert finale UI, Code, Assets und allgemeines Challenge-System. |
| Sind die Previews klar Dokumentationsmaterial, keine UI und keine Spielassets? | Ja. Titel, Unterzeilen und README markieren den Preview-/Dokumentationscharakter ausreichend. |

## 4. Entscheidungsempfehlung

Empfehlung:

```text
M10-B Empfehlung grundsaetzlich bestaetigen.
```

Bestandteile:

- `MVP`: Tap-Auswahl.
- `Early`: Audio + Tap.
- `Later`: Matching / Sortieren.
- `Advanced`: Mini-Sequenzen.

Begruendung:

- Die erste Challenge muss in Sekunden verstaendlich sein und schnell einen
  belohnenden Erfolg erzeugen.
- Tap-Auswahl ist fuer mobile Touch-Bedienung am robustesten.
- Audio + Tap erhoeht den Lernwert, braucht aber Silent-Mode- und
  Accessibility-Fallbacks.
- Drag-and-drop kann spielerisch wirken, hat aber hoeheres Mobile- und
  Motorikrisiko.
- Matching und Sortieren passen gut zu Wortpaaren und Containern, brauchen aber
  mehr Regeln und mehr UI-Zustand.
- Mini-Sequenzen sind fuer Aktionswoerter stark, aber fuer den ersten
  Besteck-Flow zu komplex.

Diese Empfehlung bestaetigt nur eine erste Prototype-Richtung. Sie ist keine
finale Challenge-Systementscheidung fuer alle Themen.

## 5. Auffaelligkeiten Und Risiken

- Die Matrix ist fuer interne Planung brauchbar, aber zu technisch fuer eine
  spaetere Nutzer-/Produktansicht.
- Audio + Tap darf nicht ohne Silent-Mode- und Accessibility-Fallback geplant
  werden.
- Drag-and-drop darf nicht ohne Mobile-Bedienbarkeitspruefung entschieden
  werden.
- Sortieren und Matching brauchen weitere Beispiel-Flows, damit sie nicht nur
  aus dem Kuechen-/Besteckfall abgeleitet werden.
- Mini-Sequenzen brauchen spaeter eigene Aktionswort- und Kontextpruefung.
- M10-B2 bestaetigt keine Companion-Reaktion; M10-C bleibt offen.
- M10-B2 bestaetigt kein allgemeines Container-System; M11 bleibt offen.

## 6. Offene Follow-ups

| Follow-up | Status Nach M10-B2 | Bedeutung |
| --- | --- | --- |
| `Phase 2G-M10 Emotional Product Flow Preview` | `geprueft / grundsaetzlich brauchbar` | Emotionalere Produktflow-Preview bleibt als erstes Produktgefuehl brauchbar. |
| `Phase 2G-M10-B Challenge Interaction Comparison` | `geprueft / erste Empfehlung brauchbar` | Tap-Auswahl zuerst, Audio + Tap danach, Matching/Sortieren spaeter, Mini-Sequenzen advanced. |
| `Phase 2G-M10-C Companion Reaction Flow` | `offen` | Tali/Vori-Reaktion muss weiterhin als eigener Motivationsflow visualisiert werden. |
| `Phase 2G-M11 Multi-Example Container Flow Previews` | `offen` | Weitere Flows fuer Schule/Federmappe, Hafen/Bootskajute und Garten/Beet bleiben Pflichtpruefung. |

## 7. Stop-Regeln

Stoppen, wenn:

- aus M10-B2 eine Challenge-Implementierung abgeleitet wird,
- eine finale Challenge-Systementscheidung ohne M11 getroffen wird,
- Audio-Challenges ohne Silent-Mode- und Accessibility-Fallback geplant werden,
- Drag-and-drop ohne Mobile-Bedienbarkeitspruefung entschieden wird,
- aus M10-B oder M10-B2 App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus diesem Review wieder aufgenommen werden.

## 8. Naechster Erlaubter Schritt

Nach M10-B2 ist erlaubt:

- M10-B dokumentarisch als erste Challenge-Empfehlung bestaetigen,
- M10-C Companion Reaction Flow planen,
- M11 Multi-Example Container Flow Previews planen,
- M10-B bei konkreten Mobile-/Accessibility-Bedenken gezielt nachbessern.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNG-Aenderungen,
- finales Inselbild,
- `frame_started`,
- Bauzustaende,
- produktive Challenge-Implementierung.
