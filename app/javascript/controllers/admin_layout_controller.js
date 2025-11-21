import { Controller } from "@hotwired/stimulus"

// Admin layout controller for sidebar and profile menu
export default class extends Controller {
  static targets = ["sidebar", "profileMenu"]

  connect() {
    // Close menus when clicking outside
    this.boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.boundClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside)
  }

  toggleSidebar(event) {
    event.stopPropagation()
    this.sidebarTarget.classList.toggle("active")
  }

  closeSidebar() {
    // Close sidebar on mobile after clicking a nav item
    if (window.innerWidth <= 768) {
      this.sidebarTarget.classList.remove("active")
    }
  }

  toggleProfileMenu(event) {
    event.stopPropagation()
    this.profileMenuTarget.classList.toggle("active")
  }

  clickOutside(event) {
    // Close profile menu if clicking outside
    if (this.hasProfileMenuTarget) {
      const profileDropdown = this.element.querySelector(".profile-dropdown")
      if (profileDropdown && !profileDropdown.contains(event.target)) {
        this.profileMenuTarget.classList.remove("active")
      }
    }

    // Close sidebar on mobile if clicking outside
    if (window.innerWidth <= 768) {
      const sidebar = this.sidebarTarget
      const mobileMenuToggle = this.element.querySelector(".mobile-menu-toggle")
      
      if (sidebar && !sidebar.contains(event.target) && 
          mobileMenuToggle && !mobileMenuToggle.contains(event.target)) {
        sidebar.classList.remove("active")
      }
    }
  }
}
