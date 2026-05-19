# Local Translation Pending State

## Kontext

Talvori verwaltet importierte lokale Wörter inzwischen mit einem lokalen Übersetzungsstatus. Damit kann die App Wörter aus dem lokalen Importpfad speichern, auch wenn noch keine Übersetzung vorhanden ist.

Eine echte DeepL-HTTP-Integration existiert aktuell noch nicht. Der derzeitige Stand ist eine vorbereitende lokale Architektur für spätere automatische Übersetzungen.

## Aktueller Funktionsstand

- Importierte Wörter erhalten initial den Status `pending`.
- Es existiert ein lokales Translation-Status-Modell mit:
  - `pending`
  - `translated`
  - `failed`
- Es existiert ein `TranslationClient`-Interface.
- Es existiert ein `FakeTranslationClient` für Tests und lokale Entwicklung.
- Es existiert ein `PendingTranslationProcessor`.
- `LocalWordListScreen` zeigt den Übersetzungsstatus lokal an.
- `LocalWordDetailScreen` zeigt den Übersetzungsstatus und Details lokal an.

## Bewusste Grenze

- Es gibt noch keinen echten DeepL-HTTP-Client.
- Es gibt noch keinen API-Key im Projekt.
- Es wird bewusst kein API-Key in Git gespeichert.
- Die aktuelle Lösung ist eine vorbereitende lokale Architektur, keine produktive Online-Übersetzung.

## Architekturabsicht

Die lokale Importlogik bleibt unabhängig von Supabase. Importierte Wörter werden lokal gespeichert und können zunächst ohne Online-Abhängigkeit im Status `pending` bleiben.

Die Translation-Logik soll austauschbar bleiben. Dafür hängt der vorbereitete Processor nur am `TranslationClient`-Interface. Der `FakeTranslationClient` dient dazu, UI, Statusmodell und Processor ohne externe API zu testen.

Ein späterer echter DeepL-Client soll gegen dasselbe `TranslationClient`-Interface angebunden werden, ohne die lokale Importlogik oder die UI erneut grundlegend umbauen zu müssen.

## Statusfluss

Aktuell sind diese Statusübergänge vorgesehen:

- `pending` -> `translated`
- `pending` -> `failed`

Die Status bedeuten:

- `pending`: Wort wurde importiert, Übersetzung steht noch aus.
- `translated`: Übersetzung wurde erfolgreich ergänzt.
- `failed`: Übersetzung ist fehlgeschlagen oder konnte nicht verarbeitet werden.

## Nächster sinnvoller Schritt

Vor einer echten DeepL-Integration muss ein sicheres Key-Konzept geplant werden. API-Keys dürfen nicht ins Repository und dürfen nicht hart im Client-Code landen.

Erst danach sollte ein echter `DeepLTranslationClient` entstehen. Bis dahin bleiben `FakeTranslationClient`, `PendingTranslationProcessor` und die Tests die sichere Grundlage für die weitere Entwicklung.
