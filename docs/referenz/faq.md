# Häufige Fragen & Fehlerbehebung

← [Zur Übersicht](../README.md)

## Launcher erscheint nicht

Gehe die Punkte der Reihe nach durch:

1. **Ist der Code auf der Seite?** Öffne die Webseite, im Browser „Seitenquelltext anzeigen“ und suche nach `/embed/`.
   Steht die Zeile dort nicht, wurde sie nicht gespeichert bzw. der Seiten-Cache (WordPress-Cache-Plugin, CDN) liefert
   noch die alte Version. Cache leeren.
2. **Öffne das Skript direkt im Browser:** `https://<euer-hub>/embed/<TOKEN>.js`. Es gibt drei Möglichkeiten:
   - **Viel JavaScript-Code** → alles in Ordnung. Das Problem liegt bei der Webseite (weiter mit Punkt 3).
   - `/* Hub nicht gefunden oder deaktiviert */` → Der Token stimmt nicht (nach [Neu-Erzeugen](../benutzerhandbuch/einbinden.md#code-neu-erzeugen)
     ist der alte ungültig), oder der [Launcher ist ausgeschaltet](../benutzerhandbuch/einbinden.md#launcher-aktiv--launcher-deaktivieren).
   - `/* Launcher ist für diese Webseite nicht freigegeben */` → Die [Webseiten-Beschränkung](../benutzerhandbuch/einbinden.md#beschränkung-auf-eure-webseite)
     greift. Diese Antwort siehst du nur, wenn eine
     **fremde Seite** das Skript anfordert. Beim direkten Öffnen der Skript-Adresse in der Adresszeile sendet der Browser
     keinen Referer, dort erscheint dann normaler Code. Es bedeutet: Die hinterlegte Domain passt nicht zur Domain eurer Webseite.
3. **Beschränkung prüfen:** Unter *Einbinden* steht, für welche Domain der Launcher freigegeben ist. Passt sie zur
   Adresse in der Browserzeile (auch `www.` und Subdomains sind erlaubt, andere Domains nicht)? Zum Test das Feld unter
   *Kirche → Einstellungen* kurz leeren.
4. **Browser-Konsole öffnen (F12):** Meldet sie „Kirchen-Hub: Der Launcher ist für diese Webseite nicht freigegeben.“,
   greift die Beschränkung im Skript selbst. Meldungen wie „blocked by Content Security Policy“ deuten auf eine
   [strenge CSP](../benutzerhandbuch/einbinden.md#webseiten-mit-strenger-content-security-policy) hin.
5. **Werbeblocker / Tracking-Schutz:** Selten blockieren Erweiterungen Skripte mit Namen wie „embed“. Test im
   privaten Fenster ohne Erweiterungen.
6. **Zu frisch geändert?** Änderungen brauchen bis zu 5 Minuten. Harter Reload: Strg/Cmd + Shift + R.
7. **HTTPS:** Läuft eure Webseite auf HTTPS, muss auch der Hub auf HTTPS laufen (sonst „Mixed Content“).

## Der Launcher zeigt nicht die neuen Links / das neue Design

Der Browser darf das Skript bis zu **5 Minuten** zwischenspeichern. Nach dieser Zeit (oder mit hartem Reload) ist alles aktuell.
Prüfe außerdem, ob der Link **sichtbar** geschaltet ist und (bei Formular-Buttons) das Formular noch existiert.

## Links & Design

**Warum wird mein Link abgelehnt?** Erlaubt sind nur Adressen, die mit `http://` oder `https://` beginnen und eine Domain haben.
`mailto:` und `tel:` funktionieren nicht. Nutze ein [Kontakt-Formular](../benutzerhandbuch/formulare.md).

**Kann ich das Panel-Design komplett selbst gestalten (eigenes CSS)?** Nein. Der Launcher ist bewusst abgeschottet (Shadow DOM).
Anpassbar sind Farben, Symbol, Position, Farbschema, Eckenrundung und Texte unter [Design](../benutzerhandbuch/design.md).

**Kann ich die Schrift ändern?** Der Launcher nutzt die Systemschrift des Geräts.

**Der Launcher verdeckt einen anderen Button (Chat, Cookie-Hinweis).** Wechsle unter *Design* die **Position** nach links.

**Wie viele Links sind möglich?** Es gibt kein festes Limit. Die Übersichtlichkeit ist eher die Grenze.

## Formulare und Einsendungen

**Ich sehe „Vielen Dank!“, aber im Backend fehlt die Einsendung.**
Der Spam-Schutz verwirft Einsendungen still, wenn das Formular in weniger als **3 Sekunden** nach dem Öffnen abgeschickt wird oder das
unsichtbare Feld ausgefüllt ist (Bots sollen nicht merken, dass sie abgewiesen wurden). Beim Testen also kurz warten und
tatsächlich von Hand ausfüllen. Prüfe außerdem, ob der Filter *Ungelesen* aktiv ist.

**Das Formular zeigt eine Fehlermeldung beim Absenden.**

| Meldung | Bedeutung |
| --- | --- |
| „Das Absenden hat nicht geklappt. Bitte prüfe deine Verbindung und versuche es erneut.“ | Netzwerkproblem oder Serverfehler. Eingaben bleiben erhalten. |
| „Zu viele Einsendungen. Bitte versuche es später noch einmal.“ | Mehr als 10 Einsendungen in 10 Minuten von derselben IP-Adresse (z. B. ein Gemeindenetz mit gemeinsamer Adresse beim Testen). |
| „Das Formular ist für diese Webseite nicht freigegeben.“ | Die [Webseiten-Beschränkung](../benutzerhandbuch/einbinden.md#beschränkung-auf-eure-webseite) lässt diese Domain nicht zu. |
| „Formular nicht gefunden.“ | Das Formular ist nicht (mehr) mit einem sichtbaren Link im Hub verknüpft, wurde gelöscht oder der Launcher ist deaktiviert. |
| „Bitte stimme der Datenverarbeitung zu.“ | Das Einwilligungs-Kästchen auf der Übersichtsseite fehlt. |
| „Bitte beantworte diese Frage.“ o. Ä. | Pflichtfrage oder ungültige Eingabe. Der Launcher springt zur betroffenen Frage. |

**Ein Formular ist nicht im Launcher zu sehen.** Ein Formular erscheint nur über einen Link „Formular öffnen“, der
**sichtbar** ist. Prüfe unter *Links*, ob es einen solchen Eintrag gibt und ob er nicht „Ausgeblendet“ ist. Die
[eigene Hub-Seite](../benutzerhandbuch/eigene-seite.md) zeigt keine Formulare.

**Ich bekomme keine E-Mail-Benachrichtigung.**
1. Sind unter *Formular → Einstellungen → E-Mail an* gültige Adressen eingetragen?
2. Hat der Betreiber des Hubs den E-Mail-Versand eingerichtet? Frag ihn im Zweifel.
3. Spam-Ordner prüfen. Den Absender legt der Betreiber fest.

**Warum steht die Antwort nicht in der E-Mail?** Bewusst aus Datenschutzgründen, siehe [Einsendungen](../benutzerhandbuch/einsendungen.md#benachrichtigung-per-e-mail).

**Kann ich auf eine Einsendung im Hub antworten?** Nein. Der Hub sammelt Rückmeldungen. Antworten erfolgen über die
angegebenen Kontaktdaten (E-Mail, Telefon).

**Kann ich Einsendungen einer Frage bearbeiten?** Nein, Einsendungen sind unveränderlich. Sie lassen sich löschen.

**Wohin verschwinden alte Einsendungen?** Wenn eine **Aufbewahrungsdauer** eingestellt ist, löscht der Hub sie
automatisch ([Automatisches Löschen](../benutzerhandbuch/einsendungen.md#automatisches-löschen)).

**Im Excel-Export stehen die Umlaute falsch / alles in einer Spalte.** Öffne die Datei über *Daten → Aus Text/CSV*
mit UTF-8 und Trennzeichen Semikolon. In deutschen Excel-Installationen klappt das normalerweise per Doppelklick.

## Konto & Team

**Ich habe mein Passwort vergessen und bekomme keine E-Mail.** Prüfe den Spam-Ordner. Kommt weiterhin nichts an, ist
womöglich kein E-Mail-Versand eingerichtet. Wende dich an den Betreiber des Hubs, er kann dein Passwort zurücksetzen.

**Der Link zum Zurücksetzen ist „ungültig oder abgelaufen“.** Er gilt nur kurz (standardmäßig 15 Minuten) und ist einmalig
an das aktuelle Passwort gebunden. Fordere einen neuen an.

**Kollegin hinzufügen: „Kein Konto mit dieser E-Mail-Adresse gefunden“.** Sie muss sich zuerst über die
Registrierungsseite selbst registrieren. Beachte, dass die E-Mail-Adresse genau übereinstimmen muss. Groß-/Kleinschreibung
spielt keine Rolle.

**Ich sehe die Einstellungen der Kirche nur ausgegraut.** Sie sind dem **Besitzer** vorbehalten
([Rollen](../benutzerhandbuch/kirche-und-team.md#rollen)).

**Ich kann meine Kirche nicht löschen.** Es ist deine einzige. Lösche stattdessen dein Konto, oder lege zuerst eine
weitere Kirche an. Du musst außerdem Besitzer sein und den Namen exakt eintippen.

**Kann ich meine E-Mail-Adresse oder meinen Namen ändern?** Derzeit nicht über die Oberfläche.

**Wie viele Personen können sich anmelden?** Beliebig viele. Es gibt keine Nutzer- oder Kirchenbegrenzung.

## Sonstiges

**Wer ist „der Betreiber“?** Die Stelle, die den Kirchen-Hub bereitstellt und euch die Adresse gegeben hat. Sie kümmert sich um
Server, Sicherungen und E-Mail-Versand und ist euer Ansprechpartner bei technischen Problemen.

**Auf welchem Endgerät funktioniert das Backend?** In modernen Browsern (Chrome, Edge, Safari, Firefox in aktuellen Versionen),
Desktop wie Handy. Ältere Browser bekommen eine Hinweisseite („Nicht unterstützter Browser“). Für den **Launcher** auf
eurer Webseite gibt es keine Versionssperre. Er braucht aber Shadow-DOM-Unterstützung, die alle gängigen aktuellen Browser bieten.

**Gibt es eine Statistik, wie oft geklickt wird?** Noch nicht. „Klickstatistiken“ stehen auf der Liste „Geplant“ im [README](../../README.md).

**Kann ich den Launcher für mehrere Webseiten nutzen?** Ohne [Webseiten-Beschränkung](../benutzerhandbuch/einbinden.md#beschränkung-auf-eure-webseite)
ja, ein Code funktioniert auf beliebig vielen Seiten. Alle zeigen denselben Inhalt. Mit Beschränkung ist nur eine Domain (samt Subdomains) möglich.
Für unterschiedliche Inhalte pro Webseite legt ihr je eine Kirche an.

**Wo melde ich Fehler oder wünsche Funktionen?** Beim Betreiber des Hubs.
