require 'UsqueCensus/version'
require 'rails'
module UsqueCensus
  class Railtie < Rails::Railtie
    railtie_name :usque_census

    rake_tasks do
      load "tasks/test.rake"
    end
  end
end