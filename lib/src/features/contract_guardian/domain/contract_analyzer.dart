import 'package:veto_ai/src/features/contract_guardian/domain/contract_models.dart';

class ContractAnalyzer {
  static ContractAnalysis analyze(
    String rawText, {
    AnalysisInputQuality inputQuality = AnalysisInputQuality.typed,
  }) {
    final text = rawText.trim();
    if (text.isEmpty) {
      return const ContractAnalysis(
        findings: [
          ClauseFinding(
            title: 'No contract text provided',
            category: FindingCategory.scopeRisk,
            risk: RiskLevel.negotiable,
            confidence: FindingConfidence.high,
            matchedSnippet: 'Paste a contract or scope of work to begin.',
            explanation:
                'The app needs actual agreement language to score risk and suggest negotiation edits.',
            negotiationScript:
                'Hi, please share the written contract or project terms so I can review the scope, payment schedule, and IP language before we proceed.',
          ),
        ],
        guardianScore: 50,
        topIssue: 'Need contract text',
        inputQuality: AnalysisInputQuality.typed,
        verdict: ContractVerdict.signableAfterEdits,
      );
    }

    final findings = <ClauseFinding>[
      _matchOrFallback(
        text: text,
        title: 'Unlimited indemnity',
        category: FindingCategory.ipLegalRisk,
        risk: RiskLevel.danger,
        inputQuality: inputQuality,
        patterns: const ['indemnify', 'hold harmless', 'all claims'],
        fallbackSnippet: 'No broad indemnity language detected.',
        hitExplanation:
            'The client can shift legal and financial liability onto the freelancer, which is disproportionate for most independent contracts.',
        missExplanation:
            'There is no obvious unlimited indemnity wording in the pasted text.',
        hitScript:
            'Hi, I am happy to stand behind my own work, but I cannot accept unlimited indemnity. Please revise this clause so my liability is limited to direct damages caused by my breach and capped at the fees paid under this agreement.',
        missScript: 'No change needed here.',
      ),
      _matchOrFallback(
        text: text,
        title: 'Exclusivity or non-compete restriction',
        category: FindingCategory.clientControlRisk,
        risk: RiskLevel.danger,
        inputQuality: inputQuality,
        patterns: const [
          'exclusive basis',
          'non-compete',
          'shall not provide services to any competitor',
          'may not work with competing businesses',
        ],
        fallbackSnippet: 'No exclusivity restriction detected.',
        hitExplanation:
            'This can block the freelancer from taking other clients in the same industry, which is unusually restrictive for independent work.',
        missExplanation:
            'There is no obvious exclusivity or non-compete restriction in the pasted text.',
        hitScript:
            'Hi, I work with multiple clients, so I cannot agree to a broad exclusivity or non-compete restriction. If needed, I am open to a narrower conflict clause limited to confidential information and direct project conflicts during the engagement.',
        missScript: 'No change needed here.',
      ),
      _matchOrFallback(
        text: text,
        title: 'Late payment window',
        category: FindingCategory.moneyRisk,
        risk: RiskLevel.negotiable,
        inputQuality: inputQuality,
        patterns: const ['net 60', 'net-60', '60 days', 'within sixty'],
        fallbackSnippet: 'No extended payment window detected.',
        hitExplanation:
            'A 60-day payment cycle can create cash flow pressure for freelancers and is usually worth negotiating down to net 15 or net 30.',
        missExplanation:
            'The payment timing does not show a clearly delayed payout pattern.',
        hitScript:
            'Hi, could we revise the payment term from net 60 to net 15 or net 30? That would make the project workable on my side while keeping delivery timelines unchanged.',
        missScript: 'No change needed here.',
      ),
      _matchOrFallback(
        text: text,
        title: 'Missing upfront deposit',
        category: FindingCategory.moneyRisk,
        risk: RiskLevel.negotiable,
        inputQuality: inputQuality,
        patterns: const [
          '50% upfront',
          'advance payment',
          'deposit',
          'retainer',
        ],
        fallbackSnippet: 'No deposit or advance payment language detected.',
        hitExplanation:
            'An upfront payment or retainer gives the freelancer protection before work starts and reduces collection risk.',
        missExplanation:
            'The agreement does not appear to include a deposit or advance payment, which can make the engagement riskier for the freelancer.',
        hitScript:
            'Hi, to secure time on my schedule and reduce project risk, could we add an upfront deposit before work begins? A partial advance with the balance tied to milestones would work well.',
        missScript:
            'Hi, to secure time on my schedule and reduce project risk, could we add an upfront deposit before work begins? A partial advance with the balance tied to milestones would work well.',
      ),
      _matchOrFallback(
        text: text,
        title: 'Full IP transfer',
        category: FindingCategory.ipLegalRisk,
        risk: RiskLevel.danger,
        inputQuality: inputQuality,
        patterns: const [
          'work made for hire',
          'all rights title and interest',
          'assigns all intellectual property',
        ],
        fallbackSnippet: 'No blanket IP transfer language detected.',
        hitExplanation:
            'This wording can transfer all ownership immediately, including reusable methods or pre-existing assets, unless carve-outs are added.',
        missExplanation:
            'The pasted text does not clearly force a blanket transfer of all intellectual property.',
        hitScript:
            'Hi, I can assign final deliverables upon full payment, but I need a carve-out for my pre-existing materials, tools, templates, and general know-how. Please update the IP clause to reflect that distinction.',
        missScript: 'No change needed here.',
      ),
      _matchOrFallback(
        text: text,
        title: 'Termination for convenience',
        category: FindingCategory.clientControlRisk,
        risk: RiskLevel.negotiable,
        inputQuality: inputQuality,
        patterns: const [
          'terminate at any time',
          'without cause',
          'for convenience',
        ],
        fallbackSnippet: 'No easy termination clause detected.',
        hitExplanation:
            'The client may be able to cancel the work without warning. That should usually be paired with notice and payment for completed milestones.',
        missExplanation:
            'There is no obvious no-cause termination clause in the pasted text.',
        hitScript:
            'Hi, I am okay with a termination clause, but it should include written notice and payment for all work completed up to the termination date, including committed milestones already in progress.',
        missScript: 'No change needed here.',
      ),
      _matchOrFallback(
        text: text,
        title: 'No kill fee or cancellation payment',
        category: FindingCategory.moneyRisk,
        risk: RiskLevel.negotiable,
        inputQuality: inputQuality,
        patterns: const [
          'kill fee',
          'cancellation fee',
          'payment for work performed',
          'non-refundable',
        ],
        fallbackSnippet: 'No kill-fee protection detected.',
        hitExplanation:
            'The contract includes at least some payment protection if the project is canceled after work has already been scheduled or started.',
        missExplanation:
            'If the client cancels mid-project, the freelancer may lose reserved time and partial work value without a kill fee or non-refundable milestone.',
        hitScript:
            'Hi, if the project is canceled after kickoff, I would need a kill fee or payment for work already scheduled and completed. Could we add cancellation compensation tied to completed work or reserved production time?',
        missScript:
            'Hi, if the project is canceled after kickoff, I would need a kill fee or payment for work already scheduled and completed. Could we add cancellation compensation tied to completed work or reserved production time?',
      ),
      _matchOrFallback(
        text: text,
        title: 'Confidentiality coverage',
        category: FindingCategory.ipLegalRisk,
        risk: RiskLevel.safe,
        inputQuality: inputQuality,
        patterns: const [
          'confidential information',
          'confidentiality',
          'non-disclosure',
          'nda',
        ],
        fallbackSnippet: 'No confidentiality clause detected.',
        hitExplanation:
            'A basic confidentiality clause is normal and can protect both sides as long as it is not overly broad or permanent in an unreasonable way.',
        missExplanation:
            'There is no obvious confidentiality language. Many client projects benefit from a simple mutual confidentiality clause.',
        hitScript:
            'Hi, if this project involves internal materials or unreleased assets, we can add a simple confidentiality clause that protects both sides without expanding the rest of the agreement.',
        missScript:
            'Hi, if this project involves internal materials or unreleased assets, we can add a simple confidentiality clause that protects both sides without expanding the rest of the agreement.',
      ),
      _matchOrFallback(
        text: text,
        title: 'Revision limits',
        category: FindingCategory.scopeRisk,
        risk: RiskLevel.safe,
        inputQuality: inputQuality,
        patterns: const [
          'rounds of revisions',
          'revision rounds',
          'two rounds of revisions',
          'revision limit',
        ],
        fallbackSnippet: 'No revision limits detected.',
        hitExplanation:
            'Defined revision limits help stop open-ended scope creep and make approval cycles easier to manage.',
        missExplanation:
            'Without revision limits, the freelancer may be pulled into unlimited change requests that were never priced into the project.',
        hitScript:
            'Hi, could we add a revision limit so the scope stays predictable? For example, two rounds of revisions are included, with additional changes billed separately.',
        missScript:
            'Hi, could we add a revision limit so the scope stays predictable? For example, two rounds of revisions are included, with additional changes billed separately.',
      ),
      _matchOrFallback(
        text: text,
        title: 'Defined scope and deliverables',
        category: FindingCategory.scopeRisk,
        risk: RiskLevel.safe,
        inputQuality: inputQuality,
        patterns: const ['scope of work', 'deliverables', 'timeline', 'milestone'],
        fallbackSnippet: 'Scope details are thin or missing.',
        hitExplanation:
            'Clear scope language reduces disputes and gives the freelancer a stronger position when requesting payment or approving revisions.',
        missExplanation:
            'The agreement would be safer if it clearly named deliverables, revision limits, and deadlines.',
        hitScript:
            'Hi, to avoid confusion for both sides, could we add a brief scope section that lists deliverables, revision limits, and milestone dates?',
        missScript:
            'Hi, to avoid confusion for both sides, could we add a brief scope section that lists deliverables, revision limits, and milestone dates?',
      ),
    ];

    var score = 100;
    for (final finding in findings) {
      switch (finding.risk) {
        case RiskLevel.danger:
          if (_findingTriggered(finding)) {
            score -= 25;
          }
        case RiskLevel.negotiable:
          if (_findingTriggered(finding)) {
            score -= 12;
          }
        case RiskLevel.safe:
          if (!_findingTriggered(finding)) {
            score -= 8;
          }
      }
    }

    final clampedScore = score.clamp(12, 98);
    final ranked = findings.where((finding) {
      if (finding.risk == RiskLevel.safe) {
        return false;
      }

      return _findingTriggered(finding);
    }).toList();

    final topIssue =
        ranked.isEmpty ? 'No major issue detected' : ranked.first.title;
    final verdict = _resolveVerdict(
      guardianScore: clampedScore,
      findings: findings,
    );

    return ContractAnalysis(
      findings: findings,
      guardianScore: clampedScore,
      topIssue: topIssue,
      inputQuality: inputQuality,
      verdict: verdict,
    );
  }

  static ClauseFinding _matchOrFallback({
    required String text,
    required String title,
    required FindingCategory category,
    required RiskLevel risk,
    required AnalysisInputQuality inputQuality,
    required List<String> patterns,
    required String fallbackSnippet,
    required String hitExplanation,
    required String missExplanation,
    required String hitScript,
    required String missScript,
  }) {
    final lower = text.toLowerCase();
    final match = patterns.cast<String?>().firstWhere(
          (pattern) => lower.contains(pattern!.toLowerCase()),
          orElse: () => null,
        );

    if (match == null) {
      final fallbackRisk =
          risk == RiskLevel.safe ? RiskLevel.negotiable : RiskLevel.safe;
      return ClauseFinding(
        title: title,
        category: category,
        risk: fallbackRisk,
        confidence: _resolveConfidence(
          matched: false,
          risk: fallbackRisk,
          inputQuality: inputQuality,
        ),
        matchedSnippet: fallbackSnippet,
        explanation: missExplanation,
        negotiationScript: missScript,
      );
    }

    final snippet = _extractSnippet(text, match);
    return ClauseFinding(
      title: title,
      category: category,
      risk: risk,
      confidence: _resolveConfidence(
        matched: true,
        risk: risk,
        inputQuality: inputQuality,
      ),
      matchedSnippet: snippet,
      explanation: hitExplanation,
      negotiationScript: hitScript,
    );
  }

  static String _extractSnippet(String text, String phrase) {
    final lower = text.toLowerCase();
    final start = lower.indexOf(phrase.toLowerCase());
    if (start == -1) {
      return phrase;
    }

    final snippetStart = (start - 36).clamp(0, text.length);
    final snippetEnd = (start + phrase.length + 80).clamp(0, text.length);
    return text.substring(snippetStart, snippetEnd).replaceAll('\n', ' ').trim();
  }

  static bool _findingTriggered(ClauseFinding finding) {
    switch (finding.title) {
      case 'Defined scope and deliverables':
        return finding.matchedSnippet != 'Scope details are thin or missing.';
      case 'Confidentiality coverage':
        return finding.matchedSnippet != 'No confidentiality clause detected.';
      case 'Revision limits':
        return finding.matchedSnippet != 'No revision limits detected.';
      default:
        return !finding.matchedSnippet.startsWith('No ');
    }
  }

  static FindingConfidence _resolveConfidence({
    required bool matched,
    required RiskLevel risk,
    required AnalysisInputQuality inputQuality,
  }) {
    var score = matched ? 2 : 1;
    if (risk == RiskLevel.safe && !matched) {
      score = 1;
    }

    score -= inputQuality.confidencePenalty;
    if (score >= 2) {
      return FindingConfidence.high;
    }
    if (score == 1) {
      return FindingConfidence.medium;
    }
    return FindingConfidence.review;
  }

  static ContractVerdict _resolveVerdict({
    required int guardianScore,
    required List<ClauseFinding> findings,
  }) {
    final redCount = findings
        .where((finding) => finding.risk == RiskLevel.danger)
        .where(_findingTriggered)
        .length;
    final orangeCount = findings
        .where((finding) => finding.risk == RiskLevel.negotiable)
        .where(_findingTriggered)
        .length;

    if (redCount >= 2 || guardianScore < 45) {
      return ContractVerdict.highRisk;
    }
    if (redCount >= 1 || orangeCount >= 2 || guardianScore < 78) {
      return ContractVerdict.signableAfterEdits;
    }
    return ContractVerdict.signable;
  }
}
