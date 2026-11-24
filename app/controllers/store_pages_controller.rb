class StorePagesController < ApplicationController
  def show
    @page = StorePage.find_by!(slug: params[:slug])
  end
end
