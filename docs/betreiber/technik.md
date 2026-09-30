# Technische Referenz

← [Zur Übersicht](../README.md) · Siehe auch: [Schnittstellen](schnittstellen.md)

Für Betreiber und Entwickler: Aufbau der Anwendung, Datenmodell und Routen.

## Technologie

| Baustein | Einsatz |
| --- | --- |
| **Ruby** 4.0.7 · **Rails** 8.1 | Anwendung. Rails-8-Authentifizierung (E-Mail und Passwort, `has_secure_password`) |
| **SQLite** | Datenbank für Anwendungsdaten. Zusätzlich je eine Datei für Cache, Job-Warteschlange und Cable |
| **Solid Queue / Cache / Cable** | Hintergrundjobs, Zwischenspeicher (auch für Rate-Limits) und ActionCable, alles auf SQLite |
| **Puma** + **Thruster** | Webserver. Thruster (Port 80 im Container) reicht an Puma (Port 3000) weiter und liefert Assets komprimiert und gecacht aus |
| **Hotwire** (Turbo, Stimulus) | Interaktivität im Backend, ohne eigenes JavaScript-Framework |
| **Importmap** + **Propshaft** | JavaScript und CSS ohne Build-Schritt (kein Node.js nötig) |
| **SortableJS** | Drag & Drop beim Sortieren |
| **CSS Zero** | Design-Grundlage (Tokens, Utilities, Komponenten), eigene Ergänzungen in `app/assets/stylesheets/app.css` |
| **Docker** + **Kamal 2** | Auslieferung |

Die Oberfläche ist durchgängig Deutsch (`config/locales/de.yml`, Standard-Locale `de`, Zeitzone Berlin).

## Verzeichnisstruktur

```
app/
  controllers/     Backend-Controller. embed_*, public_hubs sind öffentlich (erben von ActionController::Base)
  models/          Church, Hub, Link, Form, FormQuestion, FormSubmission, User, Membership, Session …
                   FormTemplate (Vorlagen), OklchColor (Farbumrechnung), HttpUrl (URL-Prüfung)
  views/embed/     _widget.js.erb = der komplette Launcher (JavaScript, CSS im Shadow DOM), show.js.erb
  views/           Backend-Seiten (ERB), Mail-Vorlagen, PWA-Dateien
  javascript/controllers/   Stimulus-Controller des Backends
  jobs/            PurgeExpiredFormSubmissionsJob
  mailers/         FormSubmissionMailer, PasswordsMailer
config/
  routes.rb        alle Routen
  form_templates.yml   Formular-Vorlagen
  recurring.yml    geplante Jobs (nur Produktion)
  deploy.yml       Kamal-Konfiguration
db/                schema.rb, Migrationen, seeds.rb
public/embed-demo.html   Beispiel-Webseite mit eingebundenem Launcher
test/              Modell-, Controller-, Mailer-, Job- und System-Tests
```

## Datenmodell

```
users ──< memberships >── churches ──1:1── hubs ──< links >── forms (optional)
  │                          │                                   │
  └──< sessions              └──< forms ──< form_questions       └──< form_submissions
```

| Tabelle | Wichtige Spalten |
| --- | --- |
| `users` | `email_address` (einmalig, klein geschrieben), `password_digest`, `name` |
| `sessions` | `user_id`, `ip_address`, `user_agent` |
| `churches` | `name`, `slug` (einmalig), `website_url` |
| `memberships` | `user_id`, `church_id` (zusammen einmalig), `role` (`owner` \| `admin`, Standard `admin`) |
| `hubs` | `church_id` (einmalig), `title`, `public_token` (einmalig, Token im Embed-Code), `enabled`, `primary_color`, `text_color` (oklch), `position` (`right` \| `left`), `button_label`, `button_icon` (`grid`, `menu`, `heart`, `cross`, `link`), `color_scheme` (`light`, `dark`, `auto`), `corner_radius` (0–24) |
| `links` | `hub_id`, `title`, `kind` (`link` \| `form`), `url`, `form_id` (bei Löschung des Formulars auf NULL), `description`, `icon`, `position`, `visible` |
| `forms` | `church_id`, `title`, `intro`, `thank_you_message`, `submit_label`, `notification_emails`, `consent_text`, `privacy_url`, `retention_months` |
| `form_questions` | `form_id`, `kind`, `label`, `help_text`, `required`, `choices` (JSON-Liste), `position` |
| `form_submissions` | `form_id`, `answers` (JSON-Liste mit `question_id`, `label`, `kind`, `value`), `read_at` |

Bemerkungen:

- Beim Anlegen einer Kirche entsteht automatisch der Hub (`title` = Kirchenname, neues `public_token`).
- **Antworten werden mit Fragetext gespeichert** (`answers[].label`). Nachträgliche Änderungen am Formular verändern alte
  Einsendungen nicht.
- Löschen kaskadiert: Kirche → Mitgliedschaften, Hub (mit Links), Formulare (mit Fragen und Einsendungen). Formular löschen setzt die verknüpften Links auf `form_id = NULL`.
- Farben werden intern als `oklch(L% C H)` gespeichert. Der Farbwähler des Browsers liefert Hex, `OklchColor` rechnet um.
- Sortierung: `position` (0-basiert). Das Modul `Positionable` hängt neue Datensätze ans Ende und sortiert bei Drag & Drop neu.

### Rollen und Zugriffsschutz

- `ApplicationController#current_church` ist die per Session gewählte Kirche, die dem Konto gehören muss, sonst die erste Kirche des Kontos.
- Alle Backend-Controller laden Datensätze **ausschließlich über `current_church`** (`current_church.forms.find(…)`, `current_church.hub`).
  Fremde IDs führen zu 404.
- `require_owner` schützt: Kirche ändern/löschen, Mitglieder hinzufügen/entfernen.
- Öffentliche Controller (`EmbedController`, `EmbedSubmissionsController`, `PublicHubsController`) haben keine Anmeldung, aber auch keinen Zugriff auf Backend-Daten außer dem, was sie ausliefern.

## Routen

### Backend (Anmeldung erforderlich)

| Bereich | Routen |
| --- | --- |
| Hub | `GET /hub` (Links), `GET /hub/edit` + `PATCH /hub` (Design/Umschalten), `GET /hub/embed` (Einbinden), `POST /hub/regenerate_token` |
| Links | `GET /hub/links/new`, `POST /hub/links`, `GET /hub/links/:id/edit`, `PATCH/DELETE /hub/links/:id`, `PUT /hub/links/:id/position` |
| Formulare | `/forms` (Index, `new`, `create`, `show` = Fragen, `edit` = Einstellungen, `update`, `destroy`) |
| Fragen | `/forms/:form_id/questions` (`new`, `create`, `edit`, `update`, `destroy`), `PUT …/:id/position` |
| Einsendungen | `GET /forms/:form_id/submissions` (auch `.csv`, `?filter=unread`), `GET …/:id`, `DELETE …/:id`, `PATCH …/:id/toggle_read`, `DELETE …/destroy_all` |
| Kirche | `GET /church/edit`, `PATCH/DELETE /church`, `POST /church/memberships`, `DELETE /church/memberships/:id`, `GET/POST /churches/new`, `PATCH /church_switch` |
| Konto | `GET /account/edit`, `DELETE /account` |

### Ohne Anmeldung

| Route | Zweck |
| --- | --- |
| `GET /` | Startseite (angemeldet: Weiterleitung zu `/hub`) |
| `GET/POST /session`, `DELETE /session` | Anmelden/Abmelden |
| `GET/POST /registration` | Registrierung |
| `/passwords` | Passwort-Reset (anfordern, Link, neues Passwort) |
| `GET /embed/:token.js` | [Embed-Skript](schnittstellen.md#embed-skript) |
| `POST /embed/:token/forms/:form_id/submissions` | [Formular-Einsendung](schnittstellen.md#formular-einsendung) |
| `GET /up` | Health-Check |
| `GET /:slug` | [Öffentliche Hub-Seite](../benutzerhandbuch/eigene-seite.md). Muss die **letzte** Route sein. |

### Reservierte Kurznamen

Da `/:slug` alles unterhalb der Wurzel abfängt, sind diese Namen für Kirchen gesperrt:

`session`, `sessions`, `passwords`, `registration`, `account`, `hub`, `church`, `churches`, `church_switch`, `embed`, `up`,
`forms`, `admin`, `api`, `assets`, `rails`, `cable`, `manifest`, `service-worker`, `icon`, `robots`, `favicon`.

Wird ein neuer Top-Level-Pfad ergänzt, muss er in `Church::RESERVED_SLUGS` stehen.

## Der Launcher (Widget)

`app/views/embed/_widget.js.erb` ist eine selbstständige JavaScript-Datei ohne Abhängigkeiten. Sie wird vom Server
mit den **Daten des Hubs fest eingebettet** (`data = {title, theme, links}`), sodass zur Laufzeit keine weitere Abfrage nötig ist.

- Er hängt ein `<div data-kirchen-hub>` an `document.body` (oder an das Element aus `data-container`), erzeugt ein
  **Shadow DOM** (`mode: open`) und rendert Button, Panel und Formular-Dialog darin.
- Formular-Ablauf: Schritte `intro` → je Frage → `review` → `done`. Zustand liegt im Widget (kein `localStorage`).
- Clientseitige Prüfungen spiegeln `FormQuestion#parse_answer`. Der Server prüft erneut.
- Bedienung: `Esc` schließt Formular bzw. Panel, Klick außerhalb schließt das Panel (nicht im Inline-Modus), Fokusfalle im Formular-Dialog, Scroll-Sperre bei Vollbild.
- Das Widget hört auf das Ereignis `kirchen-hub:update` am Host-Element (`detail.theme`, `detail.title`). Damit aktualisiert
  die Live-Vorschau im Backend ihr Aussehen.
- Ohne `src` am `<script>` (wie in der Vorschau) simuliert es das Absenden.

## Caching

| Was | Verhalten |
| --- | --- |
| Embed-Skript | `Cache-Control: public, max-age=300`, `ETag` aus Hub **und** Kirche, `Vary: Referer` |
| Hub-Änderungen | Jede Änderung an Links, Formularen und Fragen aktualisiert `hubs.updated_at` (`touch`). Dadurch ändert sich der ETag. |
| Öffentliche Hub-Seite | `ETag` aus dem Hub, `Cache-Control: public` (Browser prüfen bei jedem Aufruf nach) |

## Hintergrundjobs und geplante Aufgaben

| Job | Auslöser |
| --- | --- |
| `ActionMailer` Zustellung (`deliver_later`) | Passwort-Reset, neue Einsendung |
| `PurgeExpiredFormSubmissionsJob` | täglich 3:00 Uhr (`config/recurring.yml`, nur Produktion) |
| `SolidQueue::Job.clear_finished_in_batches` | stündlich |

Im Container läuft Solid Queue **im Puma-Prozess**, wenn `SOLID_QUEUE_IN_PUMA` gesetzt ist. Ein separater Job-Server
(`bin/jobs`) ist bei höherer Last möglich.

## Stimulus-Controller (Backend)

| Controller | Aufgabe |
| --- | --- |
| `sortable` | Drag & Drop, sendet `PUT …/position` |
| `theme-preview` | Live-Vorschau auf der Design-Seite |
| `toggle-fields` | Blendet Felder je nach Auswahl ein/aus (Linkart, Fragetyp) |
| `auto-submit` | Sendet Formulare bei Änderung (Launcher-Schalter, Kirchenwechsel) |
| `input-copyable` | Kopieren-Schaltfläche für Einbettungs-Code und Adresse |
| `toggle-class` | Menü auf dem Handy |
| `flash` | Blendet Hinweismeldungen aus |

## Tests und Qualitätssicherung

```sh
bin/rails test           # Modelle, Controller, Mailer, Jobs
bin/rails test:system    # Browser-Tests (Launcher, Formulare, Links, Kirche löschen)
bin/rubocop              # Stil (rubocop-rails-omakase)
bin/brakeman             # statische Sicherheitsanalyse
bin/bundler-audit        # Gem-Schwachstellen
bin/importmap audit      # JavaScript-Schwachstellen
bin/ci                   # Zusammenfassung (config/ci.rb)
```

GitHub Actions (`.github/workflows/ci.yml`) führt Brakeman, Bundler-Audit, Importmap-Audit, RuboCop, Tests und System-Tests aus.
Dependabot ist konfiguriert (`.github/dependabot.yml`).

Wichtig für Tests von Formular-Einsendungen: Die Mindest-Ausfüllzeit lässt sich per
`EmbedSubmissionsController.minimum_fill_time = 0` abschalten (siehe `test/system/forms_test.rb`).
