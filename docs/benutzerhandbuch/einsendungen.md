# Einsendungen

← [Benutzerhandbuch](README.md) · Zurück: [Formulare](formulare.md)

Alles, was Besucher über ein [Formular](formulare.md) abschicken, landet als **Einsendung** im Backend. Öffentlich
sichtbar ist nichts davon. Zugriff haben nur angemeldete Mitglieder der Kirche.

## Wo finde ich Einsendungen?

- **Hub → Formulare →** beim gewünschten Formular auf **Einsendungen** klicken, oder
- im Formular den Reiter **Einsendungen** öffnen.

Neue, ungelesene Einsendungen zeigt ein **Badge** im Menü (Punkt „Formulare“), in der Formularübersicht („n neu“) und am
Reiter „Einsendungen“.

## Die Liste

Die Einsendungen stehen **neueste zuerst**. Jede Zeile zeigt:

- eine **Vorschau**: die erste beantwortete Frage (auf 100 Zeichen gekürzt), fett bei ungelesenen
- ein **Neu**-Badge bei ungelesenen Einsendungen
- Datum und Uhrzeit des Eingangs
- Aktionen **Als gelesen/ungelesen markieren** und **Löschen**

Mit den Filtern **Alle** und **Ungelesen** oberhalb der Liste blendest du Erledigtes aus.

## Eine Einsendung lesen

Ein Klick auf die Vorschau öffnet die Einsendung. Dort stehen **alle Fragen mit den Antworten**, dazu
das Eingangsdatum. Nicht beantwortete Fragen zeigen „Keine Angabe“, Mehrfachauswahlen erscheinen kommagetrennt.

- Beim Öffnen wird die Einsendung automatisch als **gelesen** markiert.
- **Als ungelesen markieren** setzt sie wieder auf „neu“, praktisch als Erinnerung an offene Aufgaben.
- **Löschen** entfernt sie endgültig (mit Rückfrage).

## Alle löschen

Oben rechts in der Liste gibt es **„Alle löschen“** (mit Rückfrage und Anzahl). Es löscht **alle** Einsendungen dieses
Formulars endgültig und nicht rückgängig zu machen.

## CSV-Export

**„Als CSV exportieren“** lädt die Einsendungen als Datei herunter, z. B. `gebetsanliegen-2026-09-30.csv`
(Formularname und heutiges Datum).

- Eine **Zeile pro Einsendung**, eine **Spalte pro Frage**. Vorangestellt sind „Eingegangen am“ und „Gelesen“ (ja/nein).
- Fragen, die es inzwischen nicht mehr gibt, behalten ihre Spalte mit dem damaligen Fragetext.
- Das Format ist für **Excel** und Co. im deutschsprachigen Raum ausgelegt: Semikolon als Trennzeichen, UTF-8 mit
  Markierung, sodass Umlaute korrekt erscheinen. Datum und Uhrzeit im Format `TT.MM.JJJJ HH:MM`.
- Antworten, die mit `=`, `+`, `-` oder `@` beginnen, bekommen ein vorangestelltes `'`, damit Tabellenprogramme sie
  nicht als Formel ausführen.
- Exportiert wird **immer die vollständige** Liste, unabhängig vom Filter.

> Denke daran: Die CSV-Datei enthält personenbezogene Daten. Speichere sie sicher und lösche sie, wenn sie nicht mehr
> gebraucht wird.

## Benachrichtigung per E-Mail

Trägst du in den [Formular-Einstellungen](formulare.md#einstellungen-eines-formulars) unter **„E-Mail an“** eine oder
mehrere Adressen ein, bekommen diese bei **jeder neuen Einsendung** eine E-Mail:

- **Betreff:** „Neue Einsendung: <Formularname>“
- **Inhalt:** Hinweis mit Formular- und Kirchenname und ein **Link zur Einsendung** im Backend
- **Keine Antworten in der E-Mail:** Aus Datenschutzgründen (Gebetsanliegen sind sehr persönlich) stehen Antworten nie
  in der Mail. Die Empfänger melden sich mit ihrem Konto an und lesen sie im Backend.

Den Link im Backend können nur angemeldete Mitglieder der Kirche öffnen. Trage daher Adressen von Personen ein, die
ein Konto haben und [Mitglied](kirche-und-team.md#mitglieder) sind.

Voraussetzung ist, dass der Betreiber [SMTP eingerichtet](../setup/konfiguration.md#e-mail-versand-smtp) hat.
Ohne E-Mail-Versand gibt es keine Benachrichtigungen, die Einsendungen selbst gehen aber trotzdem nicht verloren.

## Automatisches Löschen

In den Formular-Einstellungen wählst du unter **„Einsendungen automatisch löschen“** eine Aufbewahrungsdauer:
*Nie* oder nach **1, 3, 6, 12 oder 24 Monaten**.

- Ein täglicher Hintergrundjob (um 3:00 Uhr nachts) löscht Einsendungen, die **älter als die eingestellte Dauer** sind
  (gerechnet ab Eingang).
- Das Löschen ist endgültig.
- Die Aufbewahrungsdauer gilt pro Formular. Ändert ihr sie, greift die neue Frist beim nächsten Lauf auch für
  bereits vorhandene Einsendungen.
- Voraussetzung ist der [Job-Runner](../setup/konfiguration.md#umgebungsvariablen) des Betreibers (`SOLID_QUEUE_IN_PUMA`).

Speichere wichtige Daten (z. B. eine Taufanfrage) rechtzeitig anderswo, bevor die Frist abläuft.

## Wer sieht Einsendungen?

**Alle Mitglieder** der Kirche, egal ob Besitzer oder Admin. Es gibt keine getrennte Rechteverwaltung pro Formular.
Nimm daher nur Personen ins [Team](kirche-und-team.md) auf, die sensible Anliegen lesen dürfen.
