# Talvori Welt Fortschritt und Roadmap

## 1. Zweck

Dieses Dokument ist ein persoenlicher Fortschritts-Kompass fuer Andreas.

Es soll jederzeit sichtbar machen:

- was bereits erledigt wurde,
- wo Talvori Welt gerade steht,
- welche Home-Zentrale-Punkte noch offen sind,
- wann Phase 2 beginnen kann,
- welcher naechste Block sinnvoll ist.

Diese Version wurde gegen den aktuellen Git-/Code-Stand abgeglichen. Sie ersetzt nicht die Detail-Dokumente, sondern fasst den Arbeitsstand handlich zusammen.

## 2. Aktueller Gesamtstand

- Talvori ist strategisch auf **Talvori Welt** umgestellt.
- Der alte Vocabulary-MVP-Launch ist pausiert.
- Die bestehende App bleibt die Foundation Build.
- Die **Home-Zentrale** ist aktuell der Hauptfokus.
- Phase 1 ist funktional und visuell weit fortgeschritten.
- Phase 2 beginnt erst nach einem dokumentierten Home-Abschlusscheck auf dem Geraet.

Kurz gesagt:

> Home ist fast Phase-1-fertig. Vor Phase 2 fehlt vor allem der finale Home-Zentrale-Geraetetest.

## 3. Aktueller Abgleich offener Punkte aus der alten Roadmap

| Punkt aus docs/212 | aktueller Code/Git-Stand | Status | Entscheidung |
| --- | --- | --- | --- |
| Companion-Bubble: Text darf nicht abgeschnitten werden | `TalvoriCompanionCard` nutzt `SingleChildScrollView` fuer den Text und hoehere Max-Hoehen ohne Quick Actions. | erledigt | Aus Muss-To-dos entfernen; weiter nur im Geraetetest beobachten. |
| Quick Actions nur bei echten Suggestions anzeigen | `quickActions` ist optional und Buttons werden nur bei `quickActions.isNotEmpty` gerendert. Home uebergibt aktuell keine dauerhaften Quick Actions. | erledigt | Aus Muss-To-dos entfernen. |
| Keyboard per Swipe nach unten schliessen | Home nutzt `onVerticalDragUpdate`, `onVerticalDragEnd` und `Listener.onPointerMove` im Companion-Input-Overlay. | erledigt | Aus Muss-To-dos entfernen; im Geraetetest verifizieren. |
| Shooting Stars randomisieren und runder/gluehender machen | Mehrere `_HomeShootingStarEvent`s mit unterschiedlichen Startpunkten/Richtungen; Kopf wird als runder Glow/Halo/Core gemalt. | erledigt | Aus Muss-To-dos entfernen; visuell im Geraetetest pruefen. |
| Plus/X: 405-Grad-Rotation und X-Farbzustand final pruefen | `HomeSmartHubMenu` nutzt `turns: open ? 1.125 : 0`, violett betonten offenen Zustand und Wheel-Radius `144`. | erledigt / Geraetetest offen | Umsetzung erledigt; nur final visuell pruefen. |
| Debug-Logs entfernen, falls noch vorhanden | Keine alten Home-Layout-Snapshot-Logs erkennbar. Es gibt weiterhin regulaere `debugPrint`s in Home/Course/Progress-Pill-Pfaden. | unklar | Nicht pauschal entfernen; vor Phase 2 gezielt pruefen, ob stoerende Debug-Ausgaben im Home-Geraetetest auftreten. |
| Kompletter Geraetetest Home-Zentrale | Kein dokumentierter finaler Geraetetest nach allen Home-Polish-Commits vorhanden. | offen | Naechster sinnvoller Block. |
| Git-Status vor Phase 2 sauber halten | Aktueller Arbeitsbaum war beim Audit sauber. | erledigt | Weiter als Abschlusskriterium behalten. |
| Tali-Idle-/Focus-Position final feinjustieren | Keine neue Code-Aenderung im Audit. Nur per Geraet sicher bewertbar. | optional / Geraetetest | Im Abschlusscheck pruefen, nicht als separater Muss-Block vorziehen. |
| Home-Statuslogik um echte Satzfunken-/Review-Daten erweitern | Minimaler dynamischer Status ist vorhanden; echte Review-/Satzfunken-Prioritaet ist noch nicht voll angebunden. | optional / spaeter | Nicht blockierend fuer Phase 2, sofern Home-Status sauber wirkt. |

## 4. Phasenuebersicht mit Status

| Phase | Ziel | Status | Einschaetzung | Naechster Schritt |
| --- | --- | --- | --- | --- |
| Phase 0: Foundation sichern | Bestehende App als Talvori-Welt-Basis bewahren | erledigt | Strategische Umstellung ist dokumentiert; Foundation bleibt wertvoll. | Nur bei Bedarf aktualisieren. |
| Phase 1: Home-Zentrale | Premium-Home mit Globe, Companion, Plus-Wheel, Status und Space-Look | fast fertig | Ca. 90 Prozent fertig. Code-Polish ist weitgehend erledigt; finaler Geraetetest fehlt. | Phase-1-Abschlusscheck / Home-Zentrale-Geraetetest. |
| Phase 2: Lokaler Welt-Einstieg | Globe-Tap fuehrt in Startregion/Plot | offen | Noch nicht begonnen. Darf erst nach dokumentiertem Home-Abschlusscheck starten. | Nach Phase-1-Done lokalen Welt-Slice planen. |
| Phase 3: Reward Bridge | Lernen erzeugt Weltressourcen, ohne SRS zu beschaedigen | offen | Architekturziel ist klar, Umsetzung noch offen. | Erst nach lokalem Welt-Slice vorbereiten. |
| Phase 4: Import/DeepL/KI Satzfunken | Importierte Woerter und KI-Sparks werden Welt-/Companion-Material | spaeter | Bestehende Pfade sind wertvoll, aber noch nicht Welt-gekoppelt. | Nach Reward-/World-Grundlage anbinden. |
| Phase 5: Social Minimum | Freunde, Showcase, Reaktionen | spaeter | Nur vorbereiten, kein globaler Chat. | Nach lokalem Wow-Moment. |
| Phase 6: Monetarisierung/Launch-Vorbereitung | Launch, Store, Entitlements, Paywall-Regeln | spaeter | Erst nach erstem Wow-Moment sinnvoll. | Alte Release-Docs spaeter auf Talvori Welt umschreiben. |

## 5. Phase 0: Was erledigt ist

- Alter Vocabulary-MVP-Launch ist pausiert.
- Foundation Build bleibt wertvoll und wird nicht verworfen.
- `AGENTS.md` ist auf Talvori Welt ausgerichtet.
- Transition-, Vertical-Slice- und Architecture-Docs sind vorhanden.
- Alte Store-/Release-Arbeit bleibt Compliance-Material.
- Bestehende Lern-, Wort-, Import-, Translation-, Companion-, Tagesimpuls-, Profile-, Stats- und Games-Pfade bleiben nutzbar.
- Schutzregeln sind festgehalten:
  - keine Supabase Writes ohne Freigabe,
  - keine ungeplanten SQLite-/SRS-/`word_progress`-Aenderungen,
  - keine Secrets oder Release-Artefakte.

## 6. Phase 1: Home-Zentrale - erledigt

Der aktuelle Home-Stand hat bereits viel vom Zielbild erreicht:

- Premium-Globus statt altem Wireframe-/CustomPainter-Globe.
- Realistischer Globe mit Earth3D / `flutter_globe_3d`.
- Talvori-Premium-Shader.
- Coastline-Highlights.
- Night-Lights.
- City-/Node-Lichter.
- Durchgehende Network-Lines statt gestrichelter Linien.
- Lens-Flare-artige Star-/Node-Lichter.
- Globe groesser und zentral als Hero platziert.
- Aeusserer goldener Kreis entfernt.
- Globe bleibt Tap-Ziel fuer Welt/Startregion.
- Globe bleibt bei Companion-Chat und Tastatur stabil.
- Ursache des Keyboard-Zoom-Bugs gefunden: `MediaQuery.padding.bottom`.
- Home-/Hero-/Globe-Layer nutzt keyboard-stabile Safe-Area-Werte.
- Input-Bar nutzt weiterhin echtes `viewInsets.bottom`.
- Cyan/lila Ambient-Background.
- Galaxy-/Sternenlayer mit Twinkling.
- Sternschnuppen mit mehreren Richtungen, weichem Schweif und rundem Glow-Kopf.
- Zentraler Plus-/Wheel-Hub statt klassischem Bottom-Dock.
- Wheel-Radius final auf `144`.
- Plus/X-Animation mit 405-Grad-Zielrichtung umgesetzt.
- Offener Plus/X-Zustand hat staerkeren violetten Cyan/Violett-Look ohne Gold.
- Dynamischer Home-Status begonnen.
- Tali/Bubble/Companion-Chat grundsaetzlich nutzbar.
- Tali/Bubble sind ueber der Tastatur sichtbar.
- Companion-Bubble-Text ist scrollbar statt hart abgeschnitten.
- Quick Actions erscheinen nur bei vorhandenen `quickActions`.
- Keyboard-Dismiss per Swipe/Drag im Companion-Input-Overlay umgesetzt.
- Plan-Abgleich dokumentiert.

## 7. Phase 1: Home-Zentrale - noch offen

### Muss vor Phase 2

- [ ] Phase-1-Abschlusscheck / kompletter Geraetetest der Home-Zentrale.
- [ ] Plus/X 405-Grad-Animation und X-Farbzustand auf Geraet final pruefen.
- [ ] Companion-Bubble mit laengerem Text auf Geraet pruefen.
- [ ] Keyboard-Swipe-Dismiss auf Geraet pruefen.
- [ ] Galaxy/Shooting-Stars auf Geraet visuell pruefen.
- [ ] Pruefen, ob alte Debug-/Diagnose-Logs im Home-Geraetetest stoeren.
- [ ] Git-Status nach Abschlusscheck sauber halten.

### Optional vor Phase 2

- [ ] Hintergrund-Modi planen: Subtil / Atmosphaerisch / Galaxie.
- [ ] Tali-Idle-/Focus-Position final feinjustieren, falls der Geraetetest es zeigt.
- [ ] Home-Statuslogik um echte Satzfunken-/Review-Daten erweitern.
- [ ] Wheel-Hub auf unterschiedlichen Geraetegroessen visuell final pruefen.

## 8. Definition of Done fuer Phase 1

Phase 1 gilt als fertig, wenn:

- [ ] Home wirkt nicht mehr ueberladen.
- [ ] Globe ist klarer Hero.
- [ ] Globe bleibt bei Tastatur, Companion-Chat und Input stabil.
- [ ] Plus-Wheel ist intuitiv nutzbar.
- [ ] Plus/X-Zustand ist eindeutig.
- [ ] Tali/Bubble/Chat stoeren den Globe nicht.
- [x] Bubble-Text ist technisch scrollbar und nicht hart auf wenige Zeilen festgenagelt.
- [x] Quick Actions erscheinen nur bei vorhandenen Actions.
- [x] Keyboard-Dismiss per Swipe/Drag ist technisch umgesetzt.
- [ ] Hintergrund wirkt hochwertig, aber nicht ablenkend.
- [ ] Keine stoerenden offenen Debug-Logs vorhanden sind.
- [ ] Geraetetest bestanden und dokumentiert ist.
- [ ] `flutter test test/features/home_screen_layout_test.dart` gruen bleibt.
- [ ] `dart analyze` fuer geaenderte Dateien sauber ist.
- [ ] Git-Status sauber ist.

## 9. Phase 2: Was danach kommt

Phase 2 startet erst nach Phase-1-Done.

Ziel:

- Globe-Tap fuehrt nicht mehr nur zu einem Platzhalter.
- Es entsteht ein lokaler Welt-Einstieg.

Erster Scope:

- Startregion.
- Eigener Plot.
- Drei Gebaeude:
  - Haus,
  - Markt,
  - Bibliothek.
- Erste Ressourcen als lokale/mock Werte.
- Sichtbarer Ausbau oder Fortschritt.

Nicht in Phase 2:

- keine Reward Bridge als Vollsystem,
- keine Supabase Writes,
- keine Cloud-Welt,
- keine SRS-/`word_progress`-Migration,
- kein Social Backend.

## 10. Geschwindigkeit und Fortschrittseinschaetzung

Grobe Einschaetzung ohne Zeitversprechen:

| Bereich | Stand |
| --- | --- |
| Phase 0 | abgeschlossen |
| Phase 1 | ca. 90 Prozent fertig; finaler Geraetetest offen |
| Phase 2 | noch nicht begonnen |
| Bis lokalem Wow-Moment | Home fast fertig, Welt-Slice fehlt noch |

Interpretation:

- Die Richtung ist klar.
- Die wichtigsten Home-Code-Polish-Punkte sind erledigt.
- Das groesste verbliebene Phase-1-Risiko ist nicht mehr ein einzelner Codeblock, sondern der komplette Geraeteeindruck.
- Der lokale Wow-Moment beginnt erst mit Phase 2: Startregion, Plot, Gebaeude.

## 11. Naechster konkreter Block

Empfohlener naechster Block:

**Phase-1-Abschlusscheck / Home-Zentrale-Geraetetest**

Umfang:

- Home auf echtem Geraet in geschlossenen/offenen Zustaenden pruefen.
- Globe, Galaxy, Tali, Bubble, Keyboard, Plus-Wheel und Home-Status zusammen bewerten.
- Plus/X 405-Grad-Animation visuell bestaetigen.
- Companion-Bubble mit langem Text pruefen.
- Keyboard per Swipe nach unten schliessen.
- Shooting Stars/Galaxy auf Sichtbarkeit und Ruhe pruefen.
- Debug-Ausgaben beobachten.
- Ergebnis dokumentieren: Phase 1 fertig oder konkrete Restliste.

Warum dieser Block jetzt:

- Die frueheren Muss-Codepunkte sind weitgehend umgesetzt.
- Vor Phase 2 sollte kein weiterer grosser Home-Umbau auf Verdacht passieren.
- Der Geraetetest entscheidet, ob Phase 1 wirklich abgeschlossen werden kann.

## 12. Arbeitsregel fuer Andreas

Nach jedem groesseren UI-/Feature-Block:

1. Screenshot oder Geraeteeindruck pruefen.
2. Relevante Tests und Analyze pruefen.
3. Commit erstellen.
4. Dokumentationsstand kurz pruefen.
5. Erst dann den naechsten Block starten.

Wenn ein visueller Fehler nicht klar erklaerbar ist:

- erst Runtime-Werte oder Screenshots sammeln,
- dann fixen,
- nicht mehrere Hypothesen gleichzeitig umbauen.

