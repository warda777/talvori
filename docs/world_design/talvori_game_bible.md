# Talvori Game Bible

Stand: 2026-06-21

Status: `Produkt-/Game-/Lern-/Sprachreferenz / keine Implementierung`

Diese Game Bible ist die fuehrende Produktreferenz fuer Talvori Welt. Sie ist
kein Chatverlauf, kein Code-Gate, keine Persistenzfreigabe und keine
Produktivmechanik-Freigabe.

Unity Platform Supersession 2026-06-21:

- `442-talvori-unity-modular-district-platform-decision.md` und
  `443-p02-vertical-slice-and-online-foundation-roadmap.md` fuehren die
  Runtime- und Plattformarchitektur.
- Talvori ist nun primaer ein isometrisches 3D-Erkundungs- und Lernspiel in
  Unity 6 URP.
- Städte bestehen aus modularen, groesstenteils vorgebauten District-Szenen.
- Spieler veraendern feste Build-/Upgrade-Slots, nicht eine frei bebaubare
  Stadt.
- Der lokale P02-Slice kommt vor Online, Chat oder globaler Social-Welt.
- Aeltere 2D/2.5D-Formulierungen bleiben fuer mobile Lesbarkeit,
  Produktgefuehl und historische Foundation-Referenz nuetzlich, sind aber
  nicht mehr die primaere Runtime-Architektur.

## 1. Product Identity

Talvori ist ein isometrisches 3D exploration-and-learning game mit modularen
Districts, sichtbarem Weltfortschritt und kontextbasiertem Sprachlernen.

Der Spieler baut eine persoenliche Welt. Lernen entsteht nicht als isoliertes
Vokabelfenster, sondern durch Situationen, Objekte, Saetze, Aussprache,
Dialoge, Tali/Vori und sichtbaren Weltkontext.

Talvori funktioniert mit internen, kuratierten Inhalten. User-imported oder
shared words sind ein optionaler persoenlicher Zusatz, nicht die Voraussetzung
dafuer, dass Talvori spielbar ist.

Produktversprechen:

```text
Baue deine Welt.
Lerne Sprache im Kontext.
Sammle Woerter, Saetze und echte Sprachmomente.
Wachse mit Tali, Vori und Freunden.
```

## 2. Corrected Core Formula

Altes, zu enges Modell:

```text
word comes in -> word becomes object -> object builds world
```

Dieses Modell ist zu mechanisch. Es wuerde Talvori auf importierte Woerter und
direkte Wort-zu-Objekt-Abbildung reduzieren.

Korrigiertes Modell:

```text
Building creates context.
Learning uses context.
Language grows from words into sentences, pronunciation and conversations.
```

Die Welt darf also zuerst da sein. Das Haus, die Tuer, der Markt oder der
Bauplatz koennen existieren, bevor jedes einzelne sichtbare Wort gelernt wurde.
Sprache haengt sich an diesen Kontext, vertieft ihn und macht ihn sprechbar.

## 3. Core Layer Separation

Talvori trennt drei Ebenen:

### World-Building Layer

Der World-Building Layer zeigt Inseln, Bauplaetze, Gebaeude, Raeume,
Container, Figuren, Wege, Aufgaben und sichtbaren Fortschritt. Er darf Spiel-,
UI- und Hilfssprache nutzen, ohne jedes sichtbare Wort automatisch zum
Lerninhalt zu machen.

Nicht jedes UI-Wort ist automatisch Lerninhalt.

### Language Anchor Layer

Language Anchors haengen an konkreten Orten und Situationen:

- Objekten,
- Raeumen,
- Szenen,
- Containern,
- Schildern,
- Dialogen,
- Tali/Vori- oder Worker-Momenten.

Ein Objekt wie Haus, Tuer, Fenster, Tasche oder Karte kann mehrere
Sprachanker tragen, aber diese Anker werden kontrolliert, levelgerecht und
kontextgebunden sichtbar.

### Language Use Layer

Der Language Use Layer fuehrt von Wiedererkennen zu echter Nutzung:

- Hoeren,
- Verstehen,
- Sprechen,
- Satzbau,
- Aussprache,
- Dialog,
- situatives Handeln.

Das Ziel ist nicht nur, dass ein Spieler ein Wort erkennt. Das Ziel ist, dass
der Spieler Sprache in einem sinnvollen Moment versteht und benutzen kann.

## 4. Official Design Rules

### Internal Corpus Primary Rule

Talvori muss mit internem, kuratiertem Content funktionieren. Interne Inhalte
geben sicheren Start, didaktische Reihenfolge, Szenenanker und
Qualitaetskontrolle.

User-imported/shared words sind wertvoll, aber optional. Sie sind persoenliche
Entdeckungen, nicht die einzige Quelle fuer Welt- oder Sprachfortschritt.

### Construction Without Lexical Gate Rule

Weltbau darf nicht daran scheitern, dass jedes Objektwort vorher gelernt wurde.
Ein Haus kann gebaut werden, bevor `house` gelernt wurde. Eine Tuer kann
existieren, bevor `door` gelernt wurde.

Weltbau erzeugt Kontext. Sprache nutzt diesen Kontext spaeter.

### Context Before Vocabulary Rule

Der Ort kommt vor der Vokabelliste. Spieler sollen erst sehen:

- Wo bin ich?
- Was passiert hier?
- Welches Objekt oder welche Figur handelt?
- Welche Situation macht Bedeutung sichtbar?

Erst danach wird Sprache eingefuehrt, geuebt, gehoert, gesprochen oder im
Archiv wiedergefunden.

### Object-Anchor Rule

Sprache wird an Weltanker gebunden. Ein Sprachanker kann an einem Objekt, Raum,
Container, Schild, Dialog, BuildChoice, Worker-Moment oder Companion-Moment
haengen.

Das verhindert, dass Talvori in eine abstrakte Liste zurueckfaellt.

### Known Word Escalation Rule

Wenn ein Spieler ein Basiswort schon kennt, darf Talvori ihn nicht durch
offensichtliche Basics zwingen. Bekannte Woerter eskalieren stattdessen in:

- Saetze,
- Hoeren,
- Aussprache,
- Dialog,
- Kontextvarianten,
- Missionen,
- freiere Anwendung.

### Speakability Rule

Talvori soll zu sprechbarer Sprache fuehren. Wiedererkennen ist nur ein
Zwischenschritt.

Jede relevante Sprachebene soll langfristig fragen:

- Kann der Spieler es hoeren?
- Kann der Spieler es verstehen?
- Kann der Spieler es in einem Satz verwenden?
- Kann der Spieler es aussprechen?
- Kann der Spieler damit in einer Situation handeln?

### Companion-Guided Language Rule

Tali/Vori darf Sprache anfuehren, modellieren, korrigieren und anpassen. Der
Companion ersetzt aber nicht die deterministische Lern- oder Spielstruktur.

KI- und Companion-Ausgaben muessen an Szene, Level, aktive Sprache, bekannte
Inhalte und Sicherheitsregeln gebunden sein.

### Optional Capture Rule

Captured/imported/shared words sind optionale persoenliche Funde.

Wenn ein passender Kontext existiert, koennen sie in Szene, Archiv, Fundbuch,
Container oder Companion-Moment wieder auftauchen. Wenn kein Kontext existiert,
werden sie ruhig geparkt, nicht erzwungen.

## 5. World Progress vs Language Progress

World progress und language progress sind getrennte Systeme.

Ein Haus kann existieren, bevor `house` gelernt wird. Eine Tuer kann
existieren, bevor `door` gelernt wird. Ein Fenster kann sichtbar sein, bevor
`window` als Zielanker geuebt wird.

Die Welt erzeugt Kontext. Sprache haengt sich spaeter daran.

Regeln:

- Weltobjekte duerfen als Spiel-/Baukontext sichtbar sein.
- Language Anchors bestimmen, was gerade sprachlich aktiv ist.
- Lernfortschritt darf keine direkte Voraussetzung fuer jede sichtbare
  Konstruktion sein.
- Sprachfortschritt schreibt nicht automatisch BuildState.
- BuildState, Persistenz, SRS und `word_progress` bleiben getrennt, bis eigene
  Gates sie verbinden.

## 6. Active Target Language Model

Im normalen Spiel gibt es eine aktive Zielsprache.

Regeln:

- Englisch, Spanisch, Franzoesisch oder andere Zielsprachen werden im normalen
  Gameplay nicht frei gemischt.
- Dieselben Weltobjekte koennen mehrere Sprachschichten tragen.
- Eine normale Session zeigt nur die aktive Zielsprache.
- Sprachvergleich, Polyglot-Modus oder Mehrsprachenvergleich koennen spaeter
  eigene Gates werden.
- Sprachwechsel darf nicht heimlich SRS, `word_progress`, SQLite-Content oder
  Supabase-Daten veraendern.

Beispiel:

Ein Hausobjekt kann Anker fuer `house`, `casa` und `maison` tragen. Sichtbar
ist aber nur die aktive Zielsprache der Session.

## 7. UI Language vs Target Language vs Companion Language

Talvori trennt drei Sprachrollen:

| Rolle | Bedeutung |
| --- | --- |
| UI language | Sprache der App-Bedienung, Navigation, Buttons und Hilfetexte. |
| Target language | Sprache, die der Spieler gerade lernt. |
| Companion language | Sprache, in der Tali/Vori unterstuetzt, erklaert, motiviert oder uebt. |

Diese Rollen koennen zusammenfallen, muessen es aber nicht.

Beispiel:

- UI language: Deutsch
- Target language: Englisch
- Companion language: Deutsch mit einfachen englischen Einsprengseln

Fortgeschrittene Spieler koennen spaeter mehr Target-Language-Anteil im
Companion bekommen. Das ist ein Profil-/Level- und UX-Thema, kein automatischer
Default.

## 8. Language Passport

Jede Zielsprache braucht ein eigenes Language Passport/Profile.

Ein Passport beschreibt:

- target language,
- UI/helper language,
- rough level,
- goals,
- known basics,
- weak areas,
- strong areas,
- active scenes,
- progress per skill,
- preferred practice mode,
- speaking confidence,
- review needs.

Der Passport ist kein einzelner linearer Levelwert. Er ist ein Profil, damit
Talvori erkennen kann, ob ein Spieler Basics braucht, Saetze ueben sollte,
mehr Hoeren braucht, sprechen moechte oder schon freie Rollenspiele vertragen
kann.

Persistenz, Datenmodell und Migration fuer Language Passport brauchen spaeter
ein eigenes Gate.

## 9. Skill Profile Instead of One Linear Level

Talvori darf Sprachfaehigkeit nicht nur als eine Leiter lesen.

Skill-Dimensionen:

- word recognition,
- meaning understanding,
- listening,
- sentence building,
- pronunciation,
- dialogue ability,
- situation ability,
- travel ability,
- work ability,
- everyday-life ability.

Ein Spieler kann z. B. viele Woerter erkennen, aber wenig sprechen. Ein anderer
kann einfache Dialoge fuehren, hat aber schwache Aussprache. Talvori muss diese
Unterschiede langfristig beruecksichtigen.

## 10. Beginner, Advanced and Very Advanced Experience

### Beginner

Anfaenger brauchen:

- mehr Kontext,
- Muttersprache oder Hilfssprache,
- Auswahl statt freie Produktion,
- Tali/Vori-Hilfe,
- kurze Szenen,
- sichere Wiederholung,
- wenig Druck.

### Advanced

Fortgeschrittene brauchen:

- keine erzwungenen Basics,
- mehr Saetze,
- mehr Hoeren,
- mehr Sprechen,
- Missionen,
- Situationen mit Wahlmoeglichkeiten,
- weniger UI-Erklaerung.

### Very Advanced

Sehr Fortgeschrittene brauchen:

- Rollenspiel,
- freie Dialoge,
- Reise-, Berufs- und Alltagsmissionen,
- Nuancen,
- Stil,
- Korrektur,
- Aussprache- und Dialogfeedback.

Regel:

Kein advanced user sollte durch offensichtliche Basics wie hello, home, door
oder window gezwungen werden, wenn diese bereits bekannt sind.

## 11. Core Loop

Der Core Loop fuer Talvori Sprache und Welt:

```text
Discover
-> Act
-> World changes
-> Language is anchored
-> Language is used
-> New possibility opens
```

Der Loop muss spielerisch beginnen. Sprache wird aus Handlung und Kontext
heraus genutzt, nicht als isolierte Pflichtkarte vorangestellt.

## 12. Build Loop

World-building ist vom Sprachloop getrennt, aber liefert dessen Kontext.

Build Loop:

```text
See island/place
-> choose plot
-> choose direction
-> see BuildChoice
-> focus plot
-> visible problem
-> worker receives task
-> build phase changes
-> new context appears
-> new language anchors become possible
```

Der Build Loop darf in lokalen Previews ohne Persistenz, ohne BuildState und
ohne App-Integration getestet werden. Produktive Bauzustaende brauchen eigene
Gates.

## 13. Language Stages / Scenes

Mindestens relevante Szenen:

- Uferhain,
- Build site,
- Home,
- Market,
- Archive,
- Travel bag / map,
- Workshop,
- Tali/Vori dialogue.

Diese Szenen sind keine finalen App-Routes. Sie sind Sprach- und Weltkontexte,
an denen passende Anker, Saetze, Hoer-/Sprechmomente und Missionen entstehen
koennen.

## 14. Optional Word Sharing Loop

User-shared/imported words sind:

- optional,
- persoenliche Entdeckungen,
- moegliche Quest-/Companion-Rohstoffe,
- kein Pflichtinput fuer Weltbau.

Wenn kein Kontext existiert:

- Archiv,
- Fundbuch,
- Spaeter/Ablage,
- Companion-Hinweis ohne Druck.

Wenn spaeter Kontext existiert:

- Wort kann wieder auftauchen,
- Tali/Vori kann es einordnen,
- Szene kann passenden Anker anbieten,
- Nutzer entscheidet, ob es aktiv wird.

Keine automatische Wortplatzierung. Keine ungepruefte Uebersetzung als finale
Wahrheit.

## 15. First MVP Scope: Talvori Uferhain Zuhause

Grobe MVP-Lesart:

- World: Uferhain.
- Build plots: 3-5 usable slots.
- First flow: Zuhause -> Haus.
- Build phases: foundation -> outer wall ghost -> door/window ghost -> first
  room.
- Characters: Tali or Vori plus 1 worker.
- Internal content: curated internal learning items.
- Language mode: listening, recognition, sentence blocks, repeat/speak.

Der erste MVP muss nicht alle Sprachprofile, Polyglot-Faelle oder
Advanced-User-Pfade loesen. Er muss zeigen, dass eine gebaute Welt sinnvollen
Sprachkontext erzeugt.

## 16. AI / DeepL / Tali/Vori Roles

### DeepL

DeepL kann helfen bei:

- Uebersetzungsvorschlaegen,
- Bedeutungspruefung,
- alternativen Formulierungen.

DeepL ist nicht alleinige Wahrheit fuer:

- Level-Einstufung,
- didaktische Reihenfolge,
- Spielkontext,
- finale Content-Freigabe,
- sensible oder mehrdeutige Bedeutungen.

### KI / Tali/Vori

KI und Tali/Vori koennen helfen bei:

- gefuehrten Gespraechen,
- Anpassung an Level,
- Rollenspielen,
- Satzvarianten,
- Korrektur,
- Aussprache-/Dialogfeedback,
- Companion-Hinweisen.

Aber:

KI muss an Szene, Level, aktive Sprache und bekannte Inhalte gebunden sein.
Deterministische App-/Backend-Logik entscheidet nicht delegierbare Dinge wie
Progression, Persistenz, Safety, Ownership, Premium und gespeicherte
Weltzustaende.

## 17. Relation to Current M16 Flow

M16-BT ist ein Weltbau-/Rejoin-Slice, kein Sprachlevel-Slice.

M16-BT muss Anfaenger/Fortgeschritten/Mehrsprachigkeit noch nicht loesen.
M16-BT beweist nur:

```text
Weltkontext kann gebaut und lokal wieder verbunden werden.
```

Danach braucht Talvori spaeter ein Language Layer Design ueber existierenden
Weltobjekten:

- welche Objekte aktive Language Anchors bekommen,
- wie Target Language sichtbar wird,
- wie bekannte Basics uebersprungen oder eskaliert werden,
- wie Tali/Vori Sprache fuehrt,
- wie Listening, Speaking und Dialogue in die Welt passen,
- wie Language Passport/Profile gespeichert werden duerfte.

Bis dahin bleiben M16-BT und verwandte Previews lokale Proofs ohne
Produktivmechanik, ohne Persistenz, ohne BuildState, ohne SRS- oder
`word_progress`-Aenderung.
