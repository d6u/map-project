class NgTemplatesController < ApplicationController

  # render slim template in development or testing mode
  #   because Grunt render slim is too slow

  # GET  /scripts/*template_path.html
  def index
    render "/development/js/#{params[:template_path]}"
  end

end
