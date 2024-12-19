require "helper"
require "termtime"

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

    def test_tparm
      assert_equal "1;1", TermTime.tparm("%i%p1%d;%p2%d")
      assert_equal "0;0", TermTime.tparm("%p1%d;%p2%d")
      assert_equal "1;2", TermTime.tparm("%i%p1%d;%p2%d", 0, 1)
      assert_equal "true", TermTime.tparm("%p1%ttrue%efalse%;", 1)
      assert_equal "false", TermTime.tparm("%p1%ttrue%efalse%;", 0)
      assert_equal "8", TermTime.tparm("%{8}%d")
      assert_equal "%", TermTime.tparm("%%")
      assert_equal [40].pack("C"), TermTime.tparm("%{40}%c")
      #assert_equal "false", TermTime.tparm("%p1%ttrue%efalse%;", 2)
    end

    def test_tparm_lt
      assert_equal "less", TermTime.tparm("%?%p1%{8}%<%tless%emore%?", 0)
      assert_equal "less", TermTime.tparm("%?%p1%{8}%<%tless%emore%;", 0)
      assert_equal "more", TermTime.tparm("%?%p1%{8}%<%tless%emore%;", 8)
    end

    def test_tparm_gt
      assert_equal "less", TermTime.tparm("%?%p1%{8}%>%tmore%eless%;", 0)
      assert_equal "more", TermTime.tparm("%?%p1%{8}%>%tmore%eless%;", 9)
    end

    def test_tparm_eq
      assert_equal "no", TermTime.tparm("%?%p1%{8}%=%tyes%eno%;", 0)
      assert_equal "yes", TermTime.tparm("%?%p1%{8}%=%tyes%eno%;", 8)
    end

    def test_tparm_math
      assert_equal "9", TermTime.tparm("%{8}%p1%+%d", 1)
      assert_equal "7", TermTime.tparm("%{8}%p1%-%d", 1)
      assert_equal "16", TermTime.tparm("%{8}%p1%*%d", 2)
      assert_equal "4", TermTime.tparm("%{8}%p1%/%d", 2)
      assert_equal "1", TermTime.tparm("%{9}%p1%m%d", 2)
    end

    def test_tparm_bits
      assert_equal "1", TermTime.tparm("%{9}%p1%&%d", 1)
      assert_equal "9", TermTime.tparm("%{8}%p1%|%d", 1)
      assert_equal "6", TermTime.tparm("%{5}%p1%^%d", 3)
      assert_equal "-6", TermTime.tparm("%{5}%~%d")
    end

    def test_tparm_bool
      assert_equal "1", TermTime.tparm("%{0}%!%d")
      assert_equal "0", TermTime.tparm("%{5}%!%d")
    end

    def test_tparm_logic
      assert_equal "1", TermTime.tparm("%p1%p2%A%d", 1, 5)
      assert_equal "0", TermTime.tparm("%p1%p2%A%d", 1, 0)
      assert_equal "1", TermTime.tparm("%p1%p2%O%d", 1, 5)
      assert_equal "1", TermTime.tparm("%p1%p2%O%d", 1, 0)
    end

    def test_tparm_char_constant
      assert_equal "65", TermTime.tparm("%'A'%d")
    end

    def test_odk
      x = "\e]4;1;rgb:00/00/01\e\\"
      y = TermTime.tparm("\e]4;%p1%d;rgb:%p2%{255}%*%{1000}%/%2.2X/%p3%{255}%*%{1000}%/%2.2X/%p4%{255}%*%{1000}%/%2.2X\e\\", 1, 2, 3, 4)
      assert_equal x, y
    end
  end
end
