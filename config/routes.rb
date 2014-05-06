Browserlog::Engine.routes.draw do
  get ':env', to: 'logs#index'
  get ':env/changes', to: 'logs#changes'
end
