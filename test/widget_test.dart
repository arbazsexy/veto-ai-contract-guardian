import 'package:flutter_test/flutter_test.dart';
import 'package:veto_ai/src/features/contract_guardian/domain/contract_analyzer.dart';
import 'package:veto_ai/src/features/contract_guardian/domain/contract_models.dart';

void main() {
  test('analyzer flags common freelance contract risks', () {
    const riskyContract = '''
Payment terms are net 60 from invoice date.
Freelancer agrees this is a work made for hire and assigns all rights title and interest.
Freelancer shall indemnify and hold harmless the client from all claims.
Client may terminate this agreement at any time for convenience.
Freelancer may not work with competing businesses during the term of this agreement.
''';

    final analysis = ContractAnalyzer.analyze(riskyContract);

    expect(analysis.guardianScore, lessThan(70));
    expect(analysis.redCount, greaterThanOrEqualTo(3));
    expect(analysis.orangeCount, greaterThanOrEqualTo(1));
    expect(analysis.verdict, ContractVerdict.highRisk);
    expect(analysis.topIssue, isNotEmpty);
  });

  test('analyzer rewards protective scope and revision language', () {
    const healthierContract = '''
Scope of work includes a homepage redesign and mobile responsive handoff.
Deliverables will be provided in two milestones over a three-week timeline.
Two rounds of revisions are included.
Client will pay a 50% upfront deposit and the remaining balance on final approval.
Confidential information shared during the project will remain confidential.
''';

    final analysis = ContractAnalyzer.analyze(healthierContract);

    expect(analysis.greenCount, greaterThanOrEqualTo(3));
    expect(analysis.guardianScore, greaterThan(70));
    expect(analysis.verdict, isNot(ContractVerdict.highRisk));
  });
}
