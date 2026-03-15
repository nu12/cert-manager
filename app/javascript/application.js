// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('turbo:load',() => {
  const toastElList = document.querySelectorAll('.toast')
  toastElList.forEach(toastEl => {
    new bootstrap.Toast(toastEl, {"autohide": true}).show()
  })
})