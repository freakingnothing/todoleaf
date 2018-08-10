module V1
  class TagsController < ApplicationController
    include Pagy::Backend
    before_action :authenticate_user!

    # GET /v1/tags
    def index
      @pagy, @tags = pagy(current_user.owned_tags.most_used)
      pagination_headers(@pagy)

      render json: @tags
    end

    # GET /v1/tags/1
    def show
      @tag = ActsAsTaggableOn::Tag.find(params[:id])
      @tasks = Task.tagged_with(@tag, owner_by: current_user).select(:id, :body, :aasm_state)

      render json: @tasks
    end
  end
end
