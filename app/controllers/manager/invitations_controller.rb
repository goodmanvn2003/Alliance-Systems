class Manager::InvitationsController < ApplicationController
  layout nil

  def create
    render :json => { :status => 'success' }
  end

  def update
    render :json => { :status => 'success' }
  end

  def destroy
    render :json => { :status => 'success' }
  end

end