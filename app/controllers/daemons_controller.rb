class DaemonsController < ApplicationController
  before_filter :assign_daemon

  def index
  end

  def start
    r = @daemon.start
    redirect_to daemons_path, :flash => {:info => "Daemon started. #{r}"}
  end

  def stop
    r = @daemon.stop
    redirect_to daemons_path, :flash => {:info => "Daemon stopped. #{r}"}
  end

  def restart
    r = @daemon.stop
    r = @daemon.start
    redirect_to daemons_path, :flash => {:info => "Daemon restarted. #{r}"}
  end

  def logs
    lines = params[:lines] || 1000
    @logs = `tail -n #{lines} log/crawler_daemon.rb.output`
  end

  private

  def assign_daemon
    @daemon =Daemons::Rails::Monitoring.controllers.first
  end
end
