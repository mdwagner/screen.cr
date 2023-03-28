module Screen
  extend self

  {% if flag?(:win32) %}
    lib LibC
      alias SHORT = Int16
      alias TCHAR = WCHAR

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

  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

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
      handle = LibC.GetStdHandle(LibC::STD_OUTPUT_HANDLE)
      cursor = LibC::COORD.new # home for the cursor

      # Get the number of character cells in the current buffer
      return if LibC.GetConsoleScreenBufferInfo(handle, out h) == 0

      total = (h.dwSize.x * h.dwSize.y).to_u32

      # Fill the entire screen with blanks
      return if LibC.FillConsoleOutputCharacterW(handle, ' '.ord, total, cursor, out _) == 0

      # Get the current text attribute
      return if LibC.GetConsoleScreenBufferInfo(handle, out h) == 0

      # Set the buffer's attributes accordingly
      LibC.FillConsoleOutputAttribute(handle, h.wAttributes, total, cursor, out _)
    {% else %}
      print "\033[2J"
    {% end %}
  end

  # Resets cursor position
  def move_top_left : Nil
    {% if flag?(:win32) %}
      handle = LibC.GetStdHandle(LibC::STD_OUTPUT_HANDLE)
      cursor = LibC::COORD.new # home for the cursor

      # Put the cursor at its home coordinates
      LibC.SetConsoleCursorPosition(handle, cursor)
    {% else %}
      print "\033[H"
    {% end %}
  end
end
