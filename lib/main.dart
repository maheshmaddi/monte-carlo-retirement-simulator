import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MonteCarloApp());

class MonteCarloApp extends StatelessWidget {
  const MonteCarloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monte Carlo Retirement Simulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0d1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF58a6ff),
          secondary: Color(0xFF3fb950),
          surface: Color(0xFF161b22),
        ),
      ),
      home: const SimulatorPage(),
    );
  }
}

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  // Input controllers
  final _ageCtrl = TextEditingController(text: '30');
  final _retireAgeCtrl = TextEditingController(text: '65');
  final _savingsCtrl = TextEditingController(text: '50000');
  final _contribCtrl = TextEditingController(text: '12000');
  final _returnCtrl = TextEditingController(text: '7');
  final _inflationCtrl = TextEditingController(text: '3');
  final _lifestyleCtrl = TextEditingController(text: '80');
  final _salaryCtrl = TextEditingController(text: '75000');
  final _volatilityCtrl = TextEditingController(text: '15');

  bool _isRunning = false;
  MonteCarloResult? _result;

  void _runSimulation() {
    setState(() => _isRunning = true);

    Future.delayed(const Duration(milliseconds: 100), () {
      final inputs = SimulationInputs(
        currentAge: int.tryParse(_ageCtrl.text) ?? 30,
        retirementAge: int.tryParse(_retireAgeCtrl.text) ?? 65,
        currentSavings: double.tryParse(_savingsCtrl.text) ?? 50000,
        annualContribution: double.tryParse(_contribCtrl.text) ?? 12000,
        avgReturn: double.tryParse(_returnCtrl.text) ?? 7.0,
        inflationRate: double.tryParse(_inflationCtrl.text) ?? 3.0,
        lifestylePercent: double.tryParse(_lifestyleCtrl.text) ?? 80.0,
        currentSalary: double.tryParse(_salaryCtrl.text) ?? 75000,
        volatility: double.tryParse(_volatilityCtrl.text) ?? 15.0,
      );

      final result = MonteCarloEngine.run(inputs, simulations: 1000);

      setState(() {
        _result = result;
        _isRunning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildInputSection(),
                const SizedBox(height: 20),
                _buildRunButton(),
                const SizedBox(height: 24),
                if (_isRunning) _buildLoading(),
                if (_result != null && !_isRunning) ...[
                  _buildComparisonCards(),
                  const SizedBox(height: 24),
                  _buildConfidenceTable(),
                  const SizedBox(height: 24),
                  _buildHistogram(),
                  const SizedBox(height: 24),
                  _buildInsight(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF58a6ff).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.casino, color: Color(0xFF58a6ff), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monte Carlo Retirement Simulator',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Demo — See how market volatility affects your retirement outcomes',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161b22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF30363d)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This demo runs 1,000 simulated lifetimes with randomized market returns to show the probability of different retirement outcomes. Compare the fixed-rate result vs. the Monte Carlo analysis.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Inputs', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _inputField('Current Age', _ageCtrl, Icons.person),
              _inputField('Retirement Age', _retireAgeCtrl, Icons.elderly),
              _inputField('Current Salary (\$)', _salaryCtrl, Icons.attach_money),
              _inputField('Current Savings (\$)', _savingsCtrl, Icons.savings),
              _inputField('Annual Contribution (\$)', _contribCtrl, Icons.add_circle_outline),
              _inputField('Expected Return (%)', _returnCtrl, Icons.trending_up),
              _inputField('Market Volatility (%)', _volatilityCtrl, Icons.show_chart),
              _inputField('Inflation (%)', _inflationCtrl, Icons.arrow_upward),
              _inputField('Lifestyle Goal (%)', _lifestyleCtrl, Icons.home),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, IconData icon) {
    return SizedBox(
      width: 180,
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
          prefixIcon: Icon(icon, color: const Color(0xFF58a6ff), size: 20),
          filled: true,
          fillColor: const Color(0xFF0d1117),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF30363d)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF30363d)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF58a6ff)),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRunButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isRunning ? null : _runSimulation,
        icon: _isRunning
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.play_arrow),
        label: Text(_isRunning ? 'Simulating...' : 'Run 1,000 Simulations'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF58a6ff),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF58a6ff)),
            SizedBox(height: 16),
            Text('Running 1,000 simulations...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCards() {
    final r = _result!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _resultCard(
            'Traditional (Fixed Rate)',
            'Assumes constant ${r.inputs.avgReturn}% every year',
            'Savings last until age ${r.deterministicAge}',
            const Color(0xFF58a6ff),
            Icons.straighten,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _resultCard(
            'Monte Carlo (1,000 sims)',
            'Random returns with ${r.inputs.volatility}% volatility',
            '90% chance savings last past age ${r.percentileAge(10)}',
            const Color(0xFF3fb950),
            Icons.casino,
          ),
        ),
      ],
    );
  }

  Widget _resultCard(String title, String subtitle, String mainResult, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 12),
          Text(mainResult, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildConfidenceTable() {
    final r = _result!;
    final percentiles = [
      (90, r.percentileAge(10)),
      (75, r.percentileAge(25)),
      (50, r.percentileAge(50)),
      (25, r.percentileAge(75)),
      (10, r.percentileAge(90)),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confidence Levels', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text('"At least X% chance your savings last past this age"', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 16),
          ...percentiles.map((p) => _confidenceRow('${p.$1}%', 'Age ${p.$2}', _getAgeColor(p.$2, r.inputs.retirementAge))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${r.simsThatRanOutBefore(80)} out of 1,000 simulations (${(r.simsThatRanOutBefore(80) / 10).round()}%) ran out before age 80',
                    style: const TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAgeColor(int age, int retireAge) {
    if (age >= retireAge + 25) return const Color(0xFF3fb950);
    if (age >= retireAge + 15) return const Color(0xFF58a6ff);
    if (age >= retireAge + 10) return Colors.orange;
    return const Color(0xFFf85149);
  }

  Widget _confidenceRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF21262d),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.8, // simplified
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistogram() {
    final r = _result!;
    // Bucket ages for histogram
    final buckets = <int, int>{};
    for (final age in r.runOutAges) {
      final bucket = (age / 5).floor() * 5;
      buckets[bucket] = (buckets[bucket] ?? 0) + 1;
    }

    final sortedKeys = buckets.keys.toList()..sort();
    if (sortedKeys.isEmpty) return const SizedBox.shrink();
    final maxCount = buckets.values.reduce(max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribution of Outcomes', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text('How many simulations ran out at each age range', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: sortedKeys.map((age) {
                final count = buckets[age]!;
                final height = (count / maxCount * 120).clamp(4.0, 120.0);
                final color = _getAgeColor(age + 2, r.inputs.retirementAge);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('$count', style: TextStyle(color: Colors.grey[400], fontSize: 9)),
                      const SizedBox(height: 2),
                      Container(
                        width: 24,
                        height: height,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$age', style: TextStyle(color: Colors.grey[500], fontSize: 9)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('Age when savings run out', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildInsight() {
    final r = _result!;
    final p90 = r.percentileAge(10);
    final median = r.percentileAge(50);
    final diff = r.deterministicAge - median;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3fb950).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFF3fb950)),
              const SizedBox(width: 8),
              Text('Key Insight', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'The traditional calculator says your savings last until age ${r.deterministicAge}. '
            'But Monte Carlo shows the median outcome is age $median${diff > 0 ? " — that\'s $diff years earlier!" : ""}. '
            'With 90% confidence, plan for savings lasting to age $p90. '
            '${p90 < r.inputs.retirementAge + 15 ? "⚠️ Consider increasing contributions or delaying retirement." : "✅ Your plan looks reasonably solid."}',
            style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3fb950).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '💡 This is why Monte Carlo matters — it shows risk, not just averages. '
              'Professional financial planners use this method to give clients realistic expectations.',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data Models & Engine ───

class SimulationInputs {
  final int currentAge;
  final int retirementAge;
  final double currentSavings;
  final double annualContribution;
  final double avgReturn;
  final double inflationRate;
  final double lifestylePercent;
  final double currentSalary;
  final double volatility;

  const SimulationInputs({
    required this.currentAge,
    required this.retirementAge,
    required this.currentSavings,
    required this.annualContribution,
    required this.avgReturn,
    required this.inflationRate,
    required this.lifestylePercent,
    required this.currentSalary,
    required this.volatility,
  });
}

class MonteCarloResult {
  final SimulationInputs inputs;
  final List<int> runOutAges;
  final int deterministicAge;

  MonteCarloResult({required this.inputs, required this.runOutAges, required this.deterministicAge});

  int percentileAge(int percentile) {
    if (runOutAges.isEmpty) return 100;
    final sorted = List<int>.from(runOutAges)..sort();
    final index = (sorted.length * percentile / 100).floor().clamp(0, sorted.length - 1);
    return sorted[index];
  }

  int simsThatRanOutBefore(int age) {
    return runOutAges.where((a) => a < age).length;
  }
}

class MonteCarloEngine {
  static final _random = Random();

  static MonteCarloResult run(SimulationInputs inputs, {int simulations = 1000}) {
    final runOutAges = <int>[];

    // Calculate deterministic (fixed rate) for comparison
    final deterministicAge = _simulateSingle(inputs, (mean, _) => mean);

    // Monte Carlo
    for (int i = 0; i < simulations; i++) {
      final age = _simulateSingle(inputs, _randomReturn);
      runOutAges.add(age);
    }

    return MonteCarloResult(
      inputs: inputs,
      runOutAges: runOutAges,
      deterministicAge: deterministicAge,
    );
  }

  static int _simulateSingle(SimulationInputs inputs, double Function(double, double) returnFn) {
    double balance = inputs.currentSavings;
    final yearsToRetirement = inputs.retirementAge - inputs.currentAge;

    // Calculate final salary (with growth)
    double salary = inputs.currentSalary;
    final salaryGrowth = inputs.inflationRate + 1.0; // rough approximation
    for (int y = 0; y < yearsToRetirement; y++) {
      salary *= (1 + salaryGrowth / 100);
    }

    // Working years
    for (int y = 0; y < yearsToRetirement; y++) {
      final yearReturn = returnFn(inputs.avgReturn, inputs.volatility);
      balance = balance * (1 + yearReturn / 100) + inputs.annualContribution;
    }

    // Retirement years - withdraw lifestyle% of final salary
    final annualSpending = salary * (inputs.lifestylePercent / 100);

    for (int age = inputs.retirementAge; age < 120; age++) {
      final yearsIntoRetirement = age - inputs.retirementAge;
      final inflationAdjustedSpending = annualSpending * pow(1 + inputs.inflationRate / 100, yearsIntoRetirement);
      final yearReturn = returnFn(inputs.avgReturn, inputs.volatility);
      balance = balance * (1 + yearReturn / 100) - inflationAdjustedSpending;
      if (balance <= 0) return age;
    }

    return 120; // didn't run out
  }

  static double _randomReturn(double mean, double stdDev) {
    // Box-Muller transform for normal distribution
    final u1 = _random.nextDouble();
    final u2 = _random.nextDouble();
    final z = sqrt(-2 * log(u1)) * cos(2 * pi * u2);
    return mean + stdDev * z;
  }
}
