class Admin::UsersController < ApplicationController
  before_action :ensure_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :activate, :deactivate]

  def index
    @users = User.order(:name)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      redirect_to admin_user_path(@user), notice: 'Usuário criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'Usuário atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.id == current_user.id
      redirect_to admin_users_path, alert: 'Você não pode excluir sua própria conta.'
      return
    end
    
    @user.destroy
    redirect_to admin_users_path, notice: 'Usuário excluído com sucesso.'
  end

  def activate
    @user.update!(active: true)
    redirect_to admin_user_path(@user), notice: 'Usuário ativado com sucesso.'
  end

  def deactivate
    if @user.id == current_user.id
      redirect_to admin_user_path(@user), alert: 'Você não pode desativar sua própria conta.'
      return
    end
    
    @user.update!(active: false)
    redirect_to admin_user_path(@user), notice: 'Usuário desativado com sucesso.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :role, :active, :password, :password_confirmation)
  end
end 