class WelcomeController < ApplicationController
  before_filter :login_required, :except => [:index]
  before_filter :check_auth_delegated

  def index
  end
end
