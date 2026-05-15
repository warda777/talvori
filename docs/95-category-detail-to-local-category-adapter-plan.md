# 95 Category Detail To Local Category Adapter Plan

Stand: 2026-05-14

## 1. Zweck Des Adapters

Der Adapter soll eine kontrollierte Bruecke zwischen bestehenden `CategoryDetail`-/Startdaten und der lokalen Offline-first-Kette bilden.

Er soll:

- bestehende CategoryDetail-Daten lesen oder entgegennehmen
- daraus eine lokale `categoryId` fuer `talvori_local_v1.db` bestimmen
- intern den `LocalCategoryIdResolver` verwenden
- keine Session starten
- keine UI veraendern
- keine bestehende Navigation veraendern
- keine Supabase-Daten laden

Der Adapter ist damit ein reiner Uebersetzer zwischen alter UI-Datenform und lokaler Kategorie-ID. Er gehoert vor einen spaeteren lokalen Startpfad, nicht in die eigentliche Lernsession-Logik.

## 2. Aktuelle CategoryDetail-Eingaben

`CategoryDetailScreen` erhaelt aktuell:

- `title`
  - sichtbarer Kategorie-Name, z. B. `Health & Fitness`
- `categoryId`
  - aktuell Supabase-UUID beziehungsweise alte `word_categories.id`
  - kann `null` sein
- `categorySlug`
  - Fallback-/Slug-Wert
  - kann `null` sein
- `listFilter`
  - bestehender Filter fuer die Wortliste

Im Screen entsteht zusaetzlich:

- `currentId`
  - aus `CategoryInfo.id`
  - oder Fallback auf `widget.categoryId`
- aktueller Kategorie-Name
  - aus `CategoryInfo.name`
  - oder Fallback auf `widget.title`

`CategoryDetailController` arbeitet aktuell mit `CategoryInfo`.

`CategoryInfo` enthaelt:

- `id`
- `name`
- `slug`
- `groupSlug`
- `groupName`
- `orderIndex`

Aus `word_hub_taxonomy.dart` koennen spaeter relevante Daten kommen:

- `HubSubcat.key`
- `HubSubcat.label`
- `HubSubcat.supabaseId`
- `HubSection.key`
- `HubSection.title`

Wichtig: Diese Daten existieren aktuell in unterschiedlichen Schichten und duerfen nicht automatisch gleichgesetzt werden.

## 3. Sinnvolle Eingaben Fuer Den Ersten Lokalen Schritt

Fuer den ersten lokalen Schritt sollte der Adapter sehr schmal bleiben.

Empfohlen:

- `basics` als Debug-/Asset-Fall
- optional ein klar benannter String wie `categoryKey`
- optional ein `categorySlug`
- optional ein `categoryName`, aber noch nicht als primaeres Mapping

Noch nicht primaer:

- Supabase-ID
- UI-Label
- komplette `CategoryInfo`-Abhaengigkeit
- komplette `HubSubcat`-Abhaengigkeit

Begruendung:

Die echte lokale Asset-Datei enthaelt aktuell nur `basics`. Der vorhandene Resolver bildet nur `basics` ab und gibt fuer unbekannte Werte, auch `travel`, bewusst `null` zurueck. Deshalb sollte der Adapter im ersten Schritt nur beweisen, dass bekannte lokale Eingaben sicher durchgereicht werden.

Spaeter kann der Adapter mehrere Eingabefelder priorisiert pruefen, z. B.:

1. expliziter lokaler Debug-/Category-Key
2. Taxonomy-Key
3. Slug
4. optionales Legacy-Mapping fuer Supabase-ID

## 4. Ausgabe

Minimal empfohlene Ausgabe fuer Version 1:

- `String? localCategoryId`

Beispiel:

- Eingabe `basics`
- Ausgabe `basics`

Bei unbekannter Kategorie:

- Ausgabe `null`

Spaeter koennte ein kleiner Result-Typ sinnvoll werden.

Moegliche Felder:

- `localCategoryId`
- `reason`
- `source`

Moegliche Gruende:

- `mapped`
- `unknownCategory`
- `missingInput`
- `legacyMappingNotConfigured`

Empfehlung:

Fuer den kleinsten TDD-Schritt reicht `String?`. Ein Result-Typ sollte erst eingefuehrt werden, wenn konkrete UI- oder Diagnoseentscheidungen davon abhaengen.

## 5. Was Nicht Passieren Darf

Der Adapter darf nicht:

- eine Datenbank abfragen
- Supabase verwenden
- einen Import ausloesen
- eine lokale Session starten
- Progress erzeugen
- Review-History schreiben
- `LearnModeController` umbauen oder verwenden
- `learn_mode_screen.dart` umbauen oder verwenden
- bestehende Navigation veraendern
- unbekannte Kategorien automatisch auf `basics` abbilden

Der Adapter darf auch nicht die alte Kategorie-ID stillschweigend als lokale Kategorie-ID behandeln, wenn diese aus Supabase stammt.

## 6. Sinnvolle Tests Spaeter

Sinnvolle erste Tests:

- `adapter_maps_basics_to_local_category_id`
- `adapter_returns_null_for_unknown_category`
- `adapter_does_not_require_supabase_or_database`
- `adapter_does_not_fallback_to_basics`

Weitere Tests, wenn mehr Kontext eingefuehrt wird:

- `adapter_prefers_explicit_local_key_over_supabase_id`
- `adapter_maps_known_taxonomy_key_when_asset_category_exists`
- `adapter_returns_null_for_taxonomy_key_without_local_asset_category`
- `adapter_keeps_supabase_id_mapping_optional`

Regressionen, die spaeter wichtig werden:

- bestehender Supabase-Startpfad bleibt unveraendert
- `LearnModeController` wird nicht automatisch durch den Adapter verwendet
- `CategoryDetailScreen` startet keine lokale Session ohne expliziten lokalen Startpfad

## 7. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt ist ein isolierter Adapter ohne UI, DB, Supabase und Navigation.

Empfohlen:

1. Neue Datei planen/erstellen, z. B.:
   - `lib/core/local_database/adapters/category_detail_local_category_adapter.dart`
2. Eine kleine Eingabestruktur verwenden, z. B.:
   - `categoryKey`
   - optional spaeter `categorySlug`
   - optional spaeter `categoryName`
   - optional spaeter `supabaseId`
3. Nur einen ersten Test schreiben:
   - `adapter_maps_basics_to_local_category_id`
4. Erwartung:
   - Eingabe `basics` ergibt `basics`
   - der Adapter nutzt `LocalCategoryIdResolver`
   - keine Datenbank wird geoeffnet
   - kein Supabase ist noetig
   - kein Import wird gestartet
   - keine Session wird gestartet

Danach sollte als naechster Sicherheitstest folgen:

- `adapter_returns_null_for_unknown_category`

Erst danach sollte ueber Taxonomy-Key- oder CategoryDetailScreen-naehere Eingaben entschieden werden.
