Rails.application.routes.draw do
  root 'cyoa_book#show'
  get 'cyoa_book/show'
  post 'cyoa_book/create'
end
