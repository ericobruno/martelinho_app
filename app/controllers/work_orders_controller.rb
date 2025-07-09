class WorkOrdersController < ApplicationController
  before_action :set_work_order, only: [:show, :edit, :update, :destroy, :start, :complete, :cancel]
  before_action :set_vehicle, only: [:new, :create], if: -> { params[:vehicle_id].present? }

  def index
    @work_orders = WorkOrder.includes(:vehicle, :user).order(created_at: :desc)
    
    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("work_orders_list", partial: "work_orders/list", locals: { work_orders: @work_orders }) }
    end
  end

  def show
    @work_order_items = @work_order.work_order_items.includes(:service_type)
    @vehicle_statuses = @work_order.vehicle_statuses.includes(:department, :user).order(created_at: :desc)
    
    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("work_order_details", partial: "work_orders/details", locals: { work_order: @work_order }) }
    end
  end

  def new
    @work_order = @vehicle ? @vehicle.work_orders.build : WorkOrder.new
    @work_order.user = current_user
    
    # Load data for step-by-step form
    @customers = Customer.order(:name)
    @vehicles = Vehicle.includes(:customer, :vehicle_brand, :vehicle_model).order(:license_plate) unless @vehicle
    @vehicle_brands = VehicleBrand.order(:name)
    @vehicle_models = VehicleModel.includes(:vehicle_brand).order(:name)
    @service_types = ServiceType.active.order(:name)
    @departments = Department.active.order(:name)
    
    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("work_order_form", partial: "work_orders/form", locals: { work_order: @work_order }) }
    end
  end

  def create
    @work_order = @vehicle ? @vehicle.work_orders.build(work_order_params) : WorkOrder.new(work_order_params)
    @work_order.user = current_user
    
    respond_to do |format|
      if @work_order.save
        format.html { redirect_to @work_order, notice: 'Ordem de serviço criada com sucesso.' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("work_order_form", partial: "work_orders/form_success", locals: { work_order: @work_order }),
            turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Ordem de serviço criada com sucesso." })
          ]
        end
      else
        # Reload data for form in case of errors
        @customers = Customer.order(:name)
        @vehicles = Vehicle.includes(:customer, :vehicle_brand, :vehicle_model).order(:license_plate) unless @vehicle
        @vehicle_brands = VehicleBrand.order(:name)
        @vehicle_models = VehicleModel.includes(:vehicle_brand).order(:name)
        @service_types = ServiceType.active.order(:name)
        @departments = Department.active.order(:name)
        
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("work_order_form", partial: "work_orders/form", locals: { work_order: @work_order }),
            turbo_stream.update("flash_messages", partial: "shared/flash", locals: { alert: "Erro ao criar ordem de serviço. Verifique os campos." })
          ]
        end
      end
    end
  end

  def edit
    @customers = Customer.order(:name)
    @vehicles = Vehicle.includes(:customer, :vehicle_brand, :vehicle_model).order(:license_plate)
    @vehicle_brands = VehicleBrand.order(:name)
    @vehicle_models = VehicleModel.includes(:vehicle_brand).order(:name)
    @service_types = ServiceType.active.order(:name)
    @departments = Department.active.order(:name)
    
    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("work_order_form", partial: "work_orders/form", locals: { work_order: @work_order }) }
    end
  end

  def update
    respond_to do |format|
      if @work_order.update(work_order_params)
        format.html { redirect_to @work_order, notice: 'Ordem de serviço atualizada com sucesso.' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("work_order_details", partial: "work_orders/details", locals: { work_order: @work_order }),
            turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Ordem de serviço atualizada com sucesso." })
          ]
        end
      else
        @customers = Customer.order(:name)
        @vehicles = Vehicle.includes(:customer, :vehicle_brand, :vehicle_model).order(:license_plate)
        @vehicle_brands = VehicleBrand.order(:name)
        @vehicle_models = VehicleModel.includes(:vehicle_brand).order(:name)
        @service_types = ServiceType.active.order(:name)
        @departments = Department.active.order(:name)
        
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("work_order_form", partial: "work_orders/form", locals: { work_order: @work_order }),
            turbo_stream.update("flash_messages", partial: "shared/flash", locals: { alert: "Erro ao atualizar ordem de serviço. Verifique os campos." })
          ]
        end
      end
    end
  end

  def destroy
    @work_order.destroy
    
    respond_to do |format|
      format.html { redirect_to work_orders_path, notice: 'Ordem de serviço excluída com sucesso.' }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("work_order_#{@work_order.id}"),
          turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Ordem de serviço excluída com sucesso." })
        ]
      end
    end
  end

  def start
    if @work_order.start!
      respond_to do |format|
        format.html { redirect_to @work_order, notice: 'Ordem de serviço iniciada com sucesso.' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("work_order_status_#{@work_order.id}", partial: "work_orders/status_badge", locals: { work_order: @work_order }),
            turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Ordem de serviço iniciada com sucesso." })
          ]
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @work_order, alert: 'Não foi possível iniciar a ordem de serviço.' }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/flash", locals: { alert: "Não foi possível iniciar a ordem de serviço." })
        end
      end
    end
  end

  def complete
    if @work_order.complete!
      respond_to do |format|
        format.html { redirect_to @work_order, notice: 'Ordem de serviço concluída com sucesso.' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("work_order_status_#{@work_order.id}", partial: "work_orders/status_badge", locals: { work_order: @work_order }),
            turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Ordem de serviço concluída com sucesso." })
          ]
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @work_order, alert: 'Não foi possível concluir a ordem de serviço.' }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/flash", locals: { alert: "Não foi possível concluir a ordem de serviço." })
        end
      end
    end
  end

  def cancel
    if @work_order.cancel!
      respond_to do |format|
        format.html { redirect_to @work_order, notice: 'Ordem de serviço cancelada.' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("work_order_status_#{@work_order.id}", partial: "work_orders/status_badge", locals: { work_order: @work_order }),
            turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Ordem de serviço cancelada." })
          ]
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @work_order, alert: 'Não foi possível cancelar a ordem de serviço.' }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/flash", locals: { alert: "Não foi possível cancelar a ordem de serviço." })
        end
      end
    end
  end

  private

  def set_work_order
    @work_order = WorkOrder.find(params[:id])
  end

  def set_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
  end

  def work_order_params
    params.require(:work_order).permit(
      :vehicle_id, :notes, :expected_delivery, :description, :status, :department_id,
      customer_attributes: [:name, :cpf_cnpj, :email, :phone, :address],
      vehicle_attributes: [:license_plate, :year, :color, :fuel_type, :vehicle_brand_id, :vehicle_model_id],
      work_order_items_attributes: [:service_type_id, :description, :quantity, :unit_price, :total_price, :_destroy]
    )
  end
end 