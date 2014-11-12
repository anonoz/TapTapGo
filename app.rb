require 'sinatra/base'
require 'haml'

module Taptapgo
  class Web < Sinatra::Base
    get '/' do
      haml :index
    end
  end
end