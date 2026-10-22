import { Controller } from "@hotwired/stimulus"

// Keeps the title of the closed schedule accordion telling what is set: a
// badge for whether the button is scheduled at all, and a line with the
// details in the same words the server renders them, e.g.
// "Jede Woche So 08:00–12:00 · bis 31.12.2026 00:00".
export default class extends Controller {
  static targets = [ "badge", "details", "schedule", "weekday", "startTime", "endTime", "from", "until" ]

  update() {
    const schedule = this.scheduleTargets.find(radio => radio.checked)
    const scheduled = Boolean(schedule) && schedule.value !== "always"
    const details = scheduled ? this.#details(schedule) : ""

    this.badgeTarget.textContent = scheduled ? "Zeitgesteuert" : "Immer"
    this.badgeTarget.classList.toggle("badge--primary", scheduled)
    this.badgeTarget.classList.toggle("badge--secondary", !scheduled)
    this.detailsTarget.textContent = details
    this.detailsTarget.hidden = !details
  }

  // Fields of sections that don't apply to the schedule are disabled.
  #details(schedule) {
    const parts = []

    if (!this.startTimeTarget.disabled) {
      const days = this.weekdayTargets.filter(box => box.checked).map(labelOf).join(", ")
      const times = [ this.startTimeTarget.value, this.endTimeTarget.value ].filter(Boolean).join("–")
      parts.push([ labelOf(schedule), days, times ].filter(Boolean).join(" "))
    }
    if (!this.fromTarget.disabled && this.fromTarget.value) parts.push(`ab ${formatDateTime(this.fromTarget.value)}`)
    if (!this.untilTarget.disabled && this.untilTarget.value) parts.push(`bis ${formatDateTime(this.untilTarget.value)}`)

    return parts.join(" · ")
  }
}

const labelOf = input => input.closest("label").textContent.trim()

// "2026-12-31T08:00" → "31.12.2026 08:00"
function formatDateTime(value) {
  const [ , year, month, day, time ] = value.match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}:\d{2})/) || []
  return year ? `${day}.${month}.${year} ${time}` : value
}
