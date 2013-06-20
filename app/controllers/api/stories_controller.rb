class Api::StoriesController < Api::BaseController

  def index
    project = Project.find(params[:project_id])
    respond_with project.stories.as_json(methods: :epoch)
  end

  def create
    story = Story.create! name: params[:name], project_id: params[:project_id]
    respond_with story
  end
end