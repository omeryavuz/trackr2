require 'rho/rhocontroller'
class CommentController < Rho::RhoController

  def index
    @story_id=@params['story_id']
    project_id=@params['project_id']
    #    unless  story_id.nil? || story_id.empty?
    @comments = Comment.find(:all,:conditions =>{:story_id =>@story_id})
    if (@comments.nil? || @comments.empty?)&&get_count_search<=0
      Comment.search(
        :from => 'search',
        :search_params => {:count_search=>get_count_search,:story_id =>@story_id, :project_id => project_id},
        :offset => '',
        :max_results => '',
        :callback => url_for(:action => :search_callback),
        :callback_param => "story_id=#{@story_id}&project_id=#{project_id}&count_search=#{get_count_search}"
      )
      render :action=>:ok
    else
      render
    end
  end

  def search_callback
    status = @params['status']
    if (status && status == 'ok' && @params['story_id']&& @params['project_id'])
      WebView.navigate( url_for :action => :index,
        :query => {:count_search=>get_count_search,:project_id => @params['project_id'].gsub(/[^0-9]/, ''), :story_id => @params['story_id'].gsub(/[^0-9]/, '')} )
    end
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
