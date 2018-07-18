module V1
  class TasksController < ApplicationController
    before_action :authenticate_user!

    # GET /v1/tasks
    def index
      @tasks = current_user.tasks.roots

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
        render json:@task, status: :created
      else
        head(:error)
      end
    end

    # PATCH/PUT /v1/tasks/1
    def update
      @task = Task.find(params[:id])

      if @task.update(task_params)
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
      params.require(:task).permit(:body)
    end
  end
end
