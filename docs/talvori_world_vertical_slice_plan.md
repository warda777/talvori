# Talvori Welt Vertical Slice Plan

Stand: 2026-06-01

Dieses Dokument definiert den ersten Engineering-Slice fuer Talvori Welt. Es
ist Planung, keine Implementierung. Es wurden keine Produktionsdaten, keine
Supabase-Daten, keine Imports, keine SQLite-/Vokabeldaten, keine SRS-Daten und
kein `word_progress` geaendert.

## 1. Ziel Des Vertical Slice

Der erste Slice soll beweisen:

- Home ist eine Welt-Zentrale.
- Die Weltkugel ist die zentrale Handlung.
- Lernen erzeugt sichtbaren Weltfortschritt.
- Tali oder Vori begleitet als ausgewaehlter Companion.
- Der Prototyp funktioniert lokal ohne Cloud-Abhaengigkeit.

Der Slice soll klein genug bleiben, um schnell testbar zu sein, aber gross
genug, um den neuen Produktkern zu fuehlen.

## 2. Home: Talvori-Welt-Zentrale

Elemente:

- dunkler Space-/Neon-Hintergrund
- grosse rotierende oder pulsierende Weltkugel als Hauptaktion
- reduzierter oder entfernter oberer Bildframe
- Top Bar mit sinnvoller Statusinformation:
  - Streak oder Tagesenergie
  - Ressourcen-Kurzstand
  - Companion-Zustand
  - Weltfortschritt
- Zentraler Smart-Hub statt dauerhaftem Bottom Dock:
  - Lernen
  - Woerter / Import
  - Spiele
  - Welt
  - Satzfunken / Tagesimpuls
  - Profil/Freunde, wenn sinnvoll
- Companion sichtbar, aber nicht dominant ueber dem Globe

Designentscheidung:

- Die Home-Zentrale nutzt vorerst einen zentralen Smart-Hub statt eines
  permanenten Bottom-Docks, damit der Globus der visuelle Hero bleibt.

Nicht-Ziele:

- keine komplette Home-Neugestaltung ueber alle Features hinweg
- keine Cloud-Welt
- kein globaler Chat
- keine Paywall vor dem ersten Weltmoment

## 3. Companion Slice

Companion-Auswahl:

- Tali oder Vori ist aktiv.
- Aktiver Companion kann spaeter in Profile/Settings gewechselt werden.
- Im Slice reicht ein lokaler Zustand/Stub.

Zustaende:

- `idle`
- `focus`
- `chat_open`
- `excited`
- `comeback`
- `soft_reminder`

Interaktion:

- kleiner Avatar auf Home
- Tap zeigt Fokus/Bubble
- zweiter Tap oder Bubble Action oeffnet Companion Chat Sheet
- Quick Actions:
  - `Was kann ich lernen?`
  - `Baue weiter`
  - `Mach aus meinen Woertern einen Satz`
  - `Zeig mir meine Welt`

Trennung:

- Companion Chat ist Tali/Vori.
- Human Chat/Friends ist spaeter ein eigener Social-Bereich.

## 4. World Slice

Lokaler Start:

- eine Startregion
- ein eigener Plot
- wenige Beispielplots als visuelle Nachbarschaft
- kein echtes Social Backend
- lokale Speicherung

Gebaeude:

- House
- Market
- Library

Jedes Gebaeude:

- Level 1
- Level 2
- Level 3
- sichtbarer Fortschritt durch Ressourcen
- klare, simple Silhouette

Umgebung:

- Terrasse oder Vorplatz
- Pond/tree group
- kleine Wege oder Lichtpunkte

Ziel:

- Nutzer sieht nach einer kurzen Session: Etwas ist gewachsen.

## 5. Building Und Resources

Ressourcen:

- `stone`
- `wood`
- `glass`
- `residents`
- `light`

Erste Mapping-Idee:

- Meaning recognition -> `stone`
- Typing -> `wood`
- Cloze sentence -> `glass`
- Phrase/context task -> `residents`
- Companion/NPC answer -> `light`

Regel:

- Ressourcen duerfen aus LearningResult entstehen.
- Ressourcen duerfen SRS/`word_progress` nicht veraendern.
- Reward-Events muessen getrennt speicherbar sein.

## 6. Exercise Slice

Erste Uebungstypen fuer den Weltaufbau:

- meaning recognition
- typing
- cloze sentence
- phrase task
- NPC selection answer

Anbindung:

- bestehende Lern- und Spielpfade bleiben erhalten
- am Ende einer Aufgabe entsteht ein `LearningResult`
- Reward Bridge verarbeitet den Result
- UI zeigt Weltfortschritt

Nicht in diesem Slice:

- neue vollstaendige SRS-Regeln
- alte Fortschrittssemantik aendern
- Migrationslogik fuer `word_progress`

## 7. KI / Import Slice

Bestehende wertvolle Pfade:

- Web-/Share-Wortimport
- DeepL-/Translation-Logik
- AI-/Companion-Chat
- Tagesimpuls

Erster Slice:

- 3-5 importierte oder ausgewaehlte Woerter koennen eine Sentence Spark
  erzeugen.
- Sentence Spark wird als Quest-/Companion-Material angezeigt.
- Kein automatischer Produktivimport.
- Keine ungepruefte Uebersetzung als finaler Content.

Beispiel:

- Nutzer sammelt `airport`, `ticket`, `luggage`.
- Companion erzeugt einen einfachen Kontextsatz.
- Daraus entsteht eine kleine Weltaktion oder NPC-Frage.

## 8. Social Minimum

Nur vorbereiten:

- friend preview
- showcase preview
- reactions concept

Nicht jetzt:

- global public chat
- public world feed
- ranking pressure
- moderation-heavy social surface

Sozialer Grundsatz:

- Freunde und Reaktionen sollen Weltfortschritt sichtbar machen.
- Human Chat bleibt getrennt vom Companion Chat.

## 9. Entitlements / Monetization

Nur konzeptionell vorbereiten:

- free
- welt_plus
- founder
- classroom
- feature limits

Regeln:

- kein harter Paywall-Block vor dem ersten Wow-Moment
- keine Lootboxes
- kein Pay-to-win
- keine Echtgeld-Plot-Auktionen
- keine Premium-Versprechen im ersten Slice

## 10. Akzeptanzkriterien

Ein erfolgreicher Slice:

- startet lokal
- zeigt Home mit zentralem Globe
- laesst den Nutzer in eine lokale Region/einen Plot gelangen
- zeigt drei Gebaeude mit Leveln
- zeigt Ressourcen
- erzeugt nach einer Lernaktion einen sichtbaren Baufortschritt
- zeigt Tali oder Vori in mindestens drei Zustaenden
- veraendert keine bestehende SRS-/`word_progress`-Semantik
- braucht keine Supabase Writes

## 11. Empfohlene Erste Implementierungsbloecke

1. Home-Zentrale UI-Prototyp mit Globe, Top Bar, Bottom Dock und Companion.
2. Lokale World-State-Models und Demo-Region ohne DB-Migration.
3. World Region Screen mit Plot und drei Gebaeuden.
4. Reward Bridge Interface und Fake/Lokal-Result-Demo.
5. Anschluss an eine bestehende Uebung als echtes `LearningResult`.
6. Companion Chat Sheet mit Zustandswechseln und Quick Actions.
