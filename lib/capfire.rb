# Gem for applications to automatically post to Campfire after an deploy.

require 'broach'

class Capfire
  # To see how it actually works take a gander at the generator
  # or in the capistrano.rb
  class << self
    def config_file_path
      "config/capfire.yml"
    end

    def config_file_exists?
      File.exists?( config_file_path )
    end

    def valid_config?
      config = self.config
      config["pre_message"] && config["post_message"] && config["room"] && config ["token"] && config["account"]
    end

    def config
      YAML::load( File.open( config_file_path ) )
    end

    # Campfire room
    def room
      self.config["room"]
    end

    # Campfire account
    def account
      self.config["account"]
    end

    # Campfire token
    def token
      self.config["token"]
    end

    # Who is deploying
    def deployer
      ENV["USER"]
    end

    # Link to github's excellent Compare View
    def github_compare_url(repo_url, first_commit, last_commit)
      repo_url.gsub!(/git@/, 'http://')
      repo_url.gsub!(/\.com:/,'.com/')
      repo_url.gsub!(/\.git/, '')
      "#{repo_url}/compare/#{first_commit}...#{last_commit}"
    end

    def default_idiot_message
      "lol. #deployer# wanted to deploy #application#, but forgot to push first."
    end

    # Message to post on deploying without pushing
    def idiot_message(application)
      message = self.config["idiot_message"]
      message = default_idiot_message unless message
      message.gsub!(/#deployer#/, self.deployer)
      message.gsub!(/#application#/, application)
      message
    end

    # Message to post to campfire on deploy
    def pre_deploy_message(args,compare_url, application)
      message = self.config["pre_message"]
      message.gsub!(/#deployer#/, deployer)
      message.gsub!(/#application#/, application)
      message.gsub!(/#args#/, args)
      message.gsub!(/#compare_url#/, compare_url)
      message
    end

    # Message to post to campfire on deploy
    def post_deploy_message(args,compare_url, application)
      message = self.config["post_message"]
      message.gsub!(/#deployer#/, deployer)
      message.gsub!(/#application#/, application)
      message.gsub!(/#args#/, args)
      message.gsub!(/#compare_url#/, compare_url)
      message
    end

    # Initializes a broach campfire room
    def broach_room
      Broach.settings = {
        'account' => self.account,
        'token' => self.token,
        'use_ssl' => true
      }
      Broach::Room.find_by_name(self.room)
    end

    # Posts to campfire
    def speak(message)
      self.broach_room.speak(message)
    end

  end

end
