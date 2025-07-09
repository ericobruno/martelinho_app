import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "button", "form"]
  static values = { 
    swipeThreshold: { type: Number, default: 50 },
    longPressDelay: { type: Number, default: 500 }
  }

  connect() {
    this.setupMobileOptimizations()
    this.setupSwipeGestures()
    this.setupLongPress()
  }

  disconnect() {
    this.removeEventListeners()
  }

  setupMobileOptimizations() {
    // Add mobile-specific classes
    if (this.isMobile()) {
      document.body.classList.add('mobile-device')
      this.element.classList.add('mobile-optimized')
    }

    // Optimize touch targets
    this.buttonTargets.forEach(button => {
      button.style.minHeight = '44px'
      button.style.minWidth = '44px'
    })
  }

  setupSwipeGestures() {
    this.cardTargets.forEach(card => {
      let startX = 0
      let startY = 0
      let currentX = 0
      let currentY = 0

      const handleTouchStart = (e) => {
        startX = e.touches[0].clientX
        startY = e.touches[0].clientY
      }

      const handleTouchMove = (e) => {
        currentX = e.touches[0].clientX
        currentY = e.touches[0].clientY
      }

      const handleTouchEnd = () => {
        const deltaX = currentX - startX
        const deltaY = currentY - startY

        if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > this.swipeThresholdValue) {
          if (deltaX > 0) {
            this.handleSwipeRight(card)
          } else {
            this.handleSwipeLeft(card)
          }
        }
      }

      card.addEventListener('touchstart', handleTouchStart, { passive: true })
      card.addEventListener('touchmove', handleTouchMove, { passive: true })
      card.addEventListener('touchend', handleTouchEnd, { passive: true })
    })
  }

  setupLongPress() {
    this.cardTargets.forEach(card => {
      let pressTimer = null

      const handleTouchStart = () => {
        pressTimer = setTimeout(() => {
          this.handleLongPress(card)
        }, this.longPressDelayValue)
      }

      const handleTouchEnd = () => {
        if (pressTimer) {
          clearTimeout(pressTimer)
          pressTimer = null
        }
      }

      card.addEventListener('touchstart', handleTouchStart, { passive: true })
      card.addEventListener('touchend', handleTouchEnd, { passive: true })
      card.addEventListener('touchcancel', handleTouchEnd, { passive: true })
    })
  }

  handleSwipeLeft(card) {
    // Show quick actions on swipe left
    const actions = card.querySelector('.quick-actions')
    if (actions) {
      actions.style.transform = 'translateX(0)'
      actions.style.opacity = '1'
    }
  }

  handleSwipeRight(card) {
    // Hide quick actions on swipe right
    const actions = card.querySelector('.quick-actions')
    if (actions) {
      actions.style.transform = 'translateX(100%)'
      actions.style.opacity = '0'
    }
  }

  handleLongPress(card) {
    // Show context menu or additional options
    this.showContextMenu(card)
  }

  showContextMenu(card) {
    const menu = document.createElement('div')
    menu.className = 'context-menu'
    menu.innerHTML = `
      <div class="context-menu-item" data-action="edit">
        <i class="fas fa-edit"></i> Editar
      </div>
      <div class="context-menu-item" data-action="delete">
        <i class="fas fa-trash"></i> Excluir
      </div>
    `

    menu.addEventListener('click', (e) => {
      const action = e.target.closest('.context-menu-item')?.dataset.action
      if (action) {
        this.handleContextMenuAction(card, action)
      }
      this.hideContextMenu()
    })

    document.body.appendChild(menu)
    
    // Position menu near the card
    const rect = card.getBoundingClientRect()
    menu.style.position = 'fixed'
    menu.style.left = `${rect.left}px`
    menu.style.top = `${rect.bottom + 10}px`
    menu.style.zIndex = '1000'

    // Hide menu when clicking outside
    setTimeout(() => {
      document.addEventListener('click', this.hideContextMenu.bind(this), { once: true })
    }, 100)
  }

  hideContextMenu() {
    const menu = document.querySelector('.context-menu')
    if (menu) {
      menu.remove()
    }
  }

  handleContextMenuAction(card, action) {
    const id = card.dataset.id
    const type = card.dataset.type

    switch (action) {
      case 'edit':
        if (type === 'quote') {
          window.location.href = `/quotes/${id}/edit`
        } else if (type === 'work_order') {
          window.location.href = `/work_orders/${id}/edit`
        }
        break
      case 'delete':
        if (confirm('Tem certeza que deseja excluir este item?')) {
          if (type === 'quote') {
            this.deleteQuote(id)
          } else if (type === 'work_order') {
            this.deleteWorkOrder(id)
          }
        }
        break
    }
  }

  async deleteQuote(id) {
    try {
      const response = await fetch(`/quotes/${id}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html'
        }
      })
      
      if (response.ok) {
        const card = document.querySelector(`[data-id="${id}"][data-type="quote"]`)
        if (card) {
          card.remove()
        }
      }
    } catch (error) {
      console.error('Error deleting quote:', error)
    }
  }

  async deleteWorkOrder(id) {
    try {
      const response = await fetch(`/work_orders/${id}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html'
        }
      })
      
      if (response.ok) {
        const card = document.querySelector(`[data-id="${id}"][data-type="work_order"]`)
        if (card) {
          card.remove()
        }
      }
    } catch (error) {
      console.error('Error deleting work order:', error)
    }
  }

  isMobile() {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ||
           window.innerWidth <= 768
  }

  removeEventListeners() {
    // Clean up event listeners if needed
  }
} 