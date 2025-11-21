import { Controller } from "@hotwired/stimulus"

// Handles horizontal scroll indicator for tables
export default class extends Controller {
  connect() {
    this.checkScroll()
    this.element.addEventListener('scroll', () => this.checkScroll())
  }

  checkScroll() {
    const isScrolledToRight = 
      this.element.scrollLeft + this.element.clientWidth >= this.element.scrollWidth - 10

    if (isScrolledToRight) {
      this.element.classList.add('scrolled-right')
    } else {
      this.element.classList.remove('scrolled-right')
    }
  }
}
