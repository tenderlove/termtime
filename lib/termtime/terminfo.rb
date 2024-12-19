# frozen_string_literal: true

require "termtime/db"

module TermTime
  class TermInfo
    class Number
      attr_reader :value, :db

      def initialize v, db
        @value = v
        @db = db
        freeze
      end

      def tiname; @db.tiname; end
    end

    class String
      attr_reader :value, :db

      def initialize v, db
        @value = v
        @db = db
        freeze
      end

      def tiname; @db.tiname; end
    end

    def initialize fname
      unless File.file? fname
        fname = "/usr/share/terminfo/#{fname.getbyte(0).to_s(16)}/#{fname}"
      end

      File.open fname, "rb" do |f|
        magic,
          names_size,
          booleans_size,
          short_int_count,
          offset_count,
          string_table_size = f.read((2 * 6)).unpack("ssssss")

        raise unless magic == 0432
        @names = f.read(names_size - 1).force_encoding("UTF-8").freeze
        raise unless f.readbyte == 0
        @flags = f.read(booleans_size - 1)

        f.readbyte
        f.readbyte if f.pos % 2 != 0 # alignment

        @numbers = f.read(short_int_count * 2)
        strings = f.read(offset_count * 2)
        string_table = f.read(string_table_size)
        @strings = decode_strings(strings, string_table)
      end
    end

    def flags
      flags = []
      @flags.bytesize.times do |i|
        if @flags.getbyte(i) > 0
          flags << DB::BOOLEAN_LIST.fetch(i)
        end
      end
      flags
    end

    def numbers
      numbers = []
      @numbers.unpack("s*").each_with_index do |v, i|
        next if v == -1
        numbers << Number.new(v, DB::NUMBER_LIST.fetch(i))
      end
      numbers
    end

    def strings
      @strings.values
    end

    def getnum name
      offset = DB::NUMBERS.fetch(name).i * 2
      @numbers.getbyte(offset) | (@numbers.getbyte(offset + 1) << 8)
    end

    def getflag name
      @flags.getbyte(DB::BOOLEANS.fetch(name).i) == 1
    end

    def getstr name
      @strings.fetch(name).value
    end

    def names
      @names.split("|")
    end

    private

    def decode_strings str_offsets, string_table
      strings = {}
      str_offsets.unpack("s*").each_with_index do |v, i|
        next if v == -1
        next if i >= DB::STRING_LIST.length

        len = string_table.byteindex("\0", v) - v
        str = string_table.byteslice(v, len).freeze
        x = DB::STRING_LIST.fetch(i)
        strings[x.tiname] = String.new(str, x)
      end
      strings
    end
  end
end
