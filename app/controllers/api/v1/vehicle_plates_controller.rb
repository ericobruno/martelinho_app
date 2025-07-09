class Api::V1::VehiclePlatesController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def lookup
    plate = params[:plate]
    
    if plate.blank?
      return render json: { 
        success: false, 
        error: 'Placa é obrigatória' 
      }, status: :bad_request
    end
    
    result = VehiclePlateService.lookup_plate(plate)
    
    if result[:success]
      # Try to find matching brand and model in our database
      vehicle_data = result[:data]
      enhanced_data = enhance_with_database_info(vehicle_data)
      
      render json: {
        success: true,
        data: enhanced_data,
        source: result[:source]
      }
    else
      render json: {
        success: false,
        error: result[:error] || 'Não foi possível consultar a placa'
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def enhance_with_database_info(vehicle_data)
    enhanced = vehicle_data.dup
    
    # Try to find brand in database
    if vehicle_data[:brand].present?
      brand = VehicleBrand.where("LOWER(name) LIKE ?", "%#{vehicle_data[:brand].downcase}%").first
      if brand
        enhanced[:brand_id] = brand.id
        enhanced[:brand_slug] = brand.slug
        
        # Try to find model
        if vehicle_data[:model].present?
          model = brand.vehicle_models
                      .where("LOWER(name) LIKE ?", "%#{vehicle_data[:model].downcase}%")
                      .first
          if model
            enhanced[:model_id] = model.id
            enhanced[:model_slug] = model.slug
            enhanced[:full_model_name] = model.full_name
          end
        end
      end
    end
    
    # Add suggestions if exact match not found
    if enhanced[:brand_id].blank? && vehicle_data[:brand].present?
      enhanced[:brand_suggestions] = suggest_brands(vehicle_data[:brand])
    end
    
    if enhanced[:model_id].blank? && vehicle_data[:model].present?
      enhanced[:model_suggestions] = suggest_models(vehicle_data[:model], enhanced[:brand_id])
    end
    
    enhanced
  end
  
  def suggest_brands(brand_name)
    VehicleBrand.where("LOWER(name) LIKE ?", "%#{brand_name.downcase}%")
               .limit(5)
               .pluck(:id, :name)
               .map { |id, name| { id: id, name: name } }
  end
  
  def suggest_models(model_name, brand_id = nil)
    models = VehicleModel.joins(:vehicle_brand)
    models = models.where(vehicle_brand_id: brand_id) if brand_id.present?
    
    models.where("LOWER(vehicle_models.name) LIKE ?", "%#{model_name.downcase}%")
          .limit(10)
          .includes(:vehicle_brand)
          .map do |model|
            {
              id: model.id,
              name: model.name,
              brand_name: model.vehicle_brand.name,
              full_name: model.full_name
            }
          end
  end
end 