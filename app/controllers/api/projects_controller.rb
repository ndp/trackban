class Api::ProjectsController < Api::BaseController

  def index
    respond_with Project.all
  end


  def show
    project = Project.find(params[:id])
    respond_with project
  end

end