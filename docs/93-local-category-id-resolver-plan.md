# 93 Local Category ID Resolver Plan

Stand: 2026-05-14

## 1. Zweck Des Resolvers

Der lokale `CategoryIdResolver` soll eine kleine, UI-neutrale Bruecke zwischen bestehender Talvori-UI und der neuen lokalen Offline-first-Datenbank bilden.

Er soll:

- bestehende UI-Kategorieinformationen auf eine lokale `categoryId` fuer `talvori_local_v1.db` abbilden
- lokale Debug- und Asset-Kategorien wie `basics` unterstuetzen
- spaeter Taxonomy-Keys aus `word_hub_taxonomy.dart` kontrolliert auf lokale Kategorien abbilden
- keine Supabase-Abhaengigkeit haben
- keine Datenbankabfrage ausfuehren
- keine UI-Aenderung erfordern
- keine Navigation oder Lernsession starten

Der Resolver ist damit kein Importservice und kein Repository. Er entscheidet nur, welche lokale Kategorie-ID fuer eine bekannte Eingabe verwendet werden darf.

## 2. Moegliche Eingaben

Version 1 sollte einfache String-Eingaben akzeptieren koennen.

Sinnvolle Eingabearten:

- lokale Debug-ID, z. B. `basics`
- `word_hub_taxonomy.key`, z. B. `travel`, `top_500`, `a1`
- Slug/String aus der bestehenden UI
- spaeter optional eine alte Supabase-ID als Legacy-Mapping

Fuer den ersten Schritt ist `basics` die wichtigste Eingabe, weil die echte lokale Asset-Datei aktuell diese Kategorie enthaelt.

`word_hub_taxonomy.dart` liefert derzeit Kategorien als `HubSubcat.key`. Diese Keys sind fachlich nuetzlich, aber noch nicht automatisch identisch mit lokalen Asset-Kategorie-IDs. Deshalb duerfen sie nicht unkontrolliert als lokale Datenbank-IDs angenommen werden.

## 3. Ausgabe

Die Ausgabe soll eine lokale `categoryId` sein, die in `talvori_local_v1.db` existieren kann.

Beispiel:

- Eingabe: `basics`
- Ausgabe: `basics`

Wenn eine Kategorie nicht bekannt oder noch nicht lokal abgebildet ist, sollte der Resolver kontrolliert reagieren.

Moegliche Rueckgabe fuer unbekannte Eingaben:

- `null`, wenn der Aufrufer selbst entscheiden soll, wie er mit fehlendem Mapping umgeht
- oder ein klares Fehlerergebnis, falls spaeter ein typisierter Result-Wert sinnvoll wird

Empfehlung fuer Version 1:

- `String? resolve(String input)`
- bekannte Werte geben eine lokale `categoryId` zurueck
- unbekannte Werte geben `null` zurueck

Das ist fuer einen ersten UI-neutralen Adapter testbar und risikoarm.

## 4. Mapping-Regeln Fuer Version 1

Empfohlene erste Regeln:

- `basics` -> `basics`
- Eingaben werden vor dem Mapping normalisiert:
  - trimmen
  - in lowercase umwandeln
  - optional Leerzeichen durch `_` oder `-` nur dann normalisieren, wenn ein Test diesen Fall absichert
- unbekannte Kategorie -> `null`

Noch nicht empfohlen:

- alle `word_hub_taxonomy.key` automatisch auf sich selbst mappen
- Labels wie `Health & Fitness` frei in IDs umwandeln
- Supabase-IDs automatisch als lokale Kategorie-IDs verwenden
- bei unbekannter Kategorie auf `basics` zurueckfallen

Ein automatischer Fallback auf `basics` waere zu riskant, weil Nutzer sonst versehentlich die falsche lokale Kategorie lernen koennten.

## 5. Warum Supabase-ID Nicht Primaerschluessel Sein Soll

Supabase-IDs sollten nicht der primaere lokale Kategorie-Schluessel werden.

Gruende:

- lokale Offline-first-Daten sollen ohne Supabase funktionieren
- Asset-Dateien verwenden stabile, sprechende lokale IDs
- Supabase-IDs sind technische Remote-IDs und fuer lokale Demo-/Startdaten nicht notwendig
- spaetere Supabase-Exports koennen eigene Mapping-Regeln brauchen
- lokale Kategorien sollen auch existieren koennen, wenn es nie eine Supabase-Kategorie dazu gab

Supabase-IDs koennen spaeter als optionales Legacy-Mapping dienen, aber nicht als Grundlage des lokalen V1-Modells.

## 6. Passung Zu Echten Asset-Kategorien

Die echte lokale Asset-Datei liegt unter:

- `assets/local_import/default_words_v1.json`

Sie enthaelt aktuell:

- Kategorie `basics`
- Woerter `basics_hello` und `basics_water`

Der Resolver sollte deshalb zuerst nur ein Mapping fuer `basics` absichern.

Wenn die Asset-Datei spaeter erweitert wird, koennen weitere lokale IDs kontrolliert aufgenommen werden, z. B.:

- `travel`
- `exam_practice`
- `top_500`
- `a1`

Wichtig ist: Neue Resolver-Mappings sollten erst entstehen, wenn die jeweilige Kategorie auch lokal geplant, als Asset vorhanden oder anderweitig bewusst importierbar ist.

## 7. Was Nicht Passieren Darf

Der Resolver darf nicht:

- eine Datenbank oeffnen
- Supabase verwenden
- einen Import ausloesen
- eine Session starten
- Progress erzeugen
- Review-History schreiben
- UI-Navigation ausloesen
- `LearnModeController` veraendern oder verwenden
- `WordUserView` verwenden
- `local_word_database.dart` verwenden

Er bleibt eine reine Mapping-Schicht.

## 8. Sinnvolle Tests Spaeter

Sinnvolle erste Tests:

- `local_category_id_resolver_maps_basics_debug_category`
- `local_category_id_resolver_normalizes_known_key`
- `local_category_id_resolver_returns_null_for_unknown_category`
- `local_category_id_resolver_does_not_require_supabase_or_database`

Spaetere Tests, wenn mehr lokale Asset-Kategorien existieren:

- `local_category_id_resolver_maps_asset_category_key`
- `local_category_id_resolver_does_not_fallback_to_basics_for_unknown_key`
- `local_category_id_resolver_keeps_supabase_id_mapping_optional`

## 9. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt ist ein isolierter Resolver ohne UI, Datenbank und Supabase.

Empfohlen:

1. Neue Datei fuer den Resolver planen/erstellen, z. B. `lib/core/local_database/adapters/local_category_id_resolver.dart`.
2. Nur einen ersten Test schreiben:
   - `local_category_id_resolver_maps_basics_debug_category`
3. Erwartung:
   - Eingabe `basics` ergibt Ausgabe `basics`
   - keine Datenbank wird geoeffnet
   - kein Supabase ist noetig
   - kein Import wird gestartet

Danach kann als zweiter Schritt die Normalisierung bekannter Keys getestet werden.
