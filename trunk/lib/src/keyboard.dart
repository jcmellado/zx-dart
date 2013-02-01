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

class Key {
  final int row, bit;

  const Key(this.row, this.bit);
}

class Keyboard {
  final List<int> _rows = [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff];

  final Map<int, List<Key>> _mapping = new Map<int, List<Key>>();

  Keyboard() {
    _initMapping();

    html.document.onKeyDown.listen(_onKeyDown);
    html.document.onKeyUp.listen(_onKeyUp);
  }

  void _initMapping() {
    _mapping[html.KeyCode.SHIFT] = const [const Key(0, 0x01)]; //Caps Shift
    _mapping[html.KeyCode.Z] = const [const Key(0, 0x02)]; //Z
    _mapping[html.KeyCode.X] = const [const Key(0, 0x04)]; //X
    _mapping[html.KeyCode.C] = const [const Key(0, 0x08)]; //C
    _mapping[html.KeyCode.V] = const [const Key(0, 0x10)]; //V
    _mapping[html.KeyCode.A] = const [const Key(1, 0x01)]; //A
    _mapping[html.KeyCode.S] = const [const Key(1, 0x02)]; //S
    _mapping[html.KeyCode.D] = const [const Key(1, 0x04)]; //D
    _mapping[html.KeyCode.F] = const [const Key(1, 0x08)]; //F
    _mapping[html.KeyCode.G] = const [const Key(1, 0x10)]; //G
    _mapping[html.KeyCode.Q] = const [const Key(2, 0x01)]; //Q
    _mapping[html.KeyCode.W] = const [const Key(2, 0x02)]; //W
    _mapping[html.KeyCode.E] = const [const Key(2, 0x04)]; //E
    _mapping[html.KeyCode.R] = const [const Key(2, 0x08)]; //R
    _mapping[html.KeyCode.T] = const [const Key(2, 0x10)]; //T
    _mapping[html.KeyCode.ONE] = const [const Key(3, 0x01)]; //1
    _mapping[html.KeyCode.TWO] = const [const Key(3, 0x02)]; //2
    _mapping[html.KeyCode.THREE] = const [const Key(3, 0x04)]; //3
    _mapping[html.KeyCode.FOUR] = const [const Key(3, 0x08)]; //4
    _mapping[html.KeyCode.FIVE] = const [const Key(3, 0x10)]; //5
    _mapping[html.KeyCode.ZERO] = const [const Key(4, 0x01)]; //0
    _mapping[html.KeyCode.NINE] = const [const Key(4, 0x02)]; //9
    _mapping[html.KeyCode.EIGHT] = const [const Key(4, 0x04)]; //8
    _mapping[html.KeyCode.SEVEN] = const [const Key(4, 0x08)]; //7
    _mapping[html.KeyCode.SIX] = const [const Key(4, 0x10)]; //6
    _mapping[html.KeyCode.P] = const [const Key(5, 0x01)]; //P
    _mapping[html.KeyCode.O] = const [const Key(5, 0x02)]; //O
    _mapping[html.KeyCode.I] = const [const Key(5, 0x04)]; //I
    _mapping[html.KeyCode.U] = const [const Key(5, 0x08)]; //U
    _mapping[html.KeyCode.Y] = const [const Key(5, 0x10)]; //Y
    _mapping[html.KeyCode.ENTER] = const [const Key(6, 0x01)]; //Enter
    _mapping[html.KeyCode.L] = const [const Key(6, 0x02)]; //L
    _mapping[html.KeyCode.K] = const [const Key(6, 0x04)]; //K
    _mapping[html.KeyCode.J] = const [const Key(6, 0x08)]; //J
    _mapping[html.KeyCode.H] = const [const Key(6, 0x10)]; //H
    _mapping[html.KeyCode.SPACE] = const [const Key(7, 0x01)]; //Space
    _mapping[html.KeyCode.ALT] = const [const Key(7, 0x02)]; //Symbol Shift
    _mapping[html.KeyCode.M] = const [const Key(7, 0x04)]; //M
    _mapping[html.KeyCode.N] = const [const Key(7, 0x08)]; //N
    _mapping[html.KeyCode.B] = const [const Key(7, 0x10)]; //B
    _mapping[html.KeyCode.ESC] = const [const Key(0, 0x01), const Key(7, 0x01)]; //Escape = Caps Shift + Space
    _mapping[html.KeyCode.BACKSPACE] = const [const Key(0, 0x01), const Key(4, 0x01)]; //Backspace = Caps Shift + 0
    _mapping[html.KeyCode.CAPS_LOCK] = const [const Key(0, 0x01), const Key(3, 0x02)]; //Caps Lock = Caps Shift + 2
  }

  void _onKeyDown(html.KeyboardEvent event) {
    if (_mapping.containsKey(event.keyCode)) {

      _mapping[event.keyCode].forEach((key) {
        _rows[key.row] &= key.bit ^ 0xff;
      });

      event.preventDefault();
    }
  }

  void _onKeyUp(html.KeyboardEvent event) {
    if (_mapping.containsKey(event.keyCode)) {

      _mapping[event.keyCode].forEach((key) {
        _rows[key.row] |= key.bit;
      });

      event.preventDefault();
    }
  }

  int read(int port) {
    var value = 0xff;

    port >>= 8;

    for (var row in _rows) {
      if ((port & 0x01) == 0) {
        value &= row;
      }
      port >>= 1;
    }

    return value;
  }
}
