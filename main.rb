# Requires the Gemfile
require 'bundler' ; Bundler.require
require 'time'
require 'active_support/time'
require 'json'
require 'sinatra/cross_origin'

before do
    content_type :json    
    headers 'Access-Control-Allow-Origin' => '*', 
             'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']  
end

limit = 10000

post '/upload_task' do
    a = {}
    talks = {} 
    line_cont = 0
    chars = %w(A B C D E F G H J K L M N O P Q R S T U V W X Y Z )

    filename = params[:file][:filename]
    tempfile = params[:file][:tempfile]
    target = "#{filename}"
    File.open(target, 'wb') {|f| f.write tempfile.read }
    File.readlines('proposals.txt').each do |line|
        line_cont += 1
        talks[line_cont] = line.strip
    end

    talks.each do |key,value|
        aux = value.scan(/\w+|\W/).last.scan(/\d+/).first
        aux = 5 if aux == nil
        a[key] = aux.to_i
    end

    w = a.clone 
    final_resp = {}
    track = 0

    while a != {}
        track += 1
        resp = []
        #descobre sequencia até o almoço
        sample_size = 1
        best_sample = []
        while sample_size <= a.values.count
            cont = 1
            while cont < limit do
                cont += 1
                b = a.values.sample(sample_size)
                #guarda melhor sample até o momento, o mais proximo dos 180 minutos
                if b.sum < 180 and b.sum > best_sample.sum
                    best_sample = b
                end
                if b.sum == 180
                    best_sample = b
                    break
                end
            end
            if b.sum != 180
                sample_size += 1
            else
                break 
            end
        end

        best_sample.each do |c|
            a.tap {
                |d| resp << a.key(c)
                d.delete(a.key(c))
            }
        end

        #descobre sequencia até hora do networking
        sample_size = 1
        best_sample = []
        while sample_size <= a.values.count
            cont = 1
            while cont < limit do
                cont += 1
                b = a.values.sample(sample_size)
                #guarda melhor sample até o momento, o mais proximo dos 240 minutos
                if b.sum < 240 and b.sum > best_sample.sum
                    best_sample = b
                end
                if b.sum == 240
                    best_sample = b 
                    break
                end
            end
            if b.sum != 240
                sample_size += 1
            else
                break 
            end
        end

        best_sample.each do |c|
            a.tap {
                |d| resp << a.key(c)
                d.delete(a.key(c))
            }
        end

        final_resp[track] = resp
        
    end

    #mostra resultado
    cont = 0
    result = []
    final_resp.each do |key, value|
        clock = Time.parse("9:00")
        result << "TRACK " + chars[key-1]
        value.each do |k|
            cont += 1
            if clock.strftime("%H:%M").to_s == "12:00"
                result << "12:00 almoço"
                clock = Time.parse("13:00")
                result << clock.strftime("%H:%M").to_s + ' ' + talks[k].to_s  unless w[k].nil?
                clock = clock + w[k].minutes unless w[k].nil?
            else  
                if (clock + w[k].minutes > Time.parse("12:00")) and (clock + w[k].minutes < Time.parse("13:00"))  
                    result << "12:00 almoço"
                    clock = Time.parse("13:00")
                else
                    result << clock.strftime("%H:%M").to_s + ' ' + talks[k].to_s  unless w[k].nil?
                    clock = clock + w[k].minutes unless w[k].nil?
                end
            end

            if cont == value.count
                result << "12:00 almoço" if clock < Time.parse("12:00")
                if clock < Time.parse("16:00")
                    result << "16:00 networking"
                else
                    result << "17:00 networking"
                end
                cont = 0
            end
        end
    end

    content_type :json
    result.to_json

end