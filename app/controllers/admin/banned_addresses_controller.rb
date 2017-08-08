class Admin::BannedAddressesController < ApplicationController
  before_action :check_admin
  before_action :set_address
  skip_before_action :set_address, only: [:index]

  def index
    @addresses = BannedAddress.all
  end

  def destroy
    @address.destroy
    redirect_to admin_banned_addresses_path
  end

  private

  def set_address
    @address = BannedAddress.find(params[:id])
  end

end
