Rails.application.routes.draw do
  mount Browserlog::Engine => '/logs'
end
