require 'set'

class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy, :approve, :reject, :send_quote, :convert_to_work_order]
  before_action :set_vehicle, only: [:new, :create], if: -> { params[:vehicle_id].present? }

  def index
    @quotes = Quote.includes(:user, vehicle: [:customer, :vehicle_brand, :vehicle_model], quote_items: :service_type, work_orders: :quote).order(created_at: :desc)
    
    # Apply filters
    if params[:customer_name].present?
      @quotes = @quotes.joins(vehicle: :customer).where("customers.name ILIKE ?", "%#{params[:customer_name]}%")
    end
    
    if params[:customer_cpf].present?
      @quotes = @quotes.joins(vehicle: :customer).where("customers.cpf_cnpj ILIKE ?", "%#{params[:customer_cpf]}%")
    end
    
    if params[:vehicle_plate].present?
      @quotes = @quotes.joins(:vehicle).where("vehicles.license_plate ILIKE ?", "%#{params[:vehicle_plate]}%")
    end
    
    if params[:vehicle_brand].present?
      @quotes = @quotes.joins(vehicle: :vehicle_brand).where("vehicle_brands.name ILIKE ?", "%#{params[:vehicle_brand]}%")
    end
    
    if params[:vehicle_model].present?
      @quotes = @quotes.joins(vehicle: :vehicle_model).where("vehicle_models.name ILIKE ?", "%#{params[:vehicle_model]}%")
    end
    
    if params[:status].present?
      @quotes = @quotes.where(status: params[:status])
    end
    
    if params[:date_from].present?
      @quotes = @quotes.where("quotes.created_at >= ?", Date.parse(params[:date_from]).beginning_of_day)
    end
    
    if params[:date_to].present?
      @quotes = @quotes.where("quotes.created_at <= ?", Date.parse(params[:date_to]).end_of_day)
    end
    
    respond_to do |format|
      format.html
      format.turbo_stream { 
        render turbo_stream: turbo_stream.replace("quotes_list", partial: "quotes/list", locals: { quotes: @quotes }) 
      }
      format.any { head :not_acceptable } # ou renderizar algo padrão
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
      Rails.logger.info "Quote after processed params: #{@quote.inspect}"
      Rails.logger.info "Quote attributes: #{@quote.attributes.inspect}"
    else
      @quote.assign_attributes(quote_params)
      Rails.logger.info "Quote after quote_params: #{@quote.inspect}"
      Rails.logger.info "Quote attributes: #{@quote.attributes.inspect}"
    end
    
    Rails.logger.info "Quote before save: #{@quote.inspect}"
    Rails.logger.info "Quote service_value: #{@quote.service_value.inspect}"
    Rails.logger.info "Quote service_value_cents: #{@quote.service_value_cents.inspect}"
    Rails.logger.info "Quote total_amount: #{@quote.total_amount.inspect}"
    Rails.logger.info "Quote valid?: #{@quote.valid?}"
    Rails.logger.info "Quote errors: #{@quote.errors.full_messages}" unless @quote.valid?
    
    respond_to do |format|
      if @quote.save
        Rails.logger.info "✅ Quote saved successfully: #{@quote.id}"
        Rails.logger.info "🔄 Redirecting to root_path: #{root_path}"
        Rails.logger.info "🔄 Root URL: #{root_url}"
        format.html { redirect_to root_path, notice: 'Orçamento criado com sucesso.' }
        format.turbo_stream { redirect_to root_path, notice: 'Orçamento criado com sucesso.' }
      else
        Rails.logger.error "❌ Quote save failed: #{@quote.errors.full_messages}"
        Rails.logger.error "❌ Quote validation errors details: #{@quote.errors.details}"
        
        # Collect all error messages including nested models
        all_errors = collect_all_errors(@quote)
        error_message = "Erro ao criar orçamento:\n#{all_errors.join("\n")}"
        
        # Reload data for form in case of errors
        @customers = Customer.order(:name)
        @vehicles = Vehicle.includes(:customer, :vehicle_brand, :vehicle_model).order(:license_plate) unless @vehicle
        @vehicle_brands = VehicleBrand.order(:name)
        @vehicle_models = VehicleModel.includes(:vehicle_brand).order(:name)
        @service_types = ServiceType.active.order(:name)
        
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          streams = []
          streams << turbo_stream.replace("quote_form", partial: "quotes/form", locals: { quote: @quote })
          streams << turbo_stream.update("flash_messages", partial: "shared/flash", locals: { alert: error_message })
          
          render turbo_stream: streams
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
          streams = []
          streams << turbo_stream.replace("quote_details", partial: "quotes/details", locals: { quote: @quote })
          streams << turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Orçamento atualizado com sucesso." })
          
          render turbo_stream: streams
        end
      else
        @customers = Customer.order(:name)
        @vehicles = Vehicle.includes(:customer, :vehicle_brand, :vehicle_model).order(:license_plate)
        @vehicle_brands = VehicleBrand.order(:name)
        @vehicle_models = VehicleModel.includes(:vehicle_brand).order(:name)
        @service_types = ServiceType.active.order(:name)
        
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          streams = []
          streams << turbo_stream.replace("quote_form", partial: "quotes/form", locals: { quote: @quote })
          streams << turbo_stream.update("flash_messages", partial: "shared/flash", locals: { alert: "Erro ao atualizar orçamento. Verifique os campos." })
          
          render turbo_stream: streams
        end
      end
    end
  end

  def destroy
    @quote.destroy
    
    respond_to do |format|
      format.html { redirect_to quotes_path, notice: 'Orçamento excluído com sucesso.' }
      format.turbo_stream do
        streams = []
        streams << turbo_stream.remove("quote_#{@quote.id}")
        streams << turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Orçamento excluído com sucesso." })
        
        render turbo_stream: streams
      end
    end
  end

  def approve
    Rails.logger.info "=== QUOTE APPROVAL DEBUG ==="
    Rails.logger.info "Quote ID: #{@quote.id}"
    Rails.logger.info "Quote Status: #{@quote.status}"
    Rails.logger.info "Can be approved: #{@quote.can_be_approved?}"
    
    # Security: Only allow approval of quotes that belong to customer or are public
    unless @quote.can_be_approved?
      error_message = 'Este orçamento não pode ser aprovado no momento.'
      Rails.logger.error "❌ Cannot approve quote: #{error_message}"
      
      respond_to do |format|
        format.html { redirect_to @quote, alert: error_message }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/flash", locals: { alert: error_message })
        end
      end
      return
    end
    
    # Verificar se o orçamento já foi aprovado
    if @quote.aprovado?
      notice_message = 'Este orçamento já foi aprovado anteriormente.'
      Rails.logger.info "⚠️ Quote already approved"
    else
      # Tentar aprovar o orçamento
      Rails.logger.info "📝 Attempting to approve quote..."
      
      if @quote.approve!
        Rails.logger.info "✅ Quote approved successfully"
        
        # Verificar se já existe uma ordem de serviço antes de tentar converter
        existing_work_order = @quote.work_orders.first
        
        if existing_work_order
          Rails.logger.info "⚠️ Work order already exists: #{existing_work_order.id}"
          notice_message = 'Orçamento aprovado com sucesso! Ordem de serviço já existia.'
        else
          # Auto-convert to work order
          Rails.logger.info "🔄 Converting to work order..."
          work_order = @quote.convert_to_work_order!(current_user)
          
          if work_order
            Rails.logger.info "✅ Work order created successfully: #{work_order.id}"
            notice_message = 'Orçamento aprovado com sucesso e ordem de serviço gerada!'
          else
            Rails.logger.error "❌ Failed to create work order"
            notice_message = 'Orçamento aprovado com sucesso!'
          end
        end
      else
        Rails.logger.error "❌ Failed to approve quote: #{@quote.errors.full_messages}"
        notice_message = 'Erro ao aprovar orçamento.'
      end
    end
    
    Rails.logger.info "📤 Sending response with message: #{notice_message}"
    
    respond_to do |format|
      format.html { redirect_to @quote, notice: notice_message }
      format.turbo_stream do
        Rails.logger.info "🎬 Rendering turbo stream response"
        
        # Build the turbo stream array step by step to avoid render issues
        streams = []
        
        # Always update flash messages
        streams << turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: notice_message })
        
        # Update status badge if element exists
        if dom_id_exists?("quote_status_#{@quote.id}")
          streams << turbo_stream.replace("quote_status_#{@quote.id}", partial: "quotes/status_badge", locals: { quote: @quote })
        end
        
        # Update actions section if element exists
        if dom_id_exists?("quote_actions_#{@quote.id}")
          streams << turbo_stream.replace("quote_actions_#{@quote.id}", partial: "quotes/actions", locals: { quote: @quote })
        end
        
        # Add a custom event to trigger modal close
        streams << turbo_stream.append("body", content: "<script>document.dispatchEvent(new CustomEvent('quote:approved', { detail: { quoteId: #{@quote.id} } }));</script>")
        
        render turbo_stream: streams
      end
    end
  end

  def reject
    # Security: Only allow rejection of quotes that can be rejected
    unless @quote.status.in?(['enviado', 'aberto'])
      return redirect_to @quote, alert: 'Este orçamento não pode ser rejeitado no momento.'
    end
    
    @quote.update!(status: 'rejeitado')
    
    respond_to do |format|
      format.html { redirect_to @quote, notice: 'Orçamento rejeitado.' }
      format.turbo_stream do
        streams = []
        streams << turbo_stream.replace("quote_status_#{@quote.id}", partial: "quotes/status_badge", locals: { quote: @quote })
        streams << turbo_stream.replace("quote_actions_#{@quote.id}", partial: "quotes/actions", locals: { quote: @quote })
        streams << turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Orçamento rejeitado." })
        
        render turbo_stream: streams
      end
    end
  end

  def send_quote
    @quote.update!(status: 'enviado')
    
    respond_to do |format|
      format.html { redirect_to @quote, notice: 'Orçamento enviado ao cliente.' }
      format.turbo_stream do
        streams = []
        streams << turbo_stream.replace("quote_status_#{@quote.id}", partial: "quotes/status_badge", locals: { quote: @quote })
        streams << turbo_stream.replace("quote_actions_#{@quote.id}", partial: "quotes/actions", locals: { quote: @quote })
        streams << turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Orçamento enviado ao cliente." })
        
        render turbo_stream: streams
      end
    end
  end

  def convert_to_work_order
    work_order = @quote.convert_to_work_order!(current_user)
    
    respond_to do |format|
      if work_order
        format.html { redirect_to work_order, notice: 'Ordem de serviço criada com sucesso a partir do orçamento.' }
        format.turbo_stream do
          streams = []
          streams << turbo_stream.redirect_to(work_order_path(work_order))
          streams << turbo_stream.update("flash_messages", partial: "shared/flash", locals: { notice: "Ordem de serviço criada com sucesso a partir do orçamento." })
          
          render turbo_stream: streams
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

  def dom_id_exists?(id)
    # For simplicity, we'll assume the elements exist on the page
    # In a more sophisticated implementation, you could check the referer
    # or use a parameter to determine the page context
    true
  end

  def set_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
  end

  def quote_params
    params.require(:quote).permit(
      :vehicle_id, :customer_id, :notes, :expires_at, :valid_until, :service_value,
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
      return { 
        vehicle_id: params_hash['vehicle_id'], 
        notes: params_hash['notes'],
        service_value: params_hash['service_value']
      }
    end
    
    # Case 2: New vehicle with existing customer
    if params_hash['customer_id'].present? && params_hash['vehicle_attributes'].present?
      vehicle_attrs = process_vehicle_attributes(params_hash['vehicle_attributes'].dup)
      vehicle_attrs['customer_id'] = params_hash['customer_id']
      vehicle_attrs.delete('customer_attributes') # Remove nested customer attrs since we're using existing customer
      return { 
        vehicle_attributes: vehicle_attrs, 
        notes: params_hash['notes'],
        service_value: params_hash['service_value']
      }
    end
    
    # Case 3: New vehicle with new customer (nested attributes)
    if params_hash['vehicle_attributes'].present?
      vehicle_attrs = process_vehicle_attributes(params_hash['vehicle_attributes'])
      return { 
        vehicle_attributes: vehicle_attrs, 
        notes: params_hash['notes'],
        service_value: params_hash['service_value']
      }
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

  def collect_all_errors(record)
    errors = []
    seen_errors = Set.new
    
    # Quote-specific errors (excluding nested model errors that will be shown separately)
    record.errors.full_messages.each do |msg|
      # Skip nested errors that start with model names, we'll format them better
      unless msg.start_with?('Vehicle', 'Customer')
        unless seen_errors.include?(msg)
          errors << msg
          seen_errors.add(msg)
        end
      end
    end
    
    # Vehicle errors (if vehicle exists)
    if record.vehicle.present? && !record.vehicle.valid?
      record.vehicle.errors.full_messages.each do |msg|
        formatted_msg = "Veículo: #{msg}"
        unless seen_errors.include?(formatted_msg)
          errors << formatted_msg
          seen_errors.add(formatted_msg)
        end
      end
      
      # Customer errors (if customer exists through vehicle)
      if record.vehicle.customer.present? && !record.vehicle.customer.valid?
        record.vehicle.customer.errors.full_messages.each do |msg|
          formatted_msg = "Cliente: #{msg}"
          unless seen_errors.include?(formatted_msg)
            errors << formatted_msg
            seen_errors.add(formatted_msg)
          end
        end
      end
    end
    
    errors
  end
end 