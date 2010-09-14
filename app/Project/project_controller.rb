require 'rho/rhocontroller'
require 'rho/rhoapplication'
class ProjectController < Rho::RhoController

  #GET /Product


  def tab_index
    puts "*"*90
    puts "tab index"
    create_tabbar
    WebView.navigate("/app/Project/index", 0)
  end




  def index
    puts "*"*90
    puts "project index"
    @projects = Project.find(:all)
    if @projects && !@projects.empty?
      add_objectnotify(@projects)
      render
    else
      Project.set_notification('/app/Project/sync_notification', 'sync_complete=true')
      render :action=>:ok
    end

  end
  #
  # GET /Product/{1}
  def show
    @project = Project.find(@params['id'])
    render :action => :show
    #    redirect :controller => "", :action => :index, :query => {:query => @project.object}
  end

  def create
    @project = Project.new(@params['product'])
    @project.save
    # immediately send to the server
    SyncEngine.dosync_source(@project.source_id)
    redirect :action => :index
  end

  def ok
    NativeBar.create(Rho::RhoApplication::NOBAR_TYPE, [])
  end


  def sync_notification
    puts "*"*90
    puts "project sync_notification params: #{@params.inspect}"
    status = @params['status'] ? @params['status'] : ""
    if status == "error"
      errCode = @params['error_code'].to_i
      @msg = @params['error_message']
      elssg = Rho::RhoError.new(errCode).message
      WebView.navigate(url_for(:controller=>:Settings,:action => :login, :query => {:msg => @msg}))
    end
 
    if status == "ok"
      if SyncEngine::logged_in > 0
        WebView.navigate(url_for(:action => :index))
      end
    end
  end

  def create_tabbar
    puts "*"*90
    puts "create tabbar"
    # do not init more than one time
    #    unless $tabbar_initialized
    tabs = [{ :label => "Projects", :action => '/app/Project/index', :icon => "/public/images/tabs/project.png" },
      { :label => "Settings",  :action => '/app/Settings/index',  :icon => "/public/images/tabs/settings.png" }]
    ::NativeBar.create(Rho::RhoApplication::TABBAR_TYPE, tabs)
    ::NativeBar.switch_tab(0)
    $tabbar_initialized=true
    #    end
  end

end
