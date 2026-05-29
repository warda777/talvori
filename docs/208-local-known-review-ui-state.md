# Lokale „Wörter prüfen“-UI

## Ausgangspunkt

Der V-Button oben links im HomeScreen öffnete bisher den alten `VocabSortScreen`.
Dieser Pfad war noch an `VocabSortController` und `SupabaseWordRepository`
gekoppelt.

Für den lokalen MVP wurde der V-Button zunächst auf eine neue Review-UI
umgestellt. Diese erste lokale Variante war fachlich korrekt, aber optisch zu
stark vereinfacht. Der Zielstand wurde deshalb korrigiert: Die lokale Review-UI
baut die alte `VocabSortScreen`-Anmutung nach, nutzt aber weiterhin lokale
Daten. Der alte Screen bleibt im Projekt erhalten, wird vom Home-V-Button aber
nicht mehr geöffnet.

## Ziel

Die neue UI heißt intern weiterhin „Wörter prüfen“, wirkt aber wieder wie die
alte Sortierseite: oben `Wörter prüfen`, in der Mitte die Word-Wheel mit
Overlay-Zähler und unten die Category-Wheel. Sie soll Nutzer durch lokale
Wortwelten führen und einzelne Wörter als bereits bekannt markieren.

## Datenbasis

Die UI nutzt ausschließlich lokale Daten:

- `word_world_memberships.is_known`
- `word_world_memberships.is_reviewed_for_learning`
- `WordRepository.loadUnknownWordsForReview(...)`
- `WordRepository.countKnownWords(...)`
- `WordRepository.countReviewedForLearningWords(...)`
- `CategoryVocabularyController.markKnown(...)`
- `CategoryVocabularyController.restoreKnown(...)`

Es gibt keine neue Supabase-Abhängigkeit im neuen V-Button-Pfad.
Für `Noch lernen` wurde eine lokale Migration auf DB-Version 6 ergänzt. Das
neue Feld ist membership-basiert, verändert keine SRS-/`word_progress`-Daten
und hat für bestehende Daten den Default `0`.

„Wörter, die ich kenne“ ist keine echte Zielkategorie. Es ist eine globale
Filteransicht über Memberships mit `is_known = 1`. Wörter werden beim Markieren
nicht verschoben und Memberships werden nicht gelöscht. Ein Wort bleibt weiter
in seiner ursprünglichen Wortwelt sichtbar; dort erscheint es als `Kenn ich`
und wird nur aus Lernmodus/Practice herausgefiltert.

## UI-Ablauf

1. Nutzer öffnet über den V-Button „Wörter prüfen“.
2. Die UI lädt die erste lokale Wortwelt mit aktiven, noch nicht bekannten
   Wörtern.
3. Die rechte Word-Wheel zeigt die lokalen Wörter der ausgewählten Wortwelt.
4. Die Category-Wheel unten wechselt zwischen lokalen Wortwelten.
5. Der Plus-Button markiert das aktuelle Wheel-Wort als bekannt.
6. Wörter, die nicht per Plus markiert werden, bleiben automatisch im
   Lernstoff. Dafür gibt es keinen eigenen „Noch lernen“-Button mehr.
7. Wenn keine Wörter mehr im Durchgang sind, erscheint „Alles geprüft.“.

Die Review-UI ist damit nur eine schnelle Oberfläche für dieselbe
Aktiv-/Known-Entscheidung, die Nutzer sonst in jeder Wortwelt einzeln treffen
müssten.

## Auswirkungen

Ein Wort mit `is_known = 1` verschwindet aus dem normalen lokalen
Practice-/Lernmodus-Pfad, weil `loadWordsForWordWorld(...)` bekannte
Memberships standardmäßig herausfiltert.

Gleichzeitig erscheint es in der globalen lokalen Quelle „Wörter, die ich
kenne“, weil diese Quelle alle bekannten Memberships sammelt.

Beim Reaktivieren aus „Wörter, die ich kenne“ setzt die App `is_known = 0`.
Da die Known-Ansicht aktuell dedupliziert, wird ein Wort im MVP in allen
bekannten Memberships wieder aktiviert. In der ursprünglichen Wortwelt ist es
danach wieder aktiv und kommt wieder in Practice/Lernmodus vor.

Die Review-UI stellt vor dem Laden einer Wortwelt sicher, dass lokale Wörter
dieser Wortwelt auch passende `word_world_memberships` besitzen. Dadurch können
Plus-Markierungen und „Noch lernen“-Markierungen nicht mehr still ins Leere
laufen, wenn eine ältere lokale Kategorie bisher nur über die `words`-Tabelle
verfügbar war.

## Umgesetzt

- Neuer Screen `LocalKnownReviewScreen`
- Neuer Controller `LocalKnownReviewController`
- V-Button öffnet die lokale Review-UI statt `VocabSortScreen`
- VocabSort-nahe Oberfläche mit deutschem Header `Wörter prüfen`,
  Overlay-Zähler, rechter Word-Wheel, zwei linken persistenten Countern und
  unterer Category-Wheel
- Kategorie-/Wortwelt-Labels laufen über den bestehenden
  `wordHubItemDisplayName(...)`-Resolver, z. B. `Basics` -> `Grundlagen`,
  `Travel` -> `Reisen`, `Health & Fitness` -> `Gesundheit & Fitness`.
- Lokale Category-Wheel für echte WordHub-Wortwelten mit Review-Wörtern. Die
  Review-Quelle nutzt nicht mehr die Debug-/Rohkategorien aus der lokalen DB,
  sondern dieselbe Wortwelten-Struktur wie WordHub/CategoryDetail. Kategorien
  wie `Basics` werden dadurch nicht als Review-Wortwelt angeboten.
- Wheel-basierter Durchgang mit lokalem Plus/„Kenne ich“
- Die Word-Wheel läuft visuell weicher und nutzt weiterhin haptisches Feedback
  pro Wortwechsel. Der Controller schreibt Counter-Reloads nach asynchronen
  DB-Operationen nicht mehr mit einem alten Wheel-Index zurück; dadurch fühlt
  sich die Wheel wieder flüssiger an und wird nicht durch persistente
  „Noch lernen“-Updates auf einen vorherigen Center-Stand gezogen.
- Die Word-Wheel bleibt strukturell erhalten, wurde aber farblich stärker auf
  Talvori Neon-Dark mit Cyan/Violett-Akzenten angepasst.
- `Kenn ich` ist persistent und zählt eindeutige lokale Wörter mit mindestens
  einer Membership `is_known = 1`. Der Plus-Button setzt `is_known = true`,
  entfernt das Wort aus der „Noch lernen“-Zählung und aktualisiert den
  universalen `Kenn ich`-Zähler.
- `Noch lernen` ist persistent und zählt eindeutige lokale Wörter mit
  `is_reviewed_for_learning = 1`, solange sie nicht `is_known` sind. Es ist
  kein SRS-Status und schreibt keine `word_progress`-Daten.
- Der Bearbeitungszustand wird pro Wortwelt-Membership gespeichert:
  `unbearbeitet` bedeutet `is_known = 0`, `is_reviewed_for_learning = 0` und
  `is_disabled = 0`; `Noch lernen` bedeutet `is_reviewed_for_learning = 1`;
  `Kenn ich` bedeutet `is_known = 1`.
- Die Review-Wheel lädt nur unbearbeitete Wörter. Bereits geprüfte Wörter
  erscheinen nach erneutem Öffnen derselben Wortwelt nicht wieder unterhalb der
  Markierleiste, sondern bleiben über die persistenten Counter und die
  Wortwelt-Statistik erfasst.
- Wenn die Wheel zurückgedreht wird und ein Wort wieder unter die
  Markierlinie wandert, wird nur eine in dieser Session neu gesetzte
  „Noch lernen“-Markierung wieder entfernt. Ältere gespeicherte
  Review-Markierungen werden nicht versehentlich gelöscht.
- Die persistente „Noch lernen“-Markierung hängt an derselben Above-Line-Logik,
  die Wörter in der Wheel violett färbt: Sobald ein Wort durch einen normalen
  Center-Wechsel oberhalb der mittleren Markierlinie liegt, wird
  `is_reviewed_for_learning = 1` gesetzt. Beim Zurückdrehen wird nur die in
  derselben Session gesetzte Markierung zurückgenommen.
- Der Rückgängig-Flow läuft über einen echten Undo-Stack. Mehrere
  „Kenne ich“-Aktionen werden in umgekehrter Reihenfolge wiederhergestellt.
  Undo betrifft nur Known-Aktionen und schreibt `is_known` wieder zurück; es
  ist keine allgemeine „Noch lernen“- oder Abschlussaktion.
- Bugfix: Die persistenten Counter werden nach Plus, Undo und Wheel-Cross
  direkt aus der lokalen DB neu gelesen. Nach einer Known-Markierung wird die
  Review-Liste ebenfalls neu geladen, damit bekannte Wörter sofort und auch
  nach erneutem Öffnen nicht mehr in der Wheel erscheinen.
- Bugfix: `WordRepository` erzeugt fehlende Membership-Zeilen idempotent, bevor
  `is_known` oder `is_reviewed_for_learning` geschrieben wird. Das behebt Fälle,
  in denen Kategorie-Fallback-Wörter sichtbar waren, DB-Updates aber keine Zeile
  trafen.
- Bugfix: Nach Plus wird das bekannte Wort kontrolliert aus der aktuellen
  Wheel-Liste entfernt und der Index auf derselben Position gehalten. Dadurch
  springt die Wheel nicht mehr unnötig an den Anfang oder auf ein altes Wort.
- Bugfix: Das Center-Wort der sichtbaren Word-Wheel und das
  Controller-`currentWord` werden bei Scroll-Updates synchronisiert. Der
  Plus-Button markiert damit immer exakt das Wort auf der mittleren
  Markierleiste, z. B. `rest` statt eines vorherigen oder benachbarten Wortes.
- Bugfix: Beim Entfernen eines Known-Wortes wird der interne Above-Line-Zustand
  der Wheel neu auf den stabilisierten Index gesetzt. Dadurch wird ein
  List-Reload nach Plus nicht als künstliches Zurückdrehen interpretiert und der
  `Noch lernen`-Counter fällt nicht mehr durch mehrere falsche Cross-Downs ab.
- Bugfix: Das letzte Wort kann über ein unsichtbares End-Element der Wheel
  ebenfalls über die Markierlinie laufen. Wird es als `Noch lernen` geprüft,
  setzt die App `is_reviewed_for_learning = 1` und zeigt anschließend den
  abgeschlossenen Zustand.
- Abgeschlossene Kategorien bleiben in der unteren Category-Wheel sichtbar und
  werden ausgegraut. Abgeschlossen bedeutet: Für diese Wortwelt gibt es keine
  unbearbeiteten, aktiven Review-Wörter mehr.
- Neben der Category-Wheel bleibt nur noch die linke Kategorieaktion:
  `Kategorie zurücksetzen` setzt `is_reviewed_for_learning = 0` und
  `is_known = 0` für die aktuell ausgewählte Wortwelt zurück. Bekannte Wörter
  werden dort wieder aktiv prüfbar. Die Aktion fragt vorher per Dialog nach.
  Der frühere rechte Reaktivieren-/Erneut-prüfen-Button wurde entfernt.
- `Wörter, die ich kenne` ist eine reine Vocabs-/Filteransicht. Sie öffnet
  keine CategoryDetail-Seite und bietet keinen Lernmodus, sondern zeigt nur
  Wörter mit `is_known = 1`. Aktivieren in dieser Liste setzt Known zurück und
  entfernt das Wort aus der Filteransicht.
- `Noch zu lernen` wurde als zweite reine Vocabs-/Filteransicht ergänzt. Sie
  zeigt Wörter mit `is_reviewed_for_learning = 1` und `is_known = 0`.
  Aktivieren/Zurücksetzen in dieser Liste entfernt die
  `is_reviewed_for_learning`-Markierung, damit das Wort in seiner Wortwelt
  wieder unbearbeitet im Prüfmodus erscheinen kann.
- Die `Kenn ich`- und `Noch lernen`-Counter in `Wörter prüfen` sind jetzt
  antippbare Filterbuttons. Sie öffnen per Push die passenden reinen
  Vocabs-Listen und kehren per Zurück wieder in den Review-Screen zurück.
- Die Counter-Buttons sind visuell als kleine Neon-Dark-Kacheln gestaltet:
  `Noch lernen` nutzt einen Cyan/Türkis-Akzent, `Kenn ich` einen
  Lila/Violett-Akzent. Dadurch sind sie nicht mehr nur als Text/Zahl lesbar,
  sondern klar als antippbare Einstiege erkennbar.
- Die mittlere Markierleiste zeigt live die noch unbearbeiteten Wörter der
  aktuell ausgewählten Wortwelt. Nach `Noch lernen`, Plus/Known, Undo oder
  Reset wird der Wert sofort aus den aktualisierten Kategorie-Stats übernommen,
  ohne die Wortwelt wechseln zu müssen.
- Die zuletzt ausgewählte Review-Wortwelt wird lokal in SharedPreferences
  gespeichert und beim erneuten Öffnen wieder ausgewählt, sofern sie noch
  existiert.
- Der Completed-Untertext wurde mit zusätzlichem Abstand unterhalb der
  Markierleiste platziert, damit er nicht mit Pfeilen oder Leisteninhalt
  kollidiert.
- Der Completed-State zeigt `Alles geprüft.` nur noch einmal in der mittleren
  Leiste. Der doppelte Titel unterhalb der Leiste wurde entfernt; dort bleibt
  nur der erklärende Untertitel.
- Bugfix: Das Session-Touched-Set dient nur noch dazu, frisch in dieser Session
  gesetzte `is_reviewed_for_learning`-Markierungen beim Zurückdrehen wieder zu
  entfernen. Bereits vorher persistent gespeicherte „Noch lernen“-Wörter bleiben
  erhalten; der sichtbare Counter kommt weiterhin aus der DB.
- `Kenn ich` und `Noch lernen` schließen sich in der Zählung gegenseitig aus:
  `is_known = 1` entfernt ein Wort aus dem reviewed Counter, aber nur dieses
  konkrete Wort.
- Die lokale Vocabs-Liste unterscheidet zwischen `Kenn ich` und `Pausiert`.
  `Kenn ich` entspricht `is_known = 1`; `Pausiert` entspricht
  `is_disabled = 1`. Beide Zustände lassen das Wort in der Wortwelt sichtbar,
  filtern es aber aus dem Lernmodus. Falls beide Flags vorhanden sind, hat
  `Kenn ich` in der UI Vorrang, weil das Wort dann fachlich als bekannt gilt
  und zusätzlich in der Known-Filteransicht erscheint.
- Die Snackbar mit „Rückgängig“ wurde entfernt.
- Unten gibt es eine vorbereitete Quellenwahl für `Wortwelten`, `Lernlevel`
  und `Sprachwerkzeuge`. `Wortwelten` ist lokal funktional; die anderen Modi
  zeigen aktuell einen vorbereiteten Leerzustand ohne Supabase.
- Tests für Screen, Aktionen und Home-V-Button-Pfad

## Offen

- Swipe-UI für schnellere Durchgänge, falls die Wheel später ergänzt werden
  soll
- Bessere Statistiken pro Wortwelt
- Eigene Ansicht für abgeschlossene/übersprungene Review-Runden
- Lokale Review-Daten für `Lernlevel` und `Sprachwerkzeuge`
- Alten `VocabSortScreen` später entfernen oder vollständig lokal neu
  verdrahten

## Tests

Abgedeckt sind:

- V-Button öffnet `LocalKnownReviewScreen`
- Review-Screen zeigt die alte Sort-Struktur mit Category-Wheel und Word-Wheel
- „Kenne ich“ setzt `is_known`
- „Noch lernen“ ist kein Aktionsbutton mehr; der Counter ist ein Filterbutton
  und die Markierung schreibt nur `is_reviewed_for_learning`, keine SRS-Daten
- `Kenn ich` steigt bei Plus und sinkt bei Undo
- `Noch lernen` steigt bei Vorwärtsdurchlauf über die Markierlinie und sinkt
  beim Zurückdrehen für aktuelle Session-Markierungen wieder
- Controller-Neuaufbau lädt beide Zähler persistent aus der lokalen DB
- Undo stellt bekannte Wörter in Stack-Reihenfolge wieder her
- Der persistente Weiterlernen-Zähler zählt deduplizierte reviewed Wörter
- Die Quellenwahl zeigt Wortwelten, Lernlevel und Sprachwerkzeuge
- Completed-State nach dem Durchgang
- Reine Filterlisten für `Wörter, die ich kenne` und `Noch zu lernen`
- Persistierte letzte Review-Wortwelt und live aktualisierte mittlere Leiste
- Lokale Known-/Practice-Grundlage bleibt grün
