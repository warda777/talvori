# Talvori Welt: Build Feedback, Animation Und Sound

Stand: 2026-06-04

Dieses Dokument definiert Phase 2E-A6: Build-Feedback, Animation und
Sound-Konzept fuer den ersten lokalen Bauzustandswechsel in Talvori Welt.

Es ist Pflichtgrundlage fuer Phase 2E-E und spaetere Bauzustaende. Es wurden
keine Sounddateien, keine neuen Packages, keine Persistenz, keine Supabase
Writes, keine SQLite-/SRS-/`word_progress`-Aenderungen, keine Reward Bridge,
keine echten Ressourcen und keine produktive Audio- oder Feedback-Schicht
geplant oder gebaut.

Grundlagen:

- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `docs/world_design/225-in-world-learning-ui.md`
- `docs/world_design/232-onboarding-first-session.md`
- `docs/world_design/238-multi-scale-world-and-interior-system.md`
- `docs/world_design/240-private-island-state-system.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`

## 1. Zweck Des Dokuments

Dieses Dokument definiert Build-Feedback, Animation und Sound fuer Talvori.

Es verhindert, dass Baufortschritt statisch, billig oder wie ein harter
Bildtausch wirkt.

Es legt fest, dass der Wechsel `empty -> foundation_started` ein kleiner
Build-Feedback-Moment sein muss:

- kurz,
- ruhig,
- klar,
- mobile-tauglich,
- ohne uebertriebene Effekte,
- ohne produktive Audio- oder Reward-Logik.

## 2. Research-Ergebnis

Das Professional Game Development Research Gate wurde fuer diesen Schritt
angewendet.

| Quelle / Orientierung | Ableitung fuer Talvori | Konkrete Entscheidung |
| --- | --- | --- |
| `Designing Game Feel. A Survey`, arXiv: `https://arxiv.org/abs/2011.09201` | Game Feel entsteht durch Tuning, Juicing und Streamlining. Feedback muss Ereignisse verstaendlich und spuerbar machen. | Baufortschritt braucht eine kurze visuelle Rueckmeldung, nicht nur einen Zustandswechsel. |
| Unity Learn, Dynamic Sound Effects: `https://learn.unity.com/tutorial/create-dynamic-sound-effects-1` | Sound ist ein eigener Produktionsbereich und sollte als Effekt gedacht werden, nicht als zufaelliger Widget-Nebeneffekt. | Phase 2E-E bereitet nur eine Sound-/Feedback-ID vor. Keine echte Sounddatei und kein Playback. |
| Material Design Motion, Duration & Easing: `https://m1.material.io/motion/duration-easing.html` | Kurze, natuerliche Bewegungen mit Easing wirken responsiver als mechanische harte Wechsel. | Overlay-Fade/Scale nutzt kurze Dauer und ruhiges Easing. |
| Microsoft Xbox Accessibility Guideline 105: `https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/105` | Audioausgabe braucht spaeter getrennte Lautstaerke-/Mute-Kontrolle. Wichtige Information darf nicht nur akustisch vermittelt werden. | Sound muss spaeter abschaltbar sein; Phase 2E-E zeigt alle wichtigen Informationen visuell/textlich. |
| Flutter `MediaQueryData.disableAnimations`: `https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html` | Flutter kann reduzierte Animationen aus Accessibility-Settings erkennen. | 2E-E-Animationen werden so klein gehalten, dass sie spaeter leicht reduziert oder deaktiviert werden koennen. |

Kurzfassung:

Professionelle Spiele nutzen Game Feel/Juice, damit Aktionen unmittelbar und
bedeutungsvoll wirken. Sound, Timing, kleine visuelle Effekte und klare
Rueckmeldung machen Fortschritt greifbar. Gleichzeitig duerfen diese Effekte
den Nutzer nicht ueberladen, muessen kurz bleiben und brauchen spaeter
Accessibility-/Mute-Regeln.

Ableitung fuer Talvori:

Talvori nutzt bei Bauaktionen einen ruhigen Build-Feedback-Moment. Der erste
Slice bleibt minimal: Fade/Scale des Overlays, dezente Hervorhebung,
Hinweistext und vorbereitete Effekt-ID ohne Sounddatei.

## 3. Grundentscheidung

Talvori nutzt bei Bauaktionen einen kurzen Build-Feedback-Moment:

1. Nutzeraktion.
2. Kurze visuelle Reaktion.
3. Bauimpuls.
4. Fundament erscheint.
5. Kurzer Abschlussmoment.
6. Kurzer Hinweis oder Companion-Kommentar.

Der Moment soll sagen:

> Ich habe etwas getan, und meine Welt hat reagiert.

Er soll nicht sagen:

> Hier wurde nur ein Bild ausgetauscht.

## 4. Phase-2E-E Erlaubter Feedback-Scope

Erlaubt:

- leichte Fade-/Scale-Animation des `foundation_started`-Overlays,
- kurze subtile Highlight-/Glow-Andeutung an der `main_build_area`,
- kurzer Hinweistext `Das Fundament hat begonnen.`,
- Sound-Architektur nur als vorbereitete ID/Hook,
- keine echte Sounddatei,
- keine neuen Packages.

Nicht erlaubt:

- keine echten Sounddateien,
- keine neuen Audio-Packages,
- keine komplexe Partikel-Engine,
- keine Kamera-Shakes, wenn es unruhig wirkt,
- keine Explosion,
- keine starke Magie-Uebertreibung,
- keine Reward Bridge,
- keine Ressourcenanimation,
- keine Persistenz.

## 5. Ablauf Fuer `empty -> foundation_started`

Der erste lokale Baufortschritt folgt diesem Ablauf:

1. Nutzer tippt auf `main_build_area`.
2. Kontextkarte `Fundament beginnen` erscheint.
3. Nutzer tippt Button `Fundament beginnen`.
4. Die Baufläche bekommt eine kurze Hervorhebung.
5. `foundation_started` blendet ein.
6. Optional erscheint ein minimaler Glow oder Staub-Eindruck ohne neues Asset.
7. Text erscheint: `Das Fundament hat begonnen.`
8. Spaeter optional: kurzer Companion-Kommentar.

Phase 2E-E nutzt nur die Schritte 1 bis 7. Der Companion-Kommentar bleibt
konzeptionell vorbereitet und kann spaeter im bestehenden Companion-System
sauber angeschlossen werden.

## 6. Timing-Richtwerte

Nicht finale Richtwerte:

- Tap-Reaktion: 100 bis 150 ms.
- Overlay-Fade/Scale: 300 bis 500 ms.
- Highlight/Glow: 400 bis 700 ms.
- Hinweistext nach Effekt: nach ca. 300 bis 600 ms.
- Gesamtdauer: unter ca. 1.5 Sekunden.

Regel:

Der Effekt muss kurz genug sein, dass die App reaktionsschnell bleibt, aber
klar genug, dass der Baufortschritt als bewusstes Ereignis wahrgenommen wird.

## 7. Sound-Konzept

Sound bleibt in Phase 2E-E rein konzeptionell.

Spaeter denkbar:

- kurzer weicher Stein-/Bau-Sound,
- kein lauter Kampf- oder Clash-Sound,
- keine aggressive Belohnungsfanfare,
- kein Sound, der bei Wiederholung nervt.

Regeln:

- Sound muss abschaltbar sein.
- Sound darf keine wichtige Information allein tragen.
- Sound wird ueber IDs vorbereitet, z. B. `build.foundation.started`.
- Konkrete Sounddateien kommen spaeter.
- Widget-Code darf nicht hart an eine Sounddatei gekoppelt werden.

## 8. Ersetzbare Architektur

Spaeteres Zielmodell:

`BuildFeedbackEvent`

- `id`
- `visualEffectId`
- `soundEffectId`
- `hapticEffectId` optional spaeter
- `durationMs`
- `canBeMuted`
- `reducedMotionCompatible`

Phase 2E-E bereitet nur die ID vor:

- `build.foundation.started`

Keine harte Sounddatei, kein produktiver Audio-Service und keine zentrale
Feedback-Schicht in diesem Slice.

## 9. Accessibility / Settings

Regeln:

- Reduzierte Animation muss spaeter beruecksichtigt werden.
- Sound muss spaeter mutebar sein.
- Keine wichtige Information darf nur ueber Sound vermittelt werden.
- Effekte bleiben kurz und ruhig.
- Text und sichtbarer Zustand bleiben die primären Rueckmeldungen.

Phase 2E-E soll bereits so gebaut sein, dass spaetere Reduced-Motion-Regeln
einfach anwendbar bleiben.

## 10. Beziehung Zu Phase 2E-E

Der aktuelle 2E-E-Code-Slice darf minimal ergaenzt werden:

- Animation fuer das Einblenden von `foundation_started`,
- lokaler Feedback-State,
- vorbereitete konstante Feedback-ID `build.foundation.started`,
- keine echte Audio-Implementierung.

Der Slice darf weiterhin nicht bauen:

- Persistenz,
- Supabase Writes,
- SRS-/`word_progress`-Aenderung,
- Reward Bridge,
- echte Ressourcenlogik,
- Expansion,
- PlacedItems,
- Interiors/ObjectDetail,
- produktive Bau-/Lernlogik.

## 11. Roadmap-Bezug

`docs/world_design/235-world-production-roadmap-and-checklists.md` fuehrt diese
Planung als Phase 2E-A6.

Status nach Erstellung dieses Dokuments:

- Phase 2E-A6: `fertig`.
- Phase 2E-E: bleibt `umgesetzt / lokal mock`, muss aber vor Commit den hier
  definierten Feedback-Scope beachten.
- Sound/Effekte sind fuer 2E-E nur vorbereitet/minimal, nicht produktiv.

## 12. Stop-Regeln

Stoppen, wenn:

- Baufortschritt nur harter Bildwechsel bleibt,
- Effekt zu uebertrieben wirkt,
- Sound/Animation fest verdrahtet wird,
- neue Packages eingebaut werden,
- echte Audio-Dateien erzeugt werden,
- Reward-/Ressourcenanimation gebaut wird,
- Persistenz, Supabase, SRS, `word_progress` oder Reward Bridge beruehrt werden.

## 13. Akzeptanzkriterien

Das Dokument ist gut, wenn:

- klar ist, wie `empty -> foundation_started` visuell wirken soll,
- Animation/Sound als erweiterbares System gedacht sind,
- keine Sounddateien oder neuen Packages noetig sind,
- Phase 2E-E klein bleibt,
- spaetere Sound-/Effekt-Erweiterung vorbereitet ist,
- bestehende Daten-, Lern- und Reward-Grenzen geschuetzt bleiben.

## Offene Fragen

- Wann wird eine zentrale Audio-/Feedback-Schicht geplant?
- Soll Haptik in Talvori Welt spaeter ueber eigene Effekt-IDs vorbereitet
  werden?
- Welche Settings-Struktur steuert spaeter Sound, reduzierte Animation und
  Haptik?
