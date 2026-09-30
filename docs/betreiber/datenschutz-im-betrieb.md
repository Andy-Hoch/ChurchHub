# Datenschutz & Sicherheit im Betrieb

← [Zur Übersicht](../README.md)

Was du als **Betreiber** des Kirchen-Hubs beachten solltest. Die Sicht der Kirchen (welche Daten gespeichert werden,
Empfehlungen für Formulare) steht unter [Datenschutz & Sicherheit](../referenz/datenschutz-und-sicherheit.md). Sie ist
zugleich eine gute Grundlage für Verzeichnis der Verarbeitungstätigkeiten und Auftragsverarbeitungsvertrag.

## Rollenverständnis

Betreibst du den Hub für mehrere Kirchen, verarbeitest du deren Daten typischerweise **im Auftrag**. Schließe mit jeder Kirche einen
Vertrag zur Auftragsverarbeitung ab, wenn das für sie erforderlich ist, und lass dich zur Vertraulichkeit verpflichten. Du hast technisch Zugriff auf die
gesamte Datenbank, auch auf Einsendungen im Klartext.

## Checkliste

- **HTTPS ist Pflicht** (`force_ssl`, siehe [Installation](produktion.md#schritt-4-https-erzwingung-aktivieren)).
- **Server-Logs:** Bei `RAILS_LOG_LEVEL=info` (Standard) schreibt Rails die Parameter jeder Anfrage ins Log. Der Hub
  filtert Parameter mit Namen wie `password`, `email` oder `token` heraus, **nicht aber** die Formular-Antworten
  (`answers`). Dadurch **können Antworten (z. B. Gebetsanliegen) in den Logs erscheinen.** Ergänze deshalb in
  `config/initializers/filter_parameter_logging.rb` den Eintrag `:answers` in der Liste `filter_parameters` und begrenze
  die Log-Aufbewahrung. Lass Logs nie länger als nötig liegen.
- **Backups verschlüsseln** und nur so lange aufbewahren, wie die Löschfristen der Kirchen es zulassen
  ([Backups](betrieb.md#backups)).
- **`config/master.key` geheim halten.** Er schützt die SMTP-Zugangsdaten und weitere Rails-Geheimnisse.
- **Registrierung ist offen** ([Hinweis](produktion.md#registrierung-ist-offen)). Sperre sie bei Bedarf am Reverse-Proxy.
- **Updates einspielen.** Sicherheitsprüfungen sind Teil der CI (`bin/brakeman`, `bin/bundler-audit`, `bin/importmap audit`).
- **Meldeweg für Sicherheitsprobleme:** Nutzer sollen Auffälligkeiten dir melden können. Gib in deiner Einladung an Nutzer eine
  Kontaktadresse an.
- **E-Mail-Versand** einrichten ([Konfiguration](konfiguration.md#e-mail-versand-smtp)), damit Nutzer ihr Passwort selbst
  zurücksetzen können und Benachrichtigungen ankommen.

## Was du Nutzern mitgeben solltest

Damit die [Nutzer-Dokumentation](../benutzerhandbuch/README.md) für sie stimmig ist, teile ihnen mit:

1. die **Adresse** des Hubs (zum Registrieren und Anmelden),
2. **wer der Ansprechpartner** bei Problemen ist (die Doku verweist auf „den Betreiber“),
3. ob **E-Mail-Versand** eingerichtet ist (Passwort-Reset, Benachrichtigungen),
4. wie lange **Sicherungen** aufbewahrt werden und wo der Server steht.
