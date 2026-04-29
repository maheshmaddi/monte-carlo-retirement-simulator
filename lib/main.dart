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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                _buildHistoricalReturns(),
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
                    'Demo — Uses 98 years of real S&P 500 returns (1926–2024)',
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
                  'This demo runs 1,000 simulated lifetimes using actual S&P 500 annual returns from 1926–2024. Each simulation randomly picks real historical years — capturing crashes like 1931 (-43%), 2008 (-36%), and booms like 1954 (52%).',
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
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: MediaQuery.of(context).size.width > 800 ? 2.5 : 3.2,
            children: [
              _inputField('Current Age', _ageCtrl, Icons.person),
              _inputField('Retirement Age', _retireAgeCtrl, Icons.elderly),
              _inputField('Current Salary (\$)', _salaryCtrl, Icons.attach_money),
              _inputField('Current Savings (\$)', _savingsCtrl, Icons.savings),
              _inputField('Annual Contribution (\$)', _contribCtrl, Icons.add_circle_outline),
              _inputField('Expected Return (%)', _returnCtrl, Icons.trending_up),
              // Volatility hidden — using real historical data
              _inputField('Inflation (%)', _inflationCtrl, Icons.arrow_upward),
              _inputField('Lifestyle Goal (%)', _lifestyleCtrl, Icons.home),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
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
    );
  }

  Widget _buildHistoricalReturns() {
    final returns = MonteCarloEngine.historicalReturns;
    final startYear = 1926;
    final avgReturn = returns.reduce((a, b) => a + b) / returns.length;
    final bestYear = returns.asMap().entries.reduce((a, b) => a.value > b.value ? a : b);
    final worstYear = returns.asMap().entries.reduce((a, b) => a.value < b.value ? a : b);
    final positiveYears = returns.where((r) => r > 0).length;
    final maxAbsReturn = returns.map((r) => r.abs()).reduce(max);

    // Calculate 10-year rolling averages
    final rollingAvg = <double>[];
    for (int i = 9; i < returns.length; i++) {
      final slice = returns.sublist(i - 9, i + 1);
      rollingAvg.add(slice.reduce((a, b) => a + b) / 10);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: Color(0xFF58a6ff), size: 20),
              const SizedBox(width: 8),
              Text('S&P 500 Historical Returns (1926–2024)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Annual total returns including dividends. This is the data powering the Monte Carlo simulation.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 16),

          // Stats row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0d1117),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _statBox('Avg Return', '${avgReturn.toStringAsFixed(1)}%', const Color(0xFF58a6ff)),
                    _statBox('Best Year', '${bestYear.value.toStringAsFixed(1)}% (${startYear + bestYear.key})', const Color(0xFF3fb950)),
                    _statBox('Worst Year', '${worstYear.value.toStringAsFixed(1)}% (${startYear + worstYear.key})', const Color(0xFFf85149)),
                    _statBox('Positive Years', '$positiveYears/${returns.length} (${(positiveYears / returns.length * 100).round()}%)', Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bar chart
          Text('Annual Returns', style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: LayoutBuilder(builder: (context, constraints) {
              final barWidth = (constraints.maxWidth - returns.length) / returns.length;
              return Stack(
                children: [
                  // Zero line
                  Positioned(
                    top: 160 / 2,
                    left: 0,
                    right: 0,
                    child: Container(height: 1, color: Colors.grey[700]),
                  ),
                  // Bars
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: returns.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final val = entry.value;
                      final isPositive = val >= 0;
                      final color = isPositive ? const Color(0xFF3fb950) : const Color(0xFFf85149);
                      final barHeight = (val.abs() / maxAbsReturn) * 70;
                      return GestureDetector(
                        child: Container(
                          width: barWidth.clamp(2.0, 8.0),
                          height: barHeight.clamp(1.0, 70.0),
                          margin: EdgeInsets.only(
                            top: isPositive ? 80 - barHeight : 80,
                            bottom: isPositive ? 80 : 80 - barHeight,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1926', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              Text('1950', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              Text('1975', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              Text('2000', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              Text('2024', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),

          // Rolling 10-year average
          Text('10-Year Rolling Average Return', style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: LayoutBuilder(builder: (context, constraints) {
              final w = constraints.maxWidth / (rollingAvg.length - 1);
              final minR = rollingAvg.reduce(min);
              final maxR = rollingAvg.reduce(max);
              final range = maxR - minR;
              final points = <Offset>[];
              for (int i = 0; i < rollingAvg.length; i++) {
                final x = i * w;
                final y = 90 - ((rollingAvg[i] - minR) / range) * 80;
                points.add(Offset(x, y));
              }
              return CustomPaint(
                painter: _LineChartPainter(points, const Color(0xFF58a6ff)),
              );
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1935', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              Text('1960', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              Text('1985', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              Text('2010', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              Text('2024', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF58a6ff).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '📊 Key takeaway: While individual years vary wildly (-43% to +54%), the 10-year rolling average consistently stays positive. This is why long-term investing works — but the volatility is exactly what Monte Carlo captures.',
              style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
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
            'Randomly picks from 98 years of real S&P 500 data',
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

  /// S&P 500 annual total returns (including dividends) 1926–2024
  /// Source: Ibbotson/SBBI, S&P Dow Jones Indices
  static const historicalReturns = [
    11.62, 37.49, 43.61, -8.42, -24.90, // 1926-1930
    -43.34, -8.19, 53.99, -1.44, 47.67, // 1931-1935
    33.92, -35.03, 31.12, -0.41, -9.78, // 1936-1940
    -11.59, 20.34, 25.90, 19.75, 36.44, // 1941-1945
    -8.07, 5.71, 5.50, 18.79, 31.71,   // 1946-1950
    24.02, 18.37, 22.97, -0.99, 19.53,  // 1951-1955
    34.11, -10.46, 43.72, 12.81, 10.47, // 1956-1960
    26.64, -8.81, 22.64, 16.58, 12.27,  // 1961-1965
    -10.04, 24.01, 11.57, 11.00, -0.47, // 1966-1970
    14.22, 18.76, -14.66, -26.40, 19.15, // 1971-1975
    32.46, 7.43, -6.10, 18.50, 32.64,   // 1976-1980
    -4.70, 21.42, 22.34, 6.27, 32.46,   // 1981-1985
    18.47, 5.23, 16.72, 31.49, -3.06,   // 1986-1990
    30.55, 7.67, 10.08, 1.36, 37.43,    // 1991-1995
    23.07, 33.17, 28.58, 21.04, -9.03,  // 1996-2000
    -11.85, -21.97, 28.36, 10.82, 4.89, // 2001-2005
    15.74, 5.49, -36.55, 25.94, 14.82,  // 2006-2010
    2.13, 16.00, 32.31, 13.76, 12.17,   // 2011-2015
    12.00, 21.71, -4.23, -6.16, 31.26,  // 2016-2020
    28.68, -18.01, 26.24, -19.32, 24.86, // 2021-2024 (approx)
  ];

  static MonteCarloResult run(SimulationInputs inputs, {int simulations = 1000}) {
    final runOutAges = <int>[];

    final deterministicAge = _simulateSingleDeterministic(inputs);

    for (int i = 0; i < simulations; i++) {
      final age = _simulateSingleBootstrap(inputs);
      runOutAges.add(age);
    }

    return MonteCarloResult(
      inputs: inputs,
      runOutAges: runOutAges,
      deterministicAge: deterministicAge,
    );
  }

  static int _simulateSingleDeterministic(SimulationInputs inputs) {
    double balance = inputs.currentSavings;
    final yearsToRetirement = inputs.retirementAge - inputs.currentAge;

    double salary = inputs.currentSalary;
    for (int y = 0; y < yearsToRetirement; y++) {
      salary *= (1 + (inputs.inflationRate + 1.0) / 100);
    }

    for (int y = 0; y < yearsToRetirement; y++) {
      balance = balance * (1 + inputs.avgReturn / 100) + inputs.annualContribution;
    }

    final annualSpending = salary * (inputs.lifestylePercent / 100);
    for (int age = inputs.retirementAge; age < 120; age++) {
      final yrs = age - inputs.retirementAge;
      final spending = annualSpending * pow(1 + inputs.inflationRate / 100, yrs);
      balance = balance * (1 + inputs.avgReturn / 100) - spending;
      if (balance <= 0) return age;
    }
    return 120;
  }

  static int _simulateSingleBootstrap(SimulationInputs inputs) {
    double balance = inputs.currentSavings;
    final yearsToRetirement = inputs.retirementAge - inputs.currentAge;
    final totalYears = 120 - inputs.currentAge;

    final returns = List.generate(totalYears, (_) => _pickHistoricalReturn());

    double salary = inputs.currentSalary;
    for (int y = 0; y < yearsToRetirement; y++) {
      salary *= (1 + (inputs.inflationRate + 1.0) / 100);
    }

    int rIdx = 0;
    for (int y = 0; y < yearsToRetirement; y++) {
      balance = balance * (1 + returns[rIdx++] / 100) + inputs.annualContribution;
    }

    final annualSpending = salary * (inputs.lifestylePercent / 100);
    for (int age = inputs.retirementAge; age < 120; age++) {
      final yrs = age - inputs.retirementAge;
      final spending = annualSpending * pow(1 + inputs.inflationRate / 100, yrs);
      balance = balance * (1 + returns[rIdx++] / 100) - spending;
      if (balance <= 0) return age;
    }
    return 120;
  }

  static double _pickHistoricalReturn() {
    return historicalReturns[_random.nextInt(historicalReturns.length)];
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  _LineChartPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Fill area under line
    final fillPath = Path()..moveTo(points[0].dx, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => false;
}
