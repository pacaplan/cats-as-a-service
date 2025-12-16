module CatContent
  class CustomCatsController < ActionController::API
    before_action :authenticate_user!


    def index
      result = custom_cat_service.list(
        user_id: current_user_id,
        page: params[:page]&.to_i || 1,
        per_page: [params[:per_page]&.to_i || 20, 100].min,
        include_archived: params[:include_archived] == "true"
      )
      
      render json: {
        custom_cats: result.items.map { |c| serializer(c).as_json },
        meta: result.to_meta
      }
    end

    def show
      cat = custom_cat_service.get(user_id: current_user_id, id: params[:id])
      
      if cat
        render json: serializer(cat).as_json_full
      else
        render json: { error: "Not Found" }, status: :not_found
      end
    end

    def create
      command = Commands::GenerateCustomCatCommand.new(
        prompt: params[:prompt],
        name: params[:name],
        tags: parse_tags(params[:tags])
      )
      
      cat = custom_cat_service.generate(user_id: current_user_id, command: command)
      
      render json: serializer(cat).as_json_full, status: :created
    rescue => e
       render json: { error: e.message }, status: :unprocessable_entity
    end
    
    def regenerate_description
      command = Commands::RegenerateDescriptionCommand.new(
        prompt: params[:prompt]
      )
      
      cat = custom_cat_service.regenerate_description(
        user_id: current_user_id,
        id: params[:id],
        command: command
      )
      render json: serializer(cat).as_json_full
    rescue CatContent::ResourceNotFound
      render json: { error: "Not Found" }, status: :not_found
    end

    def destroy
      custom_cat_service.archive(user_id: current_user_id, id: params[:id])
      head :no_content
    rescue CatContent::ResourceNotFound
      render json: { error: "Not Found" }, status: :not_found
    end

    private
    
    def authenticate_user!
      unless current_user_id
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    def current_user_id
      request.headers["X-User-Id"]
    end

    def custom_cat_service
      @custom_cat_service ||= Infrastructure::Wiring::Container.resolve(:custom_cat_service)
    end
    
    def serializer(cat)
      Infrastructure::Http::Serializers::CustomCatSerializer.new(cat)
    end
    
    def parse_tags(tags_param)
      return [] if tags_param.nil? || tags_param.empty?
      return tags_param if tags_param.is_a?(Array)
      tags_param.to_s.split(",").map(&:strip).reject(&:empty?)
    end
  end
end
