# Schnellstart: Von der Anmeldung bis zum Hub auf der Webseite

← [Benutzerhandbuch](README.md)

Diese Anleitung führt dich in etwa **15 Minuten** von der Registrierung bis zu einem funktionierenden Hub – auf eurer
Webseite, als eigene Hub-Seite oder beides. Jeder Schritt verweist auf die ausführliche Beschreibung.

**Das brauchst du:**

- die **Adresse des Kirchen-Hubs** (bekommst du vom Betreiber, siehe [Grundbegriffe](grundbegriffe.md)),
- eine **E-Mail-Adresse** und ein Passwort,
- eure **Links** (Adressen, die ihr zeigen wollt: Livestream, Termine, Spenden …),
- für den Launcher auf der Webseite: **Zugang zur Bearbeitung eurer Webseite** (oder jemanden, der das für dich
  erledigt). Für die eigene Hub-Seite brauchst du ihn nicht.

**Welchen Weg möchtest du?**

| Ich möchte … | Schritte |
| --- | --- |
| **den Launcher auf unserer Webseite** | 1 bis 4, dann [Schritt 5a](#schritt-5a-launcher-auf-der-webseite-einbinden) |
| **nur eine eigene Seite mit unseren Links** (z. B. für QR-Code oder Social Media, oder weil ihr keine Webseite habt) | 1 bis 4, dann [Schritt 5b](#schritt-5b-eigene-hub-seite-teilen) |
| **beides** | 1 bis 4, dann 5a und 5b |

---

## Schritt 1: Registrieren

1. Öffne die Adresse des Kirchen-Hubs und klicke auf **„Kostenlos registrieren“**.
2. Fülle das Formular aus:
   - **Name deiner Kirche**, so wie er erscheinen soll
   - **Webseite eurer Gemeinde** (optional, aber empfohlen): z. B. `https://kirche-musterstadt.de`. Dann funktioniert der
     Launcher nur auf dieser Webseite und nicht auf fremden Seiten. Hast du keine Webseite, lass das Feld leer.
   - **Dein Name**, **E-Mail-Adresse** und ein **Passwort** (mindestens 8 Zeichen, zweimal eingeben)
3. Klicke auf **„Registrieren“**.

Du bist jetzt angemeldet und **Besitzer** deiner Kirche. Der Hub existiert bereits, noch ohne Links.
Beim nächsten Mal meldest du dich über **„Anmelden“** mit E-Mail-Adresse und Passwort an.
→ Ausführlich: [Konto & Anmeldung](konto-und-anmeldung.md)

## Schritt 2: Orientierung

Links siehst du die Navigation, oben rechts „Abmelden“. Die Menüpunkte:

| Menüpunkt | Wofür |
| --- | --- |
| **Links** | Einträge des Launchers verwalten |
| **Design** | Aussehen anpassen, mit Live-Vorschau |
| **Formulare** | Formulare und eingegangene Antworten |
| **Einbinden** | Einbettungs-Code und Adresse der eigenen Hub-Seite |
| **Einstellungen** (unter Kirche) | Name, Webseite, Kurzname, Team |

→ Ausführlich: [Übersicht des Backends](README.md#aufbau-des-backends)

## Schritt 3: Links anlegen

1. Wähle **Links** und dann **„Ersten Link hinzufügen“**.
2. Trage ein:
   - **Titel**, z. B. „Gottesdienst live“
   - **Adresse (URL)**, beginnend mit `https://`
   - optional eine **Beschreibung** („Sonntags um 10 Uhr“) und ein **Symbol** (ein Emoji wie 📺)
3. **Speichern**. Wiederhole das für jeden Link.
4. **Sortiere** die Links per Drag & Drop am Griff (⋮⋮) links in der Zeile. Das Wichtigste nach oben.

Nicht mehr benötigte Links kannst du beim Bearbeiten über den Schalter **„Im Launcher anzeigen“** ausblenden.
→ Ausführlich: [Links verwalten](links.md)

## Schritt 4: Design anpassen

Öffne **Design**. Rechts siehst du eine **Live-Vorschau**, die sich bei jeder Änderung sofort aktualisiert.

- **Überschrift** im Panel (Voreinstellung: Name der Kirche) und **Button-Text**
- **Hauptfarbe** (z. B. Farbe aus eurem Logo) und **Textfarbe** darauf, mit gutem Kontrast
- **Symbol**, **Position** (unten rechts oder links), **Farbschema** (hell, dunkel, wie System) und **Eckenrundung**

Klicke danach auf **„Speichern“**. Ohne Speichern gehen Änderungen verloren.
→ Ausführlich: [Design anpassen](design.md)

*Optional: Formulare.* Wenn ihr Rückmeldungen sammeln wollt (Gebetsanliegen, Kontakt, „Neu hier“), lege unter **Formulare**
eine Vorlage an, passe sie an und nimm sie über **„Als Button hinzufügen“** in den Hub auf.
→ Ausführlich: [Formulare](formulare.md), [Einsendungen](einsendungen.md)

---

## Schritt 5a: Launcher auf der Webseite einbinden

1. Öffne **Einbinden**. Im Feld **Einbettungs-Code** steht eine Zeile, die so aussieht:

   ```html
   <script src="https://<adresse-des-hubs>/embed/DEIN_TOKEN.js" async></script>
   ```

   Klicke auf das **Kopieren-Symbol**.
2. Füge die Zeile in eure Webseite ein, **vor dem schließenden `</body>`-Tag**, am besten in den Fußbereich, der auf allen
   Seiten geladen wird. Wo genau das geht, hängt vom System ab (WordPress, Squarespace, Wix …). Eine Tabelle mit den
   üblichen Stellen steht unter [Auf der Webseite einbinden](einbinden.md#einfügen).
3. Speichere die Webseite und rufe sie auf. Unten rechts erscheint der Button.
4. Klicke ihn an und prüfe Links und Formulare.

**Erscheint nichts?** Warte ein paar Minuten (Zwischenspeicher), lade die Seite mit Strg/Cmd + Shift + R neu und prüfe,
dass unter **Einbinden** der Schalter **„Launcher aktiv“** eingeschaltet und die richtige **Webseite** hinterlegt ist
(Einstellungen der Kirche). → [Hilfe bei Problemen](../referenz/faq.md#launcher-erscheint-nicht)

## Schritt 5b: Eigene Hub-Seite teilen

1. Öffne **Einbinden**. Im Abschnitt **„Eigene Seite“** steht die Adresse, z. B. `https://<adresse-des-hubs>/demo-gemeinde`.
2. Klicke auf **„Öffnen“**, um sie anzusehen. Sie zeigt eure Links in den Farben aus dem Design.
3. Verteile die Adresse:
   - als **QR-Code** (Adresse in einen QR-Code-Generator kopieren) für Gottesdienstblatt, Plakat, Schaukasten,
   - in **Social-Media-Profilen** und **Newslettern**.

Formulare erscheinen auf der eigenen Seite **nicht**, nur Links zu Webseiten. Den Kurznamen (Teil der Adresse) ändern kannst du
unter **Kirche → Einstellungen**. Bedenke: Danach ändert sich die Adresse.
→ Ausführlich: [Eigene Hub-Seite](eigene-seite.md)

---

## Schritt 6: Testen

- [ ] Alle Links öffnen die richtigen Seiten (auf Desktop **und** Handy)
- [ ] Reihenfolge, Titel und Symbole passen
- [ ] Der Button ist gut lesbar und verdeckt nichts Wichtiges (sonst Position wechseln)
- [ ] Formular einmal komplett ausfüllen, absenden, Einsendung unter **Formulare → Einsendungen** finden
      (nach dem Öffnen mindestens 3 Sekunden Zeit lassen, sonst wird die Einsendung als Spam verworfen)
- [ ] Testeinsendung löschen

## Schritt 7: Team einladen

Kolleginnen und Kollegen können mitarbeiten:

1. Die Person **registriert sich selbst** beim Kirchen-Hub.
2. Du gehst zu **Kirche → Einstellungen → Mitglied hinzufügen** und gibst ihre E-Mail-Adresse ein.

Sie ist dann Admin und kann Links, Design und Formulare bearbeiten. Es gibt keine Einladungs-E-Mail, sag ihr Bescheid.
→ Ausführlich: [Kirche & Team](kirche-und-team.md)

## Wie geht es weiter?

- **Änderungen:** Neue Links, geändertes Design oder neue Fragen erscheinen auf der Webseite nach spätestens **5 Minuten**,
  auf der eigenen Hub-Seite sofort.
- **Einsendungen** regelmäßig lesen. Ein Badge im Menü zeigt neue an. Richte eine Benachrichtigung per E-Mail ein und
  eine automatische Löschfrist ([Einsendungen](einsendungen.md)).
- **Datenschutz:** Ergänzt eure Datenschutzerklärung und nutzt bei Formularen den Einwilligungstext
  ([Datenschutz & Sicherheit](../referenz/datenschutz-und-sicherheit.md)).
- **Probleme?** → [Häufige Fragen & Fehlerbehebung](../referenz/faq.md) oder der Betreiber des Hubs.
