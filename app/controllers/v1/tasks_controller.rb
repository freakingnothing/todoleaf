module V1
  class TasksController < ApplicationController
    include Pagy::Backend
    before_action :authenticate_user!

    # GET /v1/tasks
    def index
      @pagy, @tasks = pagy(current_user.tasks.roots.where(aasm_state: ['active', 'done']).select(:id, :body, :aasm_state))
      pagination_headers(@pagy)

      render json: @tasks, methods: :all_tags_list

    end

    # GET /v1/archived
    def index_archived_tasks
      @pagy, @tasks = pagy(current_user.tasks.roots.select(:id, :body, :aasm_state).archived)
      pagination_headers(@pagy)

      render json: @tasks, methods: :all_tags_list
    end

    # GET /v1/tasks/1
    def show
      @task = Task.find(params[:id]).subtree.arrange_serializable do |parent, children|
        {
          id: parent.id,
          body: parent.body,
          aasm_state: parent.aasm_state,
          ancestry: parent.ancestry,
          all_tags_list: parent.all_tags_list,
          # children_amount: count_children(parent),
          children: children
        }
      end
      
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
        current_user.tag(@task, with: params[:tag_list].join(", "), on: :tags) if params[:tag_list]
        render json: @task, status: :created, methods: :all_tags_list
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
        render json: @task, status: :ok, methods: :all_tags_list
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

    def count_children(task)
      return task.children.count
    end
  end
end
