class SiteController < ApplicationController

  def submit
    # @username = params[:u]
    redirect_to "/#{params[:u]}"
  end

  def show

    @markov_string = return_markov(params[:username])
  end
end
