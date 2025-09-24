import 'dart:typed_data';

class NFCData {
  /// Generates the service code list as List<Uint8List> (2 bytes)
  static List<Uint8List> getServiceCodeList({int serviceCode = 0x220F}) {
    Uint8List bytes = Uint8List(2);
    bytes[0] = serviceCode & 0xFF;        // Low byte
    bytes[1] = (serviceCode >> 8) & 0xFF; // High byte

    // Wrap the full service code as one Uint8List element
    return [bytes];
  }

  /// Generates the block list as List<Uint8List>, each block is 2 bytes
  static List<Uint8List> getBlockList({int startBlock = 0, int numberOfBlocks = 10}) {
    List<Uint8List> blocks = [];
    for (int i = 0; i < numberOfBlocks; i++) {
      Uint8List block = Uint8List(2);
      block[0] = 0x80;           // Control byte
      block[1] = startBlock + i; // Block number
      blocks.add(block);
    }
    return blocks;
  }
}