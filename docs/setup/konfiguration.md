# Konfiguration

← [Zur Übersicht](../README.md) · Zurück: [Installation im Internet](produktion.md) · Weiter: [Betrieb & Wartung](betrieb.md)

Der Kirchen-Hub braucht wenig Konfiguration. Alles Wesentliche steckt in **Umgebungsvariablen** und in den
**verschlüsselten Credentials**. Diese Seite ist die Nachschlage-Referenz.

## Umgebungsvariablen

Sie werden beim Start des Containers gesetzt (bei Kamal unter `env:` in `config/deploy.yml`, bei Docker per `-e`).

| Variable | Standard | Bedeutung |
| --- | --- | --- |
| `RAILS_MASTER_KEY` | – | Schlüssel zum Entschlüsseln von `config/credentials.yml.enc` (Inhalt von `config/master.key`). **Pflicht in Produktion**, sofern du SMTP über die Credentials konfigurierst. Geheim halten! |
| `APP_HOST` | `example.com` | Domain deines Hubs **ohne** `https://`, z. B. `hub.eure-kirche.de`. Sie wird für Links in E-Mails verwendet (Passwort-Reset, Einsendungs-Benachrichtigung). Ist sie falsch, zeigen die Links auf `example.com`. |
| `SOLID_QUEUE_IN_PUMA` | nicht gesetzt | Auf `true` setzen, damit der Job-Runner im Web-Prozess mitläuft. **Nötig** für E-Mail-Versand und das tägliche automatische Löschen von Einsendungen. In der mitgelieferten `deploy.yml` bereits aktiviert. |
| `PORT` | `3000` | Port des Rails-Servers (Puma). Im Container leitet Thruster von Port 80 dorthin weiter, du musst ihn dort nicht ändern. |
| `RAILS_MAX_THREADS` | `3` (Puma) / `5` (DB-Pool) | Threads pro Prozess. Für kleine Installationen unverändert lassen. |
| `WEB_CONCURRENCY` | `1` | Anzahl Puma-Prozesse. Bei SQLite meist nicht nötig. |
| `JOB_CONCURRENCY` | `1` | Anzahl Job-Prozesse. |
| `RAILS_LOG_LEVEL` | `info` | Auf `debug` stellen, um alles zu loggen. Achtung: Dann können **personenbezogene Daten** (z. B. Formular-Antworten) in den Logs landen. |
| `SECRET_KEY_BASE` | aus Credentials | Alternative zum `secret_key_base` in den Credentials. Normalerweise nicht nötig. |

Der Kirchen-Hub verwendet außerdem die üblichen Rails-Variablen (`PIDFILE`, `RAILS_ENV` …).
`RAILS_ENV=production` ist im Docker-Image bereits gesetzt.

## Credentials (verschlüsselte Zugangsdaten)

Bearbeiten mit:

```sh
EDITOR="nano" bin/rails credentials:edit
```

Erforderlich ist der passende `config/master.key`. Die Einrichtung ist in
[Installation im Internet, Schritt 2](produktion.md#schritt-2-eigene-zugangsdaten-credentials-erzeugen) beschrieben.
Nach Änderungen an der Datei musst du neu deployen (`bin/kamal deploy`), damit der Server sie bekommt.

Aufbau:

```yaml
secret_key_base: …          # wird beim Erzeugen automatisch gesetzt

smtp:                       # E-Mail-Versand, siehe unten
  address: smtp.example.com
  port: 587
  user_name: hub@eure-kirche.de
  password: geheim
  from: hub@eure-kirche.de
```

## E-Mail-Versand (SMTP)

Der Hub verschickt zwei Arten von E-Mails:

| E-Mail | Wann | Inhalt |
| --- | --- | --- |
| **Passwort zurücksetzen** | Jemand nutzt „Passwort vergessen?“ | Link zum Festlegen eines neuen Passworts (kurze Zeit gültig, standardmäßig 15 Minuten) |
| **Neue Einsendung** | Jemand schickt ein Formular ab, für das E-Mail-Adressen hinterlegt sind | Nur ein Hinweis mit Formularname und Link ins Backend. **Keine Antworten**, aus Datenschutzgründen |

Ist im Block `smtp:` etwas hinterlegt, nutzt der Hub diesen SMTP-Server. Felder:

| Feld | Pflicht | Bedeutung |
| --- | --- | --- |
| `address` | ja | Hostname des SMTP-Servers |
| `port` | nein | Standard `587` (STARTTLS) |
| `user_name` | ja* | Benutzername des Postfachs |
| `password` | ja* | Passwort bzw. App-Passwort |
| `from` | empfohlen | Absenderadresse aller Mails. Ohne Angabe wird `from@example.com` verwendet, viele Anbieter lehnen das ab. |

\* Bei Servern ohne Anmeldung nicht sinnvoll; die Authentifizierungsart ist fest auf `plain` eingestellt.

Bewährt haben sich die SMTP-Zugänge eures Webhosters oder eines Transaktions-Mail-Dienstes. Achte darauf, dass die
Absenderadresse zu eurer Domain passt und SPF/DKIM für sie eingerichtet sind, sonst landen Mails im Spam.

**Ohne SMTP-Konfiguration** werden keine E-Mails zugestellt. Das hat zwei Folgen:

- „Passwort vergessen?“ funktioniert nicht. Ein Passwort lässt sich dann nur vom Betreiber zurücksetzen, siehe
  [Betrieb & Wartung](betrieb.md#passwort-zurücksetzen-ohne-e-mail).
- Formular-Benachrichtigungen kommen nicht an. Einsendungen selbst werden trotzdem gespeichert und sind im
  Backend sichtbar.

Getestet ist die Konfiguration am einfachsten, indem du „Passwort vergessen?“ mit deiner eigenen Adresse ausprobierst.

## Sprache und Zeitzone

Die Oberfläche ist durchgängig **Deutsch** und die Zeitzone ist **Berlin** (`config/application.rb`). Zeitangaben
im Backend (z. B. „Eingegangen am“) und in der CSV-Datei sind in dieser Zeitzone.

## Geplante Aufgaben

In Produktion laufen automatisch (über den Job-Runner, siehe `config/recurring.yml`):

| Aufgabe | Zeitplan | Wirkung |
| --- | --- | --- |
| Abgelaufene Einsendungen löschen | täglich um 3:00 Uhr | Löscht Einsendungen, die älter sind als die im Formular eingestellte Aufbewahrungsdauer |
| Erledigte Jobs aufräumen | stündlich (Minute 12) | Hält die Job-Datenbank klein |

## Feste Grenzen

Diese Werte sind im Code verankert. Sie zu ändern erfordert eine Code-Anpassung.

**Zugriff und Missbrauchsschutz**

| Bereich | Grenze |
| --- | --- |
| Anmeldung, Registrierung, „Passwort vergessen?“, Konto löschen | je 10 Versuche pro 3 Minuten und IP-Adresse |
| Formular-Einsendungen (öffentlich) | 10 pro 10 Minuten und IP-Adresse |
| Mindest-Ausfüllzeit eines Formulars | 3 Sekunden ab Öffnen; schneller gilt als Bot |
| Passwort | mindestens 8, höchstens 72 Zeichen |
| Zwischenspeicher des Embed-Skripts | 5 Minuten (Änderungen im Backend erscheinen also mit bis zu 5 Minuten Verzögerung auf der Webseite) |

**Textlängen und Anzahlen**

| Feld | Grenze |
| --- | --- |
| Hub-Überschrift | 80 Zeichen |
| Button-Text | 30 Zeichen |
| Eckenrundung | 0 bis 24 Pixel |
| Link: Titel / Beschreibung / Symbol | 80 / 160 / 8 Zeichen |
| Formular: Titel | 80 Zeichen |
| Formular: Begrüßung, Danke-Text, Einwilligungstext | je 1000 Zeichen |
| Formular: Text des Absenden-Buttons | 30 Zeichen |
| Aufbewahrung | nie, 1, 3, 6, 12 oder 24 Monate |
| Frage: Text / Hinweis | 200 / 300 Zeichen |
| Antwortmöglichkeiten | höchstens 30 Einträge mit je höchstens 100 Zeichen |
| Antwort „Kurzer Text“ / „Langer Text“ | 200 / 5000 Zeichen |

Weitere technische Details: [Technische Referenz](../referenz/technik.md).
