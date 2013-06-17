require 'pp'

class ProjectsController < ApplicationController

  def new

  end

  def create
    #21441  smilemaker = 83
    project_id = params[:project_id]
    project = PivotalTrackerImporter.new(project_id).import
    pp project
    render nothing: true
  end

  #embeds_one :workflow


  def index
    respond_to do |format|
      format.json { render json: Project.all }
      format.html { render }
    end
  end


  def show
    project = Project.find(params[:id])
    respond_to do |format|
      format.json { render json: project.to_json(includes: :stories) }
      format.html { render }
    end
  end
end
