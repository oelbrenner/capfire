# Capistrano task for posting to Campfire.
#
# There are two ways to use Capfire, either run the generator (see the README)
# or add 'require "capfire/capistrano"' to your deploy.rb.

require 'capfire'

Capistrano::Configuration.instance(:must_exist).load do
  if Capfire.valid_config?
    before "deploy", "capfire:pre_announce"
    after "deploy", "capfire:post_announce"
  else
    logger.info "Not all required keys found in your config/capfire.yml file."
  end

  namespace :capfire do

    desc "Pre-announce the deploy in Campfire"
    task :pre_announce do
      begin
        source_repo_url = repository.clone
        logger.info 'Finding Deployed Version'
        deployed_version = previous_revision[0,7] rescue "000000"
        logger.info "* Done (#{deployed_version})"
        logger.info 'Finding Local Version'
        local_version = `git rev-parse HEAD`[0,7]
        logger.info "* Done (#{local_version})"
        
        logger.info 'Building Github Compare URL'
        COMPARE_URL = Capfire.github_compare_url source_repo_url, deployed_version, local_version
        logger.info 'Building Message'
        message = Capfire.pre_deploy_message(ARGV.join(' '), COMPARE_URL, application)

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
        message = Capfire.post_deploy_message(ARGV.join(' '), COMPARE_URL, application)

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
