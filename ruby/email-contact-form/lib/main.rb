# Initialize the Appwrite client
require 'appwrite'
require 'dotenv/load'




include Appwrite

client = Client.new()
apiKey = ENV['API_KEY']
client
    .set_endpoint('https://cloud.appwrite.io/v1') # Your Appwrite Endpoint
    .set_project('6744021a002dff4af8c7') # Your project ID
    .set_key(apiKey) # Your secret API key



#Testing 
databases = Appwrite::Databases.new(client)
puts databases.list