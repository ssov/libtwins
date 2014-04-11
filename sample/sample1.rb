require 'io/console'
require_relative '../lib/libtwins.rb'

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

# 履修状況(Web画面よりスクレイピング)
@account.course.registration_status.status
# 履修状況(CSV)
p @account.course.registration_status.csv
