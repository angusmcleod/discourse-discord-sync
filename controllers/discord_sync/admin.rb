class DiscordSync::AdminController < ::Admin::AdminController
  def index
    render_json_dump(logs: DiscordSync::Log.list)
  end
  
  def start
    Jobs.enqueue(:discord_sync_trust_level_with_role)
    render json: success_json
  end
  
  def clear
    DiscordSync::Log.clear
    render json: success_json
  end
end