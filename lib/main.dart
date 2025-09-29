import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:metro/nfc_manager_felica/nfc_manager_felica.dart'; // your file

class FeliCaReaderApp extends StatefulWidget {
  @override
  State<FeliCaReaderApp> createState() => _FeliCaReaderAppState();
}

class _FeliCaReaderAppState extends State<FeliCaReaderApp> {
  String _log = "Tap a FeliCa card";

  void _startNfcSession() {
    NfcManager.instance.startSession(
      pollingOptions: <NfcPollingOption>{NfcPollingOption.iso18092},
      onDiscovered: (tag) async {
      try {
        final felica = FeliCa.from(tag);
        if (felica == null) {
          setState(() => _log = "Not a FeliCa tag");
          return;
        }

        // Get IDm
        final idm = felica.idm;
        final idmHex = idm.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        setState(() => _log = "Card detected\nIDm: $idmHex");

        // Service code (0x220F little-endian → [0x0F, 0x22])
        final serviceCodeList = [Uint8List.fromList([0x0F, 0x22])];

        // Block list (10 blocks starting from 0 → [0x80, blockNo])
        final blockList = List.generate(
          10,
          (i) => Uint8List.fromList([0x80, i]),
        );

        // Read without encryption
        final response = await felica.readWithoutEncryption(
          serviceCodeList: serviceCodeList,
          blockList: blockList,
        );

        final buffer = StringBuffer();
        buffer.writeln("StatusFlag1: ${response.statusFlag1}");
        buffer.writeln("StatusFlag2: ${response.statusFlag2}");

        for (int i = 0; i < response.blockData.length; i++) {
          final block = response.blockData[i];
          final hex = block.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
          buffer.writeln("Block $i: $hex");
        }

        setState(() => _log += "\n\n${buffer.toString()}");
      } catch (e) {
        setState(() => _log = "Error: $e");
      } finally {
        NfcManager.instance.stopSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("FeliCa Reader")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _startNfcSession,
                child: Text("Scan FeliCa Card"),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_log),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
