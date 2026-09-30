# Design anpassen

← [Benutzerhandbuch](README.md)

Unter **Hub → Design** gestaltest du den Launcher passend zu eurer Webseite. Links steht das Formular, rechts die
**Live-Vorschau**: Der Launcher erscheint dort geöffnet und aktualisiert sich bei jeder Änderung sofort, noch
bevor du speicherst. Erst „Speichern“ übernimmt die Einstellungen dauerhaft.

> In der Vorschau lassen sich auch Formulare durchklicken. Dort wird nichts gesendet, das steht am Ende deutlich als
> „Vorschau: Es wurde nichts gesendet.“

## Einstellungen

| Einstellung | Wirkung | Grenzen / Standard |
| --- | --- | --- |
| **Überschrift im Panel** | Titel oben im geöffneten Panel. Auch Titel der [eigenen Hub-Seite](eigene-seite.md). | Pflicht, max. 80 Zeichen. Voreinstellung: Name der Kirche |
| **Button-Text** | Beschriftung des schwebenden Buttons. | Pflicht, max. 30 Zeichen. Standard: „Links“ |
| **Hauptfarbe** | Farbe des Buttons, der Panel-Kopfzeile, der Kopfzeile und Buttons in Formularen, des Fortschrittsbalkens und der Markierungen. | Standard: dunkles Anthrazit |
| **Textfarbe auf Hauptfarbe** | Schriftfarbe auf Flächen in der Hauptfarbe. | Standard: Weiß |
| **Symbol** | Icon im Button: *Kacheln*, *Menü*, *Herz*, *Kreuz* oder *Link*. Bei geöffnetem Panel zeigt der Button ein Schließen-Kreuz. | Standard: Kacheln |
| **Position** | *Unten rechts* oder *Unten links* auf der Webseite. | Standard: unten rechts |
| **Panel-Farbschema** | *Hell*, *Dunkel* oder *Wie System* (folgt der Einstellung des Besuchers). Gilt für das Panel und die Formulare, nicht für den Button (der nutzt die Hauptfarbe). | Standard: Hell |
| **Eckenrundung** | Rundung von Panel, Listeneinträgen und Formularfeldern, stufenlos von 0 (eckig) bis 24 Pixel. Der Button selbst ist immer rund. | Standard: 12 |

### Farben wählen

Die Farbfelder öffnen den Farbwähler deines Browsers. Intern speichert der Hub Farben im Format `oklch()`
und rechnet die Auswahl automatisch um. Dadurch kann die im Farbwähler angezeigte Farbe minimal von der
ursprünglichen abweichen, was praktisch nicht auffällt.

**Kontrast beachten:** Wähle Haupt- und Textfarbe so, dass die Schrift auf dem Button und in der Kopfzeile gut
lesbar bleibt (dunkle Hauptfarbe → helle Textfarbe und umgekehrt). Prüfe das Ergebnis auch auf dem Handy.

### Passt es zu eurer Seite?

- Nimm die **Hauptfarbe aus eurem Logo** oder aus dem Menü der Webseite.
- Steht bei euch schon ein Chat- oder Cookie-Button unten rechts? Dann setze den Launcher **nach links**.
- „Wie System“ ist eine gute Wahl, wenn viele Besucher abends auf dem Handy den Dunkelmodus nutzen.

## Wann erscheinen Änderungen auf der Webseite?

Nach dem Speichern erscheinen sie auf eurer Webseite **innerhalb von etwa 5 Minuten**. So lange darf der Browser die
ausgelieferte Version zwischenspeichern. Die [eigene Hub-Seite](eigene-seite.md) zeigt Änderungen sofort.
Ein Neuladen der Webseite (Strg/Cmd + Shift + R) beschleunigt das beim Testen.

## Verhalten auf dem Handy

Auf Bildschirmen bis 640 Pixel Breite öffnet sich das Panel automatisch **im Vollbild**, und die Webseite dahinter
lässt sich nicht mehr scrollen. Formulare öffnen sich immer im Vollbild.
