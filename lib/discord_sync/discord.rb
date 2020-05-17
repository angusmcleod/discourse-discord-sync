require 'excon'

class DiscordSync::Discord
  def self.request(type, path, opts={})

    connection = Excon.new(
      "https://discordapp.com/api/v6#{path}",
      :headers => {
        "Authorization" => "Bot #{SiteSetting.discord_sync_bot_token}",
        "Accept" => "application/json, */*",
        "Content-Type" => "application/json",
        "User-Agent" => "Development"
      }
    )

    params = {
      method: type
    }

    if opts[:query]
      params[:query] = opts[:query]
    end

    if opts[:body]
      params[:body] = opts[:body].to_json
    end

    response = connection.request(params)

    response.body.present? ? JSON.parse(response.body) : nil
  end
end
