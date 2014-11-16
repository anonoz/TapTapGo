require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/reloader'

require 'haml'
require 'sass'
require 'coffee-script'

module Taptapgo
  class Web < Sinatra::Base

    # Live Reloader
    configure :development do
      register Sinatra::Reloader
    end

    # ASSETS
    register Sinatra::AssetPack

    assets {
      js :app, '/js/app.js', [
        '/bower_components/jquery/dist/jquery.min.js',
        '/bower_components/webcomponentsjs/webcomponents.min.js',
        '/js/taptapgo.js'
      ]

      css :application, '/css/application.css', [
        '/css/basic.css'
      ]

      puts :FinishingAssetPack
    }

    # Actual Business
    get '/' do
      haml :index
    end

  end
end