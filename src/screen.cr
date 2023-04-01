module Screen
  extend self

  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  {% if flag?(:win32) && compare_versions(::Crystal::VERSION, "1.7.0") < 0 %}
    {% raise "Screen requires Crystal >= 1.7.0 for Windows" %}
  {% end %}

  {% if flag?(:win32) %}
    @[Link("kernel32")]
    lib LibWindows
      alias SHORT = Int16
      alias TCHAR = ::LibC::WCHAR
      alias BOOL = ::LibC::BOOL
      alias HANDLE = ::LibC::HANDLE
      alias WORD = ::LibC::WORD
      alias DWORD = ::LibC::DWORD

      STD_INPUT_HANDLE  = -10.to_u32!
      STD_OUTPUT_HANDLE = -11.to_u32!
      STD_ERROR_HANDLE  = -12.to_u32!

      struct COORD
        x, y : SHORT
      end

      struct SMALL_RECT
        left, top, right, bottom : SHORT
      end

      type SmallRect = SMALL_RECT

      struct CONSOLE_SCREEN_BUFFER_INFO
        dwSize, dwCursorPosition : COORD
        wAttributes : WORD
        srWindow : SmallRect
        dwMaximumWindowSize : COORD
      end

      type ConsoleScreenBufferInfo = CONSOLE_SCREEN_BUFFER_INFO

      fun GetConsoleScreenBufferInfo(hConsoleOutput : HANDLE, lpConsoleScreenBufferInfo : ConsoleScreenBufferInfo*) : BOOL
      fun SetConsoleCursorPosition(hConsoleOutput : HANDLE, dwCursorPosition : COORD) : BOOL
      fun FillConsoleOutputCharacterW(hConsoleOutput : HANDLE, cCharacter : TCHAR, nLength : DWORD, dwWriteCoord : COORD, lpNumberOfCharsWritten : DWORD*) : BOOL
      fun FillConsoleOutputAttribute(hConsoleOutput : HANDLE, wAttribute : WORD, nLength : DWORD, dwWriteCoord : COORD, lpNumberOfAttrsWritten : DWORD*) : BOOL
      fun GetStdHandle(nStdHandle : DWORD) : HANDLE
    end
  {% end %}

  # Clears the screen and resets cursor position
  #
  # linux/macos: https://github.com/inancgumus/screen/blob/master/clear_others.go
  # win32: https://learn.microsoft.com/en-us/windows/console/clearing-the-screen#example-3
  def cls : Nil
    clear
    move_top_left
  end

  # Clears the screen
  def clear : Nil
    {% if flag?(:win32) %}
      handle = LibWindows.GetStdHandle(LibWindows::STD_OUTPUT_HANDLE)
      cursor = LibWindows::COORD.new # home for the cursor

      # Get the number of character cells in the current buffer
      return if LibWindows.GetConsoleScreenBufferInfo(handle, out h) == 0

      total = (h.dwSize.x * h.dwSize.y).to_u32

      # Fill the entire screen with blanks
      return if LibWindows.FillConsoleOutputCharacterW(handle, ' '.ord, total, cursor, out _) == 0

      # Get the current text attribute
      return if LibWindows.GetConsoleScreenBufferInfo(handle, pointerof(h)) == 0

      # Set the buffer's attributes accordingly
      LibWindows.FillConsoleOutputAttribute(handle, h.wAttributes, total, cursor, out _)
    {% else %}
      print "\033[2J"
    {% end %}
  end

  # Resets cursor position
  def move_top_left : Nil
    {% if flag?(:win32) %}
      handle = LibWindows.GetStdHandle(LibWindows::STD_OUTPUT_HANDLE)
      cursor = LibWindows::COORD.new # home for the cursor

      # Put the cursor at its home coordinates
      LibWindows.SetConsoleCursorPosition(handle, cursor)
    {% else %}
      print "\033[H"
    {% end %}
  end
end
