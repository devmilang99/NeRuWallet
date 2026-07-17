import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_service.g.dart';

@Riverpod(keepAlive: true)
AiService aiService(Ref ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final db = ref.watch(appDatabaseProvider);
  return AiService(apiKey, db);
}

class AiService {
  final String apiKey;
  final AppDatabase _db;
  late final GenerativeModel _model;

  AiService(this.apiKey, this._db) {
    _model = GenerativeModel(
      model: 'gemini-3.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  Future<String> getFinancialSummary({
    required List<Transaction> transactions,
    required Map<String, double> categoryTotals,
    required double totalIncome,
    required double totalExpense,
    required double monthlyExpense,
  }) async {
    if (transactions.isEmpty) return "{}";

    // Prepare a concise category breakdown
    final categorySummary = categoryTotals.entries
        .map((e) => '${e.key}:${e.value.toStringAsFixed(0)}')
        .join(', ');

    // Latest transactions for context
    final recentTxs = transactions
        .take(5)
        .map((t) => '${t.title}:${t.amount.toStringAsFixed(0)}')
        .join('|');

    final prompt =
        '''
Analyze these transaction table statistics ONLY. Be concise.
DATA:
- Total Income: Rs. $totalIncome
- Total Expenses: Rs. $totalExpense
- Current Month: Rs. $monthlyExpense
- Categories: $categorySummary
- Recent Transactions: $recentTxs

JSON ONLY:
{
  "summary": "1-2 sentences on patterns.",
  "suggestions": ["3 saving tips"],
  "unusual": [{"t": "title", "a": amount, "r": "reason"}],
  "potential": "Estimated savings",
  "steps": ["Next 2 actions"]
}
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final jsonResponse = response.text ?? "{}";

    await _db.saveAiMemory(
      AiMemoriesCompanion.insert(
        role: 'model',
        content: jsonResponse,
        type: const Value('json'),
      ),
    );

    return jsonResponse;
  }

  Future<String> chat(List<Transaction> transactions, String message) async {
    // Ultra-concise context
    final txSummary = transactions
        .take(5)
        .map((t) => '${t.title}:${t.amount}')
        .join('|');
    final memories = await _db.getAiMemories(limit: 3);
    final history = memories.reversed
        .map(
          (e) =>
              '${e.role[0]}:${e.content.substring(0, (e.content.length > 40 ? 40 : e.content.length))}',
        )
        .join('\n');

    final systemPrompt =
        '''
NeRu Assistant. JSON ONLY. Rules: Finance focus, Max 2 sentences. 
If goal set: "update":{"key":"ai_monthly_budget","val":"value"}.
Txs:$txSummary. Hist:$history
Output:{"text":"...", "update":null}
''';

    await _db.saveAiMemory(
      AiMemoriesCompanion.insert(role: 'user', content: message),
    );

    final response = await _model.generateContent([
      Content.text(systemPrompt),
      Content.text("User: $message"),
    ]);

    String jsonStr = response.text ?? '{"text": "Error processing"}';

    try {
      final data = jsonDecode(jsonStr);
      if (data['update'] != null) {
        final up = data['update'];
        await _db.setPreference(up['key'], up['val'].toString());
      }
    } catch (_) {}

    await _db.saveAiMemory(
      AiMemoriesCompanion.insert(
        role: 'model',
        content: jsonStr,
        type: const Value('json'),
      ),
    );

    return jsonStr;
  }
}
