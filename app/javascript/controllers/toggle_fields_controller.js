import { Controller } from "@hotwired/stimulus"

// Shows only the sections whose data-show-for lists the chosen option, e.g.
// the URL field for links and the form picker for form buttons. Fields in
// hidden sections are disabled so their browser validation doesn't block.
// An optional summary target shows the chosen option's data-toggle-fields-summary
// once it changes, e.g. the title of the schedule accordion.
export default class extends Controller {
  static targets = [ "section", "summary" ]

  connect() {
    this.update()
  }

  update(event) {
    const value = this.#value

    this.sectionTargets.forEach(section => {
      const visible = section.dataset.showFor.split(" ").includes(value)
      section.hidden = !visible
      section.querySelectorAll("input, select, textarea").forEach(field => field.disabled = !visible)
    })

    const summary = event?.target.dataset.toggleFieldsSummary
    if (summary && this.hasSummaryTarget) this.summaryTarget.textContent = summary
  }

  // Sources of nested toggle-fields controllers (e.g. the schedule inside
  // the link form) belong to those, not to this one.
  get #value() {
    const sources = this.element.querySelectorAll("input[data-toggle-fields-source]:checked, select[data-toggle-fields-source]")
    return Array.from(sources).find(source => source.closest("[data-controller~='toggle-fields']") === this.element)?.value
  }
}
