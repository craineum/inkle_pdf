Rails.application.routes.draw do
  root 'uploads#show'
  get 'uploads/show'
  post 'uploads/create'
end
