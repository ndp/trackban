class StoriesController < ApplicationController
  respond_to :json, :xml
  def index
    respond_with Story.all
  end

  def show
  end

  def update
  end

  def create
    Story.create! name: params[:name]
  end
end
