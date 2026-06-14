class UploadedFilesController < ApplicationController
  before_action :require_login, except: [ :show ]

  def index
    @new_file = UploadedFile.new
    @uploaded_files = UploadedFile.all
  end

  def show
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
