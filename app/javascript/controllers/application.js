import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = true
window.Stimulus = application

// Add error handling
application.handleError = (error, message, detail) => {
  console.error('🚨 Stimulus Error:', {
    error,
    message,
    detail,
    stack: error.stack
  })
}

console.log('🚀 Stimulus Application started with debug mode enabled')

export { application }
