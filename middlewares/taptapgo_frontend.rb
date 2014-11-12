require 'faye/websocket'
require 'nfc'

module Taptapgo

  class Frontend
    KEEPALIVE_TIME = 15

    def initialize(app)
      @app = app
      @clients = []

      # Start NFC Reader
      # @nfc_context = NFC::Context.new
      # @nfc_device = @nfc_context.open nil

      # Spawn thread
      # Thread.new do
      #   while true
      #     # Poll the device
      #     @raw_uid = @nfc_device.poll

      #     # Skip to next loop if no result
      #   end
      # end
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