import 'package:flutter/material.dart';
import 'package:veto_ai/src/features/contract_guardian/domain/contract_models.dart';

class HeroPanel extends StatelessWidget {
  const HeroPanel({
    super.key,
    required this.score,
    required this.verdict,
  });

  final int score;
  final ContractVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;

        return Container(
          padding: EdgeInsets.all(isCompact ? 20 : 28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1C1917), Color(0xFF3F2D1F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Contract Guardian v1',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 16 : 20),
              Text(
                'Spot contract traps before you sign.',
                style: (isCompact
                        ? theme.textTheme.headlineMedium
                        : theme.textTheme.displaySmall)
                    ?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Paste freelance contract text and get a practical read on payment risk, IP transfer, indemnity clauses, and negotiation leverage.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFE7DCCF),
                  height: 1.4,
                ),
              ),
              SizedBox(height: isCompact ? 20 : 28),
              Container(
                padding: EdgeInsets.all(isCompact ? 14 : 18),
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ScoreBadge(score: score),
                          const SizedBox(height: 14),
                          _VerdictContent(verdict: verdict),
                        ],
                      )
                    : Row(
                        children: [
                          _ScoreBadge(score: score),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _VerdictContent(verdict: verdict),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          '$score',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1C1917),
          ),
        ),
      ),
    );
  }
}

class _VerdictContent extends StatelessWidget {
  const _VerdictContent({required this.verdict});

  final ContractVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Guardian Score',
          style: TextStyle(
            color: Color(0xFFE7DCCF),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          verdict.label,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          verdict.summary,
          style: const TextStyle(
            color: Color(0xFFE7DCCF),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: verdict.accent.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Decision signal',
            style: TextStyle(
              color: verdict.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
