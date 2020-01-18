# Install Gems
bundle check || bundle install

# Update Gems
bundle update

# Run Rails application
bundle exec rails server -b 0.0.0.0
