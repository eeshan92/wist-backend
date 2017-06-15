class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :authenticate_user_from_token!

  def me
    @user = User.where(email: params[:email]).try(:first)

    if @user && @user.valid_password?(params[:password])
      render json: { token: @user.authentication_token, email: @user.email, username: @user.username }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :password)
    end
end
