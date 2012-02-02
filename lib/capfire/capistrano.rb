# Capistrano task for posting to Campfire.
#
# There are two ways to use Capfire, either run the generator (see the README)
# or add 'require "capfire/capistrano"' to your deploy.rb.

require 'capfire'

Capistrano::Configuration.instance(:must_exist).load do
  if Capfire.valid_config?
    before "deploy", "capfire:check_for_push"
    before "deploy", "capfire:pre_announce"
    after "deploy", "capfire:post_announce"
  else
    logger.info "Not all required keys found in your config/capfire.yml file."
  end

  namespace :capfire do

    desc "Check if local version was pushed to github"
    task :check_for_push do
      deployed_version = current_revision[0,7] rescue "0000000"
      local_version = `git rev-parse HEAD`[0,7]

      if deployed_version == local_version
        Capfire.speak(Capfire.idiot_message(application)) unless dry_run
        logger.important "\nDidn't you forget something? A hint: `git push`."
        exit
      end
    end

    desc "Pre-announce the deploy in Campfire"
    task :pre_announce do
      begin
        source_repo_url = repository.clone
        deployed_version = previous_revision[0,7] rescue "000000"
        local_version = `git rev-parse HEAD`[0,7]

        COMPARE_URL = Capfire.github_compare_url source_repo_url, deployed_version, local_version
        message = Capfire.deploy_message(ARGV.join(' '), COMPARE_URL, application)

        if dry_run
          logger.info "Capfire would have posted:\n#{message}"
        else
          Capfire.speak message
          logger.info "Posting to Campfire"
        end
      rescue => e
        # Making sure we don't make capistrano fail.
        # Cause nothing sucks donkeyballs like not being able to deploy
        logger.important e.message
      end
    end

    desc "Announce the deploy finished in Campfire"
    task :post_announce do
      begin
        message = Capfire.deploy_message(ARGV.join(' '), COMPARE_URL, application)

        if dry_run
          logger.info "Capfire would have posted:\n#{message}"
        else
          Capfire.speak message
          logger.info "Posting to Campfire"
        end
      rescue => e
        # Making sure we don't make capistrano fail.
        # Cause nothing sucks donkeyballs like not being able to deploy
        logger.important e.message
      end
    end
  end
end
