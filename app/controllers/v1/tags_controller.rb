module V1
  class TagsController < ApplicationController
    before_action :authenticate_user!

    # GET /v1/tags
    def index
      @tags = current_user.owned_tags.most_used

      render json: @tags
    end

    # GET /v1/tags/1
    def show
      @tag = ActsAsTaggableOn::Tag.find(params[:id])
      @tasks = Task.tagged_with(@tag, owner_by: current_user)

      render json: @tasks
    end
  end
end
