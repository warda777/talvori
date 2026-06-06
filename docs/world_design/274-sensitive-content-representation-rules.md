# Phase 2G-M12-D: Sensitive Content Representation Rules

Stand: 2026-06-06

Status: `Planungs- und Visualisierungsblock gestartet`

Dieses Dokument definiert erste Regeln fuer sensible, abstrakte oder
gesellschaftlich heikle Lerninhalte in Talvori. Ziel ist, solche Begriffe nicht
automatisch als Gebaeude, Symbol, Objekt, Insel, Reward oder Companion-Drama zu
visualisieren.

M12-D ist:

- Planungsgrundlage,
- Previewgrundlage,
- keine finale Safety-Implementierung,
- keine Moderations-Implementierung,
- keine finale Datenstruktur,
- keine App-Integration,
- keine ThemeIsland-Umsetzung,
- keine Assetfreigabe,
- keine Freigabe fuer `frame_started`.

## 1. Zweck

M12-B bestaetigt, dass Woerter zuerst geroutet werden muessen. M12-C bestaetigt,
dass Plot-Capabilities nur Erlaubnisse sind. M12-D klaert nun, welche Inhalte
trotz Routing und Plot-Faehigkeiten nicht automatisch sichtbar platziert werden
duerfen.

M12-D beantwortet:

- Wann ist ein Lernwort sensibel oder abstrakt?
- Welche Darstellungsarten sind sicherer als sichtbare Weltobjekte?
- Welche Begriffe brauchen Nutzerkontext, Satzkontext oder Sense-Auswahl?
- Welche Themen bleiben blockiert, bis spaetere Safety-/UX-Regeln existieren?
- Welche Stop-Regeln verhindern falsche Symbolik, Beratung oder Druck?

Grundsatz:

Sensible Inhalte duerfen gelernt werden, aber Talvori darf sie nicht ohne
Kontext, Nutzerentscheidung und spaetere Safety-Pruefung als Gebaeude, Symbol,
Deko, Reward oder Streak-Druck darstellen.

## 2. Sensitive-Kategorien

| Kategorie | Beispiele | Warum sensibel | Standard-Richtung |
| --- | --- | --- | --- |
| Gesundheit / Krankheit / Pflege | Gesundheit, Krankheit, Schmerz, Pflege | kann private oder belastende Lebenssituationen beruehren | `CodexEntry`, `ContextCard`, `CompanionDialog` |
| Medizinische Objekte / Medikamente / Notfall | Medikament, Spritze, Notruf, Verband | darf keine medizinische Beratung oder Panik erzeugen | `ContextCard`, `BacklogOnly`, `BlockedUntilRules` |
| Politik / Verwaltung / Gesellschaft | Politik, Partei, Wahl, Regierung | kann ideologisch oder meinungsbildend wirken | `CodexEntry`, `ContextCard`, `RequiresUserChoice` |
| Gericht / Polizei / Recht / Gerechtigkeit | Polizei, Gericht, Gerechtigkeit, Strafe | betrifft Macht, Recht, Sicherheit und soziale Konflikte | `CodexEntry`, `ContextCard`, `BlockedUntilRules` |
| Religion / Kultur / Weltanschauung | Kirche, Tempel, Gebet, Tradition | braucht neutrale Darstellung ohne pauschale Symbolik | `ContextCard`, `CompanionDialog`, `RequiresUserChoice` |
| Krieg / Gewalt / Katastrophen | Krieg, Angriff, Explosion, Flut | darf nicht als Spielbelohnung verharmlost werden | `CodexEntry`, `ContextCard`, `BacklogOnly` |
| Angst / Trauer / Emotionen / soziale Konflikte | Angst, traurig, Streit, Mobbing | emotional belastend oder persoenlich | `CompanionDialog`, `ContextCard`, `QuestWithoutSymbol` |
| Koerper / persoenliche Themen | Koerperteile, Privates, Aussehen | kann intim, beschamend oder altersabhaengig sein | `CodexEntry`, `RequiresUserChoice`, `BlockedUntilRules` |
| Tod / Verlust / Krise | Tod, sterben, Verlust, Krise | stark belastend; kein Reward-Thema | `CodexEntry`, `ContextCard`, `BacklogOnly` |
| Diskriminierung / Identitaet / soziale Gruppen | Identitaet, Herkunft, Geschlecht, Gruppe | braucht respektvolle und nicht-stereotype Darstellung | `CodexEntry`, `CompanionDialog`, `RequiresUserChoice` |
| Mehrdeutige sensible Begriffe | bank, right, party, patient | falsche Sense kann falsche Weltlogik erzeugen | `RequiresUserChoice`, `ContextCard` |
| Abstrakte Begriffe ohne klare Visualisierung | Freiheit, Meinung, Verantwortung | nicht sinnvoll als einzelnes Objekt | `CodexEntry`, `CompanionDialog`, `QuestWithoutSymbol` |

## 3. Sichere Darstellungsarten

| Darstellungsart | Zweck | Geeignet fuer | Nicht geeignet fuer |
| --- | --- | --- | --- |
| `CodexEntry` | neutraler Erklaerungseintrag | abstrakte, sensible oder unklare Begriffe | emotionale Dramatisierung |
| `ContextCard` | kurzer Kontext ohne Weltobjekt | Satzbeispiele, Alltagssituationen, Sense-Klaerung | Gebaeude-/Symbolfreigabe |
| `CompanionDialog` | sanfte Tali/Vori-Erklaerung | Emotionen, Unsicherheit, abstrakte Begriffe | Beratung, Druck, Schuldgefuehl |
| `QuestWithoutSymbol` | Lernaufgabe ohne starkes Symbol | Reflexions-, Sortier- oder Kontextaufgaben | politische/religioese Zielvorgaben |
| `NeutralBlueprint` | Platzhalter fuer spaetere Planung | spaeteres Spezialthema ohne Assetfreigabe | sofortige Visualisierung |
| `BacklogOnly` | Begriff speichern, nicht sichtbar platzieren | fehlende Regeln, fehlende Insel, hohe Unsicherheit | sichtbaren Fortschritt vortaeuschen |
| `RequiresUserChoice` | Sinn/Kontext vom Nutzer bestaetigen lassen | mehrdeutige oder persoenliche Begriffe | automatische Sense-Entscheidung |
| `BlockedUntilRules` | blockiert bis zu separater Pruefung | Krankenhaus, Polizei, Religion, Politik, Krieg | MVP-Schnellumsetzung |

Regel:

Die sichere Darstellungsart gewinnt gegen sichtbare Platzierung, wenn ein
Begriff sensibel, abstrakt, mehrdeutig, persoenlich, alterskritisch oder
kontextarm ist.

## 4. Regeln Fuer Automatische Platzierung

Automatische Analyse darf sensible Kandidaten erkennen. Automatische sichtbare
Platzierung ist fuer sensible Inhalte verboten.

Pflichtregeln:

- Keine automatische sichtbare Platzierung sensibler Begriffe.
- Keine automatische Gebaeude-/Symbolerzeugung fuer Politik, Religion,
  Polizei, Gericht oder Krankenhaus.
- Keine Krankheit als dekoratives Objekt darstellen.
- Keine Angst, Trauer, Tod oder Krise als spielerische Belohnung darstellen.
- Keine sensiblen Begriffe fuer Retention-Druck oder Streak-Druck nutzen.
- Keine dramatischen oder manipulativen Companion-Reaktionen.
- Keine pauschalen Symbole fuer Gruppen, Identitaeten, Religionen oder
  politische Richtungen.
- Keine medizinische Beratung.
- Keine juristische Beratung.
- Keine politische Meinung als Spielziel.
- Nutzerkontext, Satzkontext und Sense-Auswahl sind Pflicht, wenn der Begriff
  mehrdeutig, persoenlich oder sensibel ist.
- Fallback ist `CodexEntry`, `ContextCard`, `BacklogOnly`,
  `NeutralBlueprint` oder ein neutraler Companion-Hinweis.

## 5. Sensitive Routing Pipeline

1. Word intake
   - Lernwort, Import, Satz, Nutzerwunsch oder Companion-Kontext.
2. Sensitivity check
   - Kategorie, Risiko, Alters-/Privatheitsnaehe, Safety-Bedarf.
3. Context and sense check
   - Satzkontext, Sprache, Bedeutung, Nutzerziel, Mehrdeutigkeit.
4. Safe representation candidate
   - Codex, ContextCard, CompanionDialog, QuestWithoutSymbol, Backlog.
5. User choice
   - Nutzer bestaetigt Bedeutung, lehnt Vorschlag ab oder speichert spaeter.
6. Safe result
   - neutraler Eintrag, Kontextkarte, Backlog, neutraler Blueprint oder
     blockiert bis zu spaeteren Regeln.

Stop-Gate:

Wenn Sensitivity, Sense oder Kontext unsicher sind, wird nicht sichtbar
platziert.

## 6. Beispielrouting

| Begriff | Kategorie | Darstellung | Regel |
| --- | --- | --- | --- |
| `health / Gesundheit` | Gesundheit / abstrakt | `CodexEntry` oder `ContextCard` | keine automatische Inselplatzierung |
| `hospital / Krankenhaus` | Gesundheit / oeffentliches Gebaeude | `BlockedUntilRules`, spaeter Special Theme | keine fruehe Assetfreigabe |
| `medicine / Medikament` | medizinisches Objekt | `ContextCard`, `BacklogOnly` | neutral, keine Beratung, keine Dosierung |
| `justice / Gerechtigkeit` | Recht / abstrakt | `CodexEntry`, `CompanionDialog`, `ContextCard` | keine automatische Symbol- oder Gebaeudeplatzierung |
| `police / Polizei` | oeffentliche Institution / sensibel | `ContextCard`, `BlockedUntilRules` | keine automatische Station oder Autoritaetsfantasie |
| `church / Kirche` | Religion / Kultur | `RequiresUserChoice`, `ContextCard` | nur mit neutralen Darstellungsregeln |
| `fear / Angst` | Emotion | `CompanionDialog`, `ContextCard` | kein Objekt, kein Reward, kein Druck |
| `war / Krieg` | Gewalt / Konflikt | `CodexEntry`, `ContextCard`, `BacklogOnly` | keine spielerische Darstellung |
| `death / Tod` | Verlust / Krise | `CodexEntry`, `ContextCard`, `BacklogOnly` | sehr sensibel, neutral und optional, kein Reward |
| `identity / Identitaet` | Identitaet / abstrakt | `CodexEntry`, `CompanionDialog`, `RequiresUserChoice` | keine pauschale Visualisierung |

## 7. Companion-Regeln

Tali/Vori darf sensible Inhalte begleiten, aber nicht dramatisieren.

Erlaubt:

- kurz und neutral erklaeren,
- bei Unsicherheit nach Kontext fragen,
- einen Codex- oder Kontextkartenweg anbieten,
- dem Nutzer erlauben, das Thema spaeter zu behandeln,
- sanft bleiben, wenn ein Wort emotional schwer ist.

Nicht erlaubt:

- Schuldgefuehl erzeugen,
- Angst oder Krise zur Rueckkehrmotivation nutzen,
- politische, religioese, juristische oder medizinische Positionen als
  Spielziel ausgeben,
- die Challenge loesen,
- den Nutzer zu sensiblen Themen draengen,
- dramatische Belohnungs- oder Verlustreaktionen erzeugen.

## 8. Retention- und Reward-Grenzen

Sensible Begriffe duerfen nicht als Druckmechanik verwendet werden.

Nicht erlaubt:

- Streaks mit Angst, Krankheit, Tod, Schuld, Politik oder Religion verbinden,
- sensible Themen als seltene Reward-Objekte inszenieren,
- Krise oder Verlust als Fortschrittsverlust darstellen,
- medizinische, juristische oder politische Inhalte als Pflichtquest
  erzwingen,
- Comeback-Erinnerungen mit Schuld oder Bedrohung formulieren.

Erlaubt:

- neutrale Wiederholung,
- optionaler Codex-Fortschritt,
- freiwillige Kontextkarte,
- ruhiger Companion-Hinweis,
- spaeteres Lernen ohne harte Strafe.

## 9. ThemeIsland- und Plot-Grenzen

M12-D erlaubt keine sensible ThemeIsland-Umsetzung.

Blockiert bis zu spaeteren Regeln:

- Gesundheitsinsel,
- Krankenhaus,
- Polizei-/Gerichts-/Rechtsbereich,
- Verwaltungs-/Politikbereich,
- Religions-/Kultur-Spezialbereich,
- Krisen-/Krieg-/Katastrophenbereich.

Diese Themen brauchen spaeter mindestens:

- eigenes Safety-/UX-Konzept,
- neutrale Sprache,
- Alters- und Kontextregeln,
- klares Opt-in,
- sensible Visualisierungsgrenzen,
- Mobile-/Clutter-Pruefung,
- keine automatische Assetproduktion.

## 10. Open Questions

Offene Folgefragen:

- Wie wird Nutzeralter oder Familienmodus spaeter beruecksichtigt?
- Welche Inhalte bleiben lokal, und welche duerften spaeter Cloud-/KI-Pruefung
  brauchen?
- Wie wird Import-Kontext bei sensiblen Saetzen gespeichert oder verworfen?
- Wie sehen neutrale Kontextkarten visuell aus?
- Welche Tali/Vori-Formulierungen sind fuer sensible Themen erlaubt?
- Welche sensiblen Themen duerfen nie als Weltobjekt erscheinen?
- Wie wird eine Nutzerentscheidung protokolliert, ohne sensible Daten unnoetig
  zu speichern?

## 11. Weiterhin Offene Folgeblocks

Weiterhin offen:

- `Phase 2G-M12-E Mobile And Clutter Rules For Small Objects`

Zusaetzlich spaeter sinnvoll:

- Sensitive Content Visual Review,
- neutrale ContextCard-Preview,
- Companion-Textregeln fuer sensible Themen,
- Privacy-/Import-Regeln fuer sensible Satzkontexte,
- Safety-/UX-Konzept fuer Gesundheits-, Politik-, Rechts- und Religionsthemen.

## 12. Stop-Regeln

Stoppen, wenn:

- aus M12-D eine sensible ThemeIsland-Umsetzung abgeleitet wird,
- sensible Begriffe automatisch visualisiert werden,
- Gebaeude, Symbole oder Assets fuer sensible Begriffe aus M12-D abgeleitet
  werden,
- medizinische, juristische oder politische Beratung im Spielsystem geplant
  wird,
- Retention-Mechaniken mit Angst, Krankheit, Tod, Schuld, Politik oder
  Religion geplant werden,
- Companion-Reaktionen sensible Inhalte dramatisieren oder Druck erzeugen,
- pauschale Symbolik fuer Religion, Politik, Identitaet oder soziale Gruppen
  geplant wird,
- aus M12-D App- oder Assetfreigabe abgeleitet wird,
- finale Sensitive-Content-Implementierung ohne spaetere Safety-/UX-Pruefung
  geplant wird.

## 13. Naechster Erlaubter Schritt

Erlaubt:

- M12-D visuell pruefen,
- M12-D nachbessern,
- M12-E Mobile And Clutter Rules planen,
- spaeter eine neutrale ContextCard-/Companion-Preview planen.

Weiterhin nicht erlaubt:

- Code,
- App-Integration,
- Tests aendern,
- Spielassets,
- finale Safety-Implementierung,
- Moderations-Implementierung,
- finale Datenstruktur,
- sensible ThemeIsland-Umsetzung,
- Assetfreigabe,
- `frame_started`.
