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
    def generate_new_file
        
        open('proposals.txt', 'w') do |f|
            for i in 1..(rand 1..150) 
                task_name = (0...5).map { ('a'..'z').to_a[rand(26)] }.join
                min = rand 1..60
                line = task_name + ' '+min.to_s+'min'
                f.puts line
            end 
        end

    end

    def test_it_ok
        generate_new_file
        post "/upload_task", "file" => Rack::Test::UploadedFile.new("proposals.txt", "text/plain")
        assert_equal 200, last_response.status
        
        assert_include last_response.body,"TRACK A"
        assert_include last_response.body,"9:00"
        assert_include last_response.body,"12:00"
        assert_include last_response.body,"almoço"
        assert_include last_response.body,"networking"

        for j in 1..59
            hora = '12:0'+j.to_s if j < 10
            hora = '12:'+j.to_s if j >= 10
            assert_not_include last_response.body,hora
        end

        for i in 0..8
            for j in 0..59
                hora = '0'+i.to_s+':0'+j.to_s if j < 10
                hora = '0'+i.to_s+':'+j.to_s if j >= 10
                assert_not_include last_response.body,hora
            end
        end

        for i in 17..23
            for j in 0..59
                hora = '0'+i.to_s+':0'+j.to_s if j < 10
                hora = '0'+i.to_s+':'+j.to_s if j >= 10
                assert_not_include last_response.body,hora
            end
        end
        
    end

end
