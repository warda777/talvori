# Talvori Welt: Onboarding Und Erste Session

Stand: 2026-06-04

Dieses Dokument plant den ersten Nutzerfluss von Talvori Welt. Es beschreibt,
was der Nutzer zuerst sieht, wann der Wow-Moment passiert, wann die erste Insel
gewaehlt wird, wann die erste Lernaufgabe kommt und wann der erste sichtbare
Baufortschritt entsteht.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten,
kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und
keine Release-Artefakte geaendert.

Grundlagen:

- `docs/world_design/000-world-design-document-map.md`
- `docs/world_design/223-learning-to-building-loop.md`
- `docs/world_design/224-economy-balancing.md`
- `docs/world_design/225-in-world-learning-ui.md`
- `docs/world_design/226-build-progression-and-zones.md`
- `docs/222-talvori-world-game-system-master-plan.md`
- `docs/221-talvori-world-build-and-expansion-architecture.md`

## 1. Ziel Des Onboardings

Der Nutzer soll schnell verstehen:

> Lernen baut meine Welt.

Onboarding-Ziele:

- Kein langes Formular zuerst.
- Kein Dashboard-Gefuehl.
- Welt und Companion fuehren den Einstieg.
- Erster Wow-Moment muss kostenlos und frueh passieren.
- Nutzer sieht innerhalb weniger Minuten eine sichtbare Veraenderung.

Nicht-Ziel:

- Kein vollstaendiges Tutorialsystem.
- Keine Reward Bridge.
- Keine Persistenz.
- Keine Monetarisierung im Einstieg.

## 2. Grundprinzipien

Prinzip:

> Erst sehen, dann waehlen, dann kleine Aktion.

Regeln:

- Nicht zu viele Ressourcen.
- Nicht zu viele Buttons.
- Nicht zu viele Erklaertexte.
- Companion erklaert kurz und kontextuell.
- Nutzer soll innerhalb weniger Minuten eine sichtbare Veraenderung sehen.
- Welt bleibt emotional wichtiger als UI.
- Erste Session nutzt maximal Stein/Bauimpuls sichtbar.
- Keine technischen Begriffe wie `Slice`, `Plot`, `BuildZone` in Nutzertexten.

## 3. First-Session-Zeitachse

### Erste 30 Sekunden

Ziel:

- Einstieg in die Welt vorbereiten.

Ablauf:

- Nutzer sieht Home-Zentrale.
- Globe ist klarer Welt-Einstieg.
- Companion-Hinweis ist kurz und optional.

Moeglicher Companion-Hinweis:

> Tali: `Deine Woerter koennen eine Welt bauen. Tippe auf den Globe.`

### Erste 1 Minute

Ziel:

- Wow-Moment durch Weltansicht.

Ablauf:

- Nutzer tippt auf Globe.
- Welt oeffnet sich.
- Showcase-Insel ist sichtbar.
- Freie Starter-Inseln sind sichtbar.
- Nutzer versteht: Showcase ist Beispiel, Starter-Inseln sind Auswahl.

### Erste 5 Minuten

Ziel:

- erste eigene Insel waehlen.

Ablauf:

- Nutzer tippt auf eine Starter-Insel.
- Empfehlung fuer ersten Slice: Waldlichtung.
- Auswahlkarte erklaert kurz Stimmung und Rolle.
- Nutzer waehlt die Insel.
- Besitzer-Markierung erscheint, z. B. kleine Fahne.
- Kein grosser Ring.
- Companion erklaert naechsten Schritt.
- Erste BuildZone / Bauplatz wird fokussiert.

### Erste 10-15 Minuten

Ziel:

- erste Lernaufgabe erzeugt sichtbaren Baufortschritt.

Ablauf:

- Nutzer tippt auf Bauplatz.
- Kontextkarte zeigt `Fundament beginnen`.
- Lokale Mock-Aufgabe: 3 einfache Woerter erkennen.
- Sichtbar nur Stein oder Bauimpuls.
- Ergebnis erfolgreich.
- `foundation_started` wird sichtbar.
- Companion kommentiert.
- Naechster Schritt wird klein angeboten.

### Erste 30 Minuten

Ziel:

- Nutzer kennt die Grundlogik.

Nutzer versteht:

- Welt ansehen.
- Eigene Insel.
- Erster Bauplatz.
- Lernen erzeugt Baufortschritt.
- Tagesziel oder naechster Schritt.

Nicht noetig nach 30 Minuten:

- komplette Economy verstehen,
- alle Ressourcen sehen,
- Gebaeudeauswahl nutzen,
- Community-Projekte verstehen,
- Premium sehen.

## 4. Screens Und Zustaende

| Zustand | Sichtbare UI | Companion-Rolle | Erlaubte Nutzeraktion | Nicht sichtbar |
| --- | --- | --- | --- | --- |
| Home-Zentrale | Globe, ruhige Home-Elemente | kurzer Hinweis auf Welt | Globe tippen, Companion ignorieren | Shop, Ressourcen-Wallet, lange Tutorialtexte |
| World-Entry | Talvori Welt, Showcase, Starter-Inseln | Wow kurz einordnen | Pan/Zoom, Insel antippen | Debug-Zonen, Premium, alle Systeme |
| Insel-Auswahl | Starter-Insel-Info, `Diese Insel waehlen` | Stimmung erklaeren | Insel waehlen oder abbrechen | Besitz als riesiger Ring |
| Meine Insel gewaehlt | kleine Fahne/Marker, Meine Insel-Fokus | naechsten Schritt zeigen | Bauplatz anschauen | Gebaeudeauswahl, Deko-System |
| Bauplatz-Fokus | Bauplatz, Kontextkarte | kurz erklaeren | `Fundament beginnen` starten | technische Zone-Namen |
| Lernaufgabe aktiv | einfache Aufgabe | ermutigend, nicht stoerend | Aufgabe loesen oder abbrechen | lange Erklaertexte |
| Baufortschritt sichtbar | `foundation_started`, kurzer Effekt | Erfolg kommentieren | naechsten Schritt waehlen | fertiges Haus |
| Session-Ende / naechster Schritt | kleiner Hinweis, Tagesziel | freundlich verabschieden | spaeter weitermachen | Schuld-/Drucksprache |

## 5. Erste Inselwahl

Regeln:

- Showcase-Insel ist Beispiel, nicht Besitz.
- Starter-Inseln sind eigene Auswahl.
- Nutzer waehlt eine Insel.
- Auswahl bleibt erstmal lokal/mock.
- Besitzmarker: Fahne reicht.
- Kein grosser Ring.
- `Meine Insel` springt zur gewaehlten Insel.

Empfehlung fuer ersten Slice:

- Waldlichtung.

Begruendung:

- ruhiges Biom,
- klarer Start,
- natuerlicher Bauplatz,
- wenig Ablenkung.

Ackerfeld und Felseninsel folgen spaeter als Vergleichsinseln.

Klarstellung:

- Waldlichtung wird fuer den ersten Slice empfohlen und darf visuell nahegelegt
  werden.
- Der Nutzer soll langfristig weiterhin echte Starter-Insel-Auswahl haben.
- Keine automatische Zwangsauswahl im Produktflow.
- Nur lokale Tests duerfen direkt mit Waldlichtung starten.

## 6. Erste Bauaktion

Kontext:

- Zielinsel: Waldlichtung.
- Eine `main_build_area`.
- Text: `Fundament beginnen`.

Nicht sichtbar:

- keine Gebaeudeauswahl,
- keine Deko,
- keine Bruecke,
- keine Innenraeume,
- keine Connectoren.

Zustand:

- nur `empty` -> `foundation_started`.

Ziel:

- Nutzer sieht: Diese kleine Lernhandlung beginnt mein Fundament.

## 7. Erste Lernaufgabe

Aufgabe:

- sehr einfache lokale Mock-Aufgabe,
- 3 einfache Woerter erkennen.

Klarstellung fuer den ersten technischen Slice:

- Die erste Aufgabe ist fest: 3 einfache Woerter erkennen.
- Keine Varianten wie Satz, Dialog, Schreiben, Aussprache oder KI im ersten
  Slice.
- Ziel ist nur, den Zusammenhang Aufgabe -> Stein/Bauimpuls ->
  `foundation_started` zu zeigen.

Sichtbar:

- nur Stein oder Bauimpuls,
- kein echtes Wallet,
- keine Ressourcenverwaltung.

Nicht Teil:

- keine Reward Bridge,
- kein SRS-/`word_progress`-Eingriff,
- kein KI-/DeepL-Call,
- keine Supabase Writes,
- keine Persistenz.

Regel:

Die erste Aufgabe prueft nur den Zusammenhang:

> Aufgabe geloest -> Bauimpuls -> Fundament beginnt.

## 8. Erster Sichtbarer Baufortschritt

`foundation_started` darf bedeuten:

- kleine Steinplatten,
- geglaettete Flaeche,
- dezenter Glow,
- kurze Staub-/Lichtwirkung,
- klarer Unterschied zu leerer Flaeche.

Nicht erlaubt:

- fertiges Haus,
- komplette Waende,
- grosse Animationen,
- Editor-Look,
- Debug-Flaechen,
- ueberdimensionierte UI-Markierung.

Ziel:

- Der Nutzer erkennt Fortschritt ohne Zahlenlast.

## 9. Companion-Texte

Texte sind Beispiele. Sie muessen kurz, freundlich und ohne Druck bleiben.

Vor Globe-Tap:

- Tali: `Deine Woerter koennen eine Welt bauen.`
- Vori: `Tippe auf den Globe. Ich zeige dir deinen Anfang.`

Bei Weltoeffnung:

- Tali: `Das ist Talvori Welt. Die grosse Insel zeigt, was spaeter moeglich ist.`
- Vori: `Such dir eine erste Insel. Sie wird dein Startpunkt.`

Nach Inselwahl:

- Tali: `Waldlichtung. Ruhig, klar und bereit fuer dein erstes Fundament.`
- Vori: `Diese Fahne markiert deine Insel. Lass uns den ersten Bauplatz wecken.`

Vor erster Aufgabe:

- Tali: `Drei Woerter reichen fuer den ersten Stein.`
- Vori: `Loese die Aufgabe, dann beginnt dein Fundament.`

Nach erstem Baufortschritt:

- Tali: `Siehst du? Dein Lernen hat den ersten Stein gelegt.`
- Vori: `Das Fundament hat begonnen. Mehr braucht es heute noch nicht.`

Bei Abbruch oder spaeter weitermachen:

- Tali: `Alles gut. Dein Bauplatz wartet auf dich.`
- Vori: `Kein Verlust. Beim naechsten Mal machen wir genau hier weiter.`

## 10. UI-Minimalismus

Dauerhaft sichtbar:

- Titel,
- wenige Ressourcen oder nur kontextueller Stein,
- `Meine Insel`,
- `Freunde` oder Zurueck,
- ggf. sehr kleiner Companion-Hinweis.

Kontextuell sichtbar:

- Bauziel,
- Lernaufgabe,
- Companion-Hinweis,
- sichtbare Wirkung.

Nicht sichtbar in der ersten Session:

- alle Ressourcen,
- Wallet,
- Shop,
- Premium,
- Community-Projekt,
- viele Buttons,
- Debug-Zonen,
- technische Begriffe wie `Slice` oder `Plot`,
- Tabellen oder Zahlenlast.

Regel:

Die Welt erklaert den Einstieg. UI hilft, aber dominiert nicht.

## 11. Abbruch Und Rueckkehr

Regeln:

- Nutzer kann Aufgabe abbrechen.
- Kein Verlust.
- Beim Zurueckkommen sieht er den naechsten kleinen Schritt.
- Companion sagt nicht: `Du hast versagt`.
- Erste Session darf auch nach Inselwahl enden.

Rueckkehrtexte:

- `Deine Insel wartet.`
- `Der erste Bauplatz ist noch bereit.`
- `Ein kleiner Schritt reicht.`

Ziel:

- Comeback bleibt freundlich und ohne Schuldgefuehl.

## 12. Kostenloser Wow-Moment

Kostenlos erlebbar:

- Weltansicht,
- Showcase-Insel,
- Starter-Insel-Auswahl,
- erste Bauwirkung.

Premium darf hier nicht blockieren.

Regel:

Der erste emotionale Beweis, dass Lernen die Welt baut, muss kostenlos sein.
Premium darf spaeter erweitern, verschoenern oder Komfort geben, aber den ersten
Wow-Moment nicht verkaufen.

## 13. Fehler- Und Frustfaelle

| Fall | Was soll passieren? | Was darf nicht passieren? |
| --- | --- | --- |
| Nutzer waehlt keine Insel | Showcase und Starter-Inseln bleiben erkundbar, Companion bietet sanft Auswahl an | keine Zwangsauswahl, kein Fehler |
| Nutzer tippt auf Community-Region | Info: `Spaeter gemeinsames Gebiet`, zurueck zur Auswahl fuehren | kein Claiming, kein falscher Besitz |
| Nutzer versteht Ressourcen nicht | UI spricht von Baufortschritt, Stein nur klein kontextuell | keine Wallet-Erklaerung mit allen Ressourcen |
| Nutzer bricht Aufgabe ab | Karte schliesst, Bauplatz bleibt unveraendert, spaeter wieder moeglich | kein Verlust, keine Schuld |
| Nutzer hat keine Woerter | lokale Demo-/Startwoerter oder sehr einfache Mock-Aufgabe anbieten | keine Sackgasse |
| Nutzer kommt spaeter zurueck | `Meine Insel` fokussiert Insel, naechster Schritt sichtbar | keine Bestrafung |
| Geraet ist offline | lokaler Mock-/Offline-Flow bleibt moeglich, keine Cloud-Aktion verlangen | kein Supabase Write, keine KI-/DeepL-Abhaengigkeit |

## 14. Bezug Zu Economy Und Build-Zonen

Verweise:

- `docs/world_design/224-economy-balancing.md`: sichtbar nur Stein im ersten
  Slice.
- `docs/world_design/226-build-progression-and-zones.md`: Waldlichtung + eine
  `main_build_area` + `foundation_started`.
- `docs/world_design/225-in-world-learning-ui.md`: BuildZone antippen ->
  Kontextkarte -> Mock-Aufgabe -> Baufortschritt.

Konsequenz:

- Onboarding darf keine anderen Systeme vorziehen.
- Erste Session testet nur den Kernbeweis.
- Alles andere ist spaeter.

## 15. Erster Technischer Slice Aus Onboarding-Sicht

Der erste Slice aus Onboarding-Sicht:

- Globe oeffnet Welt.
- Nutzer kann Starter-Insel waehlen.
- `Meine Insel` fokussiert sie.
- Bauplatz kann fokussiert/angetippt werden.
- Kontextkarte `Fundament beginnen`.
- Lokale Mock-Aufgabe `3 einfache Woerter erkennen` erfolgreich.
- `foundation_started` sichtbar.
- Companion-Kommentar.
- Keine Persistenz.
- Keine Reward Bridge.
- Keine Supabase Writes.

Nicht im Slice:

- keine echte Ressourcen-Wallet,
- keine KI,
- kein DeepL,
- keine SRS-/`word_progress`-Aenderung,
- kein Premium,
- kein Shop,
- keine Community-Projekte.

## 16. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- die erste Session konkret nachvollziehbar ist,
- der erste Wow-Moment klar ist,
- die erste Lernaufgabe klar ist,
- die erste Bauwirkung klar ist,
- UI bewusst reduziert ist,
- kein Premium/Shop den Einstieg blockiert,
- Fehler- und Abbruchfaelle freundlich geplant sind,
- ein kleiner technischer Slice ableitbar ist.

Offene Fragen:

- Welche konkreten Startwoerter oder Mock-Woerter eignen sich fuer die erste
  Aufgabe?
- Wie stark soll die Waldlichtung visuell empfohlen werden, ohne die freie
  Inselwahl zu schwaechen?
- Wie stark darf der Companion in den ersten 30 Sekunden fuehren?
- Soll `Meine Insel` vor der Auswahl einen Hinweis zeigen oder zur Auswahl
  fokussieren?
- Welche kleine visuelle Wirkung zeigt `foundation_started` auf dem
  Waldlichtung-Asset am klarsten?
