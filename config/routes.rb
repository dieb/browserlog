Browserlog::Engine.routes.draw do
  get '/', to: 'logs#index'
  get '/changes', to: 'logs#changes'
end
