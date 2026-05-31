# Store-Release-Checkliste

Stand: 2026-05-30

Diese Checkliste ist eine praktische Arbeitsliste fuer den Talvori-MVP. Sie ersetzt keine aktuelle Pruefung der Apple- und Google-Store-Vorgaben.

## 1. App-Identitaet

- [x] App-Name final: `Talvori`
- [x] Store-/Build-Identitaet geprueft: `docs/store_build_identity_check.md`
- [x] Untertitel-/Kurzbeschreibungsentwuerfe vorbereitet
- [x] Langbeschreibung als Entwurf vorbereitet
- [x] Kategorie-Empfehlung vorbereitet: primaer Bildung
- [x] Keywords / Suchbegriffe vorbereitet
- [ ] App-Icon final geprueft
- [x] Bundle ID / Package Name auf finale MVP-ID umgestellt: `eu.talvori.app`
- [x] Version und Build Number geprueft: `1.0.0+1`
- [ ] Apple Developer App ID und App Group `group.eu.talvori.app` angelegt/bestaetigt
- [ ] Google Play Application ID `eu.talvori.app` im Play Console Setup bestaetigt
- [x] Signing-Setup-Plan erstellt: `docs/store_signing_setup_plan.md`
- [x] Android Release-Build-Check dokumentiert: `docs/android_release_build_check.md`

## 2. Rechtliches

- [ ] Datenschutztext final erstellt
- [ ] Datenschutztext juristisch/fachkundig geprueft
- [x] Datenschutz-URL in App vorbereitet: `https://talvori.eu/privacy/`
- [ ] AGB oder Nutzungsbedingungen final erstellt
- [ ] AGB/Nutzungsbedingungen juristisch/fachkundig geprueft
- [x] Nutzungsbedingungen-URL in App vorbereitet: `https://talvori.eu/terms/`
- [ ] Impressum oder Anbieterinformationen final geprueft
- [x] Impressum-URL in App vorbereitet: `https://talvori.eu/imprint/`
- [ ] Anbieter/Kontakt im Store korrekt hinterlegt
- [ ] Altersfreigabe geprueft
- [ ] Datenverwendungsangaben im Store konsistent mit App-Verhalten

## 3. Support Und Feedback

- [x] Support-E-Mail festgelegt: `support@talvori.eu`
- [x] Legal-E-Mail festgelegt: `legal@talvori.eu`
- [x] Support-URL in App vorbereitet: `https://talvori.eu/support/`
- [x] Support-Kontakt in App erreichbar
- [ ] Hilfe/FAQ fuer MVP-Fragen vorbereitet
- [x] Feedback-Kanal in App vorbereitet: `support@talvori.eu`
- [ ] Bewertungslink erst aktiv, wenn Store-Ziel bekannt ist
- [ ] Keine Fake-Kontaktfunktion sichtbar

## 4. App-Funktionalitaet Fuer Review

- [x] Android Release-Appbundle lokal erfolgreich erstellt: `build/app/outputs/bundle/release/app-release.aab`
- [x] Android Release Signing lokal vorbereitet und erfolgreich fuer AppBundle-Build genutzt
- [x] Android Release Signing Template vorbereitet: `android/key.properties.example`
- [x] Keystore-/Secret-Dateien in `.gitignore` geschuetzt
- [x] `android/key.properties` und lokaler `.jks`-Keystore bleiben ignored
- [ ] Release-Build auf echtem iOS-Geraet geprueft
- [ ] Release-Build auf echtem Android-Geraet geprueft, falls Android MVP
- [x] Frischer App-Start manuell geprueft
- [x] Onboarding manuell durchlaufen
- [x] HomeScreen manuell geprueft
- [ ] Settings geprueft
- [x] Settings Legal Links manuell geprueft
- [x] Profile Support Link manuell geprueft
- [x] Feedback-Mail-Link manuell geprueft
- [x] Lernmodus manuell geprueft
- [ ] Woerter pruefen geprueft
- [ ] Wortwelten geprueft
- [x] Wortspiele manuell geprueft
- [x] Browser-oeffnen manuell geprueft
- [ ] Share-/Import-Pfade geprueft, falls im MVP sichtbar
- [ ] Tagesimpuls/Notifications geprueft, falls im MVP sichtbar
- [x] Offline-Start manuell geprueft
- [ ] App killen und neu starten geprueft

Hinweis: Der dokumentierte Smoke-Test wurde manuell durchgefuehrt; der Build-Typ ist nicht dokumentiert. Ein Android Release-Appbundle wurde erfolgreich lokal gebaut, aber ein finaler installierter Release-Build-Test direkt vor Store-Einreichung bleibt offen. Details: `docs/release_device_smoke_test.md` und `docs/android_release_build_check.md`.

## 5. Release-Sicherheit

- [x] Debug-Sichtbarkeit manuell geprueft
- [ ] Debug-Routen im finalen Release-Build nicht erreichbar
- [ ] Entwicklerbereich in Settings im finalen Release-Build nicht sichtbar
- [ ] Supabase-Importscreen im finalen Release-Build nicht normal erreichbar
- [ ] Legacy Supabase Auto-Sync im Release gegated
- [ ] Keine ungeprueften Remote-Imports beim App-Start
- [ ] Keine SRS-/word_progress-Daten werden durch Content-Sync ueberschrieben
- [x] MVP-Content-Scope als Entwurf festgelegt: `docs/mvp_content_scope.md`
- [x] Erster MVP-Content-Review-Batch erzeugt: `docs/word-review/mvp_content_first_review_batch.csv`
- [x] Travel und Food & Cooking in lokaler Working-Copy vorgeprueft
- [x] Home & Living im MVP-Content-Review-Batch geprueft
- [x] MVP-Content-Review-Overlay nach 150/150 Entscheidungen erzeugt: `docs/word-review/mvp_content_first_review_overlay.csv`
- [x] Erster MVP-Content-Review-Batch manuell geprueft
- [x] Screenshot-/Startcontent-Auswahl aus `approved_for_mvp` vorbereitet: `docs/word-review/mvp_screenshot_content_selection.csv`
- [ ] Englisch-Deutsch-MVP-Kernbestand fachlich geprueft
- [ ] Lokaler Datenbestand startet stabil
- [ ] Fehlerfaelle zeigen keine Entwicklertexte fuer Nutzer

## 6. Store-Material

- [ ] Screenshots iPhone klein/mittel/gross vorbereitet
- [ ] Screenshots iPad vorbereitet, falls iPad unterstuetzt
- [ ] Screenshots Android Phone vorbereitet, falls Android MVP
- [ ] Feature-Grafik vorbereitet, falls Google Play
- [x] Store-Metadaten-Draft erstellt: `docs/store_metadata_draft.md`
- [x] Beschreibungstexte als MVP-Entwurf vorbereitet
- [x] Nicht-bewerben-Liste erstellt
- [x] Finaler MVP-Blocker-Review erstellt: `docs/final_mvp_blocker_review.md`
- [x] Wortspiele-Release-Scope dokumentiert: `docs/word_games_release_scope.md`
- [ ] Preview-/geplante Bereiche in Texten vorsichtig formulieren
- [x] Wort-Duell als Vorschau eingeordnet, nicht als fertiger Multiplayer
- [x] Store-Testhinweise als Entwurf vorbereitet: `docs/store_review_notes_draft.md`
- [x] Store-Screenshot-Shotlist vorbereitet: `docs/store_screenshot_shotlist.md`
- [x] Screenshot-Wortzuordnung je Screen vorbereitet: `docs/word-review/mvp_screenshot_words_by_screen.csv`
- [ ] Store-Texte final gegen tatsaechlichen Release-Build pruefen
- [ ] Screenshots nur mit manuell geprueften Englisch-Deutsch-Woertern aus dem MVP-Review-Batch erstellen
- [ ] Screenshots bevorzugt mit `docs/word-review/mvp_screenshot_content_selection.csv` planen
- [ ] Keine Wort-Duell-/Premium-/Cloud-/TOEFL-/Debug-Screenshots verwenden
- [ ] Keine vollstaendige Spanisch-/Franzoesisch-Abdeckung oder 13k-Freigabe bewerben

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
- [ ] kein vollstaendig gepruefter 13k-Wortbestand behaupten
- [ ] keine vollstaendigen Spanisch-/Franzoesisch-Inhalte bewerben
- [ ] keine TOEFL-/IELTS-/Cambridge-Pakete als verfuegbar bewerben, solange nicht produktiv
- [ ] Premium/Abo nur bewerben, wenn Store/Payment wirklich fertig ist

## 9. Finale Vor-Einreichungsrunde

- [ ] `flutter test` gruen
- [ ] `git diff --check` sauber
- [x] Manueller Smoke-Test fuer zentrale MVP-Pfade dokumentiert
- [x] Android Release-Appbundle-Build erfolgreich dokumentiert
- [x] Aktuelle MVP-Blocker priorisiert: `docs/final_mvp_blocker_review.md`
- [ ] Finaler Release-Build installiert und Smoke-Test bestanden
- [ ] Debug-Sichtbarkeit manuell im finalen Release-Build geprueft
- [ ] Datenschutz-/Support-Links im Store erreichbar und auf echtem Geraet getestet
- [ ] App-Beschreibung passt zum Build
- [x] Testhinweise fuer Store Reviewer als Entwurf ergaenzt
- [ ] Store-Metadaten final eingereicht
- [x] finale MVP-Content-Richtung festgelegt: Englisch -> Deutsch, kleiner gepruefter sichtbarer Kern
- [ ] Review-Batch fuer sichtbare MVP-Wortwelten abgeschlossen
