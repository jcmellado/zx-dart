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

class Machine48k extends Machine {

  Machine48k() {
    _model = new Model48k();
    _keyboard = new Keyboard();
    _screen = new ScreenBuffer();
    _frame = new Frame48k();
    _memory = new Memory48k();
    _z80 = new Z80(this);
  }
}

class Machine {

  Model _model;

  Keyboard _keyboard;

  ScreenBuffer _screen;

  Frame _frame;

  Memory _memory;

  Z80 _z80;

  int _frames = 0;

  void run() {
    _z80.reset();

    html.window.setInterval(_update, 20);
  }

  void _update() {
    _generateFrame();
    _drawFrame();
  }

  void _generateFrame() {
    if (_frame.tstates < _model.tstatesINT) {
      _z80.INT = true;
      _z80.run(_model.tstatesINT);
    }
    _z80.INT = false;

    if (_frame.tstates < _model.tstatesScreenBegin) {
      _z80.run(_model.tstatesScreenBegin);
    }

    while (_frame.tstates < _model.tstatesScreenEnd) {
      _z80.run(_model.tstatesScreenEnd + 40);
    }

    _z80.run(_model.tstatesFrame);

    _frames ++;

    _frame.tstates %= _model.tstatesFrame;
  }

  void _drawFrame() {
    if ((_frames % 16) === 0) {
      _screen.flash();
    }
    _screen.dump(_memory);
  }

  void _contention(final int address) {
    if (_memory.isContended(address)) {
      _frame.contention();
    }
  }

  void contention(final int address, final int tstates) {
    if (_memory.isContended(address)) {
      for (int i = 0; i < tstates; ++ i) {
        _frame.contention();
        _frame.tstates += 1;
      }
    } else {
      _frame.tstates += tstates;
    }
  }

  int fetchOpcode(final int address) {
    _contention(address);
    _frame.tstates += 4;

    return _memory.readByte(address);
  }

  int peek8(final int address) {
    _contention(address);
    _frame.tstates += 3;

    return _memory.readByte(address);
  }

  int peek16(final int address) {
    final int value = peek8(address);

    return (peek8((address + 1) & 0xffff) << 8) | value;
  }

  void poke8(final int address, final int value) {
    if (_memory.isContended(address)) {
      _frame.contention();
      _frame.tstates += 3;
    } else {
      _frame.tstates += 3;
    }

    _memory.writeByte(address, value);
  }

  void poke16(final int address, final int value) {
    poke8(address, value & 0xff);

    poke8((address + 1) & 0xffff, value >> 8);
  }

  int in8(final int port) {
    _contention(port);
    _frame.tstates += 1;

    if ((port & 0x0001) !== 0) {
      contention(port, 3);
    } else {
      _contention(port);
      _frame.tstates += 3;
    }

    if ((port & 0x0001) === 0) {
      return _keyboard.read(port);
    }

    return 0xff;
  }

  void out8(final int port, final int value) {
    _contention(port);
    _frame.tstates += 1;

    if ((port & 0x0001) === 0) {
      _screen.border(value);
    }

    if ((port & 0x0001) !== 0) {
      contention(port, 3);
    } else {
      _contention(port);
      _frame.tstates += 3;
    }
  }
}
