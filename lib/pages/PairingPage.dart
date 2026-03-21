import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:equilibrium/function/APIHandler.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';

class PairingPage extends StatefulWidget {
  const PairingPage({super.key});

  @override
  State<PairingPage> createState() => _PairingPageState();
}

enum PairingStep {
  scanning,
  deviceFound,
  networkSelection,
  passwordEntry,
  connecting,
  connected,
}

class _PairingPageState extends State<PairingPage> {
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;
  bool _isDeviceFound = false;
  bool _isForward = true;
  ScanResult? _foundResult;
  WiFiAccessPoint? _selectedAccessPoint;
  BluetoothCharacteristic? _targetCharacteristic;
  PairingStep _pairingStep = PairingStep.scanning;

  @override
  void initState() {
    super.initState();
    _setupScanListener();
    _startScan();
  }

  @override
  void dispose() {
    _scanResultsSubscription?.cancel();
    _connectionSubscription?.cancel();
    _notificationSubscription?.cancel();
    _foundResult?.device.disconnect();
    // Stop scanning when leaving the page
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  void _setupScanListener() {
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        if (_isDeviceFound) return;
        print("Scan Results Updated: ${results.length} devices found");
        for (ScanResult r in results) {
          if (r.advertisementData.serviceUuids.isNotEmpty &&
              r.advertisementData.serviceUuids.contains(
                Guid("2491c78b-f009-4831-b0bf-d2c6eeef6dae"),
              )) {
            debugPrint(
              "Found EQ Box! Device: ${r.device.platformName}, RSSI: ${r.rssi}",
            );
            _connectToDevice(r);
            break;
          }
        }
      },
      onError: (e) {
        debugPrint("Scan Error: $e");
      },
    );
  }

  Future<void> _connectToDevice(ScanResult r) async {
    _isDeviceFound = true;
    FlutterBluePlus.stopScan();

    try {
      await _connectionSubscription?.cancel();
      _connectionSubscription = r.device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.connected) {
          if (!mounted) return;
          if (_foundResult == null) {
            setState(() {
              _foundResult = r;
              _pairingStep = PairingStep.deviceFound;
            });
          }
        } else if (state == BluetoothConnectionState.disconnected) {
          _targetCharacteristic = null;
          _notificationSubscription?.cancel();
          if (!mounted) return;
          if (_foundResult != null) {
            setState(() {
              _foundResult = null;
              _pairingStep = PairingStep.scanning;
              _isDeviceFound = false;
            });
            _startScan();
          }
        }
      });

      await r.device.connect(license: License.free);

      List<BluetoothService> services = await r.device.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid ==
              Guid("8162059c-5c7d-4b38-b0c3-439f29fed5f1")) {
            _targetCharacteristic = characteristic;
            debugPrint("Found target characteristic: ${characteristic.uuid}");
            await characteristic.setNotifyValue(true);
            _notificationSubscription = characteristic.onValueReceived.listen((
              value,
            ) {
              debugPrint("Notification from ${characteristic.uuid}: $value");
              if (value.isNotEmpty) {
                // 1 = connected, 0 = unsuccessful
                if (value[0] == 49) {
                  if (mounted) {
                    setState(() {
                      FakeGlobalVariable.connectedDevice = true;
                      _pairingStep = PairingStep.connected;
                    });
                  }
                } else if (value[0] == 48) {
                  if (mounted) {
                    setState(() {
                      _pairingStep = PairingStep.passwordEntry;
                    });
                    _showErrorSnackBar("Connection Unsuccessful");
                  }
                }
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Connect Error: $e");
      if (mounted) {
        setState(() {
          _isDeviceFound = false;
        });
        _startScan();
      }
    }
  }

  void _dismissFoundDevice() {
    _foundResult?.device.disconnect();
    setState(() {
      _foundResult = null;
      _isDeviceFound = false;
      _pairingStep = PairingStep.scanning;
      _targetCharacteristic = null;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _startScan();
      }
    });
  }

  Future<void> _sendCredentials(String ssid, String password) async {
    if (_targetCharacteristic == null) {
      debugPrint("Target characteristic not found");
      return;
    }
    try {
      // The device firmware expects "ssid,password" not JSON
      final userInfo = await apiHandler.getUserInfo();
      if (!userInfo.success) {
        throw Exception("Failed to retrieve user info");
      }
      final data = "$ssid,$password,${userInfo.userId}";
      await _targetCharacteristic!.write(utf8.encode(data));
      debugPrint("Sent credentials: $data");
    } catch (e) {
      debugPrint("Error sending credentials: $e");
      if (mounted) {
        // Go back to password entry or show error
        setState(() {
          _pairingStep = PairingStep.passwordEntry;
        });
        _showErrorSnackBar("Failed to connect: $e");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        elevation: 4,
      ),
    );
  }

  Future<void> _startScan() async {
    // Request permissions
    if (Platform.isAndroid) {
      await [
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
    }

    // Ensure Bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      debugPrint("Bluetooth not supported");
      return;
    }

    // Wait for Bluetooth to be enabled
    var adapterState = FlutterBluePlus.adapterState.first;
    if (await adapterState != BluetoothAdapterState.on) {
      // Ideally show a dialog or wait
      try {
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
        }
      } catch (e) {
        // Do nothing
      }
    }

    // Start scanning immediately
    if (!FlutterBluePlus.isScanningNow) {
      try {
        await FlutterBluePlus.startScan(
          // No timeout means it scans indefinitely (until stopScan is called)
          timeout: null,
          androidUsesFineLocation: true,
        );
      } catch (e) {
        debugPrint("Start Scan Error: $e");
      }
    }
  }

  Key _getStepKey(PairingStep step) {
    switch (step) {
      case PairingStep.networkSelection:
        return const ValueKey('NetworkSelection');
      case PairingStep.passwordEntry:
        return const ValueKey('PasswordEntry');
      case PairingStep.connecting:
      case PairingStep.connected:
        return const ValueKey('ConnectionStatus');
      default:
        return const ValueKey('FoundDevice');
    }
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    final currentKey = _getStepKey(_pairingStep);
    final isEntering = child.key == currentKey;
    Offset begin;

    if (_isForward) {
      if (isEntering) {
        begin = const Offset(1.0, 0.0);
      } else {
        begin = const Offset(-1.0, 0.0);
      }
    } else {
      if (isEntering) {
        begin = const Offset(-1.0, 0.0);
      } else {
        begin = const Offset(1.0, 0.0);
      }
    }

    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(animation),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Stack(
            children: [
              SizedBox.expand(
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          const Spacer(),

                          const _HeroGraphic(),

                          const SizedBox(height: 32),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              children: [
                                Text(
                                  "Searching for nearby boxes...",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    // text-2xl is ~24px
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                    // text-slate-900
                                    height: 1.2,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Keep your phone close to the EQ box",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16, // text-base
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF64748B), // text-slate-500
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          const _LoadingDots(),

                          const Spacer(),

                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 40,
                              left: 24,
                              right: 24,
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style:
                                  TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 24,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    foregroundColor: const Color(0xFF64748B),
                                    // text-slate-500
                                    backgroundColor: Colors
                                        .transparent, // hover:bg-slate-100 handled by ink response usually, or can set overlayColor
                                  ).copyWith(
                                    overlayColor: WidgetStateProperty.resolveWith((
                                      states,
                                    ) {
                                      if (states.contains(WidgetState.hovered)) {
                                        return const Color(
                                          0xFFF1F5F9,
                                        ); // bg-slate-100
                                      }
                                      return null;
                                    }),
                                  ),
                              child: Text(
                                "CANCEL PAIRING",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5, // tracking-wide
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scrim
              if (_foundResult != null)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _dismissFoundDevice,
                    child: Container(color: Colors.black54),
                  ),
                ),

              // Preloaded Bottom Sheet
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedSlide(
                  offset: _foundResult != null
                      ? Offset.zero
                      : const Offset(0, 1),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, -2),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            width: 48,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        Flexible(
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            alignment: Alignment.topCenter,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  alignment: Alignment.topCenter,
                                  children: <Widget>[
                                    ...previousChildren.map(
                                      (child) => Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: child,
                                      ),
                                    ),
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              transitionBuilder: _buildTransition,
                              child:
                                  _pairingStep == PairingStep.networkSelection
                                  ? _NetworkSelectionContent(
                                      key: const ValueKey('NetworkSelection'),
                                      onNetworkSelected: (ap) {
                                        setState(() {
                                          _isForward = true;
                                          _selectedAccessPoint = ap;
                                          _pairingStep =
                                              PairingStep.passwordEntry;
                                        });
                                      },
                                      onBack: () {
                                        setState(
                                          () {
                                            _isForward = false;
                                            _pairingStep =
                                                PairingStep.deviceFound;
                                          },
                                        );
                                      },
                                    )
                                  : _pairingStep == PairingStep.passwordEntry
                                  ? _PasswordEntryContent(
                                      key: const ValueKey('PasswordEntry'),
                                      ssid:
                                          _selectedAccessPoint?.ssid ??
                                          "Unknown",
                                      onConnect: (password) {
                                        setState(() {
                                          _isForward = true;
                                          _pairingStep = PairingStep.connecting;
                                        });
                                        _sendCredentials(
                                          _selectedAccessPoint?.ssid ?? "",
                                          password,
                                        );
                                      },
                                      onCancel: () {
                                        setState(
                                          () {
                                            _isForward = false;
                                            _pairingStep =
                                                PairingStep.networkSelection;
                                          },
                                        );
                                      },
                                    )
                                  : (_pairingStep == PairingStep.connecting ||
                                        _pairingStep == PairingStep.connected)
                                  ? _ConnectionStatusContent(
                                      key: const ValueKey('ConnectionStatus'),
                                      step: _pairingStep,
                                      ssid:
                                          _selectedAccessPoint?.ssid ??
                                          "Unknown",
                                      onDone: () {
                                        // Close pairing flow or reset
                                        Navigator.pop(context);
                                      },
                                    )
                                  : _FoundDeviceContent(
                                      key: const ValueKey('FoundDevice'),
                                      scanResult: _foundResult,
                                      onCancel: _dismissFoundDevice,
                                      onConnect: () {
                                        // Move to network selection step
                                        setState(() {
                                          _isForward = true;
                                          _pairingStep =
                                              PairingStep.networkSelection;
                                        });
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroGraphic extends StatefulWidget {
  const _HeroGraphic();

  @override
  State<_HeroGraphic> createState() => _HeroGraphicState();
}

class _HeroGraphicState extends State<_HeroGraphic>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1BBB6E);
    // Base size for the graphic container
    const double baseSize = 280.0;

    return SizedBox(
      width: baseSize,
      height: baseSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Expanding Ripples
          // We create 3 ripples delayed by 1/3 of the cycle each
          for (int i = 0; i < 3; i++)
            _Ripple(
              controller: _controller,
              offset: i * (1.0 / 3.0),
              baseSize: baseSize,
              color: primaryColor,
            ),

          // Router Device Container
          // w-32 (8rem = 128px), h-40 (10rem = 160px)
          Container(
            width: 128,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              // rounded-2xl
              border: Border.all(color: const Color(0xFFF1F5F9)),
              // border-slate-100
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.08),
                  offset: const Offset(0, 12),
                  blurRadius: 32,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.router_outlined,
                size: 64, // text-6xl
                color: primaryColor,
              ),
            ),
          ),

          // Smartphone Device Container (Floating)
          // bottom-8, right-8 relative to the 280px box.
          // w-16 (4rem = 64px), h-24 (6rem = 96px)
          Positioned(
            right: 32,
            bottom: 32,
            child: Container(
              width: 64,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                // rounded-xl
                border: Border.all(color: const Color(0xFFF1F5F9)),
                // border-slate-100
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.08),
                    offset: const Offset(0, 12),
                    blurRadius: 32,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.smartphone,
                  size: 30, // text-3xl
                  color: Color(0xFF94A3B8), // slate-400
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ripple extends StatelessWidget {
  final AnimationController controller;
  final double offset;
  final double baseSize;
  final Color color;

  const _Ripple({
    required this.controller,
    required this.offset,
    required this.baseSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Calculate progress (0.0 to 1.0) with offset
        double value = (controller.value + offset) % 1.0;

        // Scale from 0.8 to 1.6
        // This makes circles start slightly smaller than full size and expand outward
        double scale = 0.8 + (0.8 * value);

        // Opacity fades out towards the end
        // Peaks at start, fades to 0
        // Using a sine curve for smoother fade
        // double opacity = 0.2 * (1.0 - value);
        // Let's make it fade in slightly at start then fade out long
        double opacity;
        if (value < 0.2) {
          opacity = (value / 0.2) * 0.2; // Fade in to 0.2
        } else {
          opacity = 0.2 * (1.0 - (value - 0.2) / 0.8); // Fade out from 0.2
        }

        return Transform.scale(
          scale: scale,
          child: Container(
            width: baseSize,
            height: baseSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: opacity),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1BBB6E);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            // Staggered animation using sine wave
            // Phase shift for each dot
            double phase = index * (math.pi / 2); // 90 degrees shift per dot

            // Current angle based on controller time (0..1 -> 0..2pi)
            double angle = (_controller.value * 2 * math.pi) - phase;

            // Calculate sine wave value (-1.0 to 1.0)
            double sinVal = math.sin(angle);

            // Normalize to 0.0 to 1.0 for opacity and offset calculation
            // We want the peak to be at sinVal = 1
            double normalized = (sinVal + 1) / 2;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                // Opacity varies between 0.3 and 1.0
                color: primaryColor.withValues(alpha: 0.3 + (0.7 * normalized)),
                shape: BoxShape.circle,
              ),
              // Translate Y up by max 6 pixels
              transform: Matrix4.translationValues(0, -6 * normalized, 0),
            );
          }),
        );
      },
    );
  }
}

class _FoundDeviceContent extends StatelessWidget {
  final ScanResult? scanResult;
  final VoidCallback? onCancel;
  final VoidCallback? onConnect;

  const _FoundDeviceContent({
    super.key,
    this.scanResult,
    this.onCancel,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1BBB6E);
    final device = scanResult?.device;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEMS Box Graphic
          const _HemsBoxGraphic(),

          const SizedBox(height: 32),

          // Title
          Text(
            "EQ Box Found",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24, // text-3xl
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: const Color(0xFF0F172A), // slate-900
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            "A new room energy management system is nearby and ready to pair with your home.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18, // text-lg
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: const Color(0xFF64748B), // slate-500
            ),
          ),

          /* Debug info optional
          const SizedBox(height: 8),
          Text(
            "${device?.platformName} (${scanResult?.rssi} dBm)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          */
          const SizedBox(height: 32),

          // Connect button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle connection
                if (device != null) {
                  debugPrint("Connecting to ${device.platformName}");
                }
                onConnect?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: primaryColor.withValues(alpha: 0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Connect Now",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.sensors, size: 24),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Not Now button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed:
                  onCancel ??
                  () {
                    Navigator.of(context).pop();
                  },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: const Color(0xFF475569), // slate-600
                backgroundColor: const Color(0xFFF1F5F9), // slate-100
              ),
              child: Text(
                "Not Now",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkSelectionContent extends StatefulWidget {
  final ValueChanged<WiFiAccessPoint>? onNetworkSelected;
  final VoidCallback? onBack;

  const _NetworkSelectionContent({
    this.onNetworkSelected,
    this.onBack,
    super.key,
  });

  @override
  State<_NetworkSelectionContent> createState() =>
      _NetworkSelectionContentState();
}

class _NetworkSelectionContentState extends State<_NetworkSelectionContent> {
  String? _selectedSsid;
  List<WiFiAccessPoint> _accessPoints = [];
  bool _isScanning = false;
  StreamSubscription<List<WiFiAccessPoint>>? _subscription;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _startScan();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (!mounted) return;
    setState(() => _isScanning = true);

    // Check permissions
    if (await Permission.location.request().isGranted) {
      try {
        final canScan = await WiFiScan.instance.canStartScan(
          askPermissions: true,
        );
        if (canScan == CanStartScan.yes) {
          await WiFiScan.instance.startScan();
          _subscription = WiFiScan.instance.onScannedResultsAvailable.listen((
            results,
          ) {
            if (!mounted) return;
            setState(() {
              // Deduplicate SSIDs, keeping strongest signal
              final Map<String, WiFiAccessPoint> unique = {};
              for (var ap in results) {
                if (ap.ssid.isEmpty) continue;
                if (!unique.containsKey(ap.ssid) ||
                    ap.level > unique[ap.ssid]!.level) {
                  unique[ap.ssid] = ap;
                }
              }
              _accessPoints = unique.values.toList()
                ..sort((a, b) => b.level.compareTo(a.level));
              _isScanning = false;
            });
          });

          // Initial fetch
          final results = await WiFiScan.instance.getScannedResults();
          if (results.isNotEmpty && mounted) {
            setState(() {
              // Deduplicate SSIDs, keeping strongest signal
              final Map<String, WiFiAccessPoint> unique = {};
              for (var ap in results) {
                if (ap.ssid.isEmpty) continue;
                if (!unique.containsKey(ap.ssid) ||
                    ap.level > unique[ap.ssid]!.level) {
                  unique[ap.ssid] = ap;
                }
              }
              _accessPoints = unique.values.toList()
                ..sort((a, b) => b.level.compareTo(a.level));
              _isScanning = false;
            });
          }
        } else {
          debugPrint("Cannot start scan: $canScan");
          if (mounted) setState(() => _isScanning = false);
        }
      } catch (e) {
        debugPrint("Scan error: $e");
        if (mounted) setState(() => _isScanning = false);
      }
    } else {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  IconData _getSignalIcon(int level) {
    if (level >= -60) return Icons.wifi;
    if (level >= -70) return Icons.wifi_2_bar;
    return Icons.wifi_1_bar;
  }

  String _getSignalText(int level) {
    if (level >= -50) return "Excellent";
    if (level >= -60) return "Good";
    if (level >= -70) return "Fair";
    return "Weak";
  }

  String _getSecurityStatus(String capabilities) {
    if (capabilities.contains("WPA") ||
        capabilities.contains("WEP") ||
        capabilities.contains("EAP")) {
      return "Secured";
    }
    return "Open";
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1BBB6E);

    // Filter logic
    final displayedAccessPoints = _accessPoints.where((ap) {
      if (_searchQuery.isEmpty) return true;
      return ap.ssid.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Choose a Network",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Select a Wi-Fi network to connect",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Wi-Fi Name',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  isDense: true,
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFF1F5F9)),

        // Content
        if (_isScanning && _accessPoints.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: const Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          )
        else if (displayedAccessPoints.isEmpty && _searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "No networks match your search",
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                ),
              ],
            ),
          )
        else if (_accessPoints.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "No networks found",
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                ),
                TextButton(onPressed: _startScan, child: const Text("Retry")),
              ],
            ),
          )
        else
          // Network List
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              // Limit height for list
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: displayedAccessPoints.length,
                separatorBuilder: (context, index) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  final ap = displayedAccessPoints[index];
                  final isSelected = ap.ssid == _selectedSsid;
                  final status = _getSecurityStatus(ap.capabilities);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSsid = ap.ssid;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      color: isSelected
                          ? primaryColor.withValues(alpha: 0.05)
                          : null,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.1)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getSignalIcon(ap.level),
                              color: isSelected
                                  ? primaryColor
                                  : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ap.ssid,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "${_getSignalText(ap.level)} • $status",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? primaryColor
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle, color: primaryColor),
                            const SizedBox(width: 8),
                          ],
                          // Info or right arrow (optional)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Footer Actions
        Container(
          color: const Color(0xFFF8FAFC), // slate-50
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedSsid != null
                      ? () {
                          final selectedAp = _accessPoints.firstWhere(
                            (ap) => ap.ssid == _selectedSsid,
                          );
                          widget.onNetworkSelected?.call(selectedAp);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withValues(
                      alpha: 0.5,
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: primaryColor.withValues(alpha: 0.2),
                  ),

                  child: Text(
                    "Join Network",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Bottom safe area spacer approx
            ],
          ),
        ),
      ],
    );
  }
}

class _HemsBoxGraphic extends StatelessWidget {
  const _HemsBoxGraphic();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF8FAFC), // slate-50
            const Color(0xFFE2E8F0), // slate-200
          ],
        ),
        border: Border.all(color: const Color(0xFFF1F5F9)), // slate-100
      ),
      child: const ModelViewer(
        src: 'assets/model/box.glb',
        alt: 'A 3D model of the HEMS Box',
        ar: false,
        autoRotate: true,
        cameraControls: true,
        disablePan: true,
        backgroundColor: Colors.transparent,
        loading: Loading.eager,
      ),
    );
  }
}

class _PasswordEntryContent extends StatefulWidget {
  final String ssid;
  final ValueChanged<String> onConnect;
  final VoidCallback onCancel;

  const _PasswordEntryContent({
    super.key,
    required this.ssid,
    required this.onConnect,
    required this.onCancel,
  });

  @override
  State<_PasswordEntryContent> createState() => _PasswordEntryContentState();
}

class _PasswordEntryContentState extends State<_PasswordEntryContent> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1BBB6E);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            "Enter Password",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: "Enter the password for ",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
              children: [
                TextSpan(
                  text: widget.ssid,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Input Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  "Password",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155), // slate-700
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC), // sage-50 equivalent/slate-50
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ), // sage-200 / slate-200
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: "••••••••",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    // sage-400
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "SHOW",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B), // sage-500
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF64748B),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Actions
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onConnect(_passwordController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: primaryColor.withValues(alpha: 0.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Connect",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.bolt, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onCancel,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B), // slate-500
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                "Cancel",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Security Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 14,
                color: Color(0xFF94A3B8),
              ), // sage-400
              const SizedBox(width: 4),
              Text(
                "WPA3 SECURE CONNECTION",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Safe area shim
        ],
      ),
    );
  }
}

class _ConnectionStatusContent extends StatelessWidget {
  final PairingStep step;
  final String ssid;
  final VoidCallback onDone;

  const _ConnectionStatusContent({
    super.key,
    required this.step,
    required this.ssid,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1BBB6E);
    final isConnected = step == PairingStep.connected;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Visual Content Area
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isConnected) ...[
                  // Connected State: Ripples + Check
                   TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x661BBB6E),
                                    blurRadius: 24,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  // Connecting State: Modern Spinner
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 4,
                      strokeCap: StrokeCap.round,
                      backgroundColor: const Color(0xFFE2E8F0), // faint track
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Titles and Subtitles
           AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(isConnected),
              children: [
                 Text(
                  isConnected ? "Connected!" : "Connecting...",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                 Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: isConnected ? "Successfully joined " : "Establishing connection to ",
                      ),
                      TextSpan(
                        text: ssid,
                        style: TextStyle(
                          color: isConnected ? primaryColor : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action Button
           AnimatedOpacity(
            opacity: isConnected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !isConnected,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: Text(
                    "Done",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
