# Kirche & Team

← [Benutzerhandbuch](README.md)

Unter **Kirche → Einstellungen** verwaltest du die Kirche selbst und wer sie mitpflegen darf.

## Rollen

Jedes Mitglied hat in einer Kirche eine von zwei Rollen:

| Recht | Admin | Besitzer |
| --- | --- | --- |
| Links, Design, Formulare und Einsendungen verwalten | ✅ | ✅ |
| Einbettungs-Code sehen, Launcher aktivieren/deaktivieren, Code neu erzeugen | ✅ | ✅ |
| Zwischen Kirchen wechseln, neue Kirche anlegen | ✅ | ✅ |
| Einstellungen der Kirche ändern (Name, Webseite, Kurzname) | – | ✅ |
| Mitglieder hinzufügen und entfernen | – | ✅ |
| Kirche löschen | – | ✅ |

Nicht-Besitzer sehen die Einstellungen ausgegraut und ohne „Speichern“. Versuche, sie trotzdem zu ändern,
weist der Server ab („Nur Besitzer dürfen das.“).

Wer eine Kirche **anlegt**, ist automatisch Besitzer. Neu hinzugefügte Mitglieder sind **Admins**. Eine Oberfläche
zum Ändern der Rolle gibt es nicht. Bei Bedarf hilft der Betreiber, siehe
[Betrieb & Wartung](../setup/betrieb.md#weitere-wartungsaufgaben-in-der-konsole). Es kann mehrere Besitzer geben.

## Einstellungen der Kirche

| Feld | Beschreibung |
| --- | --- |
| **Name** | Pflicht. Erscheint in der Kopfzeile des Backends und in E-Mails. |
| **Webseite (optional)** | Die Domain eurer Gemeinde. Beschränkt den Launcher auf diese Domain und ihre Subdomains, siehe [Einbinden](einbinden.md#beschränkung-auf-eure-webseite). |
| **Kurzname** | Bestimmt die Adresse der [eigenen Hub-Seite](eigene-seite.md). Kleinbuchstaben, Zahlen und Bindestriche. Einmalig im System. |

## Mitglieder

Die Liste zeigt Name, E-Mail-Adresse und Rolle jedes Mitglieds (Besitzer mit hervorgehobenem Badge).

### Mitglied hinzufügen (nur Besitzer)

1. Die Person **registriert sich zuerst selbst** auf der Registrierungsseite. Dabei entsteht automatisch auch
   eine eigene Kirche für sie, die sie nicht nutzen muss.
2. Du gibst unter „Mitglied hinzufügen“ deren **E-Mail-Adresse** ein und wählst „Hinzufügen“.
3. Die Person ist sofort Admin deiner Kirche und kann sie über das Kirchen-Auswahlfeld erreichen.

Meldungen: „Kein Konto mit dieser E-Mail-Adresse gefunden. Die Person muss sich zuerst registrieren.“ bzw.
„… ist bereits Mitglied.“ Der Hub versendet **keine Einladungs-E-Mails**. Sage der Person Bescheid.

### Mitglied entfernen (nur Besitzer)

Bei jedem Mitglied außer dir selbst gibt es **Entfernen** (mit Rückfrage). Das entzieht den Zugang sofort. Das
Konto der Person bleibt bestehen. **Dich selbst kannst du nicht entfernen.** Willst du selbst gehen, muss dich ein
anderer Besitzer entfernen. Alternativ kannst du dein Konto löschen, siehe
[Konto löschen](konto-und-anmeldung.md#konto-löschen).

## Mehrere Kirchen

Ein Konto kann **mehreren Kirchen** angehören, etwa wenn du zwei Gemeinden betreust oder als Agentur mehrere Kunden.

- **Neue Kirche anlegen:** *Kirche → Neue Kirche* (Name, optional Webseite). Du wirst Besitzer und wechselst
  direkt in die neue Kirche. Sie bekommt einen eigenen Hub mit eigenem Einbettungs-Code.
- **Wechseln:** Sobald du mindestens zwei Kirchen hast, erscheint unten in der Navigation **„Kirche wechseln“**. Die Auswahl
  wirkt sofort und führt zur Link-Seite der gewählten Kirche. Die aktuelle Kirche steht in der Kopfzeile.
- Alle Seiten (Links, Design, Formulare, Einbinden) beziehen sich immer auf die **aktuell gewählte** Kirche.
  Achte beim Bearbeiten auf den Namen in der Kopfzeile.
- Jede Kirche hat ihr eigenes Team, ihre eigenen Formulare und ihren eigenen Code. Es gibt keine Verknüpfung.

## Kirche löschen

Nur Besitzer, ganz unten in den Einstellungen. Das Löschen entfernt **Hub, Links, Formulare, Fragen und alle
Einsendungen** und nimmt allen Mitgliedern den Zugang. Der Launcher auf eurer Webseite und die eigene Hub-Seite
funktionieren danach nicht mehr. **Das lässt sich nicht rückgängig machen.**

Bedingungen:

- Es darf **nicht deine einzige Kirche** sein. Hast du nur diese eine, ist das Löschen gesperrt. Lösche dann
  stattdessen [dein Konto](konto-und-anmeldung.md#konto-löschen).
- Zur Bestätigung tippst du den **Namen der Kirche** exakt ein.

> Achtung: Die Sperre zählt nur **deine** Kirchen. Eine Kirche mit weiteren Mitgliedern lässt sich also löschen,
> sofern du noch eine andere hast. Alle anderen Mitglieder verlieren dann den Zugang.
