# Betrieb & Wartung

← [Zur Übersicht](../README.md) · Zurück: [Konfiguration](konfiguration.md)

Alles, was nach dem Livegang anfällt: Updates, Sicherungen, Fehlersuche und Notfall-Maßnahmen.
Die Befehle nutzen Kamal (`bin/kamal …`). Wenn du Docker von Hand betreibst, ersetze sie durch
`docker exec` bzw. `docker logs` auf deinem Container.

## Überwachung

- **Health-Check:** `https://<euer-hub>/up` liefert HTTP 200, wenn die Anwendung läuft. Ein externer Uptime-Dienst
  kann diese Adresse prüfen.
- **Embed-Skript prüfen:** `https://<euer-hub>/embed/<TOKEN>.js` sollte JavaScript liefern. Kommt nur
  `/* Hub nicht gefunden oder deaktiviert */`, ist das Token falsch oder der Launcher ist ausgeschaltet.
- **Logs:** `bin/kamal logs` (live mitlesen) bzw. `docker logs -f kirchen-hub`. Sie werden auf STDOUT geschrieben.

## Updates einspielen

```sh
git pull                 # neuesten Stand holen (bzw. Upstream in deinen Fork mergen)
bin/kamal deploy         # Image bauen, neuen Container starten, umschalten
```

- Datenbank-Migrationen laufen beim Start des neuen Containers automatisch.
- Kamal startet den neuen Container, prüft `/up` und schaltet erst danach um. Der Wechsel geht ohne spürbare Pause.
- Lies vor größeren Updates die Änderungen (`git log`), besonders wenn `config/deploy.yml` oder
  `config/environments/production.rb` betroffen sind: Deine angepassten Werte dürfen beim Mergen nicht verloren gehen.
- **Sichere die Datenbank vor jedem Update** ([Backups](#backups)).

Sicherheits-Updates der Bibliotheken prüft das Projekt in CI mit `bin/bundler-audit`, `bin/importmap audit` und
`bin/brakeman`. Du kannst sie lokal ebenfalls ausführen.

## Backups

### Was muss gesichert werden?

| Datei in `/rails/storage` | Inhalt | Sichern? |
| --- | --- | --- |
| `production.sqlite3` | **Alle Daten**: Konten, Kirchen, Hubs, Links, Formulare, Einsendungen | **Ja, unbedingt** |
| `production_cache.sqlite3` | Zwischenspeicher (u. a. Zähler für die Missbrauchs-Sperren) | nein |
| `production_queue.sqlite3` | Warteschlange für E-Mail-Jobs | nein (nur unerledigte Jobs gehen verloren) |
| `production_cable.sqlite3` | Von Rails vorbereitet, wird nicht genutzt | nein |

Zusätzlich gehört `config/master.key` in deinen Passwortmanager. Er ist nicht Teil der Datenbank.

### Konsistente Sicherung erstellen

SQLite läuft im WAL-Modus. Die Datei `production.sqlite3` **nicht** einfach im laufenden Betrieb kopieren, sondern mit
dem Backup-Befehl von SQLite sichern:

```sh
# Mit Kamal: Sicherung innerhalb des Volumes anlegen
bin/kamal app exec --reuse 'sqlite3 storage/production.sqlite3 ".backup storage/backup.sqlite3"'
```

Die Datei `backup.sqlite3` liegt danach im Volume und muss von dort **auf ein anderes System** kopiert werden. Bei einem
Docker-Volume `kirchen_hub_storage` liegt sie unter
`/var/lib/docker/volumes/kirchen_hub_storage/_data/backup.sqlite3`. Bei Docker von Hand:
`docker exec kirchen-hub sqlite3 storage/production.sqlite3 ".backup storage/backup.sqlite3"` und dann
`docker cp kirchen-hub:/rails/storage/backup.sqlite3 .`.

**Automatisch per Cron** (auf dem Server, Beispiel mit installiertem `sqlite3` und Volume-Pfad wie oben):

```sh
# /etc/cron.d/kirchen-hub-backup – täglich um 2:30 Uhr, 30 Tage aufbewahren
30 2 * * * root sqlite3 /var/lib/docker/volumes/kirchen_hub_storage/_data/production.sqlite3 ".backup '/var/backups/hub-$(date +\%F).sqlite3'" && find /var/backups -name 'hub-*.sqlite3' -mtime +30 -delete
```

Kopiere die Sicherungen zusätzlich **außerhalb des Servers** (anderer Anbieter, Cloud-Speicher, NAS).
Teste die Wiederherstellung einmal, bevor du sie brauchst.

> Sicherungen enthalten alle Einsendungen im Klartext, etwa Gebetsanliegen. Bewahre sie verschlüsselt auf und lösche
> alte Sicherungen. Das gilt auch für die Aufbewahrungsfristen, siehe [Datenschutz & Sicherheit](../referenz/datenschutz-und-sicherheit.md).

### Wiederherstellen

1. Anwendung stoppen (`bin/kamal app stop` bzw. `docker stop kirchen-hub`).
2. Im Volume `production.sqlite3` durch die Sicherung ersetzen. Vorhandene Dateien `production.sqlite3-wal` und
   `production.sqlite3-shm` **löschen**.
3. Eigentümer anpassen: `chown 1000:1000` auf die Datei.
4. Anwendung starten (`bin/kamal app boot` bzw. `docker start kirchen-hub`).

## Passwort zurücksetzen ohne E-Mail

Ist kein SMTP eingerichtet (oder die Person hat keinen Zugriff mehr auf ihr Postfach), setzt der Betreiber das
Passwort in der Rails-Konsole:

```sh
bin/kamal console
```

```ruby
user = User.find_by(email_address: "person@example.org")
user.update!(password: "ein-neues-passwort-123")   # mindestens 8 Zeichen
user.sessions.destroy_all                            # meldet die Person überall ab
```

Ein **Passwort ändern innerhalb des Kontos** gibt es derzeit nicht. Die Person kann später über „Passwort vergessen?“
ein eigenes Passwort setzen, sobald E-Mail funktioniert.

## Weitere Wartungsaufgaben in der Konsole

```ruby
# Wer ist Mitglied der Kirche „Demo Gemeinde“?
Church.find_by(slug: "demo-gemeinde").memberships.includes(:user).map { |m| [m.user.email_address, m.role] }

# Einem Mitglied die Rolle Besitzer geben (z. B. wenn der Besitzer nicht mehr erreichbar ist)
Church.find_by(slug: "demo-gemeinde").memberships.joins(:user).find_by(users: { email_address: "person@example.org" }).owner!

# Ein Konto vollständig löschen (Kirchen ohne weitere Mitglieder werden mitgelöscht, sonst wird der Besitz übertragen)
User.find_by(email_address: "person@example.org").close_account!

# Abgelaufene Einsendungen sofort löschen (läuft sonst täglich um 3:00 Uhr)
PurgeExpiredFormSubmissionsJob.perform_now
```

## Fehlersuche im Betrieb

| Symptom | Mögliche Ursache und Lösung |
| --- | --- |
| Seite nicht erreichbar / Zertifikatsfehler | DNS zeigt nicht auf den Server, oder Ports 80/443 sind gesperrt. Let's Encrypt braucht beides. Danach `bin/kamal proxy reboot` bzw. neu deployen. |
| „Endlose“ Weiterleitungen (Redirect-Schleife) | `force_ssl` ist aktiv, aber `assume_ssl` fehlt oder der Proxy reicht `X-Forwarded-Proto` nicht durch. |
| Nach jedem Deployment sind alle Daten weg | Das Volume für `/rails/storage` fehlt oder hat sich geändert. Prüfe den Abschnitt `volumes:` in der `deploy.yml`. |
| `ActiveSupport::MessageEncryptor::InvalidMessage` / Fehler beim Start | `RAILS_MASTER_KEY` passt nicht zu `config/credentials.yml.enc`. Bei Kamal: Steht `config/master.key` lokal, wenn du deployst? |
| Mails kommen nicht an | SMTP prüfen ([Konfiguration](konfiguration.md#e-mail-versand-smtp)). Läuft der Job-Runner (`SOLID_QUEUE_IN_PUMA=true`)? Fehler stehen im Log (`bin/kamal logs`). |
| Links in E-Mails führen zu `example.com` | `APP_HOST` nicht gesetzt. |
| Eine Formular-Einsendung geht nicht ein | Siehe [Häufige Fragen](../referenz/faq.md#formulare-und-einsendungen). |
| Launcher erscheint nicht auf der Webseite | Siehe [Häufige Fragen](../referenz/faq.md#launcher-erscheint-nicht). |
