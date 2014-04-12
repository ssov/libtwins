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

# 最終的な単位取得状況(CSV)
@account.grades.finalized_grade_inquiry.csv
