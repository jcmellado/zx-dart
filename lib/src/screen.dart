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

part of zx;

class Color {
  final int r, g, b;

  const Color(this.r, this.g, this.b);
}

class Screen {
  final List<int> _rows = new List<int>.fixedLength(192);

  final List<Color> _ink = new List<Color>.fixedLength(256);
  final List<Color> _paper = new List<Color>.fixedLength(256);
  int _flash = 0;

  final List<Color> _palette =
      const [const Color(0x00, 0x00, 0x00), const Color(0x00, 0x00, 0xc0),
             const Color(0xc0, 0x00, 0x00), const Color(0xc0, 0x00, 0xc0),
             const Color(0x00, 0xc0, 0x00), const Color(0x00, 0xc0, 0xc0),
             const Color(0xc0, 0xc0, 0x00), const Color(0xc0, 0xc0, 0xc0),
             const Color(0x00, 0x00, 0x00), const Color(0x00, 0x00, 0xff),
             const Color(0xff, 0x00, 0x00), const Color(0xff, 0x00, 0xff),
             const Color(0x00, 0xff, 0x00), const Color(0x00, 0xff, 0xff),
             const Color(0xff, 0xff, 0x00), const Color(0xff, 0xff, 0xff)];

  html.CanvasRenderingContext2D _context;
  html.ImageData _imageData;

  Screen(html.CanvasElement canvas) {
    _init(canvas);
  }

  void _init(html.CanvasElement canvas) {
    _initCanvas(canvas);
    _initRows();
    _initColors();
  }

  void _initCanvas(html.CanvasElement canvas) {
    _context = canvas.context2d;

    _imageData = _context.getImageData(32, 28, 256, 192);
  }

  void _initRows() {
    for (var row = 0; row < 24; ++ row) {
      var base = row << 3;

      var address = 0x4000 + ((row & 0x18) << 8) + ((row & 0x07) << 5);
      for (var scan = 0; scan < 8; ++ scan, address += 256) {
        _rows[base + scan] = address;
      }
    }
  }

  void _initColors() {
    for (var i = 0; i < 256; ++ i) {
      var ink = (i & 0x07) | ((i & 0x40) != 0 ? 0x08 : 0x00);
      var paper = ((i >> 3) & 0x07) | ((i & 0x40) != 0 ? 0x08 : 0x00);

      _ink[i] = _palette[(i & 0x80) == 0 ? ink: paper];
      _paper[i] = _palette[(i & 0x80) == 0 ? paper: ink];
    }
  }

  void flash() {
    _flash = _flash == 0x7f ? 0xff : 0x7f;
  }

  void border(int value) {
    var color = _palette[value & 0x07];

    _context.canvas.style.background = "rgb(${color.r}, ${color.g}, ${color.b})";
  }

  void dump(Memory memory) {
    var data = _imageData.data;
    var pos = 0;
    var attrs = 22528;

    for (var row = 0; row < 192; attrs += 32) {
      for (var scan = 0; scan < 8; ++ scan) {
        var address = _rows[row ++];

        for (var col = 0; col < 32; ++ col) {
          var byte = memory.readByte(address + col);
          var attr = memory.readByte(attrs + col) & _flash;

          for (var mask = 0x80; mask != 0; mask >>= 1) {
            var color = (byte & mask) != 0 ? _ink[attr] : _paper[attr];

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
