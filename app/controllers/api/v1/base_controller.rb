class Api::V1::BaseController < ApplicationController
  acts_as_token_authentication_handler_for User

  protect_from_forgery with: :null_session

  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

end