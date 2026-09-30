# Installation im Internet (Produktion)

← [Zur Übersicht](../README.md) · Zurück: [Lokale Installation](lokale-installation.md) · Weiter: [Konfiguration](konfiguration.md)

Diese Anleitung führt dich **von einem leeren Server bis zu einem laufenden Kirchen-Hub unter eigener Adresse**,
zum Beispiel `https://hub.eure-kirche.de`. Danach kannst du dich registrieren und den Launcher auf eurer Webseite
einbinden.

Es gibt zwei Wege:

- **[Weg A: Kamal](#weg-a-deployment-mit-kamal-empfohlen)** – empfohlen. Das Projekt bringt Kamal fertig mit. Es installiert Docker auf dem Server, baut das
  Image, holt automatisch ein HTTPS-Zertifikat (Let's Encrypt) und ermöglicht Updates mit einem Befehl.
- **[Weg B: Docker von Hand](#weg-b-docker-von-hand)** – wenn du schon einen Server mit eigenem Reverse-Proxy (Caddy, nginx, Traefik …) hast.

Beide Wege nutzen dasselbe `Dockerfile`. Die Anwendung besteht aus **einem einzigen Container** (Rails + eingebetteter
Job-Runner) und speichert alles in **SQLite-Dateien** im Verzeichnis `/rails/storage`. Es ist keine separate
Datenbank, kein Redis und kein Node.js nötig.

> **Wichtig:** Wegen SQLite läuft der Hub auf **genau einem Server bzw. Container**. Mehrere Web-Server mit
> gemeinsamer Datenbank sind nicht vorgesehen.

---

## Was du vorab brauchst

| Was | Details |
| --- | --- |
| **Server** | Ein Linux-Server (z. B. Ubuntu 24.04) mit öffentlicher IP, SSH-Zugang und offenen Ports **80** und **443**. Der Ressourcenbedarf ist gering, ein kleiner VPS reicht in der Regel. |
| **Domain** | Eine (Sub-)Domain wie `hub.eure-kirche.de` mit einem **DNS-A-Eintrag** auf die IP des Servers. Der Eintrag muss vor dem ersten Deployment wirksam sein, sonst kann kein Zertifikat ausgestellt werden. |
| **Container-Registry** | Ein Ort für das Docker-Image, z. B. Docker Hub oder GitHub Container Registry (ghcr.io), samt Zugangs-Token. Nur für Weg A. |
| **Ruby auf deinem Rechner** | Für Weg A und für das Erzeugen der Zugangsdaten (Schritt 2): Ruby 4.0.7 und `bundle install`, siehe [Lokale Installation](lokale-installation.md#voraussetzungen). |
| **SMTP-Zugang** | Für den E-Mail-Versand (Passwort-Reset, Benachrichtigungen bei Einsendungen). Empfohlen, siehe [Konfiguration](konfiguration.md#e-mail-versand-smtp). |

> **Hinweis zur Domain:** Der Launcher wird auf **euren Webseiten per HTTPS** eingebunden. Browser blockieren
> unverschlüsselte Skripte auf HTTPS-Seiten. Der Hub braucht deshalb zwingend HTTPS.

---

## Weg A: Deployment mit Kamal (empfohlen)

### Schritt 1: Code holen

Am besten legst du einen **Fork** des Repositorys auf GitHub an (so kannst du deine Konfiguration versionieren
und später Updates einspielen) und klonst ihn:

```sh
git clone https://github.com/<dein-konto>/churchhub.git
cd churchhub
bundle install
```

### Schritt 2: Eigene Zugangsdaten (Credentials) erzeugen

Rails verschlüsselt geheime Werte in `config/credentials.yml.enc`. Die zum Repository gehörende Datei kannst du
**nicht entschlüsseln**, weil der passende Schlüssel (`config/master.key`) bewusst nicht im Repository liegt.
Erzeuge deshalb eine eigene:

```sh
rm config/credentials.yml.enc
EDITOR="nano" bin/rails credentials:edit
```

Dabei entstehen:

- `config/master.key` – dein **Schlüssel**. Er steht in `.gitignore` und darf **nie** ins Repository.
  **Sichere ihn in einem Passwortmanager!** Ohne ihn sind die verschlüsselten Werte verloren.
- eine neue `config/credentials.yml.enc` mit einem frischen `secret_key_base`. Diese Datei ist verschlüsselt und darf
  committet werden.

Im geöffneten Editor kannst du gleich den E-Mail-Versand ergänzen (unterhalb der Zeile `secret_key_base`):

```yaml
smtp:
  address: smtp.example.com
  port: 587
  user_name: hub@eure-kirche.de
  password: geheim
  from: hub@eure-kirche.de
```

Speichern und Editor schließen. Die Felder sind unter [Konfiguration](konfiguration.md#e-mail-versand-smtp) erklärt.
Du kannst SMTP auch später jederzeit mit `bin/rails credentials:edit` nachtragen.

### Schritt 3: `config/deploy.yml` anpassen

Die mitgelieferte Datei enthält Platzhalter. Passe mindestens diese Stellen an:

```yaml
service: kirchen_hub                 # frei wählbar, Kleinbuchstaben/Unterstrich
image: dein-registry-konto/kirchen-hub

servers:
  web:
    - 203.0.113.10                   # IP deines Servers

proxy:
  ssl: true
  host: hub.eure-kirche.de           # deine Domain

registry:
  # server: ghcr.io                  # bei Docker Hub weglassen
  username: dein-registry-konto
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    SOLID_QUEUE_IN_PUMA: true        # Job-Runner im Web-Prozess (nötig für E-Mails und Aufräum-Jobs)
    APP_HOST: hub.eure-kirche.de     # damit Links in E-Mails stimmen

volumes:
  - "kirchen_hub_storage:/rails/storage"   # hier liegen die Datenbanken – Namen passend zu "service" wählen
```

Wichtige Hinweise dazu:

- **`proxy:`** ist im Original auskommentiert. Ohne diesen Block gibt es kein HTTPS.
- **`registry.server`** steht im Original auf `localhost:5555`. Ersetze den Wert (z. B. `ghcr.io`) oder entferne die Zeile, wenn du Docker Hub nutzt.
- **`volumes`**: Ohne Volume gehen alle Daten beim nächsten Deployment verloren. Der Volume-Name sollte zu `service` passen.
- **`SOLID_QUEUE_IN_PUMA: true`** ist bereits gesetzt. Lass es so. Ohne Job-Runner werden weder E-Mails verschickt
  noch Einsendungen automatisch gelöscht.
- Die Werte `plain_blog` im Original sind Überbleibsel des Projektstarts. Sie sind austauschbar.

### Schritt 4: HTTPS-Erzwingung aktivieren

Öffne `config/environments/production.rb` und entferne das Kommentarzeichen vor diesen zwei Zeilen:

```ruby
config.assume_ssl = true
config.force_ssl = true
```

Damit gelten Cookies als „secure“, HTTP wird auf HTTPS umgeleitet und der Browser merkt sich per HSTS, dass die Seite
nur per HTTPS erreichbar ist. Das ist zwingend nötig, sobald der Kamal-Proxy TLS terminiert.

### Schritt 5: Zugang zur Registry bereitstellen

Kamal liest Geheimnisse aus `.kamal/secrets` (diese Datei enthält nur Verweise, keine Werte, und ist für Git geeignet).
Das Master-Key-Lesen ist schon eingetragen (`RAILS_MASTER_KEY=$(cat config/master.key)`). Für die Registry
entkommentierst du in `.kamal/secrets` die Zeile

```sh
KAMAL_REGISTRY_PASSWORD=$KAMAL_REGISTRY_PASSWORD
```

und exportierst das Token in deiner Shell:

```sh
export KAMAL_REGISTRY_PASSWORD=dein-token
```

### Schritt 6: Änderungen committen

```sh
git add config/deploy.yml config/credentials.yml.enc config/environments/production.rb .kamal/secrets
git commit -m "Produktionskonfiguration"
```

Kamal baut das Image aus dem **committeten** Stand. Nicht committete Änderungen werden nicht berücksichtigt.
`config/master.key` **nicht** hinzufügen.

### Schritt 7: Erstes Deployment

```sh
bin/kamal setup
```

Das tut Folgendes: per SSH mit dem Server verbinden, Docker installieren (falls nötig), Image bauen und hochladen,
Container starten, Kamal-Proxy einrichten und ein Let's-Encrypt-Zertifikat holen. Beim Start des Containers legt
`bin/docker-entrypoint` die Datenbanken an bzw. migriert sie (`db:prepare`). Ein manueller Migrationsschritt ist nie nötig.

Die Dauer liegt beim ersten Mal im Minutenbereich, weil das Image gebaut wird.

### Schritt 8: Prüfen

1. `https://hub.eure-kirche.de/up` sollte eine grüne Seite (HTTP 200) liefern.
2. `https://hub.eure-kirche.de` öffnen: Startseite mit „Kostenlos registrieren“.
3. **Registrieren.** Das erste Konto ist Besitzer seiner Kirche. Es gibt keinen speziellen Administrator-Bereich
   für den ganzen Server. Siehe auch [Registrierung ist offen](#registrierung-ist-offen).
4. Unter *Einbinden* das Snippet kopieren und auf einer Testseite einfügen (siehe
   [Auf der Webseite einbinden](../benutzerhandbuch/einbinden.md)).
5. **E-Mail testen:** „Passwort vergessen?“ mit deiner Adresse ausprobieren. Kommt die Mail an, funktioniert SMTP.

### Spätere Updates

```sh
git pull                 # oder deine Änderungen mergen
bin/kamal deploy
```

Mehr dazu in [Betrieb & Wartung](betrieb.md#updates-einspielen).

### Praktische Kamal-Befehle

Die Datei `config/deploy.yml` definiert Kurzbefehle:

```sh
bin/kamal logs         # Logs live mitlesen
bin/kamal console      # Rails-Konsole im Container
bin/kamal shell        # Shell im Container
bin/kamal dbc          # Datenbank-Konsole
bin/kamal app details  # Status
```

---

## Weg B: Docker von Hand

Für Server mit eigenem Reverse-Proxy. Du brauchst Docker auf dem Server und ein Zertifikat, das dein Proxy besorgt.

1. **Credentials erzeugen** wie in [Schritt 2](#schritt-2-eigene-zugangsdaten-credentials-erzeugen) (auf deinem Rechner) und `config/credentials.yml.enc`
   sowie den Inhalt von `config/master.key` bereitstellen.
2. **HTTPS-Erzwingung** aktivieren wie in [Schritt 4](#schritt-4-https-erzwingung-aktivieren). `assume_ssl` sorgt dafür, dass Rails hinter dem Proxy
   HTTPS annimmt.
3. **Image bauen und starten:**

   ```sh
   docker build -t kirchen-hub .

   docker run -d --name kirchen-hub --restart unless-stopped \
     -p 127.0.0.1:3000:80 \
     -e RAILS_MASTER_KEY="<Inhalt von config/master.key>" \
     -e APP_HOST=hub.eure-kirche.de \
     -e SOLID_QUEUE_IN_PUMA=true \
     -v kirchen-hub-storage:/rails/storage \
     kirchen-hub
   ```

   - Der Container lauscht auf Port **80**. Im Beispiel wird er nur lokal auf Port 3000 veröffentlicht.
   - Der benannte Volume `kirchen-hub-storage` hält die Datenbanken. Bei einem Bind-Mount
     (`-v /srv/hub:/rails/storage`) muss das Verzeichnis dem Nutzer mit der UID **1000** gehören
     (`chown 1000:1000 /srv/hub`), denn der Container läuft nicht als root.
4. **Reverse-Proxy** davor schalten. Beispiel mit [Caddy](https://caddyserver.com) (holt Zertifikate automatisch):

   ```
   hub.eure-kirche.de {
       reverse_proxy 127.0.0.1:3000
   }
   ```

   Der Proxy muss den Header `X-Forwarded-Proto: https` weitergeben (Caddy tut das von selbst, bei nginx mit
   `proxy_set_header X-Forwarded-Proto $scheme;`).
5. **Prüfen** wie in [Schritt 8](#schritt-8-prüfen).

Updates: Code aktualisieren, `docker build` wiederholen, Container stoppen, entfernen und mit demselben
`docker run` neu starten. Die Daten im Volume bleiben erhalten.

---

## Registrierung ist offen

Jede Person, die die Adresse deines Hubs kennt, kann sich registrieren und **eine eigene Kirche anlegen**. Es gibt
derzeit keinen Schalter, der die Registrierung schließt. Die Startseite und `/registration/new` sind ohne Login
erreichbar. Wenn nur ausgewählte Personen Zugang haben sollen, kannst du die Pfade `/registration` und
`/registration/new` am Reverse-Proxy sperren, **nachdem** alle gewünschten Konten angelegt sind. Bereits vorhandene
Konten lassen sich weiterhin einer Kirche als Mitglied hinzufügen, siehe [Kirche & Team](../benutzerhandbuch/kirche-und-team.md).

Die Daten verschiedener Kirchen sind voneinander getrennt: Jedes Konto sieht und ändert nur die Kirchen, in denen
es Mitglied ist. Mehr dazu unter [Datenschutz & Sicherheit](../referenz/datenschutz-und-sicherheit.md).

## Checkliste vor dem Livegang

- [ ] DNS-A-Eintrag zeigt auf den Server, `https://…/up` antwortet
- [ ] `assume_ssl` und `force_ssl` aktiv
- [ ] `config/master.key` im Passwortmanager gesichert
- [ ] Volume für `/rails/storage` eingerichtet und [Backup](betrieb.md#backups) geplant
- [ ] SMTP hinterlegt und Test-Mail („Passwort vergessen?“) angekommen
- [ ] `APP_HOST` gesetzt (Links in E-Mails zeigen auf die richtige Domain)
- [ ] Beim ersten Konto: Kirche mit **Webseite** angelegt, damit der Launcher nur dort läuft
- [ ] Launcher auf einer Testseite eingebunden und Formular-Einsendung getestet
