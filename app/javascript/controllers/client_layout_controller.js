import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "profileDropdown"]

  connect() {
    // Close dropdowns when clicking outside
    document.addEventListener('click', this.handleOutsideClick.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }

  toggleProfileDropdown(event) {
    event.stopPropagation()
    this.profileDropdownTarget.classList.toggle('active')
  }

  toggleMobileMenu(event) {
    event.stopPropagation()
    this.mobileMenuTarget.classList.toggle('active')
  }

  closeMenuOnNavClick(event) {
    // On mobile, close menu when clicking nav items
    if (window.innerWidth <= 768) {
      this.mobileMenuTarget.classList.remove('active')
    }
  }

  handleOutsideClick(event) {
    // Close profile dropdown if clicking outside
    if (this.hasProfileDropdownTarget && 
        !this.profileDropdownTarget.contains(event.target) && 
        !event.target.closest('.client-user-button')) {
      this.profileDropdownTarget.classList.remove('active')
    }

    // Close mobile menu if clicking outside
    if (this.hasMobileMenuTarget && 
        window.innerWidth <= 768 &&
        !this.mobileMenuTarget.contains(event.target) &&
        !event.target.closest('.mobile-menu-toggle')) {
      this.mobileMenuTarget.classList.remove('active')
    }
  }
}
