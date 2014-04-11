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

puts
# ある科目の履修操作を行う
@account.course.registration_status.registration("科目番号")
