import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "profileMenu"]

  connect() {
    // Close dropdowns when clicking outside
    document.addEventListener('click', this.handleOutsideClick.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }

  toggleProfileMenu(event) {
    event.stopPropagation()
    this.profileMenuTarget.classList.toggle('active')
  }

  toggleSidebar(event) {
    event.stopPropagation()
    this.sidebarTarget.classList.toggle('active')
  }

  closeSidebarOnNavClick(event) {
    // On mobile, close sidebar when clicking nav items
    if (window.innerWidth <= 768) {
      this.sidebarTarget.classList.remove('active')
    }
  }

  handleOutsideClick(event) {
    // Close profile menu if clicking outside
    if (this.hasProfileMenuTarget && 
        !this.profileMenuTarget.contains(event.target) && 
        !event.target.closest('.profile-dropdown-toggle')) {
      this.profileMenuTarget.classList.remove('active')
    }

    // Close sidebar on mobile if clicking outside
    if (this.hasSidebarTarget && 
        window.innerWidth <= 768 &&
        !this.sidebarTarget.contains(event.target) &&
        !event.target.closest('.mobile-menu-toggle')) {
      this.sidebarTarget.classList.remove('active')
    }
  }
}
