require 'faye/websocket'
require 'nfc'
require 'json'

module Taptapgo

  class Frontend
    KEEPALIVE_TIME = 15

    def initialize(app)
      @app = app
      @clients = []

      # Start NFC Reader
      @nfc_context = NFC::Context.new
      @nfc_device = @nfc_context.open nil

      @current_serial_no = "0";

      # Spawn thread
      Thread.new do
        puts "NFC Thread Started"

        while true
          # Poll the device
          @card_content = @nfc_device.poll

          # If there is card
          if @card_content.class == NFC::ISO14443A
            uid = @card_content.uid.collect! { |x| x.to_s(16) }.reverse!.join.to_i(16).to_s.rjust(10, "0")

            next if @current_serial_no == uid

            puts uid
            
            # Mock sending API request
            @current_serial_no = uid
            @send_object = {:status_code => 200, :content => uid}.to_json
            
            puts @send_object

            @clients.each { |client| client.send(@send_object) }

          # No Card
          elsif @card_content == -90

            next
          end

        end
      end

    end

    def call(env)
      if Faye::WebSocket.websocket?(env)

        # Websocket thing
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME})

        # On new connection
        ws.on :open do |event|
          p [:open, ws.object_id]
          @clients << ws
        end

        # On message, dont think we will ever use this
        ws.on :message do |event|
          p [:message, event.data]
        end

        # On disconnection
        ws.on :close do |event|
          p [:closed, ws.object_id, event.code, event.reason]
          @clients.delete(ws)
        end

        # Return async ws response, I dunno WTF it means
        ws.rack_response
      else
      	@app.call(env)
      end
    end

  end

end