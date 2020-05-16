class Discord::AdminController < ::Admin::AdminController
  def index
    render_json_dump(logs: Discord::Log.list)
  end
  
  def start
    Discord.sync
    render json: success_json
  end
  
  def clear
    Discord::Log.clear
    render json: success_json
  end
end