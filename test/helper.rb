require "minitest/autorun"

module TermTime
  class Test < Minitest::Test
    FIXTURES = File.expand_path(File.join(File.dirname(__FILE__), "fixtures"))
  end
end
