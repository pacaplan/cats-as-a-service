module CatContent
  class CatbotController < ActionController::API
    before_action :authenticate_user!, except: [:quiz, :submit_quiz]

    def generate
      command = Commands::GenerateCustomCatCommand.new(
        prompt: params[:prompt_text],
        name: params[:selected_name],
        tags: [] 
      )
      
      cat = custom_cat_service.generate(user_id: current_user_id, command: command)
      
      # Spec expects 200 or 201
      render json: serializer(cat).as_json_full, status: :created
    rescue => e
       # Spec expects 404 for unauth but here we handle generation error.
       # Using unprocessable entity for logic errors.
       render json: { error: e.message }, status: :unprocessable_entity
    end
    
    def regenerate_description
      command = Commands::RegenerateDescriptionCommand.new(
        prompt: params[:modification_hint]
      )
      
      cat = custom_cat_service.regenerate_description(
        user_id: current_user_id,
        id: params[:custom_cat_id],
        command: command
      )
      
      render json: {
        description: cat.description,
        regenerated_at: Time.current
      }
    rescue CatContent::ResourceNotFound
      render json: { error: "Not Found" }, status: :not_found
    end

    def quiz
       render json: {
         questions: [
            { id: "q1", text: "How chaotic are you?", options: ["Very", "Little"] },
            { id: "q2", text: "Favorite color?", options: ["Red", "Void"] }
         ]
       }
    end

    def submit_quiz
      render json: {
         personality: "Chaotic Gremlin",
         description: "You love chaos.",
         shareable_text: "I am a Chaotic Gremlin cat!"
      }
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
  end
end
