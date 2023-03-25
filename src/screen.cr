{% if flag?(:win32) %}
  # https://learn.microsoft.com/en-us/windows/console/clearing-the-screen#example-3
  # https://github.com/inancgumus/screen/blob/master/clear_windows.go
  lib LibC
    alias SHORT = Int16
    alias TCHAR = WCHAR
    alias LPDWORD = DWORD*

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
    fun FillConsoleOutputCharacterW(hConsoleOutput : HANDLE, cCharacter : TCHAR, nLength : DWORD, dwWriteCoord : COORD, lpNumberOfCharsWritten : LPDWORD) : BOOL
    fun FillConsoleOutputAttribute(hConsoleOutput : HANDLE, wAttribute : WORD, nLength : DWORD, dwWriteCoord : COORD, lpNumberOfAttrsWritten : LPDWORD) : BOOL
    fun GetStdHandle(nStdHandle : DWORD) : HANDLE
  end
{% end %}

module Screen
  extend self

  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  # Clears the screen and resets cursor position
  def cls : Nil
    clear
    move_top_left
  end

  # Clears the screen
  def clear : Nil
    {% if flag?(:win32) %}
      handle = LibC.GetStdHandle(LibC::STD_OUTPUT_HANDLE)
      cursor = LibC::COORD.new(x: 0, y: 0)
      h = get_screen
      total = (h.dwSize.x * h.dwSize.y).to_u32
      LibC.FillConsoleOutputCharacterW(handle, ' '.ord, total, cursor, out _)
      LibC.FillConsoleOutputAttribute(handle, h.wAttributes, total, cursor, out _)
    {% else %}
      print "\033[2J"
    {% end %}
  end

  # Resets cursor position
  def move_top_left : Nil
    {% if flag?(:win32) %}
      handle = LibC.GetStdHandle(LibC::STD_OUTPUT_HANDLE)
      cursor = LibC::COORD.new(x: 0, y: 0)
      LibC.SetConsoleCursorPosition(handle, cursor)
    {% else %}
      print "\033[H"
    {% end %}
  end

  {% if flag?(:win32) %}
    private def get_screen : LibC::ConsoleScreenBufferInfo
      handle = LibC.GetStdHandle(LibC::STD_OUTPUT_HANDLE)
      LibC.GetConsoleScreenBufferInfo(handle, out h)
      h
    end
  {% end %}
end
