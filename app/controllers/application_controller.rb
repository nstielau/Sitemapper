# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include AuthenticatedSystem
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def check_auth_delegated
    @needs_to_delegate_auth = current_user && !current_user.has_delegated_seomoz_auth
    if @needs_to_delegate_auth
      redirect_to "/" unless params[:action] == "index"
    end
  end
end
