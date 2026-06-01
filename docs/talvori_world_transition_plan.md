# Talvori Welt Transition Plan

Stand: 2026-06-01

Dieses Dokument setzt die neue Produktausrichtung fest. Es ist ein
Planungsdokument. Es wurden keine App-Logik, keine Supabase-Daten, keine
Imports, keine SQLite-/Vokabeldaten, keine SRS-Daten und kein `word_progress`
geaendert.

## 1. Was Sich Strategisch Aendert

Talvori soll nicht mehr als normale Vokabel-App oeffentlich starten. Der alte
Release-MVP-Pfad bleibt als wertvolle Vorarbeit erhalten, wird aber nicht als
naechster Launch-Pfad fortgesetzt.

Neue Richtung:

> Meine Woerter bauen eine Welt.

Talvori Welt verbindet reale gesammelte Woerter, Phrasen, Saetze, Kontext,
Uebungen und Companion-Chat mit sichtbarem Welt-/Stadtfortschritt.

Core sentence:

> Sammle Woerter aus der echten Welt. Lerne sie im Kontext. Baue deine Welt.
> Wachse mit Freunden.

## 2. Was Bestehende Arbeit Weiter Wertvoll Macht

Die aktuelle App ist die Foundation Build fuer Talvori Welt.

Wertvolle bestehende Bausteine:

- lokale Wortdaten, Wortwelten und Kategorien
- Lernmodus und SRS-/`word_progress`-Logik
- Wortspiele und Challenge-Screens
- Web-/Share-Import
- DeepL-/Translation- und Supabase Edge Function Pfade
- AI-/Companion-Chat-Pfade
- Tali/Vori-Emotionen und Home-Portal-Vorarbeit
- Tagesimpuls, Impuls-Postfach und lokale Notifications
- Profile, Settings, Stats, Rewards und Leaderboard-Grundlagen
- Supabase-Strategie, Release-Guards und Content-Package-Planung
- Store-/Legal-/Data-Safety-Dokumentation als spaeteres Compliance-Material
- Vokabelreview-Workflow, Overlays und gepruefte Screenshot-Wortauswahl

Diese Arbeit wird nicht verworfen. Sie wird in einen staerkeren Produktkontext
ueberfuehrt.

## 3. Was Am Alten Launch-Pfad Pausiert Ist

Pausiert/superseded:

- oeffentlicher Launch als klassische Vokabel-App
- Store-Screenshots und Store-Texte fuer einen normalen Vocabulary-MVP
- finale Play/App-Store-Einreichung auf Basis der alten Positionierung
- Content-Review nur mit dem Ziel, einen kleinen Vocabulary-MVP zu zeigen

Preserved:

- Legal-/Support-/Data-Safety-Docs
- Android Release Build und Signing-Vorarbeit
- Store-Checklisten
- MVP-Content-Scope und Review-Overlays
- Supabase-/Content-Package-Sicherheitsarbeit

Diese Dokumente bleiben nuetzlich, sollen aber vor einer echten Einreichung auf
Talvori Welt umgeschrieben werden.

## 4. Neue Erste Oeffentliche Release-Demonstration

Ein erster oeffentlicher Talvori-Welt-Release muss nicht die komplette Cloud-,
Social- oder Monetarisierungsvision enthalten. Er muss aber den Kern sofort
spuerbar machen:

- Nutzer sammelt oder nutzt Woerter.
- Nutzer lernt sie in Kontext.
- Lernen erzeugt sichtbare Ressourcen oder Fortschritt.
- Diese Ressourcen bauen auf einem eigenen Plot sichtbar etwas auf.
- Tali oder Vori begleitet den Prozess.
- Home fuehlt sich wie eine Welt-Zentrale an, nicht wie eine normale
  Vokabel-App.

## 5. Home Als Talvori-Welt-Zentrale

Entscheidung:

- Der aktuelle Home Screen wird zur Talvori-Welt-Zentrale.
- Dark space/neon look bleibt und wird verstaerkt.
- Das obere Bildframe wird entfernt oder stark reduziert.
- Der alte Play Button ist nicht mehr die Hauptaktion.
- Die grosse rotierende/pulsierende Weltkugel ist die zentrale Aktion.
- Globe Tap fuehrt spaeter in Region/Stadt/Welt.
- Top-Status bleibt, wenn er Weltfortschritt, Energie, Streak, Ressourcen oder
  Companion-Kontext sinnvoll traegt.
- Bottom Dock fuehrt zu Lernen, Woertern, Spielen, Welt und Profil/Settings.

## 6. Companion-Entscheidung

- Tali oder Vori ist der aktive ausgewaehlte Companion.
- Beide bleiben als Personas wertvoll, aber nicht als zwei parallele permanente
  Systeme auf dem Home Screen.
- Companion Tap Flow: kleiner Avatar -> Fokus/Bubble -> Companion Chat Sheet.
- Companion Chat bleibt getrennt von Human Chat/Friends.
- Companion soll Woerter, Saetze, Importmaterial und Weltfortschritt erklaeren,
  motivieren und in Quests uebersetzen.

## 7. Go/No-Go Kriterien Fuer Den Neuen Prototyp

Go, wenn:

- Ein neuer Nutzer versteht in der ersten Minute: Woerter bauen eine Welt.
- Eine erste kurze Session erzeugt sichtbar etwas auf dem eigenen Plot.
- Der Home Screen mit Globe fuehlt sich premium, klar und neugierig an.
- Tali/Vori wirkt als hilfreicher Companion, nicht als dekorativer Sticker.
- Import, DeepL oder KI-Sentence-Spark fuehlen sich wie Rohmaterial fuer die
  Welt an.
- Die Paywall kommt nach dem ersten Wow-Moment, nicht davor.

No-Go, wenn:

- Die App wirkt weiter wie eine normale Vokabel-App mit Welt-Deko.
- Lernen und Weltfortschritt sind nur lose nebeneinander.
- Home bleibt Play-Button-zentriert.
- Tali/Vori ist unklar oder konkurriert mit Human Chat.
- Social wird zu frueh als globaler Chat gedacht.
- Monetarisierung blockiert den ersten sichtbaren Erfolg.

## 8. Alte Docs Mit Supersession Notice

Alte MVP-/Store-Dokumente bleiben erhalten und werden mit einem kurzen Hinweis
markiert:

> This document belongs to the old vocabulary-app MVP launch path. It is
> preserved as Foundation Build / future compliance material. The current
> public product direction is Talvori Welt; do not continue this as the next
> launch path without explicit decision.

## 9. Naechste Sichere Bloecke

1. Talvori-Welt-Zentrale als UI-Plan und dann Implementierungsblock.
2. Lokaler Welt-Slice mit Plot, drei Gebaeuden und Ressourcenmodell.
3. Reward Bridge als separate Schicht zwischen Lernen und Welt.
4. Companion-Zustandsmodell und Chat-Sheet-Integration.
5. Import/DeepL/KI-Sentence-Sparks als Quest-Rohmaterial.
6. Social-Minimum als Friends/Showcase/Reactions-Konzept.
