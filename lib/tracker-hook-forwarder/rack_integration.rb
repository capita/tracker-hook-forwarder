# Makes it possible to simply use the following in config.ru
#   
#   forward 'my_project', 'https://xyz.com'
#
module TrackerHookForwarder::RackIntegration
  def forward(project, url)
    TrackerHookForwarder.add_forwarding project, url
    STDOUT.puts "Will forward POSTs on /activity/#{project} to #{url}"
  end
end