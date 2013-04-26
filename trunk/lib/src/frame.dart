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

abstract class Frame {
  int _tstates = 0;

  final List<int> _delays = new List<int>.filled(69888 + 256, 0);

  Frame() {
    _initDelays();
  }

  void _initDelays();

  int get tstates => _tstates;

  void set tstates(int tstates) {
    _tstates = tstates;
  }

  void contention() {
    _tstates += _delays[_tstates];
  }
}

class Frame48k extends Frame {

  void _initDelays() {
    var cycle = 14335;

    for (var row = 0; row < 192; ++ row, cycle += 96) {
      for (var pixel = 0; pixel < 128; pixel += 8) {
        _delays[cycle ++] = 6;
        _delays[cycle ++] = 5;
        _delays[cycle ++] = 4;
        _delays[cycle ++] = 3;
        _delays[cycle ++] = 2;
        _delays[cycle ++] = 1;
        _delays[cycle ++] = 0;
        _delays[cycle ++] = 0;
      }
    }
  }
}
