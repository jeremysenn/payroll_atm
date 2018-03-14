Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  get 'welcome/index'
  root 'welcome#index'
  
  resources :customers do
    member do
      get 'one_time_payment'
    end
    collection do
      post 'send_sms_message'
    end
  end
  resources :users
  resources :transactions
  resources :sms_messages
  resources :payroll_batches
  resources :payroll_payments
  
end
