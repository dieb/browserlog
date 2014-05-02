# Browserlog

[![Build Status](https://img.shields.io/travis/dieb/browserlog.svg)][travis]
[![Dependency Status](https://img.shields.io/gemnasium/dieb/browserlog.svg)][gemnasium]
[![Code Climate](https://img.shields.io/codeclimate/github/dieb/browserlog.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/dieb/browserlog/badge.png?branch=master)](https://coveralls.io/r/dieb/browserlog?branch=master)

[travis]: http://travis-ci.org/dieb/browserlog
[gemnasium]: https://gemnasium.com/dieb/browserlog
[codeclimate]: https://codeclimate.com/github/dieb/browserlog
[coveralls]: https://coveralls.io/r/dieb/browserlog

Browserlog is a live web log viewer for rails apps.

## Features
* Auto-refresh

## Installation

The simplest way to install Browserlog is to use [Bundler](http://bundler.io).

```ruby
gem 'browserlog', '~> 0.0.1', git: 'https://github.com/dieb/browserlog.git'
```

Browserlog is bundled as a Rails engine. Mount it on `config/routes.rb`.

```ruby
MyApplication::Application.routes.draw do
  mount Browserlog::Engine => '/logs', as: 'browserlog_engine'
end
```

## Supported Rails Versions
* Rails ~> 4.1.0
