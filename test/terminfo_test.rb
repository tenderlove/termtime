require "helper"
require "termtime/db"
require "termtime/terminfo"

module TermTime
  class TermInfoTest < Test
    def test_info
      ti = TermInfo.new File.join(FIXTURES, "xterm-256color")
      assert_equal ["xterm-256color", "xterm with 256 colors"], ti.names
      assert_equal ["am", "bce", "ccc", "xenl", "km", "mir", "msgr", "npc", "mc5i"].sort, ti.flags.map(&:tiname).sort
      assert ti.getflag("am")
      assert ti.getflag("npc")
      assert_equal ["colors", "cols", "it", "lines", "pairs"].sort, ti.numbers.map(&:tiname).sort
      assert_equal [256, 80, 8, 24, 32767], ti.numbers.sort_by(&:tiname).map(&:value)

      assert_equal 256, ti.getnum("colors")
      assert_equal 24, ti.getnum("lines")

      assert_equal "\e[H\e[2J", ti.getstr("clear")
    end

    def test_adm3a
      ti = TermInfo.new File.join(FIXTURES, "adm3a")
      assert_equal ["adm3a", "lsi adm3a"], ti.names
      assert_equal ["am"], ti.flags.map(&:tiname)
      assert ti.getflag("am")
      refute ti.getflag("npc")

      assert_equal ["cols", "lines"].sort, ti.numbers.map(&:tiname).sort
      assert_equal [80, 24], ti.numbers.sort_by(&:tiname).map(&:value)

      assert_equal ["bel", "clear", "cr", "cub1", "cud1", "cuf1", "cup", "cuu1", "home", "ind", "kcub1", "kcud1", "kcuf1", "kcuu1", "rs2"], ti.strings.map(&:tiname).sort

      assert_equal ["\a", "\x1A$<1/>", "\r", "\b", "\n", "\f", "\e=%p1%' '%+%c%p2%' '%+%c", "\v", "\x1E", "\n", "\b", "\n", "\f", "\v", "\x0E"], ti.strings.sort_by(&:tiname).map(&:value)
    end
  end
end
