# Local Translation DeepL Integration Plan

## Ausgangslage

Lokale importierte Wörter können aktuell den Übersetzungsstatus `pending`, `translated` oder `failed` haben.

Die vorbereitende lokale Architektur ist bereits vorhanden:

- `TranslationClient`
- `FakeTranslationClient`
- `PendingTranslationProcessor`

Ein echter `DeepLTranslationClient` existiert noch nicht. Die bestehende lokale Importlogik soll unverändert bleiben und weiterhin ohne DeepL, Internet oder Supabase funktionieren.

## Sicherheitsgrundsatz

Ein DeepL-API-Key darf niemals direkt im Repository gespeichert werden.

Verbindliche Regeln:

- Kein API-Key darf hart im Flutter-Code stehen.
- Keine `.env`-Datei mit echten Secrets darf committed werden.
- Eine spätere `.env.example` darf nur Platzhalter enthalten.
- Der echte Key muss lokal oder über eine sichere Laufzeitkonfiguration bereitgestellt werden.

Das Key-Konzept muss vor der echten DeepL-Anbindung final geklärt werden.

## Architekturziel

DeepL soll später nur über das bestehende `TranslationClient`-Interface angebunden werden.

Der `PendingTranslationProcessor` soll nicht wissen, ob ein `FakeTranslationClient` oder ein echter `DeepLTranslationClient` verwendet wird. Dadurch bleibt die Übersetzungslogik austauschbar, lokal testbar und unabhängig von konkreten API-Details.

UI und Importlogik sollen möglichst keine direkte DeepL-Abhängigkeit bekommen. Sie sollen weiterhin nur lokale Statuswerte wie `pending`, `translated` und `failed` anzeigen oder auslösen.

## Möglicher späterer Aufbau

Geplanter technischer Aufbau:

- `DeepLTranslationClient` implementiert `TranslationClient`.
- Der Client sendet Text sowie Quell- und Zielsprache an die DeepL-API.
- Eine erfolgreiche Antwort liefert den übersetzten Text zurück.
- Der `PendingTranslationProcessor` setzt danach den Status auf `translated`.
- Fehlerhafte Antworten oder Netzwerkfehler setzen den Status auf `failed`.
- `translation_error` speichert eine verständliche Fehlerbeschreibung.
- Der `PendingTranslationProcessor` verarbeitet nur Wörter mit Status `pending`.

Die bestehende lokale Importlogik muss dafür nicht wissen, ob später DeepL oder ein anderer Translation-Client verwendet wird.

## Noch offene Entscheidungen

Vor der Umsetzung müssen diese Punkte geklärt werden:

- Wo der API-Key sicher geladen wird.
- Ob Übersetzung direkt auf dem Gerät oder später über einen Backend-Proxy laufen soll.
- Wie Rate Limits behandelt werden.
- Wie Netzwerkfehler und API-Fehler unterschieden werden.
- Ob `failed`-Wörter manuell erneut angestoßen werden können.
- Ob Mehrwort- und Satztexte später unterstützt werden sollen.
- Ob Übersetzungen sofort nach Import oder nur manuell gestartet werden.

## Empfohlene Reihenfolge

1. Sicherheitskonzept für den API-Key finalisieren.
2. `.env.example` oder eine andere sichere Konfigurationsstruktur vorbereiten.
3. `DeepLTranslationClient` als isolierte Klasse hinzufügen.
4. Tests mit Mock/Fake ergänzen.
5. Erst danach UI oder automatische Verarbeitung erweitern.

Bis dahin bleiben `FakeTranslationClient` und `PendingTranslationProcessor` die sichere Grundlage für lokale Entwicklung und Tests.
