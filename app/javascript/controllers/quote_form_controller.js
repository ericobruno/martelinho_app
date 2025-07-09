import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "progress", "stepIndicator"]
  static values = { 
    currentStep: { type: Number, default: 1 },
    totalSteps: { type: Number, default: 4 }
  }

  connect() {
    console.log("✅ QuoteFormController connected successfully!")
    console.log("📊 Initial state:", {
      currentStep: this.currentStepValue,
      totalSteps: this.totalStepsValue,
      stepTargets: this.stepTargets.length,
      hasProgress: this.hasProgressTarget
    })
    this.updateStepDisplay()
  }

  disconnect() {
    console.log("❌ QuoteFormController disconnected")
  }

  nextStep(event) {
    event.preventDefault()
    console.log("➡️ Next step clicked, current:", this.currentStepValue)
    
    if (this.validateCurrentStep()) {
      if (this.currentStepValue < this.totalStepsValue) {
        const previousStep = this.currentStepValue
        this.currentStepValue++
        
        // If moving to review step (step 4), populate review data
        if (this.currentStepValue === 4) {
          this.populateReviewData()
        }
        
        this.updateStepDisplay()
        console.log(`✅ Moved from step ${previousStep} to step ${this.currentStepValue}`)
      } else {
        console.log("⚠️ Already at last step")
      }
    } else {
      console.log("❌ Validation failed for step", this.currentStepValue)
    }
  }

  previousStep(event) {
    event.preventDefault()
    console.log("⬅️ Previous step clicked, current:", this.currentStepValue)
    
    if (this.currentStepValue > 1) {
      const previousStep = this.currentStepValue
      this.currentStepValue--
      this.updateStepDisplay()
      console.log(`✅ Moved from step ${previousStep} to step ${this.currentStepValue}`)
    } else {
      console.log("⚠️ Already at first step")
    }
  }

  updateStepDisplay() {
    console.log("🔄 Updating step display, current step:", this.currentStepValue)
    
    // Update step visibility
    this.stepTargets.forEach((step, index) => {
      const stepNumber = index + 1
      if (stepNumber === this.currentStepValue) {
        step.classList.remove('d-none')
        step.classList.add('active')
        console.log(`👁️ Showing step ${stepNumber}`)
      } else {
        step.classList.add('d-none')
        step.classList.remove('active')
        console.log(`🙈 Hiding step ${stepNumber}`)
      }
    })

    // Update progress bar
    if (this.hasProgressTarget) {
      const percentage = (this.currentStepValue / this.totalStepsValue) * 100
      this.progressTarget.style.width = `${percentage}%`
      this.progressTarget.setAttribute('aria-valuenow', percentage)
      console.log("📊 Progress updated:", percentage + "%")
    } else {
      console.warn("⚠️ Progress target not found")
    }

    // Update step indicators
    this.updateStepIndicators()
  }

  updateStepIndicators() {
    const indicators = document.querySelectorAll('.step-item')
    console.log("🎯 Updating step indicators, found:", indicators.length)
    
    indicators.forEach((indicator, index) => {
      const stepNumber = index + 1
      indicator.classList.remove('active', 'completed')
      
      if (stepNumber === this.currentStepValue) {
        indicator.classList.add('active')
        console.log(`✨ Step ${stepNumber} indicator: active`)
      } else if (stepNumber < this.currentStepValue) {
        indicator.classList.add('completed')
        console.log(`✅ Step ${stepNumber} indicator: completed`)
      }
    })
  }

  validateCurrentStep() {
    const currentStepElement = this.stepTargets[this.currentStepValue - 1]
    if (!currentStepElement) {
      console.warn("⚠️ Current step element not found")
      return true
    }

    console.log("🔍 Validating step:", this.currentStepValue)

    // Remove previous validation errors
    currentStepElement.querySelectorAll('.is-invalid').forEach(el => {
      el.classList.remove('is-invalid')
    })

    let isValid = true
    const requiredFields = currentStepElement.querySelectorAll('input[required], select[required], textarea[required]')
    
    console.log("📝 Found required fields:", requiredFields.length)
    
    requiredFields.forEach(field => {
      const fieldValue = field.value ? field.value.trim() : ''
      if (!fieldValue || (field.type === 'select-one' && fieldValue === '')) {
        field.classList.add('is-invalid')
        console.log(`❌ Invalid field: ${field.name || field.id}`)
        isValid = false
      } else {
        field.classList.remove('is-invalid')
        console.log(`✅ Valid field: ${field.name || field.id}`)
      }
    })

    if (!isValid) {
      this.showAlert('Por favor, preencha todos os campos obrigatórios.')
    }

    console.log("✅ Step validation result:", isValid)
    return isValid
  }

  populateReviewData() {
    console.log("📝 Populating review data...")
    
    // Customer data
    const isExistingCustomer = document.getElementById('existing-customer-toggle').checked
    if (isExistingCustomer) {
      const customerSelect = document.getElementById('customer_select')
      const selectedOption = customerSelect.options[customerSelect.selectedIndex]
      if (selectedOption && selectedOption.value) {
        const customerText = selectedOption.text
        const parts = customerText.split(' - ')
        document.getElementById('review-customer-name').textContent = parts[0] || '-'
        document.getElementById('review-customer-document').textContent = parts[1] || '-'
        document.getElementById('review-customer-email').textContent = 'Cliente existente'
        document.getElementById('review-customer-phone').textContent = 'Cliente existente'
        document.getElementById('review-customer-address').textContent = 'Cliente existente'
      }
    } else {
      document.getElementById('review-customer-name').textContent = 
        document.getElementById('customer_name').value || '-'
      document.getElementById('review-customer-document').textContent = 
        document.getElementById('customer_document').value || '-'
      document.getElementById('review-customer-email').textContent = 
        document.getElementById('customer_email').value || '-'
      document.getElementById('review-customer-phone').textContent = 
        document.getElementById('customer_phone').value || '-'
      document.getElementById('review-customer-address').textContent = 
        document.getElementById('customer_address').value || '-'
    }

    // Vehicle data
    const isExistingVehicle = document.getElementById('existing-vehicle-toggle').checked
    if (isExistingVehicle) {
      const vehicleSelect = document.getElementById('vehicle_select')
      const selectedOption = vehicleSelect.options[vehicleSelect.selectedIndex]
      if (selectedOption && selectedOption.value) {
        const vehicleText = selectedOption.text
        const parts = vehicleText.split(' - ')
        document.getElementById('review-vehicle-plate').textContent = parts[0] || '-'
        document.getElementById('review-vehicle-brand').textContent = 'Veículo existente'
        document.getElementById('review-vehicle-model').textContent = parts[1] || '-'
        document.getElementById('review-vehicle-year').textContent = 'Existente'
        document.getElementById('review-vehicle-color').textContent = 'Existente'
      }
    } else {
      document.getElementById('review-vehicle-plate').textContent = 
        document.getElementById('vehicle_license_plate').value || '-'
      
      const brandSelect = document.getElementById('quote_vehicle_attributes_vehicle_brand_id')
      const brandOption = brandSelect.options[brandSelect.selectedIndex]
      document.getElementById('review-vehicle-brand').textContent = 
        brandOption ? brandOption.text : '-'
      
      const modelSelect = document.getElementById('quote_vehicle_attributes_vehicle_model_id')
      const modelOption = modelSelect.options[modelSelect.selectedIndex]
      let modelText = modelOption ? modelOption.text : '-'
      
      // Check if custom model is being used
      const customModelInput = document.getElementById('custom_model_name')
      if (customModelInput.value.trim()) {
        modelText = customModelInput.value + ' (Novo)'
      }
      document.getElementById('review-vehicle-model').textContent = modelText
      
      document.getElementById('review-vehicle-year').textContent = 
        document.getElementById('vehicle_year').value || '-'
      document.getElementById('review-vehicle-color').textContent = 
        document.getElementById('vehicle_color').value || '-'
    }

    // Notes
    document.getElementById('review-notes').textContent = 
      document.getElementById('quote_notes').value || '-'
    
    console.log("✅ Review data populated")
  }

  // Handle customer toggle
  toggleCustomer(event) {
    const isExisting = event.target.checked
    const existingSection = document.getElementById('existing-customer-section')
    const newSection = document.getElementById('new-customer-section')
    const hiddenCustomerId = document.getElementById('selected_customer_id')
    
    console.log("👤 Toggling customer mode, existing:", isExisting)
    
    if (isExisting) {
      existingSection.style.display = 'block'
      newSection.style.display = 'none'
      // Clear new customer fields
      newSection.querySelectorAll('input, select, textarea').forEach(field => {
        field.removeAttribute('required')
      })
      // Make existing customer field required
      const customerSelect = document.getElementById('customer_select')
      if (customerSelect) {
        customerSelect.setAttribute('required', 'required')
        // Add event listener for customer selection
        customerSelect.addEventListener('change', this.customerSelected.bind(this))
      }
    } else {
      existingSection.style.display = 'none'
      newSection.style.display = 'block'
      // Clear existing customer selection and hidden field
      const customerSelect = document.getElementById('customer_select')
      if (customerSelect) {
        customerSelect.value = ''
        customerSelect.removeAttribute('required')
        customerSelect.removeEventListener('change', this.customerSelected.bind(this))
      }
      if (hiddenCustomerId) hiddenCustomerId.value = ''
      // Make new customer fields required (except email which is now optional)
      newSection.querySelectorAll('input[data-required], select[data-required], textarea[data-required]').forEach(field => {
        if (field.id !== 'customer_email') { // Email is no longer required
          field.setAttribute('required', 'required')
        }
      })
    }
  }

  // Handle customer selection from dropdown
  customerSelected(event) {
    const selectedCustomerId = event.target.value
    const hiddenCustomerId = document.getElementById('selected_customer_id')
    
    console.log("👤 Customer selected, ID:", selectedCustomerId)
    
    if (hiddenCustomerId) {
      hiddenCustomerId.value = selectedCustomerId
      console.log("✅ Hidden customer_id field updated:", selectedCustomerId)
    }
  }

  // Handle vehicle toggle
  toggleVehicle(event) {
    const isExisting = event.target.checked
    const existingSection = document.getElementById('existing-vehicle-section')
    const newSection = document.getElementById('new-vehicle-section')
    
    console.log("🚗 Toggling vehicle mode, existing:", isExisting)
    
    if (isExisting) {
      existingSection.style.display = 'block'
      newSection.style.display = 'none'
      // Clear new vehicle fields
      newSection.querySelectorAll('input, select, textarea').forEach(field => {
        field.removeAttribute('required')
      })
      // Make existing vehicle field required
      const vehicleSelect = document.getElementById('vehicle_select')
      if (vehicleSelect) vehicleSelect.setAttribute('required', 'required')
    } else {
      existingSection.style.display = 'none'
      newSection.style.display = 'block'
      // Clear existing vehicle selection
      const vehicleSelect = document.getElementById('vehicle_select')
      if (vehicleSelect) {
        vehicleSelect.value = ''
        vehicleSelect.removeAttribute('required')
      }
      // Make new vehicle fields required (except year and color which are now optional)
      newSection.querySelectorAll('input[data-required], select[data-required], textarea[data-required]').forEach(field => {
        if (field.id !== 'vehicle_year' && field.id !== 'vehicle_color') {
          field.setAttribute('required', 'required')
        }
      })
    }
  }

  // Handle brand selection for models
  brandChanged(event) {
    const brandId = event.target.value
    const modelSelect = document.getElementById('quote_vehicle_attributes_vehicle_model_id')
    
    console.log("🏷️ Brand changed, ID:", brandId)
    
    if (!brandId) {
      modelSelect.disabled = true
      modelSelect.innerHTML = '<option value="">Primeiro selecione uma marca...</option>'
      return
    }

    // Show loading
    modelSelect.disabled = true
    modelSelect.innerHTML = '<option value="">Carregando modelos...</option>'

    // Fetch models via Hotwire
    fetch(`/vehicle_models/by_brand?brand_id=${brandId}`, {
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`)
      }
      return response.text()
    })
    .then(html => {
      modelSelect.innerHTML = html + '<option value="custom">+ Adicionar novo modelo</option>'
      modelSelect.disabled = false
      console.log("✅ Models loaded successfully")
    })
    .catch(error => {
      console.error('❌ Error loading models:', error)
      modelSelect.innerHTML = '<option value="">Erro ao carregar modelos</option><option value="custom">+ Adicionar novo modelo</option>'
      modelSelect.disabled = false
    })
  }

  // Handle model selection (for custom model option)
  modelChanged(event) {
    const selectedValue = event.target.value
    const customModelSection = document.getElementById('custom-model-section')
    const customModelInput = document.getElementById('custom_model_name')
    
    console.log("🏷️ Model changed, value:", selectedValue)
    
    if (selectedValue === 'custom') {
      customModelSection.style.display = 'block'
      customModelInput.setAttribute('required', 'required')
      customModelInput.focus()
      // Don't clear the model select value, keep it as 'custom' for validation
    } else {
      customModelSection.style.display = 'none'
      customModelInput.removeAttribute('required')
      customModelInput.value = ''
    }
  }

  // Create new model and add to select
  createNewModel(event) {
    const customModelInput = document.getElementById('custom_model_name')
    const modelSelect = document.getElementById('quote_vehicle_attributes_vehicle_model_id')
    const brandSelect = document.getElementById('quote_vehicle_attributes_vehicle_brand_id')
    const customModelSection = document.getElementById('custom-model-section')
    
    if (event.key === 'Enter' && customModelInput.value.trim()) {
      event.preventDefault()
      
      const brandId = brandSelect.value
      const modelName = customModelInput.value.trim()
      
      if (!brandId) {
        this.showAlert('Por favor, selecione uma marca primeiro.')
        return
      }
      
      console.log("🏗️ Creating new model:", modelName, "for brand:", brandId)
      
      // Call the controller to create the model
      fetch('/vehicle_models', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          vehicle_model: {
            name: modelName,
            vehicle_brand_id: brandId
          }
        })
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          // Add new model to select
          const newOption = document.createElement('option')
          newOption.value = data.model.id
          newOption.textContent = data.model.name
          newOption.selected = true
          
          // Insert before the "custom" option
          const customOption = modelSelect.querySelector('option[value="custom"]')
          modelSelect.insertBefore(newOption, customOption)
          
          // Hide custom section and clear input
          customModelSection.style.display = 'none'
          customModelInput.value = ''
          customModelInput.removeAttribute('required')
          
          console.log("✅ New model created and added to select:", data.model.name)
          this.showAlert(`Modelo "${modelName}" criado com sucesso!`, 'success')
        } else {
          console.error("❌ Error creating model:", data.errors)
          this.showAlert('Erro ao criar modelo: ' + data.errors.join(', '))
        }
      })
      .catch(error => {
        console.error('❌ Network error creating model:', error)
        this.showAlert('Erro de conexão ao criar modelo.')
      })
    }
  }

  showAlert(message, type = 'warning') {
    console.log("🚨 Showing alert:", message, type)
    
    const alertClass = type === 'success' ? 'alert-success' : 'alert-warning'
    const icon = type === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-triangle'
    
    // Create a simple toast notification
    const alertHtml = `
      <div class="alert ${alertClass} alert-dismissible fade show position-fixed" 
           style="top: 20px; right: 20px; z-index: 9999; max-width: 300px;" role="alert">
        <i class="${icon} me-2"></i>
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    `
    
    // Remove existing alerts
    document.querySelectorAll('.alert.position-fixed').forEach(alert => alert.remove())
    
    // Add new alert
    document.body.insertAdjacentHTML('beforeend', alertHtml)
    
    // Auto-remove after 4 seconds
    setTimeout(() => {
      const alert = document.querySelector('.alert.position-fixed')
      if (alert) alert.remove()
    }, 4000)
  }
} 