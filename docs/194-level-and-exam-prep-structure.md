# Level- und Prüfungspakete

## Ziel

Die Wortwelten-Ansicht soll nur echte thematische Wortwelten zeigen, zum Beispiel Reisen, Essen & Kochen oder Gesundheit & Fitness. A1-C2 sind Lernlevel und keine Wortwelten. Top-500-Listen, Sprachwerkzeuge und Prüfungsvorbereitung sind ebenfalls keine Wortwelten, sondern eigene Lernpakete oder Sammlungen.

## Lernlevel

A1, A2, B1, B2, C1 und C2 beschreiben das Niveau eines Wortes oder einer Übung. Sie sollen nicht als große einzelne Übungseinheiten angeboten werden, weil ein komplettes Level zu breit und zu unscharf ist.

Stattdessen werden Level in kleinere Pakete aufgeteilt. Große Level mit mehreren hundert Wörtern sind für Wortspiele demotivierend und sollen nicht als eine einzige Auswahl erscheinen. Zielgröße pro Paket: ca. 20-50 Wörter.

Aktuelle Paketstruktur:

- A1 Starter
- A1 Alltag
- A1 Verben
- A1 Nomen
- A1 Adjektive
- A1 Reisen & Orientierung
- A1 Essen & Einkaufen
- A2 Alltag
- A2 Arbeit & Schule
- A2 Reisen
- A2 Verben
- A2 Nomen
- A2 Adjektive
- A2 Kommunikation
- B1 Alltag & Meinungen
- B1 Arbeit & Bildung
- B1 Medien & Gesellschaft
- B1 Verben
- B1 Nomen
- B1 Adjektive
- B1 Redemittel
- B2 Diskussion
- B2 Beruf & Studium
- B2 Gesellschaft
- B2 Wissenschaft & Technik
- B2 Verben
- B2 Nomen
- B2 Redemittel
- C1 Argumentation
- C1 Wissenschaft
- C1 Beruflich
- C1 Abstrakte Begriffe
- C1 Stil & Ausdruck
- C1 Redemittel
- C2 Präziser Ausdruck
- C2 Fachsprache
- C2 Nuancen
- C2 Stilmittel
- C2 Seltene Wörter
- C2 Redemittel

Technisch werden die Pakete derzeit aus vorhandenen lokalen Feldern abgeleitet:

- Level aus `words.level`
- Themen über `word_world_memberships`
- Sprachwerkzeuge über vorhandene lokale Kategorien, falls sie existieren

POS-Pakete wie Verben, Nomen und Adjektive sind vorbereitet. Solange lokal kein verlässliches POS-Feld existiert, sollen diese Pakete leer bleiben statt falsche Wörter anzuzeigen.

## Prüfungsvorbereitung

Prüfungsvorbereitung ist ein eigener Bereich und keine Wortwelt. Sie wird erst angezeigt, wenn passende Inhalte vorhanden sind. Mögliche spätere Pakete:

- TOEFL
- IELTS
- Cambridge
- Schule
- Business English

Diese Pakete können Wörter aus mehreren Themen und Leveln enthalten. Sie sollten daher als Lernpakete oder Sammlungen modelliert werden, nicht als Kategorie im Sinne einer Wortwelt.

Aktuell ersetzt Lernlevel die allgemeine Prüfungsvorbereitung nicht vollständig. Eine leere Prüfungsvorbereitungs-Kachel wird bewusst nicht angezeigt.

## Sprachwerkzeuge

Sprachwerkzeuge sind eigene Lernsammlungen:

- Top 500 Wörter
- Redewendung
- Unregelmäßige Verben
- Grammatik & Satzbau

Sie sind keine Wortwelten und dürfen nicht als thematische Kategorie in den Wortspiel-Wortwelten erscheinen.

## Abgrenzung

- Wortwelt: thematischer Kontext, zum Beispiel Reisen oder Arbeit & Karriere.
- Level: sprachliches Niveau, zum Beispiel A1 oder B2.
- Paket: kuratierte Sammlung, zum Beispiel A1 Starter oder TOEFL Basis.
- Sprachwerkzeug: strukturierende Sammlung, zum Beispiel Redewendung oder Unregelmäßige Verben.

## Umsetzungshinweis

Die aktuelle Wortwelten-Ansicht blendet Level und Sprachwerkzeuge aus. Die Wortspiel-Auswahl zeigt Lernlevel und Sprachwerkzeuge als eigene Bereiche neben den Wortwelten. Die Daten bleiben erhalten und werden nicht gelöscht oder migriert.
