# Local Translation Config State

## Ausgangslage

Die lokale Translation-Architektur besitzt bereits ein `TranslationClient`-Interface, einen `FakeTranslationClient`, einen vorbereiteten `DeepLTranslationClient` und den `PendingTranslationProcessor`.

Mit der lokalen Konfigurationsstruktur kann nun kontrolliert entschieden werden, welcher `TranslationClient` erzeugt wird.

## Fake bleibt Default

Ohne explizite DeepL-Konfiguration verwendet Talvori weiterhin den `FakeTranslationClient`.

Das ist bewusst so, damit lokale Tests, lokaler Import und Offline-Entwicklung ohne Netzwerk, API-Key oder DeepL-Abhängigkeit funktionieren.

## DeepL nur explizit konfigurierbar

DeepL ist nur über eine explizite lokale Konfiguration aktivierbar.

Die Konfiguration unterstützt:

- Modus `fake` oder `deepl`
- API-Key
- optionale Base-URL

Wenn der DeepL-Modus ohne gültigen API-Key konfiguriert wird, fällt die Factory auf den `FakeTranslationClient` zurück. Dadurch wird kein leerer oder versehentlich fehlender Key produktiv verwendet.

## Kein API-Key im Repository

Es wurde kein echter API-Key im Repository gespeichert.

`.env.example` enthält nur Platzhalter. Echte `.env`-Dateien bleiben durch `.gitignore` geschützt.

## Keine automatische Online-Übersetzung

Die Konfiguration erzeugt nur einen Client. Sie startet keine automatische Übersetzung.

Insbesondere wurde nicht geändert:

- kein Auto-Translate nach Import
- kein Auto-Translate beim App-Start
- keine UI-Aktion
- keine Supabase-Logik

## Relevante Bausteine

- `LocalTranslationConfig`
- `LocalTranslationClientFactory`
- `localTranslationConfigProvider`
- `localTranslationClientFactoryProvider`
- `translationClientProvider`
- `pendingTranslationProcessorProvider`

## Nächster sinnvoller Schritt

Der nächste Schritt kann ein sicherer Runtime-Key-Pfad oder ein manueller Trigger sein.

Vor produktiver Aktivierung muss entschieden werden:

- wo der DeepL-Key sicher bereitgestellt wird
- ob die Übersetzung direkt im Client oder über einen Backend-Proxy laufen soll
- ob Nutzer die Übersetzung manuell starten oder ob später ein kontrollierter Auto-Translate-Pfad entsteht
