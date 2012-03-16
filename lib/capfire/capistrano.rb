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
        if Capfire.valid_credentials?
          source_repo_url = repository.clone

          deployed_version = previous_revision[0,7] rescue "000000"
          local_version = `git rev-parse HEAD`[0,7]

          COMPARE_URL = Capfire.github_compare_url source_repo_url, deployed_version, local_version
          message = Capfire.pre_deploy_message(ARGV.join(' '), COMPARE_URL, application)

          if dry_run
            logger.info "Stage is:\n#{stage}"
            logger.info "Capfire would have posted:\n#{message}"
          else
            Capfire.speak message
            if stage.to_s == 'production'
              logger.info "Production mode.. playing sound"
              Capfire.pre_deploy_sound
            end
            logger.info "Posting to Campfire"
          end
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
        if Capfire.valid_credentials?
          message = Capfire.post_deploy_message(ARGV.join(' '), COMPARE_URL, application)

          if dry_run
            logger.info "Capfire would have posted:\n#{message}"
          else
            Capfire.speak message
            Capfire.post_deploy_sound
            logger.info "Posting to Campfire"
          end
        end
      rescue => e
        # Making sure we don't make capistrano fail.
        # Cause nothing sucks donkeyballs like not being able to deploy
        logger.important e.message
      end
    end
  end
end
