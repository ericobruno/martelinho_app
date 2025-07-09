class ServiceTypesController < ApplicationController
  before_action :set_service_type, only: [:show, :edit, :update, :destroy, :activate, :deactivate]
  before_action :ensure_manager_or_admin!, except: [:index, :show]

  def index
    @service_types = ServiceType.order(:name)
  end

  def show
    @recent_quotes = @service_type.quotes.includes(:vehicle, :user).order(created_at: :desc).limit(5)
    @recent_work_orders = @service_type.work_orders.includes(:vehicle, :user).order(created_at: :desc).limit(5)
  end

  def new
    @service_type = ServiceType.new
  end

  def create
    @service_type = ServiceType.new(service_type_params)
    
    if @service_type.save
      redirect_to @service_type, notice: 'Tipo de serviço criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @service_type.update(service_type_params)
      redirect_to @service_type, notice: 'Tipo de serviço atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service_type.destroy
    redirect_to service_types_path, notice: 'Tipo de serviço excluído com sucesso.'
  end

  def activate
    @service_type.activate!
    redirect_to @service_type, notice: 'Tipo de serviço ativado com sucesso.'
  end

  def deactivate
    @service_type.deactivate!
    redirect_to @service_type, notice: 'Tipo de serviço desativado com sucesso.'
  end

  private

  def set_service_type
    @service_type = ServiceType.find(params[:id])
  end

  def service_type_params
    params.require(:service_type).permit(:name, :description, :default_price, :active)
  end
end 