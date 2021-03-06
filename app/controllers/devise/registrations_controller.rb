class Devise::RegistrationsController < ApplicationController
  prepend_before_filter :require_no_authentication, :only => [  ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy, :new, :create]
  include Devise::Controllers::InternalHelpers

  # GET /resource/sign_up
  def new
    authorize! :create, Staff
    build_resource({})
    render_with_scope :new
  end

  # POST /resource
  def create
    authorize! :create, Staff
    resource.devise_creation_param_handler(params[resource_name])
    build_resource

    if resource.save
	# This is absolutely a kludge to compensate for poorly designed (rkg takes full responsibility)
	# associations between staff, org and access_level. The relationships between these models has
	# to be re-thunk.
	  resource.handle_authorization_params(resource.id, params[resource_name])
      #sign_in_and_redirect(resource_name, resource)
      redirect_to(staffs_url, :notice => "Account for #{resource.last_name_first_initial} was successfully created.")
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end

  end

  # GET /resource/edit
  def edit
    @staff = Staff.find(params[:id])
    authorize! :edit, @staff
    render_with_scope :edit
  end

  # PUT /resource
  def update
    params[resource_name].delete(:password) if params[resource_name][:password].blank?
    params[resource_name].delete(:password_confirmation) if params[resource_name][:password_confirmation].blank?
    @staff = Staff.find(params[resource_name][:id])
    authorize! :update, @staff
    if resource.update_attributes(params[resource_name])
      @current_ability = nil
      @current_staff = nil
      redirect_to(staffs_url, :notice => "Account for #{resource.last_name_first_initial} was successfully updated.")
    else
      clean_up_passwords(resource)
      render_with_scope :edit
    end
  end

  # DELETE /resource
  def destroy
    resource.destroy
    set_flash_message :notice, :destroyed
    sign_out_and_redirect(self.resource)
  end

  protected

  # Authenticates the current scope and gets a copy of the current resource.
  # We need to use a copy because we don't want actions like update changing
  # the current user in place.
  def authenticate_scope!
    send(:"authenticate_#{resource_name}!")
    self.resource = resource_class.find(send(:"current_#{resource_name}").id)
  end


end
