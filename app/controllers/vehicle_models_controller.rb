class VehicleModelsController < ApplicationController
  protect_from_forgery with: :null_session, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:create], if: :json_request?
  
  def create
    @vehicle_model = VehicleModel.new(vehicle_model_params)
    
    respond_to do |format|
      if @vehicle_model.save
        format.json {
          render json: {
            success: true,
            model: {
              id: @vehicle_model.id,
              name: @vehicle_model.name,
              vehicle_brand_id: @vehicle_model.vehicle_brand_id
            }
          }, status: :created
        }
        format.html { redirect_to vehicle_models_path, notice: 'Modelo criado com sucesso!' }
      else
        format.json {
          render json: {
            success: false,
            errors: @vehicle_model.errors.full_messages.join(', ')
          }, status: :unprocessable_entity
        }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def index
    @vehicle_models = VehicleModel.includes(:vehicle_brand).order(:name)
  end

  def by_brand
    @vehicle_models = VehicleModel.where(vehicle_brand_id: params[:brand_id])
    render partial: 'options', locals: { vehicle_models: @vehicle_models }
  end
  
  private
  
  def vehicle_model_params
    params.require(:vehicle_model).permit(:name, :vehicle_brand_id)
  end
  
  def json_request?
    request.format.json?
  end
end 