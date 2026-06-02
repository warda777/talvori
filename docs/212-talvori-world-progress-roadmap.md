# Talvori Welt Fortschritt und Roadmap

## 1. Zweck

Dieses Dokument ist ein persoenlicher Fortschritts-Kompass fuer Andreas.

Es soll jederzeit sichtbar machen:

- was bereits erledigt wurde,
- wo Talvori Welt gerade steht,
- welche Home-Zentrale-Punkte noch offen sind,
- wann Phase 2 beginnen kann,
- welcher naechste Block sinnvoll ist.

Es ersetzt keine Detail-Dokumente, sondern fasst den Arbeitsstand handlich zusammen.

## 2. Aktueller Gesamtstand

- Talvori ist strategisch auf **Talvori Welt** umgestellt.
- Der alte Vocabulary-MVP-Launch ist pausiert.
- Die bestehende App bleibt die Foundation Build.
- Die **Home-Zentrale** ist aktuell der Hauptfokus.
- Phase 1 ist weit fortgeschritten, aber noch nicht abgeschlossen.
- Phase 2 beginnt erst nach Home-Polish und bestandenem Geraetetest.

Kurz gesagt:

> Home ist fast die Talvori-Welt-Zentrale. Der lokale Welt-Slice fehlt noch.

## 3. Phasenuebersicht mit Status

| Phase | Ziel | Status | Einschaetzung | Naechster Schritt |
| --- | --- | --- | --- | --- |
| Phase 0: Foundation sichern | Bestehende App als Talvori-Welt-Basis bewahren | erledigt | Strategische Umstellung ist dokumentiert; Foundation bleibt wertvoll. | Nur bei Bedarf aktualisieren. |
| Phase 1: Home-Zentrale | Premium-Home mit Globe, Companion, Plus-Wheel, Status und Space-Look | in Arbeit | Ca. 75-85 Prozent fertig. Haupt-Polish fehlt noch bei Bubble, Keyboard und finalem Geraetetest. | Companion-Bubble-Textlayout verbessern. |
| Phase 2: Lokaler Welt-Einstieg | Globe-Tap fuehrt in Startregion/Plot | offen | Noch nicht begonnen. Darf erst nach stabiler Home-Zentrale starten. | Nach Phase-1-Done lokalen Welt-Slice planen. |
| Phase 3: Reward Bridge | Lernen erzeugt Weltressourcen, ohne SRS zu beschaedigen | offen | Architekturziel ist klar, Umsetzung noch offen. | Erst nach lokalem Welt-Slice vorbereiten. |
| Phase 4: Import/DeepL/KI Satzfunken | Importierte Woerter und KI-Sparks werden Welt-/Companion-Material | spaeter | Bestehende Pfade sind wertvoll, aber noch nicht Welt-gekoppelt. | Nach Reward-/World-Grundlage anbinden. |
| Phase 5: Social Minimum | Freunde, Showcase, Reaktionen | spaeter | Nur vorbereiten, kein globaler Chat. | Nach lokalem Wow-Moment. |
| Phase 6: Monetarisierung/Launch-Vorbereitung | Launch, Store, Entitlements, Paywall-Regeln | spaeter | Erst nach erstem Wow-Moment sinnvoll. | Alte Release-Docs spaeter auf Talvori Welt umschreiben. |

## 4. Phase 0: Was erledigt ist

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

## 5. Phase 1: Home-Zentrale - erledigt

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
- Galaxy-/Sternenlayer begonnen.
- Twinkling-Sterne und Sternschnuppen eingebaut.
- Zentraler Plus-/Wheel-Hub statt klassischem Bottom-Dock.
- Wheel-Radius final auf `144`.
- Plus/X-Animation mit 405-Grad-Zielrichtung umgesetzt.
- Dynamischer Home-Status begonnen.
- Tali/Bubble/Companion-Chat grundsaetzlich nutzbar.
- Tali/Bubble sind ueber der Tastatur sichtbar.
- Plan-Abgleich dokumentiert.

## 6. Phase 1: Home-Zentrale - noch offen

### Muss vor Phase 2

- [ ] Companion-Bubble: Text darf nicht abgeschnitten werden.
- [ ] Quick Actions nur bei echten Suggestions anzeigen.
- [ ] Keyboard per Swipe nach unten schliessen.
- [ ] Shooting Stars randomisieren und runder/gluehender machen.
- [ ] Plus/X: 405-Grad-Rotation und X-Farbzustand auf Geraet final pruefen.
- [ ] Debug-Logs entfernen, falls noch vorhanden.
- [ ] Kompletter Geraetetest der Home-Zentrale.
- [ ] Git-Status vor Phase 2 sauber halten.

### Optional vor Phase 2

- [ ] Hintergrund-Modi planen: Subtil / Atmosphaerisch / Galaxie.
- [ ] Tali-Idle-/Focus-Position final feinjustieren.
- [ ] Home-Statuslogik um echte Satzfunken-/Review-Daten erweitern.
- [ ] Wheel-Hub auf unterschiedlichen Geraetegroessen visuell final pruefen.

## 7. Definition of Done fuer Phase 1

Phase 1 gilt als fertig, wenn:

- [ ] Home wirkt nicht mehr ueberladen.
- [ ] Globe ist klarer Hero.
- [ ] Globe bleibt bei Tastatur, Companion-Chat und Input stabil.
- [ ] Plus-Wheel ist intuitiv nutzbar.
- [ ] Plus/X-Zustand ist eindeutig.
- [ ] Tali/Bubble/Chat stoeren den Globe nicht.
- [ ] Bubble-Text funktioniert ohne Cutoff.
- [ ] Quick Actions erscheinen nur, wenn sie sinnvoll sind.
- [ ] Hintergrund wirkt hochwertig, aber nicht ablenkend.
- [ ] Keine offenen Debug-Logs vorhanden sind.
- [ ] Geraetetest bestanden ist.
- [ ] `flutter test test/features/home_screen_layout_test.dart` gruen bleibt.
- [ ] `dart analyze` fuer geaenderte Dateien sauber ist.
- [ ] Git-Status sauber ist.

## 8. Phase 2: Was danach kommt

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

## 9. Geschwindigkeit und Fortschrittseinschaetzung

Grobe Einschaetzung ohne Zeitversprechen:

| Bereich | Stand |
| --- | --- |
| Phase 0 | abgeschlossen |
| Phase 1 | ca. 75-85 Prozent fertig |
| Phase 2 | noch nicht begonnen |
| Bis lokalem Wow-Moment | Home fast fertig, Welt-Slice fehlt noch |

Interpretation:

- Die Richtung ist klar.
- Der sichtbarste Home-Teil ist weit.
- Die groessten verbliebenen Home-Risiken liegen im UI-Polish und Geraetetest.
- Der lokale Wow-Moment beginnt erst mit Phase 2: Startregion, Plot, Gebaeude.

## 10. Naechster konkreter Block

Empfohlener naechster Codeblock:

**Companion-Bubble Textlayout verbessern**

Umfang:

- Quick Actions nur bei echten Suggestions anzeigen.
- Standard-Bubble zeigt Tali-Name, Text und Chat-Icon.
- Text waechst bzw. scrollt statt abgeschnitten zu werden.
- Keyboard per Swipe nach unten schliessen.

Warum dieser Block zuerst:

- Es ist der sichtbarste verbleibende Home-Polish-Punkt.
- Er verbessert Talis Nutzbarkeit direkt.
- Er reduziert den Eindruck von Enge und UI-Ueberladung.
- Er ist klar abgrenzbar und sollte Globe/Hub/Background nicht beruehren.

## 11. Arbeitsregel fuer Andreas

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

