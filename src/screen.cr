{% if flag?(:win32) %}
  # https://learn.microsoft.com/en-us/windows/console/clearing-the-screen#example-3
  # https://github.com/inancgumus/screen/blob/master/clear_windows.go
  @[Link("kernel32")]
  lib LibC
    alias SHORT = Int16
    alias WCHAR = UInt16
    alias TCHAR = WCHAR
    alias LPDWORD = DWORD*

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
    fun SetConsoleCursorPosition(hConsoleOutput : HANDLE, dwCursorPosition : COORD*) : BOOL
    fun FillConsoleOutputCharacterW(hConsoleOutput : HANDLE, cCharacter : TCHAR, nLength : DWORD, dwWriteCoord : COORD, lpNumberOfCharsWritten : LPDWORD) : BOOL
    fun FillConsoleOutputAttribute(hConsoleOutput : HANDLE, wAttribute : WORD, nLength : DWORD, dwWriteCoord : COORD, lpNumberOfAttrsWritten : LPDWORD) : BOOL
  end
{% end %}

module Screen
  extend self

  VERSION = "0.1.0"

  def clear : Nil
    {% if flag?(:win32) %}
      handle = pointerof(STDOUT)
      cursor = LibC::COORD.new(x: 0, y: 0)
      h = get_screen
      total : LibC::DWORD = h.value.dwSize.x * h.value.dwSize.y
      LibC.FillConsoleOutputCharacterW(handle, ' ', total, cursor, out w)
      LibC.FillConsoleOutputAttribute(handle, h.wAttributes, total, cursor, out w)
    {% else %}
      print "\033[2J"
    {% end %}
  end

  def move_top_left : Nil
    {% if flag?(:win32) %}
      handle = pointerof(STDOUT)
      h = get_screen
      coord = LibC::COORD.new(x: 0, y: 0)
      LibC.SetConsoleCursorPosition(handle, coord)
    {% else %}
      print "\033[H"
    {% end %}
  end

  {% if flag?(:win32) %}
    private def get_screen : LibC::ConsoleScreenBufferInfoType*
      handle = pointerof(STDOUT)
      LibC.GetConsoleScreenBufferInfo(handle, out h)
      h
    end
  {% end %}
end
