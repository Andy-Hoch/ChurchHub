# Datenschutz & Sicherheit

← [Zur Übersicht](../README.md)

Diese Seite beschreibt, **welche Daten der Kirchen-Hub verarbeitet**, wie sie geschützt sind und was Betreiber und
Kirchen beachten sollten. Sie ist eine technische Beschreibung und **keine Rechtsberatung**. Für die rechtliche
Bewertung (DSGVO, kirchliche Datenschutzgesetze wie KDG oder DSG-EKD) wende dich an eure Datenschutzbeauftragte.

## Welche Daten werden gespeichert?

| Wer | Daten | Zweck |
| --- | --- | --- |
| **Mitglieder** (Backend-Nutzer) | Name, E-Mail-Adresse, Passwort (nur als Hash, nie im Klartext), Zeitpunkte | Anmeldung, Team-Anzeige, Passwort-Reset |
| **Anmeldungen (Sitzungen)** | IP-Adresse, Browser-Kennung (User-Agent), Zeitpunkt, Cookie-Kennung | Angemeldet bleiben, Sitzungen beim Passwort-Reset beenden |
| **Kirche** | Name, Kurzname, Webseite | Betrieb des Hubs |
| **Hub und Links** | Überschrift, Design, Titel, Adressen, Beschreibungen | Inhalt des Launchers. Öffentlich abrufbar. |
| **Formulare** | Fragen, Texte, Benachrichtigungsadressen, Einwilligungstext | Betrieb der Formulare |
| **Einsendungen** | Alle Antworten der Besucher samt Fragetext, Eingangszeit, „gelesen“-Status | Rückmeldungen der Gemeinde. Nur für Mitglieder sichtbar. |

Was **nicht** gespeichert wird:

- **Keine Besucher-Statistik.** Der Hub zählt weder Aufrufe noch Klicks und bindet keine Tracking-Dienste ein.
- **Keine IP-Adresse und kein Browser-Merkmal bei Einsendungen.** Eine Einsendung besteht nur aus den Antworten
  und dem Zeitpunkt.
- **Keine Cookies für Besucher eurer Webseite.** Der Launcher setzt keine Cookies und nutzt keinen lokalen Speicher.
  Formular-Einsendungen werden ohne Cookies gesendet. Cookies gibt es nur im Backend (Anmeldung).
- Technisch unvermeidbar: Beim Laden des Skripts und beim Absenden eines Formulars übermittelt der Browser wie bei
  jeder Anfrage die **IP-Adresse** (und das Referer-Merkmal) an den Hub-Server. Sie können dort im Server-Log stehen (siehe
  [Empfehlungen für Betreiber](#empfehlungen-für-betreiber)). Für die Rate-Limits merkt sich der Hub IP-Adressen vorübergehend im Zwischenspeicher.

## Wer sieht was?

- **Öffentlich** sind nur: das Embed-Skript (mit Titel, Design, Links und Formularfragen) und die
  [eigene Hub-Seite](../benutzerhandbuch/eigene-seite.md). Beides enthält die **Inhalte, die ihr selbst angelegt habt**.
- **Einsendungen und alles im Backend** sehen nur angemeldete **Mitglieder der jeweiligen Kirche**. Andere Kirchen auf
  derselben Instanz haben keinen Zugriff. Jede Abfrage im Backend ist auf die Kirche des Kontos beschränkt.
- **Der Betreiber** des Servers hat technisch Zugriff auf die Datenbank (siehe [Betrieb & Wartung](../setup/betrieb.md)). Regelt das
  organisatorisch (Verpflichtung zur Vertraulichkeit, ggf. Auftragsverarbeitung, wenn jemand den Hub für andere Kirchen betreibt).
- **E-Mail-Benachrichtigungen** enthalten aus Datenschutzgründen **keine Antworten**, sondern nur einen Link ins Backend.

## Empfehlungen für Kirchen

1. **Einwilligung einholen:** Nutze bei Formularen mit persönlichen Angaben den **Einwilligungstext** und den Link zur
   **Datenschutzerklärung** ([Formulare](../benutzerhandbuch/formulare.md#einstellungen-eines-formulars)).
2. **Datenschutzerklärung der Webseite ergänzen:** Erwähnt den Launcher, die Formulare, welche Daten dabei entstehen, wer
   sie erhält und wo der Hub gehostet wird.
3. **Löschfristen setzen:** Stelle pro Formular die **automatische Löschung** ein
   ([Einsendungen](../benutzerhandbuch/einsendungen.md#automatisches-löschen)). Gebetsanliegen brauchen oft nur wenige Monate.
4. **Nur sparsame Fragen stellen:** Frage nur ab, was ihr wirklich braucht.
5. **Team klein halten:** Jedes Mitglied sieht alle Einsendungen aller Formulare der Kirche.
6. **Sicheren Umgang mit Exporten:** CSV-Dateien und Sicherungen enthalten Klartext.
7. **Betroffenenrechte:** Auskunft und Löschung könnt ihr über das Backend erfüllen. Einzelne Einsendungen lassen sich
   lesen und löschen.
8. **Kirche/Konto löschen** entfernt die Daten vollständig ([Konto](../benutzerhandbuch/konto-und-anmeldung.md#konto-löschen)).
   Beachte Sicherungen des Betreibers: Dort bleiben Daten bis zum Ablauf der Sicherungs-Aufbewahrung.

## Empfehlungen für Betreiber

- **HTTPS ist Pflicht** (`force_ssl`, siehe [Installation](../setup/produktion.md#schritt-4-https-erzwingung-aktivieren)).
- **Server-Logs:** Bei `RAILS_LOG_LEVEL=info` (Standard) schreibt Rails die Parameter jeder Anfrage ins Log. Der Hub
  filtert Parameter mit Namen wie `password`, `email` oder `token` heraus, **nicht aber** die Formular-Antworten
  (`answers`). Dadurch **können Antworten (z. B. Gebetsanliegen) in den Logs erscheinen.** Ergänze deshalb in
  `config/initializers/filter_parameter_logging.rb` den Eintrag `:answers` in der Liste `filter_parameters` und begrenze
  die Log-Aufbewahrung. Lass Logs nie länger als nötig liegen.
- **Backups verschlüsseln** und nur so lange aufbewahren, wie die Löschfristen es zulassen
  ([Backups](../setup/betrieb.md#backups)).
- **`config/master.key` geheim halten.** Er schützt die SMTP-Zugangsdaten und weitere Rails-Geheimnisse.
- **Registrierung ist offen** ([Hinweis](../setup/produktion.md#registrierung-ist-offen)). Sperre sie bei Bedarf am Reverse-Proxy.
- **Updates einspielen.** Sicherheitsprüfungen sind Teil der CI (`bin/brakeman`, `bin/bundler-audit`, `bin/importmap audit`).

## Sicherheitsmaßnahmen im Überblick

| Bereich | Maßnahme |
| --- | --- |
| **Passwörter** | Speicherung als bcrypt-Hash (`has_secure_password`), mindestens 8 Zeichen |
| **Sitzungen** | signiertes, `HttpOnly`-Cookie mit `SameSite=Lax`, bei aktiver HTTPS-Erzwingung zusätzlich `Secure`. Passwort-Reset beendet alle Sitzungen. |
| **Brute-Force-Schutz** | Rate-Limits für Anmeldung, Registrierung, Passwort-Reset und Konto-Löschung (je 10 pro 3 Minuten und IP) |
| **Passwort-Reset** | Zeitlich begrenzter, signierter Link. Antwort verrät nicht, ob eine Adresse registriert ist. |
| **Mandantentrennung** | Backend-Zugriffe laufen immer über die Kirche der angemeldeten Person; Formulare, Links, Fragen und Einsendungen anderer Kirchen sind nicht adressierbar |
| **CSRF-Schutz** | Standard-Schutz von Rails für alle Backend-Formulare |
| **Öffentliche Formular-Schnittstelle** | Nur Formulare, die im Hub verknüpft, sichtbar und bei aktivem Launcher erreichbar sind. Kein Cookie/CSRF nötig, dafür Honeypot, Mindest-Ausfüllzeit (3 s), Rate-Limit (10 pro 10 Minuten und IP) und Prüfung der Antworten auf dem Server |
| **Webseiten-Beschränkung** | Optional: Embed-Skript und Einsendungen nur von der hinterlegten Domain ([Details und Grenzen](../benutzerhandbuch/einbinden.md#beschränkung-auf-eure-webseite)) |
| **Sichere Links** | Nur `http(s)`-Adressen für Links und Datenschutz-Link, auch im Launcher geprüft (kein `javascript:` oder `data:`) |
| **XSS-Schutz** | Inhalte werden im Launcher als Text eingefügt, nicht als HTML. Die Daten im Skript sind für JavaScript maskiert (`json_escape`). |
| **Isolation** | Launcher im Shadow DOM: kein Zugriff auf und keine Beeinflussung durch die Webseite eurer Kirche über CSS |
| **CSV-Export** | Schutz vor Formel-Injection in Tabellenkalkulationen |
| **Container** | Docker-Image läuft als Nicht-Root-Nutzer |
| **Einbettungs-Code** | Lässt sich jederzeit [neu erzeugen](../benutzerhandbuch/einbinden.md#code-neu-erzeugen), der Launcher lässt sich [abschalten](../benutzerhandbuch/einbinden.md#launcher-aktiv--launcher-deaktivieren) |

## Was das Token ist – und was nicht

Das Token im Einbettungs-Code (`/embed/<TOKEN>.js`) ist **kein Geheimnis**: Jeder Besucher eurer Webseite kann es im
Quelltext lesen. Es identifiziert euren Hub und erlaubt nur das, was öffentlich ohnehin sichtbar ist (Skript
abrufen, Formulare abschicken). **Es gibt keinen Zugang zum Backend und keine Einsendungen preis.** Die
[Webseiten-Beschränkung](../benutzerhandbuch/einbinden.md#beschränkung-auf-eure-webseite) verhindert bequeme Fremdnutzung, das Neu-Erzeugen des Codes beendet
Missbrauch.

## Sicherheitslücken melden

Hast du eine Sicherheitslücke gefunden? Bitte melde sie **nicht öffentlich** in einem Issue. Ein eigener Meldeweg ist im
Repository derzeit nicht hinterlegt. Kontaktiere die Maintainer daher direkt und vertraulich (zum Beispiel über die
Kontaktdaten im GitHub-Profil).
