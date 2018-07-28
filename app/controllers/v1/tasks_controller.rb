module V1
  class TasksController < ApplicationController
    before_action :authenticate_user!

    # GET /v1/tasks
    def index
      @tasks = current_user.tasks.roots.active

      render json: @tasks
    end

    def index_archived_tasks
      @tasks = current_user.tasks.roots.archived

      render json: @tasks
    end

    # GET /v1/tasks/1
    def show
      @task = Task.find(params[:id]).subtree.arrange_serializable

      render json: @task
    end

    # POST /v1/tasks
    def create
      if params[:parent_id].to_i > 0
        parent = Task.find(params[:parent_id])
        @task = parent.children.build(task_params)
        @task.user_id = current_user.id
      else
        @task = current_user.tasks.create(task_params)
      end

      if @task.save
        current_user.tag(@task, with: params[:tag_list].join(", "), on: :tags)
        render json:@task, status: :created
      else
        head(:error)
      end
    end

    # PATCH/PUT /v1/tasks/1
    def update
      @task = Task.find(params[:id])

      if params[:aasm_event]
        @task.send(params[:aasm_event])
      end

      if @task.update(task_params)
        current_user.tag(@task, with: params[:tag_list].join(", "), on: :tags) if params[:tag_list]
        render json: @task, status: :ok
      else
        head(:error)
      end
    end

    # DELETE v1/tasks/1
    def destroy
      @task = Task.find(params[:id])

      if @task.destroy
        head(:ok)
      else
        head(:error)
      end
    end

    private

    def task_params
      params.require(:task).permit(:body, :tag_list)
    end
  end
end
