# Kategorie-Wortverwaltung

## 1. Ziel

Der Add-Button im CategoryDetail ist die erste zentrale Stelle, um eine lokale Kategorie oder Wortwelt direkt zu erweitern. Nutzer sollen Wörter manuell hinzufügen, später gezielt KI-Vorschläge übernehmen und einzelne Wörter für den Lernmodus pausieren können.

## 2. Add-Button-Menü

Der Add-Button öffnet ein Dark-Neon-Bottom-Sheet mit zwei Aktionen:

- Wort hinzufügen
- KI-Vorschläge

Die Vorschläge werden nicht automatisch erzeugt. Sie starten nur nach aktivem Tippen auf „KI-Vorschläge“.

## 3. Manuelles Hinzufügen

Das Formular nimmt Wort, Übersetzung und optional einen Beispielsatz auf. Beim Speichern wird lokal geprüft, ob das Wort bereits in der aktuellen Kategorie vorhanden ist.

Wenn das Wort global bereits existiert, aber noch nicht in der aktuellen Wortwelt verknüpft ist, wird das vorhandene Wort wiederverwendet und nur eine Membership ergänzt. Dadurch entstehen keine unnötigen Duplikate.

## 4. KI-Vorschläge nur auf Nutzerklick

Die MVP-Schnittstelle `CategoryWordSuggestionService` nutzt die vorhandene `AiChatClient`-Struktur. Der Prompt enthält Kategorie-Name, vorhandene Wörter und eine Zielanzahl.

Wenn die KI nicht verfügbar ist oder die Antwort nicht als JSON-Liste parsebar ist, wird kein Wort gespeichert und die UI zeigt eine freundliche Fehlermeldung.

## 5. Dedupe-Regeln

- keine zweite Membership in derselben Kategorie
- vorhandene globale Wörter werden verknüpft statt dupliziert
- KI-Vorschläge werden lokal gegen vorhandene Kategorie-Wörter gefiltert
- doppelte Vorschläge in einer Antwort werden verworfen

## 6. Aktiv/deaktiviert-Logik

Der Status ist membership-bezogen:

- `word_world_memberships.is_disabled`
- `word_world_memberships.is_known`

Deaktivierte Wörter bleiben in der Vocabs-Liste sichtbar, werden aber aus Lernmodus-/Practice-Pfaden ausgeschlossen. So kann ein Wort in einer Kategorie pausiert sein, ohne global archiviert zu werden.

## 7. Bekannte Wörter

`is_known` ist als lokale Membership-Spalte vorbereitet. Die vollständige UX für „kenne ich schon“ ist noch nicht gebaut, damit die aktuelle Änderung nicht unnötig groß wird.

## 8. Lernmodus-Filter

Aktive Lernpfade laden Wortwelten weiter über `word_world_memberships`, filtern aber deaktivierte oder bekannte Memberships aus. Die Vocabs-Liste lädt dagegen inklusive deaktivierter Wörter.

## 9. Tests

Abgedeckt sind Repository-Fälle für:

- Membership-Status deaktiviert bleibt sichtbar, aber nicht practiceable
- vorhandenes Wort wird in weitere Wortwelt verknüpft statt dupliziert
- Membership-Schema enthält Statusspalten

## 10. Offene Punkte

- „Kenne ich schon“-UX vollständig bauen
- KI-Vorschläge visuell weiter verfeinern
- optionale Prüfung gegen globale Wortlisten ausbauen
- aktive/deaktivierte Counts später getrennt anzeigen
