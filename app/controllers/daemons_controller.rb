class DaemonsController < ApplicationController
  before_action :assign_daemon

  def index
    @status = dd('status')
  end 

  def start
    r = dd 'start'
    redirect_to daemons_path, :flash => {:info => "Daemon started. #{r}"}
  end 

  def stop
    r = dd 'stop'
    redirect_to daemons_path, :flash => {:info => "Daemon stopped. #{r}"}
  end 

  def restart
    dd 'stop'
    r = dd 'start'
    redirect_to daemons_path, :flash => {:info => "Daemon restarted. #{r}"}
  end 

  def logs
    lines = params[:lines] || 1000
    @logs = `tail -n #{lines} log/crawler_daemon.rb.log`

    @logs = dd 'status'
  end 

  private

  def dd cmd 
    Bundler.with_clean_env do
      return `#{@daemon.path} #{cmd}`
    end 
  end 

  def assign_daemon
    @daemon = Daemons::Rails::Monitoring.controllers.first
  end 
end
