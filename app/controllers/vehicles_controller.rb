class VehiclesController < ApplicationController
  before_action :set_vehicle, only: [:show, :edit, :update, :destroy, :status, :update_status]

  def index
    @vehicles = Vehicle.includes(:customer, :vehicle_brand, :vehicle_model).order(:license_plate)
  end

  def show
    @quotes = @vehicle.quotes.order(created_at: :desc).limit(5)
    @work_orders = @vehicle.work_orders.order(created_at: :desc).limit(5)
    @current_status = @vehicle.current_status
  end

  def new
    @customer = Customer.find(params[:customer_id]) if params[:customer_id]
    @vehicle = @customer ? @customer.vehicles.build : Vehicle.new
    @vehicle_brands = VehicleBrand.order(:name)
  end

  def create
    @customer = Customer.find(params[:customer_id]) if params[:customer_id]
    @vehicle = @customer ? @customer.vehicles.build(vehicle_params) : Vehicle.new(vehicle_params)
    
    if @vehicle.save
      redirect_to @vehicle, notice: 'Veículo criado com sucesso.'
    else
      @vehicle_brands = VehicleBrand.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @vehicle_brands = VehicleBrand.order(:name)
  end

  def update
    if @vehicle.update(vehicle_params)
      redirect_to @vehicle, notice: 'Veículo atualizado com sucesso.'
    else
      @vehicle_brands = VehicleBrand.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to vehicles_path, notice: 'Veículo excluído com sucesso.'
  end

  def status
    @vehicle_statuses = @vehicle.vehicle_statuses.includes(:department, :user).order(created_at: :desc)
  end

  def update_status
    # Implementation for updating vehicle status
    redirect_to status_vehicle_path(@vehicle), notice: 'Status atualizado com sucesso.'
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(:license_plate, :year, :color, :customer_id, :vehicle_brand_id, :vehicle_model_id)
  end
end 