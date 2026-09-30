# Eigene Hub-Seite

← [Benutzerhandbuch](README.md)

Neben dem Launcher auf eurer Webseite ist der Hub auch als **eigenständige Seite** erreichbar:

```
https://<adresse-des-hubs>/<kurzname>
```

Die genaue Adresse steht unter **Hub → Einbinden** im Abschnitt **„Eigene Seite“**, mit Kopieren-Symbol und
„Öffnen“-Schaltfläche.

## Wofür ist das gut?

- **QR-Code** im Gottesdienstblatt, auf Plakaten oder am Schaukasten: Wer ihn scannt, sieht sofort alle Links.
- **Social Media:** Als Link in der Profilbeschreibung (Instagram, Facebook …) oder in Newslettern.
- **Kirche ohne eigene Webseite:** Der Hub ersetzt dann eine einfache „Linktree“-Seite.

Tipp zum QR-Code: Kopiere die Adresse in einen beliebigen QR-Code-Generator. Da die Seite immer den aktuellen Stand
zeigt, muss der Code nie neu gedruckt werden, solange der Kurzname gleich bleibt.

## Wie sieht die Seite aus?

Eine schlanke, für das Handy optimierte Seite mit:

- Kopfzeile in eurer **Hauptfarbe** mit der **Überschrift** des Hubs
- einer Liste der sichtbaren Links, jeweils mit Symbol, Titel und Beschreibung. Sie öffnen in einem neuen Tab.
- Übernahme von **Farben, Eckenrundung und Farbschema** (hell/dunkel/automatisch) aus dem [Design](design.md)

Ohne Links steht dort „Noch keine Links vorhanden.“

## Was wird angezeigt, was nicht?

| Eintrag | Sichtbar? |
| --- | --- |
| Links zu Webseiten, die im Launcher angezeigt werden | ja |
| Ausgeblendete Links | nein |
| **Formular-Buttons** | **nein.** Formulare öffnen sich nur im Launcher auf einer Webseite. |
| Position und Button-Text (Design) | irrelevant, es gibt keinen schwebenden Button |

Ist der Launcher unter *Einbinden* **deaktiviert**, liefert die Adresse eine „Seite nicht gefunden“-Meldung.
Die Webseiten-Beschränkung gilt hier **nicht**. Die Seite ist grundsätzlich öffentlich.

## Der Kurzname

Der Kurzname (englisch „slug“) bildet den Pfad der Adresse.

- **Automatisch:** Beim Anlegen einer Kirche entsteht er aus dem Namen („Ev. Kirche Müllheim“ → `ev-kirche-mullheim`).
  Sonderzeichen werden umgeschrieben, Leerzeichen zu Bindestrichen. Ist der Name schon vergeben, wird `-2`, `-3` … angehängt.
- **Ändern:** Als Besitzer unter **Kirche → Einstellungen → Kurzname**. Erlaubt sind Kleinbuchstaben, Ziffern und
  einzelne Bindestriche (nicht am Anfang oder Ende, nicht doppelt).
- **Achtung:** Wird der Kurzname geändert, funktioniert die **alte Adresse nicht mehr**, auch nicht in gedruckten
  QR-Codes. Ändere ihn deshalb nur, wenn es unbedingt nötig ist.
- **Reserviert:** Namen, die die Anwendung selbst verwendet, sind nicht erlaubt, zum Beispiel `session`, `hub`, `forms`,
  `embed`, `admin`, `api`, `assets`, `up`. Das Formular meldet dann, dass der Name nicht verfügbar ist. Wähle einen anderen.
- Jeder Kurzname existiert nur einmal im ganzen System.

## Aktualität

Die Seite prüft bei jedem Aufruf, ob sich etwas geändert hat, und zeigt Änderungen daher ohne Verzögerung.
