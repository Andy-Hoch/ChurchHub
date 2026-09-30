# Auf der Webseite einbinden

← [Benutzerhandbuch](README.md)

Unter **Hub → Einbinden** findest du alles, um den Launcher auf euren Webseiten anzuzeigen.

## Der Einbettungs-Code

```html
<script src="https://<adresse-des-hubs>/embed/DEIN_TOKEN.js" async></script>
```

Im Backend steht die Zeile **fertig mit deiner Adresse und deinem Token** in einem Feld. Ein Klick auf das
Kopieren-Symbol legt sie in die Zwischenablage.

### Einfügen

Füge die Zeile **einmal pro Seite** vor dem schließenden `</body>`-Tag ein, am besten in einen Bereich, der auf allen
Seiten geladen wird (Fußbereich bzw. Vorlage). Das funktioniert mit jeder Seite, die eigenes HTML erlaubt.
Die Bezeichnungen der Menüs unterscheiden sich je nach System und Version, typische Orte sind:

| System | Wo einfügen |
| --- | --- |
| **WordPress** | Ein Plugin für Header/Footer-Skripte (z. B. „WPCode“ oder „Insert Headers and Footers“) → Bereich *Footer*. Alternativ in `footer.php` des (Child-)Themes vor `</body>`. |
| **Squarespace** | *Einstellungen → Erweitert → Code-Einfügung → Footer* (erfordert einen Tarif mit Code-Einfügung). |
| **Wix** | *Einstellungen → Benutzerdefinierter Code → Code hinzufügen*, Platzierung „Body – Ende“, für alle Seiten. |
| **Webflow** | *Projekteinstellungen → Custom Code → Footer Code*. |
| **Jimdo** | Einstellungen → Header/Footer-Code bzw. ein HTML-/Widget-Element (je nach Tarif). |
| **Eigenes HTML / Baukasten** | Direkt in die Vorlage vor `</body>`. |

Speichere und rufe die Webseite auf. Unten rechts (bzw. links) sollte der Button erscheinen. Falls nicht: die
Hinweise unter [Häufige Fragen](../referenz/faq.md#launcher-erscheint-nicht).

### Was passiert im Browser?

- Das Skript lädt **asynchron** und bremst die Webseite nicht.
- Der Launcher läuft in einem **Shadow DOM**: Das Design der Webseite kann ihn nicht verändern und er verändert die
  Webseite nicht.
- **Bedienung:** Klick auf den Button öffnet das Panel. Schließen mit dem X, mit der **Esc-Taste** oder einem Klick
  neben das Panel. Alles ist per Tastatur bedienbar. In Formularen bleibt der Fokus im Dialog.
- **Vollbild** auf dem Handy, siehe [Design anpassen](design.md#verhalten-auf-dem-handy).
- Der Launcher setzt **keine Cookies** und nutzt keinen lokalen Speicher. Einzige Datenübertragung ist das Laden des
  Skripts und – auf Wunsch des Besuchers – das Absenden eines Formulars.

## Beschränkung auf eure Webseite

Standardmäßig lässt sich der Einbettungs-Code auf **jeder** Webseite verwenden. Wer den Code kennt (er steht im
Quelltext eurer Seite), könnte ihn also auch woanders einsetzen. Um das zu verhindern, hinterlegst du die
Adresse eurer Webseite:

- bei der [Registrierung](konto-und-anmeldung.md#registrieren) oder
- unter **Kirche → Einstellungen → Webseite** (nur Besitzer, siehe [Kirche & Team](kirche-und-team.md)).

Auf der Seite *Einbinden* steht dann, für welche Domain der Launcher freigegeben ist.

**Regeln:**

| Eingabe | Ergebnis |
| --- | --- |
| `https://kirche-musterstadt.de` | erlaubt: `kirche-musterstadt.de`, `www.kirche-musterstadt.de` und alle Subdomains wie `gemeinde.kirche-musterstadt.de` |
| `kirche-musterstadt.de` (ohne `https://`) | wird automatisch zu `https://kirche-musterstadt.de` ergänzt |
| `www.kirche-musterstadt.de` | ein führendes `www.` wird ignoriert, es gilt wie oben die ganze Domain |
| leer | keine Beschränkung, Einbindung überall möglich |

- Nur der **Domainname** zählt. Pfad und Port der Adresse spielen keine Rolle.
- Ungültig sind Adressen ohne Punkt in der Domain (Ausnahme: `localhost`) und Adressen mit Benutzername/Passwort.
- Es lässt sich **eine** Domain (plus Subdomains) hinterlegen. Betreibt ihr mehrere unterschiedliche Domains,
  lasst das Feld leer.
- Eine **Testumgebung** unter anderer Domain (z. B. eine Staging-Seite) funktioniert bei aktiver Beschränkung nicht.
  Leert das Feld währenddessen oder nutzt die Demo-Seite.

**Wie die Prüfung funktioniert:** Der Hub vergleicht die Webseite, die den Code anfordert (Referer), mit der
hinterlegten Domain und liefert für fremde Seiten ein leeres Skript. Zusätzlich prüft das Skript selbst noch einmal
die Adresse der Seite, auf der es läuft. Auch Formular-Einsendungen von fremden Seiten werden abgelehnt.

> Das ist ein Schutz gegen versehentliche oder gedankenlose Nutzung, **keine** Zugangskontrolle im Sinne der
> Kryptographie: Ein gezielt gebauter Client kann einen Referer vortäuschen. Es verhindert aber, dass sich fremde
> Webseiten mit eurem Launcher schmücken. Mehr dazu in [Datenschutz & Sicherheit](../referenz/datenschutz-und-sicherheit.md).

## Launcher aktiv / Launcher deaktivieren

Der Schalter **„Launcher aktiv“** wirkt sofort und ohne Speichern:

- **Aus:** Der Launcher verschwindet von allen Webseiten (spätestens nach dem Zwischenspeicher von 5 Minuten).
  Formulare nehmen keine Einsendungen mehr an und die [eigene Hub-Seite](eigene-seite.md) ist nicht mehr erreichbar.
  Der Einbettungs-Code auf eurer Seite kann bleiben.
- **An:** Alles läuft wieder wie zuvor. Nichts geht durch das Ausschalten verloren.

Praktisch für Wartungsarbeiten oder wenn ihr den Launcher zeitweise nicht zeigen wollt.

## Code neu erzeugen

Unter **Code neu erzeugen** ersetzt du das Token im Einbettungs-Code durch ein neues.

- Der **alte Code funktioniert sofort nicht mehr**. Der Launcher verschwindet von allen Seiten, die noch den alten
  Code verwenden – auch von eurer eigenen, bis ihr das neue Snippet eingesetzt habt.
- Danach also: Neuen Code kopieren und **auf eurer Webseite austauschen**.
- Nutze das nur, wenn der Code missbraucht wird, etwa weil ihn jemand auf einer fremden Seite eingebunden hat und
  die [Webseiten-Beschränkung](#beschränkung-auf-eure-webseite) nicht genügt.
- Die Adresse der [eigenen Hub-Seite](eigene-seite.md) bleibt gleich. Sie hängt am Kurznamen, nicht am Token.
- Ein Bestätigungsdialog verhindert versehentliches Auslösen.

## Zwischenspeicher: Warum erscheinen Änderungen nicht sofort?

Das Skript wird von Browsern (und ggf. einem vorgeschalteten CDN) bis zu **5 Minuten** zwischengespeichert. Das
macht euren Launcher schnell. Neue Links, ein neues Design oder ein deaktivierter Launcher
sind deshalb nach spätestens etwa 5 Minuten bei allen Besuchern sichtbar.

## Erweiterte Optionen (optional)

Das Skript versteht zwei Attribute am `<script>`-Tag. Sie sind vor allem für die Vorschau im Backend gedacht,
lassen sich aber auch selbst nutzen:

| Attribut | Wirkung |
| --- | --- |
| `data-open="true"` | Das Panel ist beim Laden bereits geöffnet. |
| `data-container="#mein-element"` | Der Launcher wird **innerhalb dieses Elements** angezeigt statt schwebend auf der Seite. Das Element braucht `position: relative` und eine Höhe. In dieser Darstellung sind Vollbild und Scroll-Sperre abgeschaltet. |

```html
<script src="https://<adresse-des-hubs>/embed/DEIN_TOKEN.js" data-open="true" async></script>
```

## Webseiten mit strenger Content-Security-Policy

Setzt eure Webseite eine Content-Security-Policy ein, muss sie den Hub erlauben, sonst blockiert der Browser den Launcher:

- `script-src`: die Domain eures Hubs (zum Laden des Skripts)
- `connect-src`: die Domain eures Hubs (zum Absenden von Formularen)
- ggf. `style-src 'unsafe-inline'`, denn der Launcher fügt seine Formatierung als `<style>`-Element in sein Shadow DOM ein
