# Release-/Device-Smoke-Test

> Supersession notice: This document belongs to the old vocabulary-app MVP
> launch path. It is preserved as Foundation Build / future compliance
> material. The current public product direction is Talvori Welt; do not
> continue this as the next launch path without explicit decision.

Datum: 2026-05-30

Build-Typ: manuell getestet, Build-Typ nicht dokumentiert

Dieser Bericht dokumentiert einen manuellen Smoke-Test fuer den Talvori-MVP. Der Test ersetzt keinen finalen Release-Build-Test direkt vor der Store-Einreichung.

## 1. Zusammenfassung

Der manuelle Smoke-Test wurde fuer die wichtigsten sichtbaren MVP-Pfade durchgefuehrt. Alle dokumentierten Bereiche wurden als bestanden gemeldet.

Produktivdaten wurden dabei nicht geaendert:

- keine Supabase-Daten geaendert
- kein Import ausgefuehrt
- keine SQLite-/Vokabeldaten geaendert
- keine SRS-/`word_progress`-Daten geaendert
- keine Vokabelkorrekturen vorgenommen

## 2. Getestete Bereiche

| Bereich | Ergebnis | Notiz |
| --- | --- | --- |
| Start | bestanden | App startet im getesteten Zustand. |
| Onboarding | bestanden | Einstieg wurde manuell durchlaufen. |
| Home | bestanden | HomeScreen wurde geprueft. |
| Settings Legal Links | bestanden | Datenschutz, Nutzungsbedingungen, Impressum und Support wurden geprueft. |
| Profile Support Link | bestanden | Support-Link im Profil wurde geprueft. |
| Feedback mailto | bestanden | Feedback-Mail-Link wurde geprueft. |
| Debug-Sichtbarkeit | bestanden | Debug-/Developer-Sichtbarkeit wurde manuell geprueft. |
| Offline-Start | bestanden | App-Start ohne Verbindung wurde geprueft. |
| Wortspiele | bestanden | Wortspielbereich wurde geprueft. |
| Lernmodus | bestanden | Lernmodus wurde geprueft. |
| Browser oeffnen | bestanden | Browser-Oeffnen wurde geprueft. |

## 3. Legal-/Support-Links

In der App vorbereitet und im Smoke-Test beruecksichtigt:

- Datenschutz: `https://talvori.eu/privacy/`
- Nutzungsbedingungen: `https://talvori.eu/terms/`
- Impressum: `https://talvori.eu/imprint/`
- Support: `https://talvori.eu/support/`
- Feedback: `mailto:support@talvori.eu`

## 4. Offene Nachpruefungen

- finaler Release-Build direkt vor Store-Einreichung
- iOS und Android getrennt testen, falls beide Plattformen veroeffentlicht werden
- Store-Review-Testhinweise final vorbereiten
- Datenschutz-/AGB-/Impressum-Inhalte final juristisch pruefen
- Support-/Legal-Mailpostfaecher regelmaessig abrufen
- Store-Metadaten, Screenshots, Altersfreigabe und Datenverwendungsangaben final gegen Store-Vorgaben pruefen

## 5. Bewertung

Der Smoke-Test reduziert das Risiko fuer offensichtliche MVP-Brueche in Start, erster Nutzerreise, Legal-/Support-Verweisen, Debug-Sichtbarkeit und zentralen Lern-/Spielpfaden.

Trotzdem bleibt vor Store-Einreichung ein separater finaler Release-Build-Test Pflicht, weil der Build-Typ dieses manuellen Tests nicht dokumentiert wurde.
