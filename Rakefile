require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "capfire"
    gem.summary = %Q{Send a notification to Campfire after a cap deploy}
    gem.description = %Q{Send a notification to Campfire after a cap deploy}
    gem.email = "piet@10to1.be"
    gem.homepage = "http://github.com/pjaspers/capfire"
    gem.authors = ["pjaspers", "atog"]
    gem.files = FileList['[A-Z]*',
      'lib/**/*.rb',
      'lib/templates/*.erb']
    gem.add_dependency('broach', '>= 0.2.1')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
