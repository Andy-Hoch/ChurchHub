# Lokale Installation

← [Zur Übersicht](../README.md) · Weiter: [Installation im Internet](produktion.md)

Diese Anleitung bringt den Kirchen-Hub auf deinem eigenen Rechner zum Laufen. Ideal zum **Ausprobieren**, für
**Demos** und zum **Weiterentwickeln**. Für den echten Einsatz auf eurer Webseite brauchst du einen Server mit
Internetadresse, siehe [Installation im Internet](produktion.md).

## Voraussetzungen

| Was | Version / Hinweis |
| --- | --- |
| **Ruby** | 4.0.7 (steht in `.ruby-version`). Am einfachsten mit einem Versionsmanager wie [mise](https://mise.jdx.dev), [rbenv](https://github.com/rbenv/rbenv) oder [asdf](https://asdf-vm.com). |
| **Bundler** | Kommt mit Ruby. |
| **SQLite 3** | Als Datenbank. Auf macOS vorhanden, unter Debian/Ubuntu: `sudo apt install sqlite3 libsqlite3-dev`. |
| **Git** | Zum Herunterladen des Codes. |
| Build-Werkzeuge | Für Gems mit nativen Erweiterungen: unter Debian/Ubuntu `sudo apt install build-essential libyaml-dev pkg-config`, auf macOS die Xcode Command Line Tools. |
| Chrome/Chromium | Nur für die System-Tests (`bin/rails test:system`). |

Node.js wird **nicht** benötigt: Das JavaScript wird per Importmap ausgeliefert, es gibt keinen Build-Schritt.

## Schritt für Schritt

### 1. Code herunterladen

```sh
git clone https://github.com/andy-hoch/churchhub.git
cd churchhub
```

### 2. Einrichten und starten

```sh
bin/setup
```

`bin/setup` erledigt der Reihe nach:

1. Gems installieren (`bundle install`)
2. Datenbank anlegen und Tabellen erstellen (`bin/rails db:prepare`)
3. alte Logs und temporäre Dateien entfernen
4. den Entwicklungsserver starten (`bin/dev`, Port 3000)

Mit `bin/setup --skip-server` wird nur eingerichtet, ohne den Server zu starten. Mit `bin/setup --reset` wird die
Datenbank zusätzlich zurückgesetzt und alle lokalen Daten gehen verloren. Das Skript darf beliebig oft laufen.

Später startest du den Server einfach mit:

```sh
bin/dev
```

### 3. Demo-Daten laden (optional, empfohlen)

In einem zweiten Terminal:

```sh
bin/rails db:seed
```

Das legt an:

- ein Konto **`demo@example.com`** mit Passwort **`passwort123`**
- die Kirche **„Demo Gemeinde“** (Kurzname `demo-gemeinde`) mit dir als Besitzer
- ein Formular „Gebetsanliegen“ (aus der Vorlage, mit Einwilligungstext und Benachrichtigung an die Demo-Adresse)
- fünf Links, darunter einen Formular-Button

Die Ausgabe endet mit `Demo-Hub: /embed/<TOKEN>.js`. Das Token brauchst du für die Demo-Webseite.
Das Seeden ist wiederholbar: bereits vorhandene Daten werden nicht doppelt angelegt.

### 4. Anmelden

Öffne <http://localhost:3000> und melde dich mit den Demo-Zugangsdaten an. Alternativ registrierst du dir mit
„Kostenlos registrieren“ ein eigenes Konto.

### 5. Launcher auf einer Beispielseite ansehen

Im Repository liegt eine Demo-Webseite, die den Launcher wie eine fremde Kirchenseite einbindet:

```
http://localhost:3000/embed-demo.html?token=<TOKEN>
```

Das Token findest du in der Seed-Ausgabe oder im Backend unter **Einbinden** (im Snippet zwischen `/embed/` und `.js`).
Ohne `?token=…` zeigt die Seite ein Eingabefeld für das Token.

Direkt aufrufen kannst du außerdem:

- die **eigene Hub-Seite**: <http://localhost:3000/demo-gemeinde>
- das **Embed-Skript**: `http://localhost:3000/embed/<TOKEN>.js`

## E-Mails in der Entwicklung

Im Entwicklungsmodus werden **keine echten E-Mails verschickt**. Passwort-Zurücksetzen-Links und
Benachrichtigungen zu Formular-Einsendungen erscheinen im Terminal bzw. in `log/development.log`. Dort kannst du
den Link herauskopieren. Mail-Vorschauen (Layout der Mails) gibt es unter
<http://localhost:3000/rails/mailers>.

## Wo liegen die Daten?

Die SQLite-Datenbank liegt in `storage/development.sqlite3`. Zum Zurücksetzen genügt `bin/setup --reset`
(oder die Datei löschen und `bin/rails db:prepare` ausführen).

## Tests und Code-Prüfungen

```sh
bin/rails test           # Unit- und Controller-Tests
bin/rails test:system    # Browser-Tests (benötigt Chrome/Chromium)
bin/rubocop              # Code-Stil
bin/brakeman             # Sicherheits-Analyse
bin/ci                   # alles Wesentliche nacheinander (siehe config/ci.rb)
```

Dieselben Prüfungen laufen bei jedem Pull Request in GitHub Actions (`.github/workflows/ci.yml`).

## Typische Stolperstellen

| Problem | Lösung |
| --- | --- |
| `Your Ruby version is x, but your Gemfile specified 4.0.7` | Ruby 4.0.7 installieren, z. B. `mise install ruby@4.0.7` bzw. `rbenv install 4.0.7`. |
| `bundle install` bricht bei `sqlite3` oder `psych` ab | Entwicklungsbibliotheken nachinstallieren (siehe Voraussetzungen). |
| Port 3000 ist belegt | Mit `PORT=3001 bin/dev` auf einem anderen Port starten. |
| Der Launcher erscheint auf der Demo-Seite nicht | Token prüfen und unter *Einbinden* kontrollieren, ob der Launcher aktiv ist. Die Demo-Seite läuft auf demselben Host wie der Hub und ist daher von der [Webseiten-Beschränkung](../benutzerhandbuch/einbinden.md#beschränkung-auf-eure-webseite) nicht betroffen. |
| Eine Test-Einsendung taucht im Backend nicht auf, obwohl „Vielen Dank!“ erschien | Spam-Schutz: Wird ein Formular weniger als 3 Sekunden nach dem Öffnen abgeschickt, verwirft der Hub die Einsendung stillschweigend. Beim Testen also kurz Zeit lassen. |
