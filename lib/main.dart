import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const BaggageApp());
}

class BaggageApp extends StatelessWidget {
  const BaggageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excess Baggage Calculator',
      debugShowCheckedModeBanner: false,
      // Custom Theme Customization (Rubric #3)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
          secondary: Colors.amber,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Pages list for Navigation Drawer / Bottom Navigation
  final List<Widget> _pages = const [CalculatorScreen(), AboutScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Baggage Calculator' : 'About App'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),

      //Navigator Menu (Rubric #2)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flight_takeoff, size: 50, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Baggage Estimator',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Home / Calculator'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

//------------
// HOME SCREEN: CALCULATOR
//------------
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  //Input Controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ratedController = TextEditingController();

  // Input 2: Non-TextField Widget (Dropdown) (Rubric #1)
  String _selectedClass = 'Economy';

  // Output variable
  double? _excessWeight;
  double? _excessCharge;
  double? _totalPayable;
  String _errorMessage = '';

  void _calculateFee() {
    setState(() {
      _errorMessage = '';

      // Validation (Rubric #5)
      final double? weight = double.tryParse(_weightController.text.trim());
      final double? rate = double.tryParse(_ratedController.text.trim());

      if (weight == null || weight <= 0) {
        _errorMessage = 'Please enter a valid baggage weight (> 0 kg).';
        _resetOutputs();
        return;
      }

      if (rate == null || rate < 0) {
        _errorMessage = 'Please enter a valid rate per kg.';
        _resetOutputs();
        return;
      }

      // Calculation Rules (Rubric #1): Economy = 20kg, Business = 40kg
      final double allowance = (_selectedClass == 'Economy') ? 20.0 : 40.0;

      // Excess weight cannot be negative (max of 0 or difference)
      final double difference = weight - allowance;
      _excessWeight = difference > 0 ? difference : 0.0;

      // Excess baggage charge
      _excessCharge = _excessWeight! * rate;

      // Total payable = Charge + 8% SST
      _totalPayable = _excessCharge! + (_excessCharge! * 0.08);
    });
  }

  void _resetOutputs() {
    _excessWeight = null;
    _excessCharge = null;
    _totalPayable = null;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _ratedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Good Design: Helpful Instructions Notice (Rubric #5)
          Card(
            color: Colors.indigo.shade50,
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.indigo),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Instructions: Select your ticket class and enter your total baggage weight to calculate excess fees (SST 8% included).',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Input 1: Weight in kg
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Baggage Weight (kg)',
              hintText: 'e.g 25.0',
              prefixIcon: Icon(Icons.scale),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Input 2: Ticket Class Dropdown (Rubric #1)
          DropdownButtonFormField<String>(
            initialValue: _selectedClass,
            decoration: const InputDecoration(
              labelText: 'Ticket Class',
              prefixIcon: Icon(Icons.airline_seat_recline_extra),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Economy',
                child: Text('Economy Class (20 kg limit)'),
              ),
              DropdownMenuItem(
                value: 'Business',
                child: Text('Business Class (40 kg limit)'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedClass = value);
              }
            },
          ),
          const SizedBox(height: 16),

          // Input 3: Excess Rate
          TextField(
            controller: _ratedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Excess Rate per kg (RM)',
              hintText: 'e.g 15.00',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Calculate Button
          ElevatedButton.icon(
            onPressed: _calculateFee,
            icon: const Icon(Icons.calculate),
            label: const Text('CALCULATE FEE'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Error Message Display (Rubric #5)
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Formatted Outputs (Rubric #2)
          if (_totalPayable != null) ...[
            const Text(
              'Calculation Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildOutputRow(
                      'Excess Baggage Weight:',
                      '${_excessWeight!.toStringAsFixed(1)} kg',
                    ),
                    const Divider(),
                    _buildOutputRow(
                      'Excess Baggage Charge:',
                      'RM ${_excessCharge!.toStringAsFixed(2)}',
                    ),
                    const Divider(),
                    _buildOutputRow(
                      'Total Payable (incl. 8% SST):',
                      'RM ${_totalPayable!.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOutputRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isBold ? Colors.indigo : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

//-------
// ABOUT SCREEN (Rubric #4)
//-------
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> openGitHubURL(BuildContext context, String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String githubUrl = 'https://github.com/CodexSHa/excess_baggage_app';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Application Icon
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.indigo,
            child: Icon(Icons.luggage, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Excess Baggage Estimator',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
          const Divider(height: 32),

          // Author Information
          const ListTile(
            leading: Icon(Icons.badge),
            title: Text('Author Name'),
            subtitle: Text('MUHAMMAD SYAFIQ HAIKAL BIN ZAKARIA'),
          ),
          const ListTile(
            leading: Icon(Icons.badge),
            title: Text('Matric Number'),
            subtitle: Text('2023217428'),
          ),
          const ListTile(
            leading: Icon(Icons.badge),
            title: Text('Course'),
            subtitle: Text('Mobile (ICT602)'),
          ),

          // Clickable GitHub URL (Rubric #4)
          ListTile(
            leading: const Icon(Icons.code, color: Colors.indigo),
            title: const Text('GitHub Repository'),
            subtitle: const Text(
              githubUrl,
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            onTap: () => openGitHubURL(context, githubUrl),
          ),
          const Spacer(),

          // Copyright Notice
          const Text(
            '@ 2026 All Rights Reserved.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
