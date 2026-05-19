# Translation Key Handling Decision

## Ausgangslage

Talvori besitzt inzwischen eine vorbereitete lokale Translation-Architektur:

- `DeepLTranslationClient` existiert als isolierte Implementierung.
- `LocalTranslationConfig` existiert für eine spätere Runtime-Konfiguration.
- `FakeTranslationClient` bleibt der Default.
- Manuelle Verarbeitung von `pending`- und `failed`-Übersetzungen funktioniert lokal.
- Es gibt keinen echten API-Key im Repository.
- Es gibt keine automatische Online-Übersetzung.

## Problem

Ein DeepL-API-Key ist ein Secret.

Ein Secret sollte nicht hart im Flutter-Code stehen und nicht ins Repository gelangen. Eine Mobile-App kann einen direkt eingebetteten API-Key außerdem nie vollständig sicher schützen, weil App-Bundles analysiert und Schlüssel extrahiert werden können.

## Option A: Lokaler Key im Gerät

Vorteile:

- einfacher umzusetzen
- schneller für lokale Tests
- kein Backend nötig

Nachteile:

- Key liegt auf dem Gerät
- Schutz vor Reverse Engineering ist begrenzt
- Nutzer müsste den Key selbst verwalten oder die App müsste ihn speichern
- Missbrauch, Rate Limits und Kostenkontrolle sind schwerer zentral abzusichern

Diese Option eignet sich höchstens als bewusst aktivierter Entwicklungsmodus.

## Option B: Backend-Proxy

Vorteile:

- DeepL-Key bleibt auf dem Server
- App sendet nur Übersetzungsanfragen an einen eigenen Endpunkt
- Rate Limits, Logging, Fehlerbehandlung und Missbrauchsschutz können zentral kontrolliert werden
- besser für produktive Nutzung geeignet

Nachteile:

- zusätzlicher Backend-Aufwand
- Authentifizierung und Absicherung nötig
- Betrieb, Monitoring und Fehlerbehandlung müssen geplant werden

## Entscheidung

Für produktive Nutzung ist ein Backend-Proxy die bevorzugte Zielarchitektur.

`FakeTranslationClient` bleibt für lokale Entwicklung und Tests der sichere Default. `DeepLTranslationClient` bleibt als isolierte vorbereitende Implementierung bestehen, wird aber nicht automatisch produktiv aktiviert.

Eine direkte lokale Key-Nutzung darf nur als bewusst aktivierter Entwicklungsmodus betrachtet werden.

## Konsequenzen

- Keine UI für einen echten DeepL-Key bauen, solange die Sicherheitsentscheidung nicht weiter umgesetzt ist.
- Keine automatische DeepL-Übersetzung aktivieren.
- Lokale Tests bleiben bei Fake/Mock.
- Der nächste technische Schritt sollte ein sicherer Backend-Proxy-Plan sein.

## Nächster Schritt

Als nächstes sollte ein Backend-Proxy-Konzept dokumentiert werden. Danach ist zu entscheiden, ob Supabase Edge Function, ein eigener Server oder ein anderer gesicherter Endpunkt genutzt wird.

Erst danach sollte eine echte produktive DeepL-Aktivierung geplant werden.
