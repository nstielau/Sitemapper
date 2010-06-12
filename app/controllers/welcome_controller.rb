class WelcomeController < ApplicationController
  before_filter :login_required, :except => [:index, :example]
  before_filter :check_auth_delegated, :except => [:example]

  def index
  end

  def example
  end
end
