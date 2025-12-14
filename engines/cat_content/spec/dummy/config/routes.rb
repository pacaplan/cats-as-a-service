# frozen_string_literal: true

Rails.application.routes.draw do
  # Mount the engine at root for testing
  mount CatContent::Engine => "/", as: "cat_content"
end

