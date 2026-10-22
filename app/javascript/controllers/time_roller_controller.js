import { Controller } from "@hotwired/stimulus"

// A text field for 24-hour times ("HH:MM") with an hour and a minute roll
// that scroll and snap like rolldate's time rolls. Scrolling, clicking or
// the arrow keys write the time into the field; typing it still works.
export default class extends Controller {
  static targets = [ "input", "panel", "column" ]

  #settleTimers = new WeakMap()
  #ignoredScrolls = new WeakSet()

  open() {
    if (!this.panelTarget.hidden) return

    this.panelTarget.hidden = false
    this.inputTarget.setAttribute("aria-expanded", "true")
    this.#showValue()
  }

  close() {
    this.panelTarget.hidden = true
    this.inputTarget.setAttribute("aria-expanded", "false")
  }

  closeOnFocusOut(event) {
    if (!this.element.contains(event.relatedTarget)) this.close()
  }

  // Typed by hand: move the rolls along.
  sync(event) {
    if (event.isTrusted && !this.panelTarget.hidden) this.#showValue()
  }

  pick({ currentTarget: item }) {
    this.#select(item)
    this.#center(item, "smooth")
    this.#write()
  }

  step(event) {
    if (event.key !== "ArrowUp" && event.key !== "ArrowDown") return
    event.preventDefault()

    const column = event.currentTarget
    const current = this.#selected(column) || this.#centered(column)
    const next = event.key === "ArrowDown" ? current.nextElementSibling : current.previousElementSibling
    if (next) this.pick({ currentTarget: next })
  }

  // Once a roll comes to rest, the item in the middle is the chosen one.
  scrolled({ currentTarget: column }) {
    clearTimeout(this.#settleTimers.get(column))
    this.#settleTimers.set(column, setTimeout(() => {
      if (this.#ignoredScrolls.delete(column)) return

      const item = this.#centered(column)
      if (item === this.#selected(column)) return
      this.#select(item)
      this.#write()
    }, 120))
  }

  // Rolls to the field's time, or to 08:00 without choosing it yet.
  #showValue() {
    const [ hours, minutes ] = this.inputTarget.value.match(/^([01]\d|2[0-3]):([0-5]\d)$/)?.slice(1) || []
    const [ hourColumn, minuteColumn ] = this.columnTargets

    this.#show(hourColumn, hours || "08", hours)
    this.#show(minuteColumn, minutes && pad(Math.floor(minutes / 5) * 5), minutes)
  }

  #show(column, value, chosen) {
    const item = column.querySelector(`[data-value="${value}"]`) || column.firstElementChild
    chosen ? this.#select(item) : this.#deselect(column)
    this.#center(item, "instant", { ignore: true })
  }

  #write() {
    const [ hours, minutes ] = this.columnTargets.map(column => (this.#selected(column) || this.#centered(column)).dataset.value)
    this.inputTarget.value = `${hours}:${minutes}`
    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  #select(item) {
    this.#deselect(item.parentElement)
    item.setAttribute("aria-selected", "true")
  }

  #deselect(column) {
    this.#selected(column)?.setAttribute("aria-selected", "false")
  }

  #selected(column) {
    return column.querySelector("[aria-selected='true']")
  }

  #centered(column) {
    const middle = column.scrollTop + column.clientHeight / 2
    return Array.from(column.children).reduce((closest, item) =>
      Math.abs(item.offsetTop + item.offsetHeight / 2 - middle) < Math.abs(closest.offsetTop + closest.offsetHeight / 2 - middle) ? item : closest
    )
  }

  // Scrolling there by code must not count as choosing what lands in the middle.
  #center(item, behavior, { ignore = false } = {}) {
    const column = item.parentElement
    const top = item.offsetTop - (column.clientHeight - item.offsetHeight) / 2
    if (Math.abs(column.scrollTop - top) < 1) return

    if (ignore) this.#ignoredScrolls.add(column)
    column.scrollTo({ top, behavior })
  }
}

const pad = number => String(number).padStart(2, "0")
