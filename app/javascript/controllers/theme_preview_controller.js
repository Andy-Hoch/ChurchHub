import { Controller } from "@hotwired/stimulus"

// Pushes unsaved design changes into the embedded launcher preview.
export default class extends Controller {
  static targets = [ "form", "stage" ]

  update() {
    const host = this.stageTarget.querySelector("[data-kirchen-hub]")
    if (!host) return

    host.dispatchEvent(new CustomEvent("kirchen-hub:update", { detail: { title: this.#value("title"), theme: this.#theme } }))
  }

  get #theme() {
    return {
      primaryColor: this.#value("primary_color"),
      textColor: this.#value("text_color"),
      position: this.#value("position"),
      buttonLabel: this.#value("button_label"),
      buttonIcon: this.#value("button_icon"),
      colorScheme: this.#value("color_scheme"),
      cornerRadius: Number(this.#value("corner_radius"))
    }
  }

  #value(name) {
    return this.formTarget.elements[`hub[${name}]`]?.value
  }
}
