require 'rho/rhocontroller'

class StoryController < Rho::RhoController
 
  def index
    @project_id=@params['project_id']
    puts "story index project_id:#{@project_id}"
   unless  @project_id.nil? || @project_id.empty?
      if @params['iteration'].nil? || @params['iteration'].empty?
        @iteration="current"
      else
        @iteration = @params['iteration']
      end
      @stories = Story.find(:all,:conditions =>{:project_id =>@project_id,:iteration => @iteration})
    
      if (@stories.empty?&&get_count_search<=1)
        Story.search(
          :from => 'search',
          :search_params => {:count_search=>get_count_search,:project_id => @project_id,:iteration=>@iteration},
          :offset => '',
          :max_results => '',
          :callback => url_for(:action => :search_callback),
          :callback_param =>"iteration=#{@iteration}&project_id=#{@project_id}&count_search=#{get_count_search}"
        )
        render :action=>:ok
      else
        #im creating the tabs here
        render
      end
    end
  end

 # def ok
#   NativeBar.create(Rho::RhoApplication::NOBAR_TYPE, [])
#  end

  def search_callback
    SyncEngine.dosync
    status = @params['status']
    if ( @params['project_id'] && !@params['project_id'].empty?)
      WebView.navigate( url_for :controller=>"Story",:action => :index,
        :query => {:count_search=>get_count_search,:iteration=>@params['iteration'],:story_id=>@params['story_id'],:project_id => @params['project_id'].gsub(/[^0-9]/, '')} )
    end
  end

  def ok
    NativeBar.create(Rho::RhoApplication::NOBAR_TYPE, [])
    render
  end

  # GET /Customer/{1}
  def show
    @project_id=@params['project_id']
    @iteration=@params['iteration']
    @story = Story.find(@params['id'])
    puts "$$$"*120
    puts @story.inspect
    if (@story.nil? || @story.empty?)&&get_count_search<=0
      Story.search(
        :from => 'search',
        :search_params => {:count_search=>get_count_search,:project_id => @project_id,:iteration=>@iteration},
        :offset => '',
        :max_results => '',
        :callback => url_for(:action => :search_callback),
        :callback_param =>"iteration=#{@iteration}&project_id=#{@project_id}&count_search=#{get_count_search}"
      )
      render :action=>:ok
    else
      render :action=>:show
    end
    render :action=>:show
  end

  def edit
    @iteration=@params['iteration']
    @story = Story.find(@params['id'])
    render :action => :edit
  end

  def new
    @story = Story.new
    @type=@params['type']
    @story.project_id = @params['project_id']
    render :action => :new
  end

  def create
    @iteration = 'icebox'
    @story = Story.new(@params['story'])
    @story.iteration = @iteration
    @story.project_id = @params['project_id']
  
    if @story.save
      SyncEngine.dosync
      Story.set_notification('/app/Story/sync_notification',"iteration=#{@iteration}&project_id=#{@params['project_id']}")
      render :action=>:ok
    end
  end


  def update
    @iteration =@params['iteration'] 
    @story = Story.find(@params['story_id'])
    @story.iteration = @iteration
    @story.name="Holassssssss"
    puts "99999"*120
    @story.update_attributes(@params['story'])
    puts @story.inspect
     SyncEngine.dosync
     Story.set_notification('/app/Story/sync_notification',"iteration=#{@iteration}&project_id=#{@params['project_id']}")
    render :action=>:ok
  end


  def sync_notification
    status = @params['status'] ? @params['status'] : ""
    if status == "error"
      errCode = @params['error_code'].to_i
      if errCode == Rho::RhoError::ERR_CUSTOMSYNCSERVER
        @msg = @params['error_message']
      else
        @msg = Rho::RhoError.new(errCode).message
      end
      WebView.navigate(url_for(:action => :create_error))
      #raise "There was an error on last sync"
    elsif status == "ok"
      if SyncEngine::logged_in > 0
        WebView.navigate(url_for(:action => :index, :query => {:project_id=> @params['project_id'], :iteration => @params['iteration'] }))
      else
        # rhosync has logged us out
        WebView.navigate "/app/Settings/login"
      end
    end
  end


  def delete
    @iteration =@params['iteration'] 
    @story = Story.find(@params['story_id'])
    @story.destroy
    SyncEngine.dosync
    Story.set_notification('/app/Story/sync_notification',"iteration=#{@iteration}&story_id=#{@params['story_id']}&project_id=#{@params['project_id']}")
    render :action=>:ok 
  end

  def get_count_search
    if  @params['count_search'].nil? || @params['count_search'].empty?
      return 0
    else
      count_search=@params['count_search'].to_i
      count_search=count_search+1
      return count_search
    end
  end



end
