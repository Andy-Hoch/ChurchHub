# Kirchen-Hub

Eine kleine Rails-Plattform, mit der Kirchen einen **Launcher** für ihre Webseite erstellen – inspiriert von nucleus.com.
Ein schwebender Button öffnet ein Panel mit den wichtigsten Links (Livestream, Termine, Spenden, Kleingruppen …).
Die Einbindung auf der eigenen Webseite braucht nur eine Zeile Code.

## Funktionen

- Registrierung und Anmeldung (Rails-8-Authentifizierung, E-Mail und Passwort)
- Kirchen mit mehreren Mitgliedern (Rollen: Besitzer, Admin). Ein Konto kann zu mehreren Kirchen gehören.
- Pro Kirche ein Hub mit Links: anlegen, bearbeiten, ausblenden, per Drag & Drop sortieren
- Design: Farben, Position, Button-Text und -Symbol, Farbschema, Eckenrundung, mit Live-Vorschau
- Einbettung per `<script>`-Tag. Das Widget läuft in einem Shadow DOM und beeinflusst die Kirchen-Webseite nicht.
- Formulare: Ein Button kann statt einer Webseite ein Formular öffnen. Es erscheint im Launcher im Vollbild,
  eine Frage nach der anderen (Intro, Fortschritt, Zurück, Übersicht vor dem Absenden, Danke-Seite).
  Vorlagen für Gebetsanliegen, Kontakt, Mitarbeit, Taufe und „Neu hier“. Einsendungen sind im Backend
  einsehbar (gelesen/ungelesen, CSV-Export, Löschen, automatisches Löschen nach einer Frist).

## Stack

Rails 8 · SQLite · Hotwire (Turbo, Stimulus) · Importmap · Propshaft · [CSS Zero](https://github.com/lazaronixon/css-zero)

Styling: CSS Zero liefert Tokens, Utilities und Komponenten. Eigene Ergänzungen im gleichen Stil liegen in
`app/assets/stylesheets/app.css`. Die generierten CSS-Zero-Dateien bleiben unverändert.

## Setup

```sh
bin/setup          # Gems installieren, Datenbank vorbereiten, Server starten
bin/rails db:seed  # Demo-Daten (Login: demo@example.com / passwort123)
```

Danach unter http://localhost:3000 anmelden. Eine Beispiel-Fremdseite mit eingebundenem Launcher
gibt es unter `http://localhost:3000/embed-demo.html?token=<TOKEN>`. Das Token steht in der Seed-Ausgabe oder im Dashboard unter „Einbinden“.

## Einbinden

```html
<script src="https://<host>/embed/<token>.js" async></script>
```

`GET /embed/:token.js` ist öffentlich, per ETag und `Cache-Control: public` cachebar und liefert
für deaktivierte oder unbekannte Hubs ein leeres Skript.

Formulare senden an `POST /embed/:token/forms/:form_id/submissions` (öffentlich, CORS `*`, ohne Cookies).
Spam-Schutz: Honeypot-Feld, Mindest-Ausfüllzeit und Rate-Limit pro IP.

## E-Mail-Benachrichtigungen

Bei neuen Einsendungen gehen E-Mails an die im Formular hinterlegten Adressen. Sie enthalten nur einen
Link ins Backend, keine Antworten. Für die Produktion SMTP per `bin/rails credentials:edit` hinterlegen:

```yaml
smtp:
  address: smtp.example.com
  user_name: ...
  password: ...
  from: hub@example.com
```

Zusätzlich `APP_HOST` (z. B. `hub.example.com`) setzen, damit die Links in den E-Mails stimmen.

## Tests & Checks

```sh
bin/rails test
bin/rails test:system
bin/rubocop
bin/brakeman
```

## Geplant

- Login per Magic Link
- Klickstatistiken
