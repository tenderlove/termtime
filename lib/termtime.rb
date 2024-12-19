# frozen_string_literal: true

require "strscan"

module TermTime
  autoload :TermInfo, "termtime/terminfo"
  autoload :DB, "termtime/db"

  def self.tparm fmt, p1 = 0, p2 = 0, p3 = 0, p4 = 0, p5 = 0, p6 = 0, p7 = 0, p8 = 0, p9 = 0
    return fmt unless fmt =~ /%/

    regs = [p1, p2, p3, p4, p5, p6, p7, p8, p9]
    stack = []

    scan = StringScanner.new fmt
    buff = ''.b

    while !scan.eos?
      start = scan.pos
      case
      when scan.skip(/%i/)
        regs[0] += 1
        regs[1] += 1
      when scan.skip(/%t/)
        if stack.pop == 0
          scan.skip_until(/%e/)
        else
        end
      when scan.skip(/%c/)
        buff << stack.pop
      when scan.skip(/%</)
        y = stack.pop
        x = stack.pop
        stack << (x < y ? 1 : 0)
      when scan.skip(/%>/)
        y = stack.pop
        x = stack.pop
        stack << (x > y ? 1 : 0)
      when scan.skip(/%\+/) then stack << (stack.pop + stack.pop)
      when scan.skip(/%\*/) then stack << (stack.pop * stack.pop)
      when scan.skip(/%-/)
        y = stack.pop
        x = stack.pop
        stack << (x - y)
      when scan.skip(/%\//)
        y = stack.pop
        x = stack.pop
        stack << (x / y)
      when scan.skip(/%m/)
        y = stack.pop
        x = stack.pop
        stack << (x % y)
      when scan.skip(/%!/) then stack << (stack.pop == 0 ? 1 : 0)
      when scan.skip(/%=/) then stack << (stack.pop == stack.pop ? 1 : 0)
      when scan.skip(/%%/) then buff << "%"
      when scan.skip(/%e/)
        # if we made it to %e, we must have been in the true branch,
        # so skip until after %;
        if !scan.skip_until(/%;/)
          break;
        end
      when scan.skip(/%l/) then raise NotImplementedError
      when scan.skip(/%&/) then stack << (stack.pop & stack.pop)
      when scan.skip(/%\|/) then stack << (stack.pop | stack.pop)
      when scan.skip(/%\^/) then stack << (stack.pop ^ stack.pop)
      when scan.skip(/%~/) then stack << (~stack.pop)
      when scan.skip(/%'.'/) then stack << fmt.getbyte(start + 2)
      when scan.skip(/%A/)
        stack << (stack.pop != 0 && stack.pop != 0 ? 1 : 0)
      when scan.skip(/%O/)
        stack << (stack.pop != 0 || stack.pop != 0 ? 1 : 0)
      when scan.skip(/%[;?]/)
      when scan.skip(/%{\d+}/)
        stack << fmt.byteslice(start + 2, scan.pos - start - 3).to_i
      when scan.skip(/%p[0-9]/)
        stack.push regs[(fmt.getbyte(scan.pos - 1) - 0x30) - 1]
      when str = scan.scan(/%([0-9].[0-9])?[dsoxX]/)
        buff << sprintf(str, stack.pop)
      when str = scan.scan(/[^%]+/)
        buff << str
      else
        p scan
        raise
      end
    end
    buff
  end
end
