require 'rake/clean'
require 'rake/testtask'

CLOBBER << "tmp/Caps"
CLOBBER << "tmp"

file "tmp/Caps" do
  require "net/http"

  mkdir_p "tmp"
  url = URI("https://raw.githubusercontent.com/ThomasDickey/ncurses-snapshots/refs/heads/master/include/Caps")
  res = Net::HTTP.get(url)
  File.binwrite "tmp/Caps", res
end

file "lib/termtime/db.rb" => "tmp/Caps" do |t|
  records = []
  File.open("tmp/Caps") do |f|
    f.each_line do |line|
      break if line =~ /%%-STOP-HERE-%%/

      if line !~ /^#/
        records << line.chomp.gsub(/[\t]+/, "\t").split("\t")
      end
    end
  end

  info = records.group_by { |x| x[2] }

  require "erb"
  template = ERB.new(File.read("templates/#{t.name}.erb"), trim_mode: ">")
  File.binwrite t.name, template.result(binding)
end

task test: "lib/termtime/db.rb"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end
