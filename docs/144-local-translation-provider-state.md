# Local Translation Provider State

## Ausgangslage

Die lokale Translation-Architektur hatte bereits die zentralen Bausteine:

- `TranslationClient`
- `FakeTranslationClient`
- `PendingTranslationProcessor`

Danach wurde eine kleine Provider-/Composition-Struktur ergänzt. Ziel ist eine spätere austauschbare Anbindung eines echten `DeepLTranslationClient`, ohne Importlogik, UI oder Processor direkt an DeepL zu koppeln.

## Neue relevante Dateien

- `lib/core/local_database/providers/local_translation_provider.dart`
- `test/core/local_database/local_translation_provider_test.dart`

## Aktueller Zweck

Der lokale `TranslationClient` wird jetzt zentral bereitgestellt.

Aktuell wird weiterhin bewusst der `FakeTranslationClient` verwendet. Der `PendingTranslationProcessor` kann über die neue Provider-Struktur mit einem `TranslationClient` versorgt werden.

Dadurch muss der Processor nicht wissen, ob später ein `FakeTranslationClient` oder ein echter `DeepLTranslationClient` verwendet wird. Die Entscheidung liegt im Provider-/Composition-Layer.

## Bewusste Grenzen

- Es wurde kein `DeepLTranslationClient` eingebaut.
- Es wurde kein HTTP eingebaut.
- Es wurde kein API-Key eingebaut.
- Es wurde keine automatische Online-Übersetzung aktiviert.
- Supabase wurde nicht berührt.

## Teststand

`local_translation_provider_test.dart` prüft die neue Provider-/Composition-Struktur:

- `translationClientProvider` stellt aktuell den `FakeTranslationClient` bereit.
- `pendingTranslationProcessorProvider` erhält den injizierten `TranslationClient`.
- Der Processor kann über die Provider-Struktur mit einem überschriebenen Fake/Test-Client arbeiten.

Die relevanten lokalen Translation-Tests wurden erfolgreich ausgeführt. Die vollständige Testsuite war grün:

`00:16 +443: All tests passed!`

## Bedeutung für spätere DeepL-Integration

Der nächste echte Implementierungsschritt kann später isoliert ein `DeepLTranslationClient` sein.

Die bestehende UI und der Importservice müssen dafür möglichst nicht direkt von DeepL abhängig werden. Der Provider-/Composition-Layer ist die Stelle, an der später entschieden werden kann, welcher `TranslationClient` verwendet wird.
