import { Controller } from "@hotwired/stimulus"

// Shows only the sections whose data-show-for lists the chosen option, e.g.
// the URL field for links and the form picker for form buttons. Fields in
// hidden sections are disabled so their browser validation doesn't block.
export default class extends Controller {
  static targets = [ "section" ]

  connect() {
    this.update()
  }

  update() {
    const value = this.#value

    this.sectionTargets.forEach(section => {
      const visible = section.dataset.showFor.split(" ").includes(value)
      section.hidden = !visible
      section.querySelectorAll("input, select, textarea").forEach(field => field.disabled = !visible)
    })
  }

  get #value() {
    const source = this.element.querySelector("input[data-toggle-fields-source]:checked, select[data-toggle-fields-source]")
    return source?.value
  }
}
