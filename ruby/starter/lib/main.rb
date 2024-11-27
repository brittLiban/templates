require "appwrite"
require 'dotenv/load'

# This Appwrite function will be executed every time your function is triggered
def main(context)
  # grabbing api key for later
  apiKey = ENV['API_KEY']
  # You can use the Appwrite SDK to interact with other services
  # For this example, we're using the Users service
  client = Appwrite::Client.new
  client
  api_key = "standard_adb65471663d9ed9059fae3f3ade11319b5047720325f69118374f48ff3cb60c2ac38dff0656304887dd8139a69827566c43409a43fee68726a1441fcbb10e2c02a7c846db7d6797a47103d1635b9e2e28b8b6599ef32cfc8c1e32cedf982167d34798958e895904f173b6fcbaf2e30861fe5cf8a58a1fbac5f0bf8984c8b831"
  appwrite_endpoint = "https://cloud.appwrite.io/v1"
  appwrite_project_id = "6744021a002dff4af8c7"
  
  users = Appwrite::Users.new(client)

  begin
    response = users.list()
    # Log messages and errors to the Appwrite Console
    # These logs won't be seen by your end users
    context.log("Total users: " + response.total.to_s)
  rescue Exception => e
    context.error("Could not list users: " + e.full_message)
  end

  # The req object contains the request data
  if (context.req.path == "/ping")
    # Use res object to respond with text(), json(), or binary()
    # Don't forget to return a response!
    return context.res.text("Pong")
  end

  return context.res.json(
    {
      "motto": "Build like a team of hundreds_",
      "learn": "https://appwrite.io/docs",
      "connect": "https://appwrite.io/discord",
      "getInspired": "https://builtwith.appwrite.io",
    }
  )
end
