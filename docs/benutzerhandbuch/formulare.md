# Formulare

← [Benutzerhandbuch](README.md) · Weiter: [Einsendungen](einsendungen.md)

Mit Formularen sammelt ihr Rückmeldungen direkt im Launcher – Gebetsanliegen, Kontaktanfragen, Interesse an Mitarbeit,
Taufanfragen, Willkommenskarten. Ein Formular öffnet sich **im Vollbild** und stellt **eine Frage nach der anderen**.
Das ist auf dem Handy besonders angenehm.

Formulare gehören zur **Kirche** (nicht zu einem einzelnen Link). Damit Besucher sie sehen, nimmst du sie mit einem
[Link vom Typ „Formular öffnen“](#formular-im-hub-verknüpfen) in den Hub auf.

## Formularübersicht

**Hub → Formulare** listet alle Formulare alphabetisch. Zu jedem stehen:

- der Titel (Klick öffnet das Formular)
- die Zahl der Einsendungen und, falls vorhanden, ein Badge **„n neu“** für ungelesene
- **Einsendungen** (direkt zur Liste) und **Bearbeiten**

Im Menü zeigt ein Badge neben „Formulare“ die Gesamtzahl ungelesener Einsendungen der aktuellen Kirche.

## Formular anlegen

**„Formular anlegen“** bietet zwei Wege:

### Mit einer Vorlage (empfohlen)

Ein Klick auf eine Vorlage legt sofort ein Formular an. Es ist eine **Kopie**: Ihr könnt Titel, Texte und Fragen danach
beliebig ändern. Spätere Änderungen an den Vorlagen im Projekt betreffen bestehende Formulare nicht.

| Vorlage | Zweck | Fragen |
| --- | --- | --- |
| 🙏 **Gebetsanliegen** | Anliegen teilen, auf Wunsch vertraulich und mit Rückmeldung | 5: Anliegen (Pflicht), Name, wer es erfahren darf (Pflicht), Rückmeldung gewünscht? (Pflicht), E-Mail |
| 📞 **Kontakt / Rückruf** | Nachricht oder Rückrufwunsch mit bevorzugter Zeit | 6: Name, Worum geht es? (beide Pflicht), Kontaktweg (Pflicht), E-Mail, Telefon, Rückruf-Zeit |
| 🤝 **Mitarbeit** | Interesse an Mitarbeitsbereichen sammeln | 5: Name, E-Mail (Pflicht), Telefon, Bereiche (Mehrfachauswahl, Pflicht), Anmerkung |
| 💧 **Taufe** | Anfrage für eine Taufe oder ein Taufgespräch | 7: Name, für wen (Pflicht), Name der Person, E-Mail (Pflicht), Telefon, Wunschtermin, Anmerkung |
| 👋 **Neu hier** | Digitale Willkommenskarte für Gäste | 6: Name (Pflicht), E-Mail, „Wie hast du von uns erfahren?“, Interessen, Rückmeldung gewünscht? (Pflicht), Anmerkung |

Jede Vorlage bringt außerdem Begrüßungstext, Danke-Text und Beschriftung des Absenden-Buttons mit.

### Leeres Formular

Unten auf der Seite nur einen **Titel** eingeben und „Anlegen“. Danach Fragen und Einstellungen selbst ergänzen.

## Die Formularseite

Ein Formular hat drei Reiter:

| Reiter | Inhalt |
| --- | --- |
| **Fragen** | Die Fragen anlegen, ändern, sortieren, löschen |
| **Einsendungen** | Eingegangene Antworten, siehe [Einsendungen](einsendungen.md). Mit Badge für ungelesene. |
| **Einstellungen** | Texte, Benachrichtigung, Datenschutz, Aufbewahrung, Löschen |

Unter dem Titel steht, ob das Formular schon im Hub verknüpft ist („Im Hub als Button „…“ verknüpft“) oder ein Link
**„Als Button hinzufügen“**, der direkt das Anlegen eines passenden Links öffnet.

## Fragen

Auf dem Reiter *Fragen* stehen die Fragen in der Reihenfolge, in der Besucher sie sehen. Per **Drag & Drop** am Griff
(⋮⋮) sortierst du um. Die Reihenfolge wird sofort gespeichert. **„Frage hinzufügen“** legt eine neue an,
**Bearbeiten** und **Löschen** (mit Rückfrage) gibt es pro Zeile. Ein Badge **Pflicht** markiert Pflichtfragen.

Ein Formular ohne Fragen lässt sich sinnvoll nicht nutzen. Lege mindestens eine Frage an.

### Felder einer Frage

| Feld | Pflicht | Beschreibung |
| --- | --- | --- |
| **Frage** | ja | Der Fragetext, bis 200 Zeichen |
| **Fragetyp** | ja | Siehe Tabelle unten |
| **Antwortmöglichkeiten** | bei Auswahlfragen | **Eine Möglichkeit pro Zeile.** Höchstens 30 Zeilen mit je 100 Zeichen. Leere Zeilen und Doppelte entfallen. |
| **Hinweis** | nein | Kleiner Text unter der Frage, bis 300 Zeichen |
| **Pflichtfrage** | – | Schalter. Ohne Antwort geht es nicht weiter. Andere Fragen erscheinen im Launcher mit „(optional)“. |

### Fragetypen

| Typ | Darstellung im Launcher | Prüfung |
| --- | --- | --- |
| **Kurzer Text** | einzeiliges Feld | max. 200 Zeichen |
| **Langer Text** | mehrzeiliges Feld | max. 5000 Zeichen |
| **Einfachauswahl** | Auswahl **einer** Möglichkeit (Optionsfelder) | Antwort muss eine der Möglichkeiten sein |
| **Mehrfachauswahl** | Auswahl **mehrerer** Möglichkeiten (Kästchen) | alle Antworten müssen aus den Möglichkeiten stammen |
| **Ja / Nein** | zwei feste Optionen „Ja“ und „Nein“ | nur diese beiden Werte |
| **E-Mail-Adresse** | E-Mail-Feld (Handy zeigt passende Tastatur) | gültige E-Mail-Adresse |
| **Telefonnummer** | Telefonfeld | 5 bis 30 Zeichen: Ziffern, Leerzeichen, `+ ( ) / . -` |
| **Zahl** | Feld mit Zahlentastatur | ganze oder Dezimalzahl, Komma oder Punkt, negativ erlaubt |
| **Datum** | Datumsauswahl des Geräts | gültiges Datum, im Backend als TT.MM.JJJJ angezeigt |

Alle Prüfungen laufen zuerst im Launcher und werden zur Sicherheit auf dem Server wiederholt.
Wechselst du einen Auswahl-Typ zu einem anderen Typ, werden die Antwortmöglichkeiten verworfen.

> **Wichtig:** Die Typen „E-Mail“ und „Telefon“ speichern nur, was die Person eingibt. Der Hub verschickt nichts an
> diese Adressen. Er sendet keine Bestätigungen an Absender.

## Einstellungen eines Formulars

Reiter **Einstellungen**:

| Bereich | Feld | Beschreibung |
| --- | --- | --- |
| Allgemein | **Titel** | Wird als Überschrift im Launcher und in Listen genutzt. Bis 80 Zeichen. |
| | **Begrüßungstext** (optional) | Erscheint auf einer Startseite **vor** der ersten Frage. Ohne Text startet das Formular direkt mit Frage 1. Bis 1000 Zeichen. |
| | **Danke-Text** (optional) | Nachricht nach dem Absenden. Standard: „Wir haben deine Angaben erhalten.“ |
| | **Text des Absenden-Buttons** (optional) | Standard: „Absenden“. Bis 30 Zeichen. |
| Benachrichtigung | **E-Mail an** (optional) | Eine oder mehrere Adressen, getrennt durch Komma, Semikolon oder Leerzeichen. Bei jeder neuen Einsendung geht eine kurze E-Mail dorthin. Siehe [Einsendungen](einsendungen.md#benachrichtigung-per-e-mail). |
| Datenschutz | **Einwilligungstext** (optional) | Ist er ausgefüllt, erscheint vor dem Absenden ein Kästchen mit diesem Text, das gesetzt sein muss. Bis 1000 Zeichen. |
| | **Link zur Datenschutzerklärung** (optional) | `http(s)://…`-Adresse, erscheint als Link „Datenschutzerklärung“ hinter dem Einwilligungstext. |
| | **Einsendungen automatisch löschen** | *Nie* oder nach 1, 3, 6, 12 oder 24 Monaten. Siehe [Einsendungen](einsendungen.md#automatisches-löschen). |

Am Ende der Seite: **Formular löschen**.

## Formular im Hub verknüpfen

Ein Formular erscheint erst im Launcher, wenn ein Link darauf zeigt:

1. Im Formular auf **„Als Button hinzufügen“** klicken (oder unter *Links → Link hinzufügen* die Option
   **„Formular öffnen“** wählen und das Formular auswählen).
2. Titel vergeben (z. B. „Gebetsanliegen“), optional Beschreibung und Emoji.
3. Speichern. Der Button steht nun im Panel und ist wie jeder Link sortier- und ausblendbar.

Ein Formular kann von **mehreren** Links geöffnet werden. Nicht verknüpfte Formulare können keine Einsendungen erhalten.
Ein **ausgeblendeter** Link macht sein Formular ebenfalls unerreichbar.

## So erleben Besucher das Formular

1. **Klick auf den Button** im Panel: Das Formular öffnet sich im Vollbild. Oben stehen der Titel und ein Schließen-Kreuz,
   darunter ein **Fortschrittsbalken**.
2. **Begrüßung** (nur wenn ein Begrüßungstext existiert) mit Button „Los geht’s“.
3. **Eine Frage pro Schritt** mit „Frage 3 von 5“, dem Hinweistext und dem Eingabefeld. **Weiter** führt zur nächsten Frage,
   **Zurück** zur vorherigen. Nicht beantwortete Pflichtfragen und ungültige Eingaben werden direkt an der Frage
   bemängelt (z. B. „Bitte gib eine gültige E-Mail-Adresse ein.“). Mit der **Enter-Taste** geht es weiter.
   In mehrzeiligen Feldern mit Strg/Cmd + Enter.
4. **Übersicht** („Stimmt alles so?“): Alle Antworten stehen zur Kontrolle da. Mit **Ändern** springt man zu einer Frage
   und danach mit „Zur Übersicht“ zurück. Nicht beantwortete optionale Fragen zeigen „Keine Angabe“. Ist ein
   Einwilligungstext hinterlegt, muss hier das Kästchen gesetzt werden.
5. **Absenden** (bzw. die eigene Beschriftung): Danach erscheint die **Danke-Seite** mit dem Danke-Text und „Schließen“.

Weitere Details:

- Schließt jemand das Formular (X oder Esc) **nach Eingaben**, fragt der Launcher noch einmal nach: „Deine Eingaben
  gehen verloren. Formular wirklich schließen?“
- Schlägt das Absenden wegen der Internetverbindung fehl, bleibt alles erhalten und es erscheint ein Hinweis zum
  erneuten Versuch.
- Lehnt der Server eine Antwort ab, springt der Launcher zur betroffenen Frage.
- Das Formular ist per Tastatur und Screenreader bedienbar.

## Formulare später ändern

- Änderungen an **Fragen, Texten und Reihenfolge** wirken für neue Besucher nach spätestens 5 Minuten (Zwischenspeicher).
- **Bestehende Einsendungen bleiben unverändert.** Jede Einsendung speichert den Fragetext von damals mit. Auch wenn
  eine Frage später umformuliert oder gelöscht wird, bleibt die Antwort mit ihrem ursprünglichen Fragetext sichtbar,
  ebenso im CSV-Export.
- **Formular löschen** entfernt Fragen **und alle Einsendungen** endgültig. Verknüpfte Buttons bleiben in der
  Link-Liste stehen („Formular wurde gelöscht – wird nicht angezeigt“), sind im Launcher aber unsichtbar. Lösche
  sie bei Bedarf selbst oder verknüpfe sie neu, indem du den Link bearbeitest.

## Tipps

- **Halte Formulare kurz.** Jede Frage, die nicht nötig ist, kostet Ausfüllende. Nutze Pflichtfragen sparsam.
- **Datenschutz:** Bei sensiblen Angaben (z. B. Gebetsanliegen) empfiehlt sich ein Einwilligungstext mit Link zur
  Datenschutzerklärung und eine **automatische Löschfrist**. Klärt Details bitte mit eurer Datenschutz-Verantwortlichen.
  Mehr dazu unter [Datenschutz & Sicherheit](../referenz/datenschutz-und-sicherheit.md).
- **Eine Nachricht zurück?** Fragt E-Mail oder Telefon nur ab, wenn wirklich jemand antworten wird, und macht sie
  bei Rückmeldungswunsch zur Pflicht.
- Teste das Formular einmal selbst auf der eingebundenen Webseite und im Handy-Vollbild. Warte dabei mindestens
  3 Sekunden, bevor du abschickst (Spam-Schutz, siehe [FAQ](../referenz/faq.md#formulare-und-einsendungen)).
