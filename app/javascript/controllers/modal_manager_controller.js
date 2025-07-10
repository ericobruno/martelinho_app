import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "form", "customerName", "vehicleInfo", "value", "workOrderValue", "paidAmount", "remainingAmount"]
  static values = { 
    type: String,
    totalCents: Number,
    paidCents: Number
  }

  connect() {
    console.log('🎭 ModalManager controller connected for:', this.typeValue)
    console.log('🎭 Modal element:', this.element)
    console.log('🎭 Has form target:', this.hasFormTarget)
    if (this.hasFormTarget) {
      console.log('🎭 Form target:', this.formTarget)
      console.log('🎭 Form current action:', this.formTarget.action)
    }
    this.setupEventListeners()
  }

  disconnect() {
    console.log('🎭 ModalManager controller disconnected')
    this.cleanupEventListeners()
  }

  show(event) {
    console.log('🎭 Modal show method called', event)
    console.log('🎭 Event type:', event.type)
    console.log('🎭 Event relatedTarget:', event.relatedTarget)
    console.log('🎭 Event currentTarget:', event.currentTarget)
    
    const button = event.relatedTarget || event.currentTarget
    console.log('🎭 Button found:', button)
    
    if (!button) {
      console.error('🎭 No button found in show event')
      return
    }
    
    this.populateModalData(button)
    this.setupFormAction(button)
  }

  populateModalData(button) {
    console.log('🎭 Starting populateModalData')
    const customerName = button.getAttribute('data-customer-name')
    const vehicleInfo = button.getAttribute('data-vehicle-info')
    
    console.log('🎭 Customer name from button:', customerName)
    console.log('🎭 Vehicle info from button:', vehicleInfo)
    
    if (this.hasCustomerNameTarget && customerName) {
      this.customerNameTarget.textContent = customerName
      console.log('🎭 Set customer name target')
    }
    
    if (this.hasVehicleInfoTarget && vehicleInfo) {
      this.vehicleInfoTarget.textContent = vehicleInfo
      console.log('🎭 Set vehicle info target')
    }

    // Handle different modal types
    if (this.typeValue === 'quote-approval') {
      const quoteValue = button.getAttribute('data-quote-value')
      console.log('🎭 Quote value from button:', quoteValue)
      if (this.hasValueTarget && quoteValue) {
        this.valueTarget.textContent = quoteValue
        console.log('🎭 Set quote value target')
      }
    } else if (this.typeValue === 'work-order-finalize') {
      this.populateWorkOrderData(button)
    }
  }

  populateWorkOrderData(button) {
    const workOrderValue = button.getAttribute('data-work-order-value')
    const paidAmount = button.getAttribute('data-paid-amount')
    const remainingAmount = button.getAttribute('data-remaining-amount')
    
    this.totalCentsValue = parseInt(button.getAttribute('data-total-cents')) || 0
    this.paidCentsValue = parseInt(button.getAttribute('data-paid-cents')) || 0
    
    if (this.hasWorkOrderValueTarget && workOrderValue) {
      this.workOrderValueTarget.textContent = workOrderValue
    }
    
    if (this.hasPaidAmountTarget && paidAmount) {
      this.paidAmountTarget.textContent = paidAmount
    }
    
    if (this.hasRemainingAmountTarget && remainingAmount) {
      this.remainingAmountTarget.textContent = remainingAmount
    }

    // Set default payment amount to remaining
    const paymentInput = this.modalTarget.querySelector('#payment_amount')
    if (paymentInput) {
      const remainingCents = this.totalCentsValue - this.paidCentsValue
      paymentInput.value = (remainingCents / 100).toFixed(2)
      paymentInput.max = (remainingCents / 100).toFixed(2)
    }
  }

  setupFormAction(button) {
    console.log('🎭 Starting setupFormAction')
    const id = button.getAttribute('data-quote-id') || button.getAttribute('data-work-order-id')
    
    console.log('🎭 ID from button:', id)
    console.log('🎭 Type value:', this.typeValue)
    console.log('🎭 Has form target:', this.hasFormTarget)
    
    if (this.hasFormTarget && id) {
      console.log('🎭 Form target found, setting action...')
      if (this.typeValue === 'quote-approval') {
        const newAction = `/quotes/${id}/approve`
        this.formTarget.action = newAction
        console.log('🎭 ✅ Form action set to:', newAction)
        console.log('🎭 Form action verified:', this.formTarget.action)
      } else if (this.typeValue === 'work-order-finalize') {
        const newAction = `/work_orders/${id}/finalize`
        this.formTarget.action = newAction
        console.log('🎭 ✅ Form action set to:', newAction)
      }
    } else {
      console.error('🎭 ❌ Form target not found or ID missing')
      console.error('🎭 Form target exists:', this.hasFormTarget)
      console.error('🎭 ID:', id)
    }
  }

  setupEventListeners() {
    // Listen for turbo stream events to close modal
    this.handleTurboStreamBound = this.handleTurboStream.bind(this)
    document.addEventListener('turbo:before-stream-render', this.handleTurboStreamBound)
    
    // Listen for custom modal close events
    this.handleModalCloseBound = this.handleModalClose.bind(this)
    document.addEventListener('modal:close', this.handleModalCloseBound)
    
    // Listen for quote approval events
    this.handleQuoteApprovedBound = this.handleQuoteApproved.bind(this)
    document.addEventListener('quote:approved', this.handleQuoteApprovedBound)
    
    // Setup work order specific listeners
    if (this.typeValue === 'work-order-finalize') {
      this.setupWorkOrderListeners()
    }
  }

  setupWorkOrderListeners() {
    const fullPaymentCheckbox = this.modalTarget.querySelector('#full_payment')
    const paymentAmountInput = this.modalTarget.querySelector('#payment_amount')
    const finalPaymentInput = this.modalTarget.querySelector('#final_payment_amount')
    
    if (fullPaymentCheckbox) {
      fullPaymentCheckbox.addEventListener('change', (e) => {
        if (e.target.checked) {
          const remainingCents = this.totalCentsValue - this.paidCentsValue
          paymentAmountInput.value = (remainingCents / 100).toFixed(2)
          paymentAmountInput.disabled = true
        } else {
          paymentAmountInput.disabled = false
          paymentAmountInput.focus()
        }
      })
    }

    if (this.hasFormTarget) {
      this.formTarget.addEventListener('submit', (e) => {
        if (paymentAmountInput && finalPaymentInput) {
          finalPaymentInput.value = paymentAmountInput.value
        }
      })
    }
  }

  handleTurboStream(event) {
    console.log('🎭 Turbo stream event received')
    
    // We'll rely on the custom events (quote:approved, etc.) to close the modal
    // instead of trying to parse the stream content
    // This makes the modal closing more reliable and predictable
  }

  handleModalClose(event) {
    this.closeModal()
  }

  handleQuoteApproved(event) {
    console.log('🎭 Quote approved event received:', event.detail)
    
    // Close modal after a short delay to allow UI updates
    setTimeout(() => {
      console.log('🎭 Closing modal after quote approval')
      this.closeModal()
    }, 1000)
  }

  closeModal() {
    console.log('🎭 Attempting to close modal')
    const modal = bootstrap.Modal.getInstance(this.modalTarget)
    if (modal) {
      console.log('🎭 Modal instance found, hiding...')
      modal.hide()
    } else {
      console.log('🎭 No modal instance found')
    }
  }

  cleanupEventListeners() {
    if (this.handleTurboStreamBound) {
      document.removeEventListener('turbo:before-stream-render', this.handleTurboStreamBound)
    }
    if (this.handleModalCloseBound) {
      document.removeEventListener('modal:close', this.handleModalCloseBound)
    }
    if (this.handleQuoteApprovedBound) {
      document.removeEventListener('quote:approved', this.handleQuoteApprovedBound)
    }
  }
} 