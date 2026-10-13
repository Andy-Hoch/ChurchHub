import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
import { put } from "@rails/request.js"
import Sortable from "sortablejs"

export default class extends Controller {
  static values  = { url: String, group: String, handle: String }

  connect() {
    this.sortable = new Sortable(this.element, this.#options)
  }

  disconnect() {
    this.sortable.destroy()
  }

  // A failed save (or a redirect to the login after the session expired)
  // reloads the page, so it shows the order that was actually stored.
  async #submit({ item, newIndex }) {
    const response = await put(item.dataset.urlValue, { query: { position: newIndex } })
    if (!response.ok || response.redirected) Turbo.visit(location.href, { action: "replace" })
  }

  get #options() {
    return { animation: 150, onAdd: this.#submit, onUpdate: this.#submit, group: this.groupValue, handle: this.handleValue }
  }
}
