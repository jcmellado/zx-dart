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

class Key {
  final int row, bit;

  const Key(this.row, this.bit);
}

class Keyboard {

  final List<int> _rows;

  final Map<String, List<Key>> _mapping;

  Keyboard() :
    _rows = [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff],
    _mapping = new Map<String, List<Key>>() {

    _initMapping();

    html.document.on.keyDown.add(_onKeyDown);
    html.document.on.keyUp.add(_onKeyUp);
  }

  void _initMapping() {
    _mapping[html.KeyName.SHIFT] = const [const Key(0, 0x01)]; //Caps Shift
    _mapping["U+005A"] = const [const Key(0, 0x02)]; //Z
    _mapping["U+0058"] = const [const Key(0, 0x04)]; //X
    _mapping["U+0043"] = const [const Key(0, 0x08)]; //C
    _mapping["U+0056"] = const [const Key(0, 0x10)]; //V
    _mapping["U+0041"] = const [const Key(1, 0x01)]; //A
    _mapping["U+0053"] = const [const Key(1, 0x02)]; //S
    _mapping["U+0044"] = const [const Key(1, 0x04)]; //D
    _mapping["U+0046"] = const [const Key(1, 0x08)]; //F
    _mapping["U+0047"] = const [const Key(1, 0x10)]; //G
    _mapping["U+0051"] = const [const Key(2, 0x01)]; //Q
    _mapping["U+0057"] = const [const Key(2, 0x02)]; //W
    _mapping["U+0045"] = const [const Key(2, 0x04)]; //E
    _mapping["U+0052"] = const [const Key(2, 0x08)]; //R
    _mapping["U+0054"] = const [const Key(2, 0x10)]; //T
    _mapping["U+0031"] = const [const Key(3, 0x01)]; //1
    _mapping["U+0032"] = const [const Key(3, 0x02)]; //2
    _mapping["U+0033"] = const [const Key(3, 0x04)]; //3
    _mapping["U+0034"] = const [const Key(3, 0x08)]; //4
    _mapping["U+0035"] = const [const Key(3, 0x10)]; //5
    _mapping["U+0030"] = const [const Key(4, 0x01)]; //0
    _mapping["U+0039"] = const [const Key(4, 0x02)]; //9
    _mapping["U+0038"] = const [const Key(4, 0x04)]; //8
    _mapping["U+0037"] = const [const Key(4, 0x08)]; //7
    _mapping["U+0036"] = const [const Key(4, 0x10)]; //6
    _mapping["U+0050"] = const [const Key(5, 0x01)]; //P
    _mapping["U+004F"] = const [const Key(5, 0x02)]; //O
    _mapping["U+0049"] = const [const Key(5, 0x04)]; //I
    _mapping["U+0055"] = const [const Key(5, 0x08)]; //U
    _mapping["U+0059"] = const [const Key(5, 0x10)]; //Y
    _mapping[html.KeyName.ENTER] = const [const Key(6, 0x01)]; //Enter
    _mapping["U+004C"] = const [const Key(6, 0x02)]; //L
    _mapping["U+004B"] = const [const Key(6, 0x04)]; //K
    _mapping["U+004A"] = const [const Key(6, 0x08)]; //J
    _mapping["U+0048"] = const [const Key(6, 0x10)]; //H
    _mapping["U+0020"] = const [const Key(7, 0x01)]; //Space
    _mapping[html.KeyName.ALT] = const [const Key(7, 0x02)]; //Symbol Shift
    _mapping["U+004D"] = const [const Key(7, 0x04)]; //M
    _mapping["U+004E"] = const [const Key(7, 0x08)]; //N
    _mapping["U+0042"] = const [const Key(7, 0x10)]; //B
    _mapping["U+001B"] = const [const Key(0, 0x01), const Key(7, 0x01)]; //Escape = Caps Shift + Space
    _mapping["U+0008"] = const [const Key(0, 0x01), const Key(4, 0x01)]; //Backspace = Caps Shift + 0
    _mapping[html.KeyName.CAPS_LOCK] = const [const Key(0, 0x01), const Key(3, 0x02)]; //Caps Lock = Caps Shift + 2
  }

  void _onKeyDown(final html.KeyboardEvent event) {
    if (_mapping.containsKey(event.keyIdentifier)) {

      _mapping[event.keyIdentifier].forEach((Key key) => _rows[key.row] &= key.bit ^ 0xff);

      event.preventDefault();
    }
  }

  void _onKeyUp(final html.KeyboardEvent event) {
    if (_mapping.containsKey(event.keyIdentifier)) {

      _mapping[event.keyIdentifier].forEach((Key key) => _rows[key.row] |= key.bit);

      event.preventDefault();
    }
  }

  int read(int port) {
    int value = 0xff;

    port >>= 8;

    for (int i = 0; i < _rows.length; ++ i, port >>= 1) {
      if ((port & 0x01) === 0) {
        value &= _rows[i];
      }
    }

    return value;
  }
}
