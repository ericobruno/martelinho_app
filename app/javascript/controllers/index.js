// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

console.log('🎯 Loading Stimulus controllers...')

// Load all controllers automatically
eagerLoadControllersFrom("controllers", application)

console.log('✅ All Stimulus controllers loaded successfully')
