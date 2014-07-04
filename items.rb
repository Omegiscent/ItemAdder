require 'net/http'
require 'base64'
require 'json'
require 'net/https'
require 'uri'
require 'openssl'

class Adder
   @@api = 'FD 9B407F96-418B-4E0B-93DB-3AD33CC7D72E:205EF7823B24EE5277E318E061E5557F4648F1BF4CCFB457'
   def AddItem(username, password, items)
      base = username + ':' + password
      base = Base64.encode64(base)
      base = base.encode('utf-8')
      #Emh, this here is the headers
      headers = {
         'Authorization' => "Basic #{base.strip}" + ',' + @@api
      }
      url = URI.parse("https://api.disney.com/clubpenguin/mobile/v2/authToken")
      req = Net::HTTP::Get.new("/clubpenguin/mobile/v2/authToken?appId=CPMCAPP&appVersion=1.4&language=en", headers)
      res = Net::HTTP.new(url.host, url.port)
      res.use_ssl=true
      res.start do |http|
         @@x = http.request(req)
         if "#{@@x}".include? "HTTPOK"
            puts 'Logged in as ' + "#{username}" + ":" +  "#{password}" + "\n"
         else
            abort("Login Failed")
         end   
      end
      authToken = JSON.parse(@@x.body)
      authToken = authToken['authToken']
      @@authToken=authToken
      base = @@authToken + ':'
      base = Base64.strict_encode64(base.encode('ascii'))
      base = base.encode('utf-8')
      headers = {
         'Authorization' => "Basic #{base.strip}" + ',' + @@api
      }
      for item in items
         url = URI.parse("https://api.disney.com/clubpenguin/mobile/v2/purchase")
         req = Net::HTTP::Post.new("/clubpenguin/mobile/v2/purchase?catalogId=500435792&itemType=paper_item&itemId=#{item}", headers)
         res = Net::HTTP.new(url.host, url.port)
         res.use_ssl=true
         res.start do |http|
            @@x = http.request(req)
            if "#{@@x}".include? "HTTPOK"
               puts "Item: #{item} added"
            else
               message = JSON.parse(@@x.body)
               message = message["errorResponse"]["message"]
               puts "Item was not added. Reason: #{message}"
            end
         end
      end
   end
end
# Penguin information
username = 'orange0juice'
password = 'dicks1234'
items = [123]
ItemAdder = Adder.new
ItemAdder.AddItem(username, password, items)
