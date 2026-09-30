# Schnittstellen

← [Zur Übersicht](../README.md) · Siehe auch: [Technische Referenz](technik.md)

Die **öffentlichen** HTTP-Schnittstellen des Kirchen-Hubs. Sie werden vom Launcher auf euren Webseiten genutzt und sind
ohne Anmeldung erreichbar. `<host>` steht für die Domain eures Hubs, `<token>` für das Token aus dem Einbettungs-Code.

## Embed-Skript

```
GET https://<host>/embed/<token>.js
```

Liefert den Launcher als JavaScript, mit den aktuellen Daten des Hubs fest eingebettet. Die Endung `.js` ist Pflicht.

**Antworten**

| Fall | Antwort |
| --- | --- |
| Token unbekannt oder Hub deaktiviert | `200` mit `/* Hub nicht gefunden oder deaktiviert */` |
| Webseiten-Beschränkung aktiv und anfragende Seite (Referer) nicht erlaubt | `200` mit `/* Launcher ist für diese Webseite nicht freigegeben */` |
| Sonst | `200` mit dem Launcher-Skript. `304`, wenn der `ETag` (`If-None-Match`) noch passt |

Unbekannte Tokens liefern also **kein** `404`, damit auf Webseiten keine Fehler in der Konsole entstehen.

**Header:** `Cache-Control: public, max-age=300`, `ETag`, `Vary: Referer`. Die Antwort darf 5 Minuten zwischengespeichert werden.

**Ohne Referer** (z. B. bei `referrerpolicy="no-referrer"`) liefert der Server das Skript aus. Bei aktiver Beschränkung prüft dann
das Skript selbst `location.hostname`.

### Attribute am `<script>`-Tag

| Attribut | Wirkung |
| --- | --- |
| `data-open="true"` | Panel beim Laden geöffnet |
| `data-container="<CSS-Selektor>"` | Launcher innerhalb dieses Elements statt schwebend anzeigen |

### Nutzdaten im Skript

Das Skript enthält dieses JSON (Auszug):

```json
{
  "title": "Demo Gemeinde",
  "theme": {
    "primaryColor": "oklch(21.03% 0.0059 285.89)",
    "textColor": "oklch(100% 0 0)",
    "position": "right",
    "buttonLabel": "Links",
    "buttonIcon": "grid",
    "colorScheme": "light",
    "cornerRadius": 12
  },
  "links": [
    { "title": "Termine", "description": "…", "icon": "📅", "type": "link", "url": "https://example.com/termine" },
    {
      "title": "Gebetsanliegen", "icon": "🙏", "type": "form",
      "form": {
        "id": 1, "title": "Gebetsanliegen", "intro": "…", "thankYou": "…", "submitLabel": "Anliegen senden",
        "consentText": "…", "privacyUrl": "https://…",
        "questions": [
          { "id": 1, "kind": "long_text", "label": "Wofür dürfen wir beten?", "required": true, "maxLength": 5000 },
          { "id": 3, "kind": "single_choice", "label": "…", "required": true, "choices": ["…", "…"] }
        ]
      }
    }
  ]
}
```

Enthalten sind nur **sichtbare** Links. Formular-Buttons ohne existierendes Formular fehlen. Leere Angaben bei Links und Formularen (z. B. `description`, `icon`, `intro`) sind `null`, bei Fragen werden leere Felder weggelassen.

### Ereignis `kirchen-hub:update`

Ein am Host-Element (`[data-kirchen-hub]`) ausgelöstes `CustomEvent` ändert Darstellung und Titel ohne Neuladen:

```js
host.dispatchEvent(new CustomEvent("kirchen-hub:update", {
  detail: { theme: { primaryColor: "oklch(50% 0.2 250)", position: "left" }, title: "Neuer Titel" }
}));
```

`detail.theme` verwendet die Schlüssel aus `theme` oben. Genutzt wird das von der Live-Vorschau im Backend.

## Formular-Einsendung

```
POST https://<host>/embed/<token>/forms/<form_id>/submissions
Content-Type: multipart/form-data   (oder application/x-www-form-urlencoded)
```

Wird vom Launcher per `fetch` (ohne Cookies) aufgerufen. Die Antwort erlaubt jede Herkunft
(`Access-Control-Allow-Origin: *`). Ein CSRF-Token wird nicht benötigt, weil es weder Cookies noch Anmeldung gibt.

**Parameter**

| Name | Bedeutung |
| --- | --- |
| `answers[<question_id>]` | Antwort auf eine Frage. Bei Mehrfachauswahl `answers[<question_id>][]` mehrfach. Leere Antworten weglassen. |
| `consent` | `1`, wenn der Einwilligungstext bestätigt wurde. Pflicht, wenn das Formular einen hat. |
| `website` | **Honeypot.** Muss leer sein. |
| `elapsed_ms` | Millisekunden seit dem Öffnen des Formulars. Muss mindestens 3000 sein. |

**Antworten**

| Status | Body | Bedeutung |
| --- | --- | --- |
| `201` | `{"ok": true}` | Gespeichert (oder als Spam stillschweigend verworfen, mit derselben Antwort) |
| `422` | `{"errors": {"<question_id>": "Meldung"}}` | Antwort(en) ungültig oder Pflichtfrage leer |
| `422` | `{"errors": {"consent": "Bitte stimme der Datenverarbeitung zu."}}` | Einwilligung fehlt |
| `403` | `{"error": "Das Formular ist für diese Webseite nicht freigegeben."}` | Webseiten-Beschränkung: `Origin`/`Referer` gehört zu einer anderen Domain |
| `404` | `{"error": "Formular nicht gefunden."}` | Token unbekannt, Hub deaktiviert, Formular nicht mit einem **sichtbaren** Link verknüpft |
| `429` | `{"error": "Zu viele Einsendungen. …"}` | Mehr als 10 Einsendungen in 10 Minuten von einer IP |

Beispiel (zum Testen, `elapsed_ms` so groß setzen, dass der Spam-Schutz nicht greift):

```sh
curl -X POST "https://hub.eure-kirche.de/embed/<token>/forms/1/submissions" \
  -F "answers[1]=Bitte betet für unsere Gemeinde" \
  -F "answers[3]=Nur das Gebetsteam" \
  -F "consent=1" -F "website=" -F "elapsed_ms=8000"
```

Bei jeder gespeicherten Einsendung mit hinterlegten Benachrichtigungsadressen wird eine E-Mail (ohne Antworten) in die
Warteschlange gestellt.

## Öffentliche Hub-Seite

```
GET https://<host>/<kurzname>
```

HTML-Seite mit den sichtbaren Webseiten-Links (keine Formulare). `404`, wenn der Kurzname unbekannt oder der Hub
deaktiviert ist. Beschreibung: [Eigene Hub-Seite](../benutzerhandbuch/eigene-seite.md).

## Health-Check

```
GET https://<host>/up
```

`200`, wenn die Anwendung startet. Für Uptime-Monitoring und Load-Balancer.
