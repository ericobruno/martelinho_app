class DashboardController < ApplicationController
  def index
    @stats = {
      total_customers: Customer.count,
      total_vehicles: Vehicle.count,
      active_quotes: Quote.active.count,
      active_work_orders: WorkOrder.active.count,
      pending_work_orders: WorkOrder.aberta.count,
      in_progress_work_orders: WorkOrder.em_andamento.count,
      total_departments: Department.active.count,
      total_service_types: ServiceType.active.count
    }
    
    @recent_quotes = Quote.includes(:vehicle, :user).order(created_at: :desc).limit(5)
    @recent_work_orders = WorkOrder.includes(:vehicle, :user).order(created_at: :desc).limit(5)
    
    @work_orders_by_status = WorkOrder.group(:status).count
    @quotes_by_status = Quote.group(:status).count
    
    @departments_with_vehicles = Department.active.includes(:vehicle_statuses)
                                          .map do |dept|
      {
        name: dept.name,
        current_vehicles: dept.current_vehicles_count,
        department: dept
      }
    end
  end
end 