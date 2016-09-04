require "coveralls"
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rspec"
require "dynamoid"
require "pry"
require "aws-sdk-resources"

require "dynamodb_local"

ENV["ACCESS_KEY"] ||= "abcd"
ENV["SECRET_KEY"] ||= "1234"

Aws.config.update({
          region: "us-west-2",
          credentials: Aws::Credentials.new(ENV["ACCESS_KEY"], ENV["SECRET_KEY"])
          })

Dynamoid.configure do |config|
  config.endpoint = "http://127.0.0.1:8000"
  config.namespace = "dynamoid_tests"
  config.warn_on_scan = false
end

Dynamoid.logger.level = Logger::FATAL

MODELS = File.join(File.dirname(__FILE__), "app/models")

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Dir["#{File.dirname(__FILE__)}/app/field_types/*.rb"].each {|f| require f}

Dir[ File.join(MODELS, "*.rb") ].sort.each { |file| require file }

RSpec.configure do |config|
  config.order = :random
  config.raise_errors_for_deprecations!
  config.alias_it_should_behave_like_to :configured_with, "configured with"

  config.before(:each) do
    while !DynamoDBLocal.ensure_is_running!
      puts "Sleeping to allow DynamoDB to finish booting"
      sleep 5 # wait 5 seconds after restarting dynamodblocal
    end
    DynamoDBLocal.delete_all_specified_tables!
  end

  config.after(:each) do
    while !DynamoDBLocal.ensure_is_running!
      puts "Sleeping to allow DynamoDB to finish booting"
      sleep 5 # wait 5 seconds after restarting dynamodblocal
    end
    DynamoDBLocal.delete_all_specified_tables!
  end

end

