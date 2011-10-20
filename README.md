# Pivotal Hook Proxy

**A simple Rack app that allows you to use any number of Activity Web Hooks on your Pivotal Tracker projects by acting as an endpoint to them and forwarding the calls from Tracker to any number of configurable other urls**

***Note: This is a work in progress and has not been released as a gem yet!***

## Usage

Create a Gemfile containing:

    source :rubygems
    gem 'pivotal-hook-proxy'

Create a config.ru:

    require 'bundler/setup'
    require 'pivotal-hook-proxy'

    forward 'project_a', 'https://your.endpoint.com/for/tracker'
    forward 'project_a', 'https://someother.com/tracker?token=1234'

    forward 'project_b', 'https://someother.com/tracker?token=1234'    

    run PivotalHookProxy

Deploy the application using a rack-compatible web server, then configure your individual Pivotal Tracker projects to post Activity Web Hooks to:

    http://yourproxy.url/activity/project_a # for Project A
    http://yourproxy.url/activity/project_b # for Project B

## Developer notes

  * Clone the project
  * bundle install
  * rake test

## Copyright

Copyright (c) 2011 Christoph Olszowka, Capita Unternehmensberatung GmbH. See LICENSE for details.