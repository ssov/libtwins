require 'io/console'
require_relative '../lib/libtwins.rb'

TWINCAL="http://gam0022.net/app/twincal/"
include LibTwins

print "学籍番号: "
id = STDIN.gets.chomp
print "パスワード: "
password = STDIN.noecho(&:gets).chomp

@account = LibTwins::LibTwins.new do
  id id
  password password
end

unless @account.login
  puts "ログインに失敗しました."
end

# 履修状況(CSV)
csv = @account.course.registration_status.csv.body

@agent = Mechanize.new
page = @agent.get(TWINCAL)
page.form_with(id: "form1").file_upload_with(id: "file") do |file|
  file.file_data = csv
  file.mime_type = "text/csv"
  file.file_name = "data.csv"
end
res = page.form_with(id: "form1").submit
File.open(File.expand_path("../", __FILE__) + "/#{res.filename}", "w") do |f|
  f.puts res.body
end
