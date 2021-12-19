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

#elaborar uma função que cria arquivo texto com diferentes palestras com periodos aleatorios 

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

    #verifica horarios errados após o almoço
    cont = 1
    while cont < 60 do
        if cont < 10
            assert_not_include last_response.body,"12:0"+cont.to_s
        else
            assert_not_include last_response.body,"12:"+cont.to_s
        end
        cont += 1
    end

    #verifica horarios errados antes das 9:00
    cont_a = 1
    cont_b = 9
    while cont_b < 9 do
        while cont_a < 60 do
            assert_not_include last_response.body,cont_b.to_s+":"+cont.to_s
            cont_a += 1
        end
        cont_b += 1
    end
    
    #verifica horaios errados após as 17:00
    cont_a = 1
    cont_b = 17
    while cont_b < 24 do
        while cont_a < 60 do
            assert_not_include last_response.body,cont_b.to_s+":"+cont.to_s
            cont_a += 1
        end
        cont_b += 1
    end
    
end



end
