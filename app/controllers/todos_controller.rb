# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :set_todo, only: %i[update destroy]

  def create
    todo = Current.user.todos.new(params.permit(:description))
    save_and_redirect(todo)
  end

  def update
    @todo.assign_attributes(params.permit(:description, :completed))
    save_and_redirect(@todo)
  end

  def destroy
    @todo.destroy
    redirect_to root_path
  end

  private
    def set_todo
      @todo = Current.user.todos.find(params[:id])
    end

    def save_and_redirect(todo)
      if todo.save
        redirect_to root_path
      else
        redirect_to root_path, inertia: { errors: todo.errors.to_hash(true).transform_values(&:first) }
      end
    end
end
