import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:neruwallet/core/providers/balance_provider.dart';
import 'package:neruwallet/core/services/ai_service.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';

class AIAdvisorScreen extends ConsumerStatefulWidget {
  const AIAdvisorScreen({super.key});

  @override
  ConsumerState<AIAdvisorScreen> createState() => _AIAdvisorScreenState();
}

class _AIAdvisorScreenState extends ConsumerState<AIAdvisorScreen> {
  bool _hasConsent = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _structuredSummary;

  final List<Map<String, dynamic>> _currentSessionMessages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLatestAnalysis();
  }

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        GlassDialog.showError(
          context,
          "No internet connection. Please check your network.",
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _loadLatestAnalysis() async {
    final memories = await ref
        .read(appDatabaseProvider)
        .getAiMemories(limit: 50);
    final latestJson = memories.firstWhereOrNull((m) => m.type == 'json');
    if (latestJson != null) {
      try {
        setState(() {
          _structuredSummary = jsonDecode(latestJson.content);
        });
      } catch (_) {}
    }
  }

  void _getSummary() async {
    if (!await _checkConnectivity()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactions = ref.read(balanceProvider).transactions;
      final aiService = ref.read(aiServiceProvider);
      final jsonResponse = await aiService.getFinancialSummary(transactions);
      setState(() {
        _structuredSummary = jsonDecode(jsonResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to analyze data. Please try again.";
      });
    }
  }

  void _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    if (!await _checkConnectivity()) return;

    _chatController.clear();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentSessionMessages.add({'role': 'user', 'content': message});
    });
    _scrollToBottom();

    try {
      final transactions = ref.read(balanceProvider).transactions;
      final aiService = ref.read(aiServiceProvider);
      final response = await aiService.chat(transactions, message);

      if (mounted) {
        setState(() {
          _currentSessionMessages.add({
            'role': 'model',
            'content': response,
            'isJson': true,
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "AI encountered an issue. Tap to retry.";
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!_hasConsent) return _buildConsentScreen(isDark);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  "AI Assistant",
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
              onPressed: () => setState(() => _currentSessionMessages.clear()),
            ),
          ],
        ),
        body: Column(
          children: [
            const TabBar(
              indicatorColor: Color(0xFF10B981),
              labelColor: Color(0xFF10B981),
              unselectedLabelColor: Colors.white38,
              tabs: [
                Tab(text: "Analysis"),
                Tab(text: "Chat"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [_buildAnalysisTab(isDark), _buildChatTab(isDark)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisTab(bool isDark) {
    return RefreshIndicator(
      onRefresh: () async => _getSummary(),
      color: const Color(0xFF10B981),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_errorMessage != null) ...[
              _buildErrorRetry(),
              const SizedBox(height: 16),
            ],
            _buildChart(isDark),
            const SizedBox(height: 24),
            _buildImpactSummary(isDark),
            const SizedBox(height: 24),
            if (_isLoading && _structuredSummary == null)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              )
            else
              _buildStructuredSummaryView(isDark),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: _currentSessionMessages.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount:
                      _currentSessionMessages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _currentSessionMessages.length) {
                      return _buildTypingIndicator(isDark);
                    }
                    return _buildChatBubble(
                      _currentSessionMessages[index],
                      isDark,
                    );
                  },
                ),
        ),
        if (_errorMessage != null) _buildErrorRetry(),
        _buildChatInput(isDark),
      ],
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF10B981),
                size: 14,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child:
                    const Text(
                          "...",
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 1200.ms),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0),
    );
  }

  Widget _buildErrorRetry() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_currentSessionMessages.isNotEmpty &&
                  _currentSessionMessages.last['role'] == 'user') {
                _chatController.text = _currentSessionMessages.last['content'];
                _currentSessionMessages.removeLast();
                _sendMessage();
              } else {
                _getSummary();
              }
            },
            child: const Text(
              "Retry",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final authService = AuthService();
    final user = authService.currentUser;
    final userName = (user?.name ?? 'User').toUpperCase();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF10B981),
              size: 50,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 32),
          Text(
            "Hi, $userName!",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            "What can I help you find today?",
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Quick Explore",
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildExploreCard(
                      "Monthly Report",
                      "Financial status",
                      Icons.analytics_outlined,
                    ),
                    _buildExploreCard(
                      "Savings Tips",
                      "Save more daily",
                      Icons.lightbulb_outline_rounded,
                    ),
                    _buildExploreCard(
                      "Budget Goal",
                      "Set spending limit",
                      Icons.track_changes_rounded,
                    ),
                    _buildExploreCard(
                      "Recent Impact",
                      "Balance analysis",
                      Icons.trending_up_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildChatInput(isDark),
        ],
      ),
    );
  }

  Widget _buildExploreCard(String title, String subtitle, IconData icon) {
    return InkWell(
      onTap: () {
        _chatController.text = "Analyze my $title";
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF10B981), size: 20),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              "'$subtitle'",
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg, bool isDark) {
    final isUser = msg['role'] == 'user';
    final isJson = msg['isJson'] == true;
    String content = msg['content'].toString();

    if (isJson && !isUser) {
      content = _parseChatResponse(content);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUser
                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                : const Color(0xFF161B22),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 20 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 20),
            ),
            border: Border.all(
              color: isUser
                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF10B981),
                        size: 14,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "NERU AI",
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                content,
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.9),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  String _parseChatResponse(String rawContent) {
    try {
      String cleaned = rawContent.trim();
      // Remove markdown backticks if present
      if (cleaned.contains('```')) {
        final lines = cleaned.split('\n');
        cleaned = lines
            .where((l) => !l.trim().startsWith('```'))
            .join('\n')
            .trim();
      }

      final data = jsonDecode(cleaned);
      if (data is Map) {
        return data['text']?.toString() ?? "Analysis complete.";
      } else if (data is List && data.isNotEmpty) {
        // Handle unexpected array wrapping
        final first = data.first;
        if (first is Map) {
          return first['text']?.toString() ?? "Analysis complete.";
        }
      }
    } catch (e) {
      debugPrint("Failed to parse AI JSON: $e");
    }
    return rawContent; // Fallback to raw if all else fails
  }

  Widget _buildChatInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: "Ask NeRu about your finances...",
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _isLoading ? null : _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructuredSummaryView(bool isDark) {
    final transactions = _getFilteredTransactions();
    final hasExpenses = transactions.any((t) => t.amount < 0);

    if (transactions.isEmpty) {
      return _buildStatusCard(
        Icons.account_balance_wallet_outlined,
        "No Transactions Yet",
        "Make some transactions to enable AI financial analysis.",
        null,
      );
    }

    if (!hasExpenses) {
      return _buildStatusCard(
        Icons.shopping_cart_outlined,
        "No Expenses Found",
        "We need some expense data to analyze your spending habits.",
        null,
      );
    }

    if (_structuredSummary == null || _structuredSummary!.isEmpty) {
      return _buildStatusCard(
        Icons.analytics_outlined,
        "Ready to Analyze",
        "Tap the button below to generate your financial insights.",
        ElevatedButton(
          onPressed: _getSummary,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Generate Analysis"),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_structuredSummary!['summary'] != null &&
            _structuredSummary!['summary'].toString().isNotEmpty)
          _buildInfoCard(
            "Analysis Summary",
            _structuredSummary!['summary'],
            Icons.psychology_rounded,
            const Color(0xFF10B981),
            isDark,
          ),
        const SizedBox(height: 16),
        _buildSuggestionsList(isDark),
        const SizedBox(height: 16),
        if (_structuredSummary!['potential'] != null &&
            _structuredSummary!['potential'].toString().isNotEmpty)
          _buildInfoCard(
            "Savings Potential",
            _structuredSummary!['potential'],
            Icons.savings_outlined,
            Colors.orange,
            isDark,
          ),
      ],
    );
  }

  Widget _buildStatusCard(
    IconData icon,
    String title,
    String message,
    Widget? action,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white24, size: 48),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
          if (action != null) ...[const SizedBox(height: 24), action],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String content,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(bool isDark) {
    final suggestions = (_structuredSummary!['suggestions'] as List?) ?? [];
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Savings Suggestions",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF10B981),
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.toString(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    final transactions = _getFilteredTransactions();
    if (transactions.isEmpty) return const SizedBox.shrink();

    final Map<DateTime, double> expenseMap = {};
    for (var tx in transactions) {
      if (tx.amount < 0) {
        final date = DateTime(
          tx.createdAt.year,
          tx.createdAt.month,
          tx.createdAt.day,
        );
        expenseMap[date] = (expenseMap[date] ?? 0) + tx.amount.abs();
      }
    }

    if (expenseMap.isEmpty) return const SizedBox.shrink();

    final sortedDates = expenseMap.keys.toList()..sort();
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedDates.length; i++) {
      spots.add(FlSpot(i.toDouble(), expenseMap[sortedDates[i]]!));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Spending Trend",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactSummary(bool isDark) {
    final transactions = _getFilteredTransactions();
    final totalExpense = transactions
        .where((t) => t.amount < 0)
        .fold(0.0, (sum, t) => sum + t.amount.abs());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF10B981),
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Monthly Spending",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                "Rs. ${NumberFormat('#,###').format(totalExpense)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Transaction> _getFilteredTransactions() {
    final all = ref.watch(balanceProvider).transactions;
    final now = DateTime.now();
    return all
        .where(
          (tx) => tx.createdAt.isAfter(now.subtract(const Duration(days: 30))),
        )
        .toList();
  }

  Widget _buildConsentScreen(bool isDark) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF10B981),
                size: 80,
              ).animate().shimmer(duration: 2.seconds),
              const SizedBox(height: 40),
              const Text(
                "Secure AI Analysis",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              _buildConsentDetail(
                Icons.lock_outline_rounded,
                "Privacy First",
                "Your transaction data is analyzed securely and never shared with third parties.",
              ),
              const SizedBox(height: 16),
              _buildConsentDetail(
                Icons.insights_rounded,
                "Personalized Insights",
                "Gemini uses your spending patterns to create custom saving strategies for you.",
              ),
              const SizedBox(height: 16),
              _buildConsentDetail(
                Icons.data_usage_rounded,
                "You're in Control",
                "You can clear your AI memory and revoke this consent at any time in settings.",
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => setState(() => _hasConsent = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "I Consent & Continue",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Not Now",
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsentDetail(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF10B981), size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
