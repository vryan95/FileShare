class UploadedFilesController < ApplicationController
  before_action :require_login, except: [ :show ]

  def index
    @file = UploadedFile.new
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
