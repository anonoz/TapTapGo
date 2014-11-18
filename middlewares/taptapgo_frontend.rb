require 'faye/websocket'
require 'nfc'
require 'rest-client'
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

      @current_serial_no = "0"
      @tapped_cards = []

      # Spawn thread
      Thread.new do
        puts "NFC Thread Started"

        while true
          # Poll the device
          @card_content = @nfc_device.poll

          # If there is card
          if @card_content.class == NFC::ISO14443A

            # Get the card serial no
            uid = @card_content.uid.collect! { |x| x.to_s(16) }.reverse!.join.to_i(16).to_s.rjust(10, "0")

            # If the card is still on the reader we skip the loop
            next if @current_serial_no == uid
            @current_serial_no = uid

            # has the card been tapped before?
            # if @tapped_cards.include? uid
            #   blast :status => 409
            #   next
            # end

            # Show the user progress bar...
            blast :status => 100
              
            # Check with backend
            result = checkin uid

            # Record the card into tapped cards
            # @tapped_cards << uid if [200, 409].include? result[:status].to_i

            blast result

          # No Card
          elsif @card_content == -90

            @current_serial_no = nil

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

    def checkin(serial_no)

      # Checkin
      result = RestClient.get ("https://nfc:nfc@nfcbackend.herokuapp.com/checkin/#{ serial_no }")
      JSON.parse result

    end

    def blast(object)

      @clients.each { |client| client.send(object.to_json) }

    end

  end

end