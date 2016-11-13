#!/usr/bin/env ruby

require 'sqlite3'
require 'sinatra'

$db = SQLite3::Database.new "vocab.db"
$db.results_as_hash = true

def doDisplay
  items = $db.execute "SELECT * FROM vocab ORDER BY num_reviews, RANDOM() LIMIT 6;"
  <<-HEREDOC
    <!DOCTYPE html>
    <html>
    <head>
    <title>
      ASL Practise Words
    </title>
    </head>
    <body>
      <dl>
        #{items.map do |i|
          "<dt>#{i["list_number"]}</dt><dd>#{i["description"]} (pg. #{i["page_number"]})</dd>"
        end.join}
      </dl>
      <form method="POST">
        #{items.map do |i|
          "<input type=\"hidden\" name=\"id[]\" value=\"#{i["id"]}\" />"
        end.join}
        <input type="submit" value="Mark and Reload" name="mark" />
        <input type="submit" value="Reload Only" />
      </form>
    </body>
    </html>
  HEREDOC
end

get '/' do
  doDisplay
end

post '/' do
  if params["mark"]
    places = (['?'] * params["id"].length).join(',')
    $db.execute("UPDATE vocab SET num_reviews = num_reviews + 1 WHERE id IN (#{places})", params["id"])
  end
  doDisplay
end
