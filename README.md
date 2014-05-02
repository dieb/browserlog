# Browserlog

Browserlog is a live web log viewer for rails apps.

## Features
* Auto-refresh

## Installation

The simplest way to install Browserlog is to use [Bundler](http://bundler.io).

```ruby
gem 'browserlog', '~> 0.0.1', git: 'https://github.com/dieb/browserlog.git'
```

Browserlog is bundled as a Rails engine. To begin mount it on your routes file.

```ruby
# config/routes.rb

MyApplication::Application.routes.draw do
  mount Browserlog::Engine => '/logs', as: 'browserlog_engine'
end
```
