require 'rho/rhoapplication'

class AppApplication < Rho::RhoApplication


  def initialize
  @@toolbar=nil
    super
#    SyncEngine::set_objectnotify_url("/app/Settings/sync_notify")
#
#    # we want to be notified whenever either of these sources is synced
#    Project.set_notification("/app/Settings/sync_notify", "fixed sync_notify for Project")
#    Story.set_notification("/app/Settings/sync_notify", "fixed sync_notify for Story")
#    Comment.set_notification("/app/Settings/sync_notify", "fixed sync_notify for Comment")
  end



end
