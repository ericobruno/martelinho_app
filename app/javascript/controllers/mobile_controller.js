import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "quickActions"]
  static values = { 
    swipeThreshold: { type: Number, default: 50 },
    hapticFeedback: { type: Boolean, default: true }
  }

  connect() {
    console.log('📱 Enhanced Mobile controller connected')
    this.setupTouchHandlers()
    this.setupResponsiveObserver()
    this.optimizeForMobile()
  }

  disconnect() {
    this.cleanup()
  }

  setupTouchHandlers() {
    this.cardTargets.forEach(card => {
      let startX = 0
      let startY = 0
      let currentX = 0
      let currentY = 0
      let isDragging = false

      // Touch start
      card.addEventListener('touchstart', (e) => {
        startX = e.touches[0].clientX
        startY = e.touches[0].clientY
        currentX = startX
        currentY = startY
        
        // Add slight scale for touch feedback
        card.style.transition = 'transform 0.1s ease'
        card.style.transform = 'scale(0.98)'
        
        if (this.hapticFeedbackValue && navigator.vibrate) {
          navigator.vibrate(10)
        }
      }, { passive: true })

      // Touch move
      card.addEventListener('touchmove', (e) => {
        if (!isDragging) {
          currentX = e.touches[0].clientX
          currentY = e.touches[0].clientY
          
          const deltaX = Math.abs(currentX - startX)
          const deltaY = Math.abs(currentY - startY)
          
          // Start dragging if moved beyond threshold
          if (deltaX > 10 || deltaY > 10) {
            isDragging = true
            
            // Check if horizontal swipe
            if (deltaX > deltaY && deltaX > this.swipeThresholdValue) {
              this.handleSwipe(card, currentX > startX ? 'right' : 'left')
            }
          }
        }
      }, { passive: true })

      // Touch end
      card.addEventListener('touchend', (e) => {
        // Reset scale
        card.style.transform = 'scale(1)'
        
        if (!isDragging) {
          // This was a tap, not a swipe
          this.handleTap(card, e)
        }
        
        isDragging = false
      }, { passive: true })

      // Touch cancel
      card.addEventListener('touchcancel', (e) => {
        card.style.transform = 'scale(1)'
        isDragging = false
      }, { passive: true })
    })
  }

  handleSwipe(card, direction) {
    const quickActions = card.querySelector('.quick-actions')
    
    if (direction === 'left' && quickActions) {
      // Show quick actions
      quickActions.style.transform = 'translateX(0)'
      quickActions.style.opacity = '1'
      card.classList.add('swiped')
      
      if (this.hapticFeedbackValue && navigator.vibrate) {
        navigator.vibrate(20)
      }
      
      // Auto-hide after 3 seconds
      setTimeout(() => {
        this.hideQuickActions(card)
      }, 3000)
    } else if (direction === 'right') {
      // Hide quick actions
      this.hideQuickActions(card)
    }
  }

  hideQuickActions(card) {
    const quickActions = card.querySelector('.quick-actions')
    if (quickActions) {
      quickActions.style.transform = 'translateX(100%)'
      quickActions.style.opacity = '0'
      card.classList.remove('swiped')
    }
  }

  handleTap(card, event) {
    // Enhanced tap handling for better mobile UX
    const target = event.target
    
    // Check if tap was on a button or link
    if (target.closest('a, button')) {
      return // Let the normal click handler take care of it
    }
    
    // If tap was on the card itself, navigate to details
    const cardId = card.getAttribute('data-id')
    const cardType = card.getAttribute('data-type')
    
    if (cardId && cardType) {
      // Add visual feedback
      card.style.backgroundColor = '#f8f9fa'
      setTimeout(() => {
        card.style.backgroundColor = ''
      }, 200)
      
      // Navigate after feedback
      setTimeout(() => {
        if (cardType === 'quote') {
          window.location.href = `/quotes/${cardId}`
        } else if (cardType === 'work_order') {
          window.location.href = `/work_orders/${cardId}`
        }
      }, 150)
    }
  }

  setupResponsiveObserver() {
    // Monitor viewport changes for better responsive behavior
    if (window.ResizeObserver) {
      this.resizeObserver = new ResizeObserver((entries) => {
        this.handleResize()
      })
      this.resizeObserver.observe(document.body)
    }
    
    // Also listen for orientation changes
    window.addEventListener('orientationchange', () => {
      setTimeout(() => this.handleResize(), 100)
    })
  }

  handleResize() {
    const isMobile = window.innerWidth < 768
    
    if (isMobile) {
      this.optimizeForMobile()
    } else {
      this.optimizeForDesktop()
    }
  }

  optimizeForMobile() {
    // Add mobile-specific optimizations
    document.body.classList.add('mobile-optimized')
    
    // Improve button sizes for touch
    const buttons = document.querySelectorAll('.btn-sm')
    buttons.forEach(btn => {
      btn.style.minHeight = '44px' // Apple's recommended touch target size
      btn.style.minWidth = '44px'
    })
    
    // Add padding to prevent accidental touches
    const cards = document.querySelectorAll('.card')
    cards.forEach(card => {
      card.style.marginBottom = '1rem'
    })
  }

  optimizeForDesktop() {
    document.body.classList.remove('mobile-optimized')
    
    // Reset mobile optimizations
    const buttons = document.querySelectorAll('.btn-sm')
    buttons.forEach(btn => {
      btn.style.minHeight = ''
      btn.style.minWidth = ''
    })
  }

  // Quick action methods
  editItem(event) {
    const card = event.target.closest('[data-id]')
    const id = card.getAttribute('data-id')
    const type = card.getAttribute('data-type')
    
    if (type === 'quote') {
      window.location.href = `/quotes/${id}/edit`
    } else if (type === 'work_order') {
      window.location.href = `/work_orders/${id}/edit`
    }
  }

  deleteItem(event) {
    const card = event.target.closest('[data-id]')
    const id = card.getAttribute('data-id')
    const type = card.getAttribute('data-type')
    
    if (confirm('Tem certeza que deseja excluir este item?')) {
      // Add loading state
      card.style.opacity = '0.5'
      card.style.pointerEvents = 'none'
      
      // Perform delete
      if (type === 'quote') {
        this.performDelete(`/quotes/${id}`)
      } else if (type === 'work_order') {
        this.performDelete(`/work_orders/${id}`)
      }
    }
  }

  performDelete(url) {
    fetch(url, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Accept': 'text/vnd.turbo-stream.html'
      }
    }).then(response => {
      if (response.ok) {
        // Success feedback
        if (this.hapticFeedbackValue && navigator.vibrate) {
          navigator.vibrate([20, 10, 20])
        }
      } else {
        // Error feedback
        alert('Erro ao excluir item')
        if (this.hapticFeedbackValue && navigator.vibrate) {
          navigator.vibrate(100)
        }
      }
    }).catch(error => {
      console.error('Delete error:', error)
      alert('Erro ao excluir item')
    })
  }

  cleanup() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect()
    }
    window.removeEventListener('orientationchange', this.handleResize)
  }
} 