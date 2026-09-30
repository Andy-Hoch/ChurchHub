# Grundbegriffe

← [Benutzerhandbuch](README.md) · Praktisch loslegen: [Schnellstart](schnellstart.md)

## Was ist der Kirchen-Hub?

Der Kirchen-Hub ist ein Werkzeug, mit dem eure Kirche einen **Launcher** für ihre Webseite erstellt:

- Auf eurer Webseite erscheint ein **schwebender Button** (standardmäßig unten rechts).
- Ein Klick öffnet ein **Panel** mit euren wichtigsten Links, z. B. „Gottesdienst live“, „Termine“, „Spenden“.
- Ein Button kann statt einer Webseite ein **Formular** öffnen (Gebetsanliegen, Kontakt, „Neu hier“ …).
  Das Formular erscheint im Vollbild und stellt eine Frage nach der anderen.
- Ihr pflegt alles im **Backend** (dem Login-Bereich). Änderungen erscheinen ohne Eingriff in die Webseite.
- Eingebunden wird der Launcher mit **einer Zeile Code**. Das funktioniert mit WordPress, Squarespace, Wix und
  jeder anderen Seite, die eigenes HTML erlaubt.

Habt ihr keine eigene Webseite oder wollt ihr die Links auch anders verteilen, gibt es zusätzlich eine **eigene Hub-Seite**
(`https://<adresse-des-hubs>/<kurzname>`), zum Beispiel für QR-Codes im Gottesdienstblatt oder für Social Media.

## Die wichtigsten Begriffe

| Begriff | Bedeutung |
| --- | --- |
| **Betreiber** | Die Stelle, die den Kirchen-Hub bereitstellt und euch die Adresse gegeben hat. Ansprechpartner bei technischen Problemen. |
| **Kirche** | Eure Gemeinde im System. Sie hat einen Namen, einen Kurznamen (für die Adresse der eigenen Hub-Seite) und optional eine Webseite. Ein Konto kann zu mehreren Kirchen gehören. |
| **Hub** | Der Launcher einer Kirche. Jede Kirche hat genau einen Hub mit Überschrift, Design und Links. |
| **Link** | Ein Eintrag im Panel. Er öffnet entweder eine **Webseite** oder ein **Formular**. |
| **Formular** | Eine Reihe von Fragen, die Besucher im Launcher beantworten. Ein Formular erscheint erst im Launcher, wenn ihr es als Link (Button) in den Hub aufnehmt. |
| **Einsendung** | Die Antworten einer Person auf ein Formular. Sie sind nur im Backend sichtbar. |
| **Einbettungs-Code** | Die Zeile `<script …>` für eure Webseite. Sie enthält ein Kennzeichen (Token) eures Hubs. |
| **Eigene Hub-Seite** | Die Links des Hubs als eigenständige Webseite unter eurem Kurznamen. |
| **Besitzer / Admin** | Die beiden Rollen in einer Kirche. Besitzer dürfen zusätzlich Kirche und Team verwalten. Siehe [Kirche & Team](kirche-und-team.md). |

## Wie hängt alles zusammen?

```
Konto ──(Mitgliedschaft: Besitzer/Admin)──► Kirche ──► Hub ──► Links ──┬─► Webseite (URL)
                                              │                       └─► Formular ──► Einsendungen
                                              └──► Formulare (mit Fragen)

Hub ──► Launcher auf eurer Webseite (Einbettungs-Code)
    └─► Eigene Hub-Seite (/kurzname)
```

- Eine Kirche hat einen Hub und beliebig viele Formulare.
- Formulare gehören der Kirche, nicht dem Hub. Erst ein **Link vom Typ „Formular öffnen“** macht ein Formular im
  Launcher sichtbar. Auf der eigenen Hub-Seite erscheinen Formulare nicht.
- Ein Konto kann mehreren Kirchen angehören und zwischen ihnen wechseln.

## Was der Kirchen-Hub (noch) nicht kann

Damit du nicht vergeblich suchst – diese Dinge gibt es derzeit **nicht**:

- Klickstatistiken und Anmeldung per Magic Link (beides ist geplant).
- Links mit anderen Schemata als `http://` und `https://`, also **kein** `mailto:` oder `tel:`.
- Passwort ändern innerhalb des Kontos (Umweg: „Passwort vergessen?“, siehe [Konto & Anmeldung](konto-und-anmeldung.md)).
- Weitere Rollen als Besitzer und Admin, Einladungen per E-Mail (Mitglieder müssen sich zuerst selbst registrieren).
- Mehrsprachige Oberfläche: Backend und Launcher sind auf Deutsch.
