# Store-Release-Checkliste

Stand: 2026-05-30

Diese Checkliste ist eine praktische Arbeitsliste fuer den Talvori-MVP. Sie ersetzt keine aktuelle Pruefung der Apple- und Google-Store-Vorgaben.

## 1. App-Identitaet

- [ ] App-Name final: `Talvori`
- [ ] Untertitel / Kurzbeschreibung final
- [ ] Langbeschreibung final
- [ ] Kategorie festgelegt
- [ ] Keywords / Suchbegriffe vorbereitet
- [ ] App-Icon final geprueft
- [ ] Bundle ID / Package Name geprueft
- [ ] Version und Build Number gesetzt

## 2. Rechtliches

- [ ] Datenschutztext final erstellt
- [ ] Datenschutztext juristisch/fachkundig geprueft
- [ ] Datenschutz-URL verfuegbar
- [ ] AGB oder Nutzungsbedingungen final erstellt
- [ ] AGB/Nutzungsbedingungen juristisch/fachkundig geprueft
- [ ] Impressum oder Anbieterinformationen final
- [ ] Anbieter/Kontakt im Store korrekt hinterlegt
- [ ] Altersfreigabe geprueft
- [ ] Datenverwendungsangaben im Store konsistent mit App-Verhalten

## 3. Support Und Feedback

- [ ] Support-E-Mail oder Support-URL festgelegt
- [ ] Support-Kontakt in App erreichbar
- [ ] Hilfe/FAQ fuer MVP-Fragen vorbereitet
- [ ] Feedback-Kanal klar beschrieben
- [ ] Bewertungslink erst aktiv, wenn Store-Ziel bekannt ist
- [ ] Keine Fake-Kontaktfunktion sichtbar

## 4. App-Funktionalitaet Fuer Review

- [ ] Release-Build erstellt
- [ ] Release-Build auf echtem iOS-Geraet geprueft
- [ ] Release-Build auf echtem Android-Geraet geprueft, falls Android MVP
- [ ] Frischer App-Start geprueft
- [ ] Onboarding durchlaufen
- [ ] HomeScreen geprueft
- [ ] Settings geprueft
- [ ] Profile geprueft
- [ ] Lernmodus geprueft
- [ ] Woerter pruefen geprueft
- [ ] Wortwelten geprueft
- [ ] Wortspiele geprueft
- [ ] Browser-oeffnen geprueft
- [ ] Share-/Import-Pfade geprueft, falls im MVP sichtbar
- [ ] Tagesimpuls/Notifications geprueft, falls im MVP sichtbar
- [ ] Offline-Start geprueft
- [ ] App killen und neu starten geprueft

## 5. Release-Sicherheit

- [ ] Debug-Routen im Release nicht erreichbar
- [ ] Entwicklerbereich in Settings im Release nicht sichtbar
- [ ] Supabase-Importscreen im Release nicht normal erreichbar
- [ ] Legacy Supabase Auto-Sync im Release gegated
- [ ] Keine ungeprueften Remote-Imports beim App-Start
- [ ] Keine SRS-/word_progress-Daten werden durch Content-Sync ueberschrieben
- [ ] Lokaler Datenbestand startet stabil
- [ ] Fehlerfaelle zeigen keine Entwicklertexte fuer Nutzer

## 6. Store-Material

- [ ] Screenshots iPhone klein/mittel/gross vorbereitet
- [ ] Screenshots iPad vorbereitet, falls iPad unterstuetzt
- [ ] Screenshots Android Phone vorbereitet, falls Android MVP
- [ ] Feature-Grafik vorbereitet, falls Google Play
- [ ] Beschreibungstexte konsistent mit tatsaechlichem MVP-Scope
- [ ] Nicht enthaltene Features nicht als verfuegbar bewerben
- [ ] Preview-/geplante Bereiche in Texten vorsichtig formulieren
- [ ] Store-Testhinweise fuer Review vorbereitet

## 7. Datenschutzangaben Speziell Fuer Talvori

- [ ] lokale Lernstaende beschrieben
- [ ] Favoriten, bekannte Woerter und eigene Woerter beschrieben
- [ ] Settings/Profile-Praeferenzen beschrieben
- [ ] Supabase-Rolle korrekt beschrieben
- [ ] AI-/Companion-Datenfluesse beschrieben, falls aktiv
- [ ] Tagesimpuls/Notification-Daten beschrieben, falls aktiv
- [ ] spaetere Accounts/Backups nicht als aktuell aktiv darstellen
- [ ] spaetere Chat-/Companion-Synchronisation nicht als aktuell aktiv darstellen

## 8. Bekannte Nicht Enthaltene Features

- [ ] kein produktiver Cloud-Backup-/Account-Sync im MVP, falls nicht fertig
- [ ] kein vollstaendiger Content-Package-Sync im MVP, falls nicht fertig
- [ ] keine vollstaendige Mehrsprachigkeitsabdeckung fuer alle Zielsprachen
- [ ] keine TOEFL-/IELTS-/Cambridge-Pakete als verfuegbar bewerben, solange nicht produktiv
- [ ] Premium/Abo nur bewerben, wenn Store/Payment wirklich fertig ist

## 9. Finale Vor-Einreichungsrunde

- [ ] `flutter test` gruen
- [ ] `git diff --check` sauber
- [ ] Release-Build installiert und Smoke-Test bestanden
- [ ] Debug-Sichtbarkeit manuell im Release geprueft
- [ ] Datenschutz-/Support-Links im Store erreichbar
- [ ] App-Beschreibung passt zum Build
- [ ] Testhinweise fuer Store Reviewer ergaenzt
- [ ] finale Entscheidung: lokaler Seed oder kontrollierter Content-Paket-Stand
