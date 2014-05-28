# Browserlog

[![Build Status](https://travis-ci.org/dieb/browserlog.svg?branch=master)](https://travis-ci.org/dieb/browserlog)
[![Dependency Status](https://www.versioneye.com/user/projects/5380ec4f14c158fd78000056/badge.svg)](https://www.versioneye.com/user/projects/5380ec4f14c158fd78000056)
[![Code Climate](https://img.shields.io/codeclimate/github/dieb/browserlog.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/dieb/browserlog/badge.png?branch=master)](https://coveralls.io/r/dieb/browserlog?branch=master)

[travis]: http://travis-ci.org/dieb/browserlog
[codeclimate]: https://codeclimate.com/github/dieb/browserlog
[coveralls]: https://coveralls.io/r/dieb/browserlog

Browserlog is a live web log viewer for rails apps.

![Screenshot dark theme](https://dl.dropboxusercontent.com/u/27144161/browserlog-dark.png "Screenshot dark theme")
![Screenshot light theme](https://dl.dropboxusercontent.com/u/27144161/browserlog-light.png "Screenshot light theme")

## Features
* Auto-refresh

## Installation

The simplest way to install Browserlog is to use [Bundler](http://bundler.io).

```ruby
gem 'browserlog', '~> 0.0.1'
```

Browserlog is bundled as a Rails engine. Mount it on `config/routes.rb`.

```ruby
MyApp::Application.routes.draw do
  mount Browserlog::Engine => '/logs'
end
```

With this setup ``logs/development``, ``logs/production`` and ``logs/test`` are automatically available on the browser.

## Note for production environments

For most production environments, it's recommended to not serve logs without authentication. While an authentication scheme
is not yet ready, this gem blocks by default any requests to ``logs/*`` in such production environment (i.e. ``RAILS_ENV=production``).

In case you want to allow those logs to be displayed under production (e.g. staging servers), use the following initializer:

```ruby
# config/initializers/allow_logs_on_production.rb
Browserlog.config.allow_production_logs = true
```

## Supported Rails Versions
* Rails >= 3.2.18 and 4.1.1
