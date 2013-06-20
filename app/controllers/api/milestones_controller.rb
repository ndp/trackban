class Api::MilestonesController < Api::BaseController

  def index
    project = Project.find(params[:project_id])
    respond_with project.milestones
  end

end