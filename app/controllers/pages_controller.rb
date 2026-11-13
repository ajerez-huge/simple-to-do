# frozen_string_literal: true

class PagesController < ApplicationController
  allow_unauthenticated_access only: :home

  def home
    if authenticated?
      todos = Current.user.todos.order(created_at: :desc, id: :desc)
      render inertia: "Todos", props: { todos: todos.map { |t| todo_json(t) } }
    else
      render inertia: "Home"
    end
  end

  private
    def todo_json(todo)
      { id: todo.id, description: todo.description, completed: todo.completed }
    end
end
