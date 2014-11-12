require 'faye/websocket'
require 'nfc'

module Taptapgo

  class Frontend

    def initialize(app)
      @app = app
      @clients = []

      # Start NFC Reader
      @nfc_context = NFC::Context.new
      @nfc_device = @nfc_context.open nil
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)

        

      else
      	@app.call(env)
      end
    end

  end

end