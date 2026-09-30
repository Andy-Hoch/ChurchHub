# Einstieg & Grundbegriffe

← [Zur Übersicht](README.md)

## Was ist der Kirchen-Hub?

Der Kirchen-Hub ist eine kleine Webanwendung, mit der eine Kirche für ihre Webseite einen **Launcher** erstellt –
inspiriert von nucleus.com:

- Auf eurer Webseite erscheint ein **schwebender Button** (standardmäßig unten rechts).
- Ein Klick öffnet ein **Panel** mit euren wichtigsten Links, z. B. „Gottesdienst live“, „Termine“, „Spenden“.
- Ein Button kann statt einer Webseite ein **Formular** öffnen (Gebetsanliegen, Kontakt, „Neu hier“ …).
  Das Formular erscheint im Vollbild und stellt eine Frage nach der anderen.
- Ihr pflegt alles im **Backend** (Login-Bereich). Änderungen erscheinen ohne Eingriff in die Webseite.
- Eingebunden wird der Launcher mit **einer Zeile Code**. Das funktioniert mit WordPress, Squarespace, Wix und
  jeder anderen Seite, die eigenes HTML erlaubt.

Zusätzlich ist der Hub als **eigene Seite** erreichbar (`https://<euer-hub>/<kurzname>`), zum Beispiel für QR-Codes
im Gottesdienstblatt oder für Social Media.

## Die wichtigsten Begriffe

| Begriff | Bedeutung |
| --- | --- |
| **Kirche** | Eure Gemeinde im System. Sie hat einen Namen, einen Kurzname (für die Adresse der eigenen Seite) und optional eine Webseite. Ein Konto kann zu mehreren Kirchen gehören. |
| **Hub** | Der Launcher einer Kirche. Jede Kirche hat genau einen Hub mit Überschrift, Design und Links. |
| **Link** | Ein Eintrag im Panel. Er öffnet entweder eine **Webseite** oder ein **Formular**. |
| **Formular** | Eine Reihe von Fragen, die Besucher im Launcher beantworten. Ein Formular erscheint erst im Launcher, wenn ihr es als Link (Button) in den Hub aufnehmt. |
| **Einsendung** | Die Antworten einer Person auf ein Formular. Sie sind nur im Backend sichtbar. |
| **Einbettungs-Code** | Die Zeile `<script …>` für eure Webseite. Sie enthält ein geheim wirkendes, aber öffentliches Kennzeichen (Token) eures Hubs. |
| **Besitzer / Admin** | Die beiden Rollen in einer Kirche. Besitzer dürfen zusätzlich Kirche und Team verwalten. Siehe [Kirche & Team](benutzerhandbuch/kirche-und-team.md). |

## Wie hängt alles zusammen?

```
Konto ──(Mitgliedschaft: Besitzer/Admin)──► Kirche ──► Hub ──► Links ──┬─► Webseite (URL)
                                              │                       └─► Formular ──► Einsendungen
                                              └──► Formulare (mit Fragen)
```

- Eine Kirche hat einen Hub und beliebig viele Formulare.
- Formulare gehören der Kirche, nicht dem Hub. Erst ein **Link vom Typ „Formular öffnen“** macht ein Formular im
  Launcher sichtbar.
- Ein Konto kann mehreren Kirchen angehören und zwischen ihnen wechseln.

## In 10 Minuten zum ersten Launcher

Diese Schritte gelten, wenn es bereits einen laufenden Kirchen-Hub gibt (eigener Server oder von jemandem bereitgestellt).
Noch keinen Hub? Dann starte mit der [Lokalen Installation](setup/lokale-installation.md) zum Ausprobieren oder der
[Installation im Internet](setup/produktion.md).

1. **Registrieren.** Öffne die Adresse des Hubs, klicke auf „Kostenlos registrieren“ und gib den Namen eurer Kirche,
   optional eure Webseite (siehe unten), deinen Namen, E-Mail-Adresse und ein Passwort (mindestens 8 Zeichen) an.
   Details: [Konto & Anmeldung](benutzerhandbuch/konto-und-anmeldung.md).
2. **Links anlegen.** Unter *Links* → „Link hinzufügen“ Titel, Adresse und optional Beschreibung und Emoji eintragen.
   Per Drag & Drop sortieren. Details: [Links verwalten](benutzerhandbuch/links.md).
3. **Design anpassen.** Unter *Design* Farben, Button-Text und Position passend zu eurer Webseite wählen. Die Vorschau
   aktualisiert sich sofort. Details: [Design anpassen](benutzerhandbuch/design.md).
4. *(Optional)* **Formular anlegen.** Unter *Formulare* eine Vorlage wählen (z. B. „Gebetsanliegen“), anpassen und über
   „Als Button hinzufügen“ in den Hub aufnehmen. Details: [Formulare](benutzerhandbuch/formulare.md).
5. **Einbinden.** Unter *Einbinden* die Zeile kopieren und vor dem schließenden `</body>`-Tag eurer Webseite einfügen.
   Details: [Auf der Webseite einbinden](benutzerhandbuch/einbinden.md).

> **Tipp:** Trage schon bei der Registrierung (oder später unter *Kirche → Einstellungen*) die Adresse eurer
> Webseite ein. Dann funktioniert der Launcher nur dort und nicht auf fremden Seiten.

## Was der Kirchen-Hub (noch) nicht kann

Damit du nicht vergeblich suchst – diese Dinge gibt es derzeit **nicht**:

- Anmeldung per Magic Link und Klickstatistiken (beides steht auf der Liste „Geplant“ im [README](../README.md)).
- Links mit anderen Schemata als `http://` und `https://` – also **kein** `mailto:` oder `tel:`.
- Passwort ändern innerhalb des Kontos (Umweg: „Passwort vergessen?“, siehe [Konto & Anmeldung](benutzerhandbuch/konto-und-anmeldung.md)).
- Weitere Rollen als Besitzer und Admin, Einladungen per E-Mail (Mitglieder müssen sich zuerst selbst registrieren).
- Mehrsprachige Oberfläche: Backend und Launcher sind auf Deutsch.
