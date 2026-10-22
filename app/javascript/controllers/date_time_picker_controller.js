import { Controller } from "@hotwired/stimulus"
import "rolldate"

// Turns a datetime-local field into a rolldate calendar with a time roll.
// The field itself becomes hidden and keeps the value Rails expects
// ("2026-12-31T08:00"); a read-only text field in front of it shows the
// German format and opens the picker. Without JavaScript the native field
// stays as it is.
export default class extends Controller {
  static values = { monthNames: Array, shortMonthNames: Array, dayNames: Array }

  #display = null
  #picker = null

  connect() {
    document.addEventListener("turbo:before-cache", this.#teardown)
    this.#enhance()
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.#teardown)
    this.#teardown()
  }

  #enhance() {
    const field = this.element
    const date = parse(field.value)

    this.#display = Object.assign(document.createElement("input"), {
      type: "text", id: field.id, className: field.className, readOnly: true,
      autocomplete: "off", placeholder: "Datum wählen", value: date ? format(date) : ""
    })
    this.#display.addEventListener("click", () => this.#picker.open())
    field.id = `${field.id}_value`
    field.type = "hidden"
    field.before(this.#display)

    this.#picker = new window.RollDate(`#${CSS.escape(this.#display.id)}`, {
      theme: "light",
      containerClass: "date-picker",
      locale: "de-DE",
      dateFormat: "DD.MM.YYYY",
      startWeekFromMonday: true,
      monthsNames: this.monthNamesValue,
      monthsShortNames: this.shortMonthNamesValue,
      weekDaysNames: this.dayNamesValue,
      previousMonthLabel: "Vorheriger Monat",
      nextMonthLabel: "Nächster Monat",
      selectedLabel: "ausgewählt",
      enableTime: true,
      timePosition: "bottom",
      timeStep: 5,
      closeOnSelect: false,
      startDate: date || startOfToday(),
      footerButtons: [
        { text: "Leeren", action: "clear", variant: "link", position: "left" },
        { text: "Fertig", action: "close", variant: "primary" }
      ],
      selectDate: date => this.#select(date)
    })
    if (date) this.#picker.setValue(date)
  }

  #select(date) {
    this.element.value = date ? iso(date) : ""
    this.#display.value = date ? format(date) : ""
    this.element.dispatchEvent(new Event("change", { bubbles: true }))
  }

  // Also runs before Turbo caches the page, so a restored page is enhanced
  // afresh instead of twice, and rolldate's popup doesn't linger in the body.
  #teardown = () => {
    if (!this.#picker) return

    this.#picker.destroy()
    this.element.id = this.#display.id
    this.element.type = "datetime-local"
    this.#display.remove()
    this.#picker = this.#display = null
  }
}

const pad = number => String(number).padStart(2, "0")

// "2026-12-31T08:00" in local time, as datetime-local fields hold it.
function parse(value) {
  const match = value.match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/)
  if (!match) return null

  const [ year, month, day, hours, minutes ] = match.slice(1).map(Number)
  return new Date(year, month - 1, day, hours, minutes)
}

function iso(date) {
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`
}

function format(date) {
  return `${pad(date.getDate())}.${pad(date.getMonth() + 1)}.${date.getFullYear()} ${pad(date.getHours())}:${pad(date.getMinutes())}`
}

function startOfToday() {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return today
}
