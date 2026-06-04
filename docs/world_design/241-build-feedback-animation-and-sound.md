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

Ergaenzende Orientierung fuer Nutzerfuehrung:

| Quelle / Orientierung | Ableitung fuer Talvori | Konkrete Entscheidung |
| --- | --- | --- |
| Apple Developer: Onboarding for Games, `https://developer.apple.com/app-store/onboarding-for-games/` | Neue Mechaniken sollen frueh, kontextuell und auf die naechsten Ziele bezogen eingefuehrt werden. | Die erste Bauaktion bekommt einen kurzen Welt-Hinweis statt eines separaten Tutorial-Systems. |
| Roblox Creator Hub: Onboarding Techniques, `https://create.roblox.com/docs/production/game-design/onboarding-techniques` | Visuelle Elemente und Hinweise helfen Spielern, wichtige Schritte trotz Umgebung und UI wiederzufinden. | Die `main_build_area` bekommt in Phase 2E-E einen dezenten Fokus/Puls und kurzen Text. |
| Don Norman: Signifiers, Not Affordances, `https://jnd.org/signifiers-not-affordances/` | Nutzer brauchen wahrnehmbare Signale, wo eine Handlung moeglich ist. Versteckte Hotspots sind riskant. | Bau-Hotspots duerfen nicht nur unsichtbar klickbar sein; sie brauchen bei neuen Mechaniken sichtbare Signifier. |
| W3C WCAG 2.2 Contrast Minimum, `https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html` | Lesbarkeit und Erkennbarkeit brauchen ausreichenden Kontrast; gleicher Farbraum macht Hinweise schwer wahrnehmbar. | Bau-Hinweise duerfen nicht gruen/mint auf gruen-gelber Inseloberflaeche bleiben. |

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

## Nutzerfuehrung Bei Neuen Bauaufgaben

Neue Bauaufgaben brauchen immer sichtbare Anleitung.

Der Nutzer darf nicht raten muessen, welcher Kreis oder welche Flaeche
antippbar ist. Fuehrung entsteht durch eine Kombination aus:

- kurzem Text,
- visuellem Fokus,
- optionalem Puls oder Glow,
- spaeter optionalem Pfeil oder Companion-Hinweis.

Neue Aufgaben brauchen immer:

- kurzen Hinweistext,
- sichtbaren Fokus auf die relevante Flaeche,
- klares Ergebnisfeedback nach der Aktion.

Der Nutzer darf nie raten muessen, was als naechstes zu tun ist.

Beispiel Phase 2E-E:

- Text: `Tippe auf die Lichtung, um dein Fundament zu beginnen.`
- Bauflaeche: dezenter Puls/Glow.
- Danach Kontextkarte: `Fundament beginnen`.

Diese Regel gilt kuenftig fuer:

- neue Bauflaechen,
- neue Aufgaben,
- neue Gebaeude,
- neue Weltinteraktionen.

Hinweise muessen kurz sein. Sie duerfen nicht wie lange Tutorial-Texte wirken.
Sie verschwinden oder werden reduziert, sobald der Nutzer die Aktion verstanden
oder ausgefuehrt hat.

Nicht erlaubt:

- aggressive Pfeil-/Blink-Ueberladung,
- dauerhaft blockierende Tutorial-Overlays,
- technische Begriffe,
- dauerhaftes Blinken,
- Hinweise, die die Welt verdecken.

## Kontrastregeln Fuer Interaktive Hinweise

Interaktive Bauflaechen duerfen nicht nur mit einer Farbe hervorgehoben werden,
die im gleichen Farbraum wie der Untergrund liegt.

Gruen/Mint auf gruener oder gelber Wiesenflaeche ist zu schwach.

Talvori-Standard fuer Bau-Hinweise:

- Violett, Magenta oder Cyan als Kontrastfarbe,
- bevorzugt mit weichem Glow oder Puls,
- nicht aggressiv,
- nicht neon-ueberladen.

Das Highlight muss in World View und Island View auch auf detailreichen Assets
lesbar bleiben. Textcue und visuelle Markierung muessen zusammenarbeiten.

Wenn der Untergrund hell oder gruen ist, muss die Hervorhebung deutlich
kaelter, dunkler oder staerker gesaettigt sein.

Diese Regel gilt kuenftig fuer:

- neue Bauflaechen,
- neue Aufgaben,
- neue Gebaeude-Interaktionen,
- Objekt-Hotspots.

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

## Build-Impact-Sequenz Fuer Foundation Started

Langfristiges Zielbild fuer `foundation_started`:

1. Build Area fokussiert kurz.
2. Fundament-/Steinmasse kommt von oben oder faellt leicht in die Szene.
3. Kurzer Impact-Moment.
4. Staubwolke wird aufgewirbelt.
5. Kleine Steinsplitter/Debris bewegen sich kurz nach aussen.
6. Fundament setzt sich.
7. Kurzer Success-Glow.
8. Hinweistext erscheint: `Das Fundament hat begonnen.`
9. Optional spaeter Sound/Haptik.

Diese Sequenz ist ein Zielbild fuer spaetere Ausbaustufen. Sie soll den Moment
wertiger machen, ohne Talvori hektisch oder laut wirken zu lassen.

Phase 2E-E darf nur eine sehr reduzierte Variante umsetzen:

- Fade/Scale,
- kontrastreicher Puls/Glow,
- Hinweistext,
- vorbereitete Effekt-ID.

Nicht in Phase 2E-E:

- kein Partikelsystem,
- keine neuen Assets,
- keine Sounddateien,
- keine Haptik,
- keine produktive FX-Schicht.

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

## Modulares Sound- Und FX-ID-System

Sound und Effekte duerfen nicht hart im Widget verdrahtet werden.

Jede Bauaktion bekommt spaeter ein Event mit IDs. Diese IDs koennen spaeter
zentral auf visuelle Effekte, Sound, Haptik oder reduzierte-Animation-Varianten
abgebildet werden.

Beispiel-IDs:

- `build.foundation.focus`
- `build.foundation.drop`
- `build.foundation.impact`
- `build.foundation.dust`
- `build.foundation.complete`
- `build.foundation.started`
- `ui.task.focus`

Moegliche Zuordnung spaeter:

- `visualEffectId`,
- `soundEffectId`,
- `hapticEffectId`,
- `reducedMotionVariantId`,
- `durationMs`,
- `canBeMuted`.

In Phase 2E-E wird weiterhin nur `build.foundation.started` vorbereitet.

Nicht in Phase 2E-E:

- keine echten Sounddateien,
- keine Audio-Packages,
- kein produktiver Audio-Service.

Spaeter muss Sound mutebar, ersetzbar und konfigurierbar sein.

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

- interaktiver Hinweis nicht genug Kontrast hat,
- Gruen/Mint auf gruenem Untergrund als primaerer Bauhinweis verwendet wird,
- Nutzerfuehrung nur aus verstecktem Hotspot besteht,
- Baufortschritt nur harter Bildwechsel bleibt,
- Effekt zu uebertrieben wirkt,
- Effekt unruhig oder hektisch wirkt,
- Sound/Animation fest verdrahtet wird,
- Sound hart an Datei oder Widget gekoppelt wird,
- neue Packages eingebaut werden,
- echte Audio-Dateien erzeugt werden,
- Reward-/Ressourcenanimation gebaut wird,
- Persistenz, Supabase, SRS, `word_progress` oder Reward Bridge beruehrt werden.

## 13. Akzeptanzkriterien

Das Dokument ist gut, wenn:

- Kontrastregel klar ist,
- Violett, Magenta und Cyan als Talvori-Baukontrast definiert sind,
- Build-Impact-Zielsequenz beschrieben ist,
- Phase-2E-E-Minimalumfang klar abgegrenzt ist,
- Sound-/FX-ID-System erweiterbar geplant ist,
- Nutzerfuehrung kuenftig fuer alle neuen Interaktionen Pflicht ist,
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
