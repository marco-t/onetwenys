module Outputer
  DEFAULT_DELAY = 0.3
  CURSOR_UP = "\033[F"
  ERASE_LINE = "\033[K"

  def output(msg, delay = DEFAULT_DELAY)
    sleep(delay)
    puts msg
  end

  def output_line(msg, delay = DEFAULT_DELAY)
    sleep(delay)
    print msg
  end

  def clear_line
    print(CURSOR_UP + ERASE_LINE)
  end

  def clear_lines(number_of_lines)
    number_of_lines.times { print(CURSOR_UP + ERASE_LINE) }
  end
end