/*
  Copyright (c) 2012 Juan Mellado

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
*/

/*
References:
- JSpeccy
  http://jspeccy.speccy.org/
*/

class Color {
  final int r, g, b;

  const Color(this.r, this.g, this.b);
}

class ScreenBuffer {

  final List<int> _rows;

  final List<Color> _ink;

  final List<Color> _paper;

  int _flash;

  final List<Color> _palette;

  html.CanvasRenderingContext2D _context;

  html.ImageData _imageData;

  ScreenBuffer() :
    _rows = new List<int>(192),
    _ink = new List<Color>(256),
    _paper = new List<Color>(256),
    _flash = 0,
    _palette = const[const Color(0x00, 0x00, 0x00), const Color(0x00, 0x00, 0xc0),
                     const Color(0xc0, 0x00, 0x00), const Color(0xc0, 0x00, 0xc0),
                     const Color(0x00, 0xc0, 0x00), const Color(0x00, 0xc0, 0xc0),
                     const Color(0xc0, 0xc0, 0x00), const Color(0xc0, 0xc0, 0xc0),
                     const Color(0x00, 0x00, 0x00), const Color(0x00, 0x00, 0xff),
                     const Color(0xff, 0x00, 0x00), const Color(0xff, 0x00, 0xff),
                     const Color(0x00, 0xff, 0x00), const Color(0x00, 0xff, 0xff),
                     const Color(0xff, 0xff, 0x00), const Color(0xff, 0xff, 0xff) ] {

    _init();
  }

  void _init() {
    _initRows();
    _initColors();
    _initCanvas();
  }

  void _initRows() {
    for (int row = 0; row < 24; ++ row) {
      final int base = row << 3;

      int address = 0x4000 + ((row & 0x18) << 8) + ((row & 0x07) << 5);
      for (int scan = 0; scan < 8; ++ scan, address += 256) {
        _rows[base + scan] = address;
      }
    }
  }

  void _initColors() {
    for (int i = 0; i < 256; ++ i) {
      final int ink = (i & 0x07) | ((i & 0x40) !== 0 ? 0x08 : 0x00);
      final int paper = ((i >> 3) & 0x07) | ((i & 0x40) !== 0 ? 0x08 : 0x00);

      _ink[i] = _palette[(i & 0x80) === 0 ? ink: paper];
      _paper[i] = _palette[(i & 0x80) === 0 ? paper: ink];
    }
  }

  void _initCanvas() {
    html.CanvasElement canvas = html.document.query("canvas");

    _context = canvas.getContext("2d");

    _imageData = _context.getImageData(32, 28, 256, 192);
  }

  void flash() {
    _flash = _flash === 0x7f? 0xff: 0x7f;
  }

  void border(final int value) {
    final Color color = _palette[value & 0x07];

    _context.canvas.style.background = "rgb(${color.r}, ${color.g}, ${color.b})";
  }

  void dump(final Memory memory) {
    html.Uint8ClampedArray data = _imageData.data;

    int pos = 0;

    int attrs = 22528;

    for (int row = 0; row < 192; attrs += 32) {
      for (int scan = 0; scan < 8; ++ scan) {
        final int address = _rows[row ++];

        for (int col = 0; col < 32; ++ col) {
          final int byte = memory.readByte(address + col);
          final int attr = memory.readByte(attrs + col) & _flash;

          for (int mask = 0x80; mask !== 0; mask >>= 1) {
            final Color color = (byte & mask) !== 0 ? _ink[attr] : _paper[attr];

            data[pos ++] = color.r;
            data[pos ++] = color.g;
            data[pos ++] = color.b;
            data[pos ++] = 0xff;
          }
        }
      }
    }

    _context.putImageData(_imageData, 32, 28);
  }
}
