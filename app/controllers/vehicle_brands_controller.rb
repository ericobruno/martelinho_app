class VehicleBrandsController < ApplicationController
  protect_from_forgery with: :null_session, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:create], if: :json_request?
  
  def create
    @vehicle_brand = VehicleBrand.new(vehicle_brand_params)
    
    respond_to do |format|
      if @vehicle_brand.save
        format.json {
          render json: {
            success: true,
            brand: {
              id: @vehicle_brand.id,
              name: @vehicle_brand.name
            }
          }, status: :created
        }
        format.html { redirect_to vehicle_brands_path, notice: 'Marca criada com sucesso!' }
      else
        format.json {
          render json: {
            success: false,
            errors: @vehicle_brand.errors.full_messages.join(', ')
          }, status: :unprocessable_entity
        }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end
  
  def index
    @vehicle_brands = VehicleBrand.includes(:vehicle_models).order(:name)
  end

  def show
    @vehicle_brand = VehicleBrand.find(params[:id])
    @vehicle_models = @vehicle_brand.vehicle_models.order(:name)
    @vehicles = @vehicle_brand.vehicles.includes(:customer, :vehicle_model).limit(10)
  end
  
  private
  
  def vehicle_brand_params
    params.require(:vehicle_brand).permit(:name)
  end
  
  def json_request?
    request.format.json?
  end
end 