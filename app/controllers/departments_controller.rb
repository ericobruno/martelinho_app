class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy, :activate, :deactivate]
  before_action :ensure_manager_or_admin!, except: [:index, :show]

  def index
    @departments = Department.order(:name)
  end

  def show
    @current_vehicles = @department.current_vehicles.includes(:customer, :vehicle_brand, :vehicle_model)
    @vehicle_statuses = @department.vehicle_statuses.includes(:vehicle, :user).order(created_at: :desc).limit(10)
  end

  def new
    @department = Department.new
  end

  def create
    @department = Department.new(department_params)
    
    if @department.save
      redirect_to @department, notice: 'Departamento criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @department.update(department_params)
      redirect_to @department, notice: 'Departamento atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @department.destroy
    redirect_to departments_path, notice: 'Departamento excluído com sucesso.'
  end

  def activate
    @department.activate!
    redirect_to @department, notice: 'Departamento ativado com sucesso.'
  end

  def deactivate
    @department.deactivate!
    redirect_to @department, notice: 'Departamento desativado com sucesso.'
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name, :description, :active)
  end
end 