require_relative 'main.rb'
require 'rspec'
require 'test/unit'
require 'rack/test' 

ENV['ENV_ENV'] = 'test'

class IndexTest < Test::Unit::TestCase
include Rack::Test::Methods

def app
    Sinatra::Application
end

def test_it_post_ok
    post "/upload_task", "file" => Rack::Test::UploadedFile.new("proposals.txt", "text/plain")
    assert_equal 200, last_response.status
    assert_include last_response.body,"9:00"
    assert_include last_response.body,"12:00"
    assert_include last_response.body,"17:00"
    assert_not_include last_response.body,"00:"

    cont = 1
    while cont < 9 do
        assert_not_include last_response.body,"0"+cont.to_s+":"
        cont += 1
    end

    cont = 18
    while cont < 24 do
        assert_not_include last_response.body,cont.to_s+":"
        cont += 1
    end
    
end



end
