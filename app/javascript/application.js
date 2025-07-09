// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

console.log('🔥 Hotwire Application initialized successfully')

// Bootstrap is loaded via CDN in layout, check if it's available
document.addEventListener('DOMContentLoaded', () => {
  console.log('📋 Bootstrap loaded via CDN:', typeof window.bootstrap !== 'undefined' ? '✅' : '❌')
})
