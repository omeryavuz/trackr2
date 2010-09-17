require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'rhom/rhom_source'
require 'time'

class SettingsController < Rho::RhoController
  
  def index
    @msg = @params['msg']
    @@toolbar = nil
    render
  end

  def login
    @msg = @params['msg']
    @@toolbar = nil
    unless @msg.nil?
      @msg = "You entered an invalid credential"
    end
    render :action => :login
  end

  def become_active_callback
    puts 'become_active_callback' + @params.inspect
  end
  
  def login_callback
    err_code = @params['error_code'].to_i
    if err_code == 0
      # run sync if we were successful
      puts "*"*90
      puts "start full sync"
      SyncEngine.dosync
      puts "redirect to start path"
      WebView.navigate Rho::RhoConfig.start_path
      puts "*"*90

    else
      if err_code == Rho::RhoError::ERR_CUSTOMSYNCSERVER
        @msg = @params['error_message']
      end
        
      if !@msg || @msg.length == 0   
        @msg = Rho::RhoError.new(err_code).message
      end
      WebView.navigate ( url_for :action => :login, :query => {:msg => @msg} )
    end  
  end

  def do_login
    if @params['login'] and @params['password'] and @params['token']
      unless @params['token'].empty?
        @params['login'] = @params['token']
        @params['password']="doesnotmatter"
        Rho::RhoConfig.pivotal_token = @params['login']
      else
        Rho::RhoConfig.pivotal_token = ""
      end
      begin
        SyncEngine.login(@params['login'], @params['password'], (url_for :action => :login_callback) )
        render :action => :wait
      rescue Rho::RhoError => e
        @msg = e.message
        render :action => :login, :query => {:msg => @msg}
      end
    else
      @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
      render :action => :login, :query => {:msg => @msg}
    end
  end

  
  def logout
    Rhom::Rhom.database_full_reset
    SyncEngine.logout
    @msg = "You have been logged out."
    NativeBar.create(Rho::RhoApplication::NOBAR_TYPE, [])
    WebView.navigate url_for(:controller => 'Settings', :action => 'login', :query => {:msg => @msg})
#    render :action => :login, :query => {:msg => @msg}
  end
  
  def reset
    render :action => :reset
  end
  
  def do_reset
    Rhom::Rhom.database_full_reset
    SyncEngine.dosync
    @msg = "Database has been reset."
    puts "$$$"*120
    puts Story.find(:all).inspect
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def do_sync
    SyncEngine.dosync
    @msg =  "Sync has been triggered."
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def sync_notify
  	puts 'sync_object_notify: ' + @params.inspect  
  	# refresh the current page
  	status = @params['status'] ? @params['status'] : ""
    if status == "ok" 	
    	# need to re-register
    	Project.set_notification("/app/Settings/sync_notify", "fixed sync_notify for Project")
    	Story.set_notification("/app/Settings/sync_notify", "fixed sync_notify for Story")
      Comment.set_notification("/app/Settings/sync_notify", "fixed sync_notify for Comment")
      WebView.refresh
	  end
  end
  
end
