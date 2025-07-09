class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy, :approve, :reject, :send_quote, :convert_to_work_order]
  before_action :set_vehicle, only: [:new, :create], if: -> { params[:vehicle_id].present? }

  def index
    @quotes = Quote.includes(:vehicle, :user).order(created_at: :desc)
    
    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("quotes_list", partial: "quotes/list", locals: { quotes: @quotes }) }
    end
  end

  def show
    @quote_items = @quote.quote_items.includes(:service_type)
    
    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("quote_details", partial: "quotes/details", locals: { quote: @quote }) }
    end
  end

  def new
    @quote = @vehicle ? @vehicle.quotes.build : Quote.new
    @quote.user = current_user
    
    # Load data for step-by-step form
    @customers = Customer.order(:name)
    @vehicles = Vehicle.includes(:customer, :vehicle_brand, :vehicle_model).order(:license_plate) unless @vehicle
    @vehicle_brands = VehicleBrand.order(:name)
    @vehicle_models = VehicleModel.includes(:vehicle_brand).order(:name)
    @service_types = ServiceType.active.order(:name)
    
    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("quote_form", partial: "quotes/form", locals: { quote: @quote }) }
    end
  end

  def create
    Rails.logger.info "=== QUOTE CREATION DEBUG ==="
    Rails.logger.info "Raw params: #{params.inspect}"
    Rails.logger.info "Quote params: #{quote_params.inspect}"
    
    @quote = @vehicle ? @vehicle.quotes.build : Quote.new
    @quote.user = current_user
    
    # Handle different parameter scenarios
    processed_params = process_quote_params
    Rails.logger.info "Processed params: #{processed_params.inspect}"
    
    if processed_params
      @quote.assign_attributes(processed_params)
    else
      @quote.assign_attributes(quote_params)
    end
    
    Rails.logger.info "Quote before save: #{@quote.inspect}"
    Rails.logger.info "Quote valid?: #{@quote.valid?}"
    Rails.logger.info "Quote errors: #{@quote.errors.full_messages}" unless @quote.valid?
    
    respond_to do |format|
      if @quote.save
        Rails.logger.info "✅ Quote saved successfully: #{@quote.id}"
        format.html { redirect_to @quote, notice: 'Orçamento criado com sucesso.' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("quote_form", partial: "quotes/form_success", locals: { quote: @quote }),
            turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Orçamento criado com sucesso." })
          ]
        end
      else
        Rails.logger.error "❌ Quote save failed: #{@quote.errors.full_messages}"
        # Reload data for form in case of errors
        @customers = Customer.order(:name)
        @vehicles = Vehicle.includes(:customer, :vehicle_brand, :vehicle_model).order(:license_plate) unless @vehicle
        @vehicle_brands = VehicleBrand.order(:name)
        @vehicle_models = VehicleModel.includes(:vehicle_brand).order(:name)
        @service_types = ServiceType.active.order(:name)
        
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("quote_form", partial: "quotes/form", locals: { quote: @quote }),
            turbo_stream.update("flash_messages", partial: "shared/flash", locals: { alert: "Erro ao criar orçamento. Verifique os campos." })
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
    
    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("quote_form", partial: "quotes/form", locals: { quote: @quote }) }
    end
  end

  def update
    respond_to do |format|
      if @quote.update(quote_params)
        format.html { redirect_to @quote, notice: 'Orçamento atualizado com sucesso.' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("quote_details", partial: "quotes/details", locals: { quote: @quote }),
            turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Orçamento atualizado com sucesso." })
          ]
        end
      else
        @customers = Customer.order(:name)
        @vehicles = Vehicle.includes(:customer, :vehicle_brand, :vehicle_model).order(:license_plate)
        @vehicle_brands = VehicleBrand.order(:name)
        @vehicle_models = VehicleModel.includes(:vehicle_brand).order(:name)
        @service_types = ServiceType.active.order(:name)
        
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("quote_form", partial: "quotes/form", locals: { quote: @quote }),
            turbo_stream.update("flash_messages", partial: "shared/flash", locals: { alert: "Erro ao atualizar orçamento. Verifique os campos." })
          ]
        end
      end
    end
  end

  def destroy
    @quote.destroy
    
    respond_to do |format|
      format.html { redirect_to quotes_path, notice: 'Orçamento excluído com sucesso.' }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("quote_#{@quote.id}"),
          turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Orçamento excluído com sucesso." })
        ]
      end
    end
  end

  def approve
    @quote.update!(status: 'approved')
    
    respond_to do |format|
      format.html { redirect_to @quote, notice: 'Orçamento aprovado com sucesso.' }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("quote_status_#{@quote.id}", partial: "quotes/status_badge", locals: { quote: @quote }),
          turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Orçamento aprovado com sucesso." })
        ]
      end
    end
  end

  def reject
    @quote.update!(status: 'rejected')
    
    respond_to do |format|
      format.html { redirect_to @quote, notice: 'Orçamento rejeitado.' }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("quote_status_#{@quote.id}", partial: "quotes/status_badge", locals: { quote: @quote }),
          turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Orçamento rejeitado." })
        ]
      end
    end
  end

  def send_quote
    @quote.update!(status: 'sent')
    
    respond_to do |format|
      format.html { redirect_to @quote, notice: 'Orçamento enviado ao cliente.' }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("quote_status_#{@quote.id}", partial: "quotes/status_badge", locals: { quote: @quote }),
          turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Orçamento enviado ao cliente." })
        ]
      end
    end
  end

  def convert_to_work_order
    work_order = @quote.convert_to_work_order!(current_user)
    
    respond_to do |format|
      if work_order
        format.html { redirect_to work_order, notice: 'Ordem de serviço criada com sucesso a partir do orçamento.' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.redirect_to(work_order_path(work_order)),
            turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Ordem de serviço criada com sucesso a partir do orçamento." })
          ]
        end
      else
        format.html { redirect_to @quote, alert: 'Não foi possível converter o orçamento em ordem de serviço.' }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/flash", locals: { alert: "Não foi possível converter o orçamento em ordem de serviço." })
        end
      end
    end
  end

  private

  def set_quote
    @quote = Quote.find(params[:id])
  end

  def set_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
  end

  def quote_params
    params.require(:quote).permit(
      :vehicle_id, :customer_id, :notes, :expires_at, :status, :valid_until,
      vehicle_attributes: [
        :license_plate, :year, :color, :vehicle_brand_id, :vehicle_model_id, :customer_id, :custom_model_name,
        customer_attributes: [:name, :cpf_cnpj, :email, :phone, :address]
      ],
      quote_items_attributes: [:service_type_id, :description, :quantity, :unit_price, :total_price, :_destroy]
    )
  end

  def process_quote_params
    params_hash = quote_params.to_h
    
    # Case 1: Existing vehicle selected
    if params_hash['vehicle_id'].present?
      return { vehicle_id: params_hash['vehicle_id'], notes: params_hash['notes'] }
    end
    
    # Case 2: New vehicle with existing customer
    if params_hash['customer_id'].present? && params_hash['vehicle_attributes'].present?
      vehicle_attrs = process_vehicle_attributes(params_hash['vehicle_attributes'].dup)
      vehicle_attrs['customer_id'] = params_hash['customer_id']
      vehicle_attrs.delete('customer_attributes') # Remove nested customer attrs since we're using existing customer
      return { vehicle_attributes: vehicle_attrs, notes: params_hash['notes'] }
    end
    
    # Case 3: New vehicle with new customer (nested attributes)
    if params_hash['vehicle_attributes'].present?
      vehicle_attrs = process_vehicle_attributes(params_hash['vehicle_attributes'])
      return { vehicle_attributes: vehicle_attrs, notes: params_hash['notes'] }
    end
    
    # Default case
    nil
  end

  def process_vehicle_attributes(vehicle_attrs)
    # Handle custom model creation
    if (vehicle_attrs['vehicle_model_id'] == 'custom' || vehicle_attrs['custom_model_name'].present?) && vehicle_attrs['vehicle_brand_id'].present?
      brand = VehicleBrand.find(vehicle_attrs['vehicle_brand_id'])
      model = VehicleModel.find_or_create_by(
        name: vehicle_attrs['custom_model_name'],
        vehicle_brand: brand
      )
      vehicle_attrs['vehicle_model_id'] = model.id
      vehicle_attrs.delete('custom_model_name')
    end
    
    vehicle_attrs
  end
end 