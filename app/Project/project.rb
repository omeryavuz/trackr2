# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Project
  include Rhom::PropertyBag
  enable :sync
  set :sync_priority, 1
  #add model specifc code here
end
