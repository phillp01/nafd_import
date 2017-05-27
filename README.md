# Install
 Install Ruby 2.0+, any version over 2.0 will work
## Install the bundler gem
  
  ```
  gem install bundler
  bundle install
  ```
## In the project directory

### Setup transitionary database
  `rake db:migrate`

### Run import mechanism
  `bundle exec ruby import.rb`

