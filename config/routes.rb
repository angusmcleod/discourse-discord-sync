::DiscordSync::Engine.routes.draw do
  get 'logs' => "admin#index"
  delete "logs" => "admin#clear"
  post "start" => "admin#start"
  get 'authorization/callback' => "authorization#callback"
end

require_dependency 'staff_constraint'
Discourse::Application.routes.prepend do
  mount ::DiscordSync::Engine, at: 'discord-sync'
  get '/admin/plugins/discord-sync' => 'admin/plugins#index', constraints: StaffConstraint.new
end