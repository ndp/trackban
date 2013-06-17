class StoriesController < ApplicationController
  respond_to :json, :xml

  def index
    #respond_with Story.all.as_json(methods: :epoch)
    project = Project.find(params[:project_id])
    respond_with project.stories.as_json(methods: :epoch)
  end

  def show
  end

  def update
  end

  def create
    story = Story.create! name: params[:name], project_id: params[:project_id]
    render json: story
  end
end
