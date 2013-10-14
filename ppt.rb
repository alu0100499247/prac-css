require 'rack/request'
require 'rack/response'
require 'haml'


module PiedraPapelTijeras
	class App
		def initialize(app=nil)
			@app = app
			@content_type = :html
			@defeat = {'piedra' => 'tijeras', 'papel' => 'piedra', 'tijeras' => 'papel'}
			@throws = @defeat.keys
		end

		def call(env)
			req = Rack::Request.new(env)

			req.env.keys.sort.each { |x| puts "#{x} => #{req.env[x]}" }
			
			computer_throw = @throws.sample
			player_throw = req.GET["choice"]
			answer = if !@throws.include?(player_throw)
				"Elige una de las siguientes opciones:"
			elsif player_throw == computer_throw
				"Has empatado! Elige de nuevo :)"
			elsif computer_throw == @defeat[player_throw]
				"Bien! #{player_throw} gana a #{computer_throw}!! :D"
			else
				"Ohh! :( #{computer_throw} gana a #{player_throw}! Suerte en la próxima! ;)"
			end

			engine = Haml::Engine.new File.open("views/index.haml").read
			res = Rack::Response.new
			res.write engine.render({},
				:answer => answer,
				:throws => @throws)
			res.finish
		end
	end
end

if $0 == __FILE__
	require 'rack'
	require 'rack/showexceptions'

	builder = Rack::Builder.new do
		use Rack::Static, :urls => ['/public']
		use Rack::ShowExceptions
		use Rack::Lint

		run PiedraPapelTijeras::App.new
	end

	Rack::Handler::Thin.run builder
end








