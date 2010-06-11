class UsersController < ApplicationController
  before_filter :login_required, :except => [:new, :create]

  # render new.rhtml
  def new
    @user = User.new
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again."
      render :action => 'new'
    end
  end

  def request_seomoz_authorization
    params_to_sign = {:AccessID => SEOMOZ_ACCESS_ID, :Expires => Time.now.to_i + 60, :Redirect => CGI::escape("http://#{request.env["HTTP_HOST"]}/users/authorization/accept")}
    Rails.logger.info("Params to sign: #{params_to_sign.inspect}")
    params_to_sign[:Signature] = Linkscape::Signer.signParams(params, [:AccessID, :Expires, :Redirect], SEOMOZ_SECRET_KEY)
    host = "ec2-184-73-17-79.compute-1.amazonaws.com"
    #host = "apidash.seomoz.org"
    redirect_to "http://#{host}/delegate?AccessID=#{params_to_sign[:AccessID]}&Expires=#{params_to_sign[:Expires]}&Signature=#{params_to_sign[:Signature]}&Redirect=#{params_to_sign[:Redirect]}"
  end

  def accept_seomoz_authorization
    current_user.seomoz_secret_key = Digest::MD5.hexdigest("#{SEOMOZ_SECRET_KEY}#{params[:Token]}")
    current_user.seomoz_access_id = params[:AccessID]
    current_user.has_delegated_seomoz_auth = true
    current_user.delegated_seomoz_auth_at = Time.now
    current_user.save
    redirect_to "/"
  end
end
