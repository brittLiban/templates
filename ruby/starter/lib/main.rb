require "appwrite"

def main(context)
  # Hardcoded values
  api_key = "standard_adb65471663d9ed9059fae3f3ade11319b5047720325f69118374f48ff3cb60c2ac38dff0656304887dd8139a69827566c43409a43fee68726a1441fcbb10e2c02a7c846db7d6797a47103d1635b9e2e28b8b6599ef32cfc8c1e32cedf982167d34798958e895904f173b6fcbaf2e30861fe5cf8a58a1fbac5f0bf8984c8b831"
  appwrite_endpoint = "https://cloud.appwrite.io/v1"
  appwrite_project_id = "6744021a002dff4af8c7"

  # Set up Appwrite client
  client = Appwrite::Client.new
  client
    .set_endpoint(appwrite_endpoint)
    .set_project(appwrite_project_id)
    .set_key(api_key)

  users = Appwrite::Users.new(client)

  begin
    # Attempt to list users
    response = users.list
    context.log("Total users: #{response['total']}")
  rescue Appwrite::Exception => e
    # Log specific Appwrite error
    context.error("Appwrite error: #{e.message}")
    return context.res.text("Error: #{e.message}", status: 500)
  rescue Exception => e
    # Log other errors
    context.error("Could not list users: #{e.full_message}")
    return context.res.text("Error: Could not list users.", status: 500)
  end

  if context.req.path == "/ping"
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
