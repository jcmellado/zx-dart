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

class Bank {
  List<int> memory;
  bool writable;
  bool contended;

  Bank(this.memory, this.writable, this.contended);
}

class Memory48k extends Memory {

  void _initBanks() {
    _banks[0] = new Bank(_rom48k[0], false, false);
    _banks[1] = new Bank(_ram[5], true, true);
    _banks[2] = new Bank(_ram[2], true, false);
    _banks[3] = new Bank(_ram[0], true, false);
  }
}

abstract class Memory {
  final List<List<int>> _rom48k = new List<List<int>>.fixedLength(1);
  final List<List<int>> _ram = new List<List<int>>.fixedLength(8);
  final List<Bank> _banks = new List<Bank>.fixedLength(4);

  Memory() {
    _init();
  }

  int readByte(int address) => _banks[address >> 14].memory[address & 0x3fff];

  void writeByte(int address, int value) {
    var bank = _banks[address >> 14];
    if (bank.writable) {
      bank.memory[address & 0x3fff] = value;
    }
  }

  bool isContended(int address) => _banks[address >> 14].contended;

  void _init() {
    _initRom();
    _initRam();
    _initBanks();
  }

  void _initRom() {
    _rom48k[0] = _loadFile("roms/48k.rom");
  }

  void _initRam() {
    _allocateMemory(_ram);
    _randomizeMemory(_ram);
  }

  void _initBanks();

  void _allocateMemory(List<List<int>> memory) {
    for (var i = 0; i < memory.length; ++ i) {
      memory[i] = new List<int>.fixedLength(0x4000);
    }
  }

  void _randomizeMemory(List<List<int>> memory) {
    var random = new math.Random();
    memory.forEach((chunk) {
      for (var i = 0; i < chunk.length; ++ i) {
        chunk[i] = random.nextInt(256);
      }
    });
  }

  List<int> _loadFile(String filename) {
    var request = new html.HttpRequest();
    request.open("GET", filename, false);
    request.overrideMimeType("text/plain; charset=x-user-defined");
    request.send();

    return request.responseText.charCodes.mappedBy((int code) => code & 0xff).toList();
  }
}
