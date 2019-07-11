class Discord::JobController < ::Admin::AdminController
  def start
    Discord::Sync.start()
    render json: success_json
  end
end
