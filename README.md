# Pivotal Tracker Activity Webhook Forwarder

**A simple Rack app that allows you to use any number of Activity Web Hooks on your Pivotal Tracker projects by acting as an endpoint to them and forwarding the calls from Tracker to any number of configurable other urls**

## Usage

In a new app folder, add those files:

A `Gemfile` containing:

    source :rubygems
    gem 'tracker-hook-forwarder'

A `config.ru` containing:

    require 'bundler/setup'
    require 'tracker-hook-forwarder'

    forward 'project_a', 'https://your.endpoint.com/for/tracker'
    forward 'project_a', 'https://someother.com/tracker?token=1234'

    forward 'project_b', 'https://someother.com/tracker?token=1234'    

    run TrackerHookForwarder

Deploy the application using a rack-compatible web server (or Heroku, see section below), then configure your individual Pivotal Tracker projects to post Activity Web Hooks to:

    http://yourproxy.url/activity/project_a # for Project A
    http://yourproxy.url/activity/project_b # for Project B

For example, we use it to notify both our [Hipchat](http://www.hipchat.com) team room and our own 
[Redmine-Tracker plugin](https://github.com/capita/redmine_trackmine) using a config like this:

    forward 'some_project', 'http://redmine.url.com/pivotal_activity.xml'
    forward 'some_project', 'https://api.hipchat.com/v1/webhooks/pivotaltracker/?auth_token=API_TOKEN&room_id=ROOM_ID'

## Testing

[Postbin](http://www.postbin.org/) is a handy way to check whether requests are forwarded 
correctly. Go to http://www.postbin.org/ and create a bin, then configure it for one of your 
projects using `forward 'project', 'http://www.postbin.org/TOKEN'`. Going to your postbin url
should give you a list of all activity hooks tracker has sent to you.

## Running on Heroku

Arguably the easiest way to get the proxy up and running is to spin up a Heroku app.
Assuming you've got the `heroku` gem installed and configured and the configuration
set up as above using git, run:

    heroku create your-app-name --stack cedar

You might also want to add `thin` to your Gemfile and a `Procfile` containing:

    web: bundle exec thin start -p $PORT

Then commit your changes and push your app to heroku:

    git push heroku master

Going to your newly created app's url should now give you "Hello."

**Important:** Heroku by default idles out free applications (those that only use 1 dyno)
after a couple of minutes and further requests need to spin up a whole new instance, which
takes some time. To prevent your app from idling out, and also to get the benefit of availability monitoring, use a service like [WasItUp](http://wasitup.com/) to monitor
the site. Simply go to WasItUp, enter your app url, expect the content to be "Hello." and
enter your mail address. Your proxy should be up all night.

## Developer notes

  * Clone the project
  * bundle install
  * rake test

## Copyright

Copyright (c) 2011 Christoph Olszowka, Capita Unternehmensberatung GmbH. See LICENSE for details.