import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["element", "text", "icon"]
  static values = { 
    originalText: String,
    loadingText: String,
    successText: String,
    errorText: String,
    autoHide: { type: Boolean, default: true },
    hideDelay: { type: Number, default: 3000 }
  }

  connect() {
    console.log('🔔 Feedback controller connected')
    this.originalTextValue = this.originalTextValue || this.element.textContent.trim()
    this.setupLoadingListeners()
  }

  showLoading() {
    this.element.disabled = true
    this.addLoadingClass()
    
    if (this.hasTextTarget) {
      this.textTarget.textContent = this.loadingTextValue || 'Processando...'
    }
    
    // Hide icon during loading for cleaner look
    if (this.hasIconTarget) {
      this.iconTarget.style.visibility = 'hidden'
    }
  }

  showSuccess(message = null) {
    this.resetState()
    
    if (this.hasTextTarget) {
      this.textTarget.textContent = message || this.successTextValue || 'Sucesso!'
    }
    
    if (this.hasIconTarget) {
      this.iconTarget.className = 'fas fa-check me-1'
    }
    
    this.addSuccessClass()
    this.scheduleReset()
  }

  showError(message = null) {
    this.resetState()
    
    if (this.hasTextTarget) {
      this.textTarget.textContent = message || this.errorTextValue || 'Erro!'
    }
    
    if (this.hasIconTarget) {
      this.iconTarget.className = 'fas fa-exclamation-triangle me-1'
    }
    
    this.addErrorClass()
    this.scheduleReset()
  }

  reset() {
    this.resetState()
    
    if (this.hasTextTarget) {
      this.textTarget.textContent = this.originalTextValue
    }
    
    if (this.hasIconTarget) {
      this.resetIcon()
    }
  }

  // Private methods
  setupLoadingListeners() {
    // Listen for form submissions to show loading state
    if (this.element.form) {
      this.element.form.addEventListener('submit', () => {
        this.showLoading()
      })
    }
    
    // Listen for turbo events
    document.addEventListener('turbo:submit-start', (event) => {
      if (event.target.contains(this.element)) {
        this.showLoading()
      }
    })
    
    document.addEventListener('turbo:submit-end', (event) => {
      if (event.target.contains(this.element)) {
        this.reset()
      }
    })
  }

  addLoadingClass() {
    this.element.classList.add('loading')
    this.element.classList.remove('btn-success', 'btn-danger', 'success', 'error')
  }

  addSuccessClass() {
    this.element.classList.add('success')
    this.element.classList.remove('loading', 'error', 'btn-danger')
    
    // Add success styling for buttons
    if (this.element.classList.contains('btn')) {
      this.element.classList.add('btn-success')
      this.element.classList.remove('btn-primary', 'btn-outline-primary')
    }
  }

  addErrorClass() {
    this.element.classList.add('error')
    this.element.classList.remove('loading', 'success', 'btn-success')
    
    // Add error styling for buttons
    if (this.element.classList.contains('btn')) {
      this.element.classList.add('btn-danger')
      this.element.classList.remove('btn-primary', 'btn-outline-primary')
    }
  }

  resetState() {
    this.element.disabled = false
    this.element.classList.remove('loading', 'success', 'error', 'btn-success', 'btn-danger')
    
    // Restore icon visibility
    if (this.hasIconTarget) {
      this.iconTarget.style.visibility = 'visible'
    }
    
    // Restore original button classes
    if (this.element.classList.contains('btn')) {
      if (!this.element.classList.contains('btn-outline-primary') && 
          !this.element.classList.contains('btn-secondary') &&
          !this.element.classList.contains('btn-outline-secondary')) {
        this.element.classList.add('btn-primary')
      }
    }
  }

  resetIcon() {
    if (this.hasIconTarget) {
      this.iconTarget.style.visibility = 'visible'
      
      const originalIcon = this.element.getAttribute('data-original-icon')
      if (originalIcon) {
        this.iconTarget.className = originalIcon
      } else {
        // Try to guess the original icon based on button context
        if (this.element.textContent.includes('Aprovar')) {
          this.iconTarget.className = 'fas fa-check me-1'
        } else if (this.element.textContent.includes('Finalizar')) {
          this.iconTarget.className = 'fas fa-money-bill-wave me-1'
        } else if (this.element.textContent.includes('Salvar') || this.element.textContent.includes('Criar')) {
          this.iconTarget.className = 'fas fa-save me-1'
        } else {
          this.iconTarget.className = 'fas fa-cog me-1'
        }
      }
    }
  }

  scheduleReset() {
    if (this.autoHideValue) {
      setTimeout(() => {
        this.reset()
      }, this.hideDelayValue)
    }
  }
} 