import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "select", "textarea", "submit", "step", "progress"]
  static values = { 
    currentStep: { type: Number, default: 1 },
    totalSteps: { type: Number, default: 1 },
    autoSave: { type: Boolean, default: true }
  }

  connect() {
    this.setupMobileFormOptimizations()
    this.setupAutoSave()
    this.setupStepNavigation()
    this.setupFieldValidation()
  }

  disconnect() {
    this.clearAutoSaveTimer()
  }

  setupMobileFormOptimizations() {
    if (this.isMobile()) {
      // Add mobile-specific classes
      this.element.classList.add('mobile-form')
      
      // Optimize input fields for mobile
      this.fieldTargets.forEach(field => {
        field.addEventListener('focus', this.handleFieldFocus.bind(this))
        field.addEventListener('blur', this.handleFieldBlur.bind(this))
      })

      // Optimize select fields
      this.selectTargets.forEach(select => {
        select.addEventListener('change', this.handleSelectChange.bind(this))
      })

      // Optimize textarea fields
      this.textareaTargets.forEach(textarea => {
        textarea.addEventListener('input', this.handleTextareaInput.bind(this))
      })
    }
  }

  setupAutoSave() {
    if (this.autoSaveValue) {
      this.fieldTargets.forEach(field => {
        field.addEventListener('input', this.debounce(this.autoSave.bind(this), 1000))
      })
    }
  }

  setupStepNavigation() {
    if (this.hasStepTarget) {
      this.showCurrentStep()
      this.updateProgress()
    }
  }

  setupFieldValidation() {
    this.fieldTargets.forEach(field => {
      field.addEventListener('blur', this.validateField.bind(this))
      field.addEventListener('input', this.clearFieldError.bind(this))
    })
  }

  handleFieldFocus(event) {
    const field = event.target
    field.parentElement.classList.add('focused')
    
    // Scroll to field on mobile
    if (this.isMobile()) {
      setTimeout(() => {
        field.scrollIntoView({ behavior: 'smooth', block: 'center' })
      }, 300)
    }
  }

  handleFieldBlur(event) {
    const field = event.target
    field.parentElement.classList.remove('focused')
  }

  handleSelectChange(event) {
    const select = event.target
    const value = select.value
    
    // Show/hide dependent fields
    this.toggleDependentFields(select, value)
  }

  handleTextareaInput(event) {
    const textarea = event.target
    const maxLength = textarea.getAttribute('maxlength')
    
    if (maxLength) {
      const currentLength = textarea.value.length
      const remaining = maxLength - currentLength
      
      // Update character counter
      const counter = textarea.parentElement.querySelector('.char-counter')
      if (counter) {
        counter.textContent = `${currentLength}/${maxLength}`
        counter.classList.toggle('text-danger', remaining < 10)
      }
    }
  }

  toggleDependentFields(select, value) {
    const dependentFields = select.parentElement.querySelectorAll('[data-depends-on]')
    
    dependentFields.forEach(field => {
      const dependsOn = field.dataset.dependsOn
      const dependsValue = field.dataset.dependsValue
      
      if (dependsOn === select.name && dependsValue === value) {
        field.style.display = 'block'
        field.querySelector('input, select, textarea').required = true
      } else {
        field.style.display = 'none'
        field.querySelector('input, select, textarea').required = false
      }
    })
  }

  validateField(event) {
    const field = event.target
    const value = field.value.trim()
    const required = field.hasAttribute('required')
    const pattern = field.getAttribute('pattern')
    
    let isValid = true
    let errorMessage = ''
    
    // Check required
    if (required && !value) {
      isValid = false
      errorMessage = 'Este campo é obrigatório'
    }
    
    // Check pattern
    if (pattern && value && !new RegExp(pattern).test(value)) {
      isValid = false
      errorMessage = field.getAttribute('data-error-message') || 'Formato inválido'
    }
    
    // Check email format
    if (field.type === 'email' && value && !this.isValidEmail(value)) {
      isValid = false
      errorMessage = 'Email inválido'
    }
    
    // Check phone format
    if (field.getAttribute('data-phone') && value && !this.isValidPhone(value)) {
      isValid = false
      errorMessage = 'Telefone inválido'
    }
    
    this.showFieldError(field, isValid, errorMessage)
    return isValid
  }

  showFieldError(field, isValid, message) {
    const fieldContainer = field.parentElement
    const existingError = fieldContainer.querySelector('.field-error')
    
    if (existingError) {
      existingError.remove()
    }
    
    if (!isValid) {
      field.classList.add('is-invalid')
      const errorDiv = document.createElement('div')
      errorDiv.className = 'field-error text-danger small mt-1'
      errorDiv.textContent = message
      fieldContainer.appendChild(errorDiv)
    } else {
      field.classList.remove('is-invalid')
    }
  }

  clearFieldError(event) {
    const field = event.target
    const fieldContainer = field.parentElement
    const error = fieldContainer.querySelector('.field-error')
    
    if (error) {
      error.remove()
      field.classList.remove('is-invalid')
    }
  }

  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }

  isValidPhone(phone) {
    const phoneRegex = /^[\d\s\(\)\-\+]+$/
    return phoneRegex.test(phone) && phone.replace(/\D/g, '').length >= 10
  }

  autoSave() {
    const formData = new FormData(this.element)
    
    fetch(this.element.action, {
      method: 'POST',
      body: formData,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'text/vnd.turbo-stream.html'
      }
    })
    .then(response => response.text())
    .then(html => {
      // Update form with server response if needed
      console.log('Form auto-saved')
    })
    .catch(error => {
      console.error('Auto-save error:', error)
    })
  }

  nextStep() {
    if (this.validateCurrentStep()) {
      this.currentStepValue++
      this.showCurrentStep()
      this.updateProgress()
    }
  }

  prevStep() {
    if (this.currentStepValue > 1) {
      this.currentStepValue--
      this.showCurrentStep()
      this.updateProgress()
    }
  }

  showCurrentStep() {
    this.stepTargets.forEach((step, index) => {
      if (index + 1 === this.currentStepValue) {
        step.style.display = 'block'
      } else {
        step.style.display = 'none'
      }
    })
  }

  updateProgress() {
    if (this.hasProgressTarget) {
      const percentage = (this.currentStepValue / this.totalStepsValue) * 100
      this.progressTarget.style.width = `${percentage}%`
      this.progressTarget.setAttribute('aria-valuenow', percentage)
    }
  }

  validateCurrentStep() {
    const currentStep = this.stepTargets[this.currentStepValue - 1]
    const fields = currentStep.querySelectorAll('input[required], select[required], textarea[required]')
    
    let isValid = true
    
    fields.forEach(field => {
      if (!this.validateField({ target: field })) {
        isValid = false
      }
    })
    
    return isValid
  }

  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }

  clearAutoSaveTimer() {
    // Clear any pending auto-save timers
  }

  isMobile() {
    return window.innerWidth <= 768
  }
} 