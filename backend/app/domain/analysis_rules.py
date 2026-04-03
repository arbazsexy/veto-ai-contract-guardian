from dataclasses import dataclass

from app.schemas.analysis import FindingCategory, RiskLevel


@dataclass(frozen=True)
class AnalysisRule:
    title: str
    category: FindingCategory
    risk: RiskLevel
    patterns: tuple[str, ...]
    penalty: int
    priority: int
    fallback_snippet: str
    hit_explanation: str
    miss_explanation: str
    hit_script: str
    miss_script: str


DEFAULT_ANALYSIS_RULES: tuple[AnalysisRule, ...] = (
    AnalysisRule(
        title="Unlimited indemnity",
        category=FindingCategory.ip_legal_risk,
        risk=RiskLevel.danger,
        patterns=("indemnif", "hold harmless", "defend and indemn", "all claims"),
        penalty=28,
        priority=100,
        fallback_snippet="No broad indemnity language detected.",
        hit_explanation=(
            "The client can shift legal and financial liability onto the freelancer, "
            "which is disproportionate for most independent contracts."
        ),
        miss_explanation="There is no obvious unlimited indemnity wording in the contract text.",
        hit_script=(
            "Hi, I am happy to stand behind my own work, but I cannot accept unlimited indemnity. "
            "Please revise this clause so my liability is limited to direct damages caused by my breach "
            "and capped at the fees paid."
        ),
        miss_script="No change needed here.",
    ),
    AnalysisRule(
        title="Full IP transfer",
        category=FindingCategory.ip_legal_risk,
        risk=RiskLevel.danger,
        patterns=(
            "work made for hire",
            "all rights title and interest",
            "assigns all intellectual property",
            "hereby assigns",
            "exclusive ownership",
        ),
        penalty=26,
        priority=96,
        fallback_snippet="No blanket IP transfer language detected.",
        hit_explanation=(
            "This wording can transfer all ownership immediately, including reusable methods "
            "or pre-existing assets, unless carve-outs are added."
        ),
        miss_explanation="The text does not clearly force a blanket transfer of all intellectual property.",
        hit_script=(
            "Hi, I can assign final deliverables upon full payment, but I need a carve-out for pre-existing materials, "
            "tools, templates, and general know-how."
        ),
        miss_script="No change needed here.",
    ),
    AnalysisRule(
        title="Exclusivity or non-compete restriction",
        category=FindingCategory.client_control_risk,
        risk=RiskLevel.danger,
        patterns=(
            "exclusive basis",
            "exclusive services",
            "non-compete",
            "shall not provide services to any competitor",
            "may not work with competing businesses",
        ),
        penalty=24,
        priority=92,
        fallback_snippet="No exclusivity restriction detected.",
        hit_explanation=(
            "This can block the freelancer from taking other clients in the same industry, "
            "which is unusually restrictive for independent work."
        ),
        miss_explanation="There is no obvious exclusivity or non-compete restriction in the contract text.",
        hit_script=(
            "Hi, I work with multiple clients, so I cannot agree to a broad exclusivity or non-compete restriction. "
            "If needed, I am open to a narrower conflict clause limited to confidential information and direct project conflicts."
        ),
        miss_script="No change needed here.",
    ),
    AnalysisRule(
        title="Payment conditioned on client approval",
        category=FindingCategory.money_risk,
        risk=RiskLevel.danger,
        patterns=("accepted by client", "sole discretion", "subject to client approval", "if approved by client"),
        penalty=22,
        priority=90,
        fallback_snippet="No payment-on-approval clause detected.",
        hit_explanation=(
            "If payment depends on client approval or sole discretion, the freelancer may deliver work and still have no clear payment protection."
        ),
        miss_explanation=(
            "There is no obvious wording that makes payment depend entirely on client approval or sole discretion."
        ),
        hit_script=(
            "Hi, I need payment to be tied to objective milestones or delivery, not solely to discretionary approval. Could we define acceptance criteria and confirm payment for completed work?"
        ),
        miss_script="No change needed here.",
    ),
    AnalysisRule(
        title="Late payment window",
        category=FindingCategory.money_risk,
        risk=RiskLevel.negotiable,
        patterns=("net 45", "net-45", "net 60", "net-60", "45 days", "60 days", "within sixty"),
        penalty=14,
        priority=76,
        fallback_snippet="No extended payment window detected.",
        hit_explanation=(
            "A long payment cycle can create cash flow pressure and is usually worth "
            "negotiating down to net 15 or net 30, especially for solo freelancers."
        ),
        miss_explanation="The payment timing does not show a clearly delayed payout pattern.",
        hit_script=(
            "Hi, could we revise the payment term to net 15 or net 30? "
            "That would make the project workable on my side while keeping delivery timelines unchanged."
        ),
        miss_script="No change needed here.",
    ),
    AnalysisRule(
        title="Missing upfront deposit",
        category=FindingCategory.money_risk,
        risk=RiskLevel.negotiable,
        patterns=("50% upfront", "advance payment", "deposit", "retainer"),
        penalty=10,
        priority=68,
        fallback_snippet="No deposit or advance payment language detected.",
        hit_explanation=(
            "An upfront payment or retainer gives the freelancer protection before work starts "
            "and reduces collection risk."
        ),
        miss_explanation=(
            "The agreement does not appear to include a deposit or advance payment, "
            "which can make the engagement riskier for the freelancer."
        ),
        hit_script=(
            "Hi, to secure time on my schedule and reduce project risk, could we add an upfront deposit before work begins? "
            "A partial advance with the balance tied to milestones would work well."
        ),
        miss_script=(
            "Hi, to secure time on my schedule and reduce project risk, could we add an upfront deposit before work begins? "
            "A partial advance with the balance tied to milestones would work well."
        ),
    ),
    AnalysisRule(
        title="No kill fee or cancellation payment",
        category=FindingCategory.money_risk,
        risk=RiskLevel.negotiable,
        patterns=("kill fee", "cancellation fee", "payment for work performed", "non-refundable"),
        penalty=12,
        priority=72,
        fallback_snippet="No kill-fee protection detected.",
        hit_explanation=(
            "The contract includes at least some payment protection if the project is canceled "
            "after work has already been scheduled or started."
        ),
        miss_explanation=(
            "If the client cancels mid-project, the freelancer may lose reserved time and partial work value "
            "without a kill fee or non-refundable milestone."
        ),
        hit_script=(
            "Hi, if the project is canceled after kickoff, I would need a kill fee or payment for work already "
            "scheduled and completed. Could we add cancellation compensation tied to completed work or reserved time?"
        ),
        miss_script=(
            "Hi, if the project is canceled after kickoff, I would need a kill fee or payment for work already "
            "scheduled and completed. Could we add cancellation compensation tied to completed work or reserved time?"
        ),
    ),
    AnalysisRule(
        title="Termination for convenience",
        category=FindingCategory.client_control_risk,
        risk=RiskLevel.negotiable,
        patterns=("terminate at any time", "without cause", "for convenience", "terminate this agreement at any time"),
        penalty=13,
        priority=70,
        fallback_snippet="No easy termination clause detected.",
        hit_explanation=(
            "The client may be able to cancel the work without warning. This should usually "
            "be paired with notice and payment for completed milestones."
        ),
        miss_explanation="There is no obvious no-cause termination clause in the contract text.",
        hit_script=(
            "Hi, I am okay with a termination clause, but it should include written notice "
            "and payment for all work completed up to the termination date."
        ),
        miss_script="No change needed here.",
    ),
    AnalysisRule(
        title="Open-ended scope language",
        category=FindingCategory.scope_risk,
        risk=RiskLevel.negotiable,
        patterns=("as needed", "from time to time", "as requested by client", "as reasonably requested"),
        penalty=11,
        priority=66,
        fallback_snippet="No clearly open-ended scope wording detected.",
        hit_explanation=(
            "Open-ended scope language can expand the job far beyond the original price or timeline if limits are not defined."
        ),
        miss_explanation=(
            "There is no obvious open-ended scope wording driving unlimited tasks or shifting deliverables."
        ),
        hit_script=(
            "Hi, could we tighten the scope wording so deliverables, revision limits, and change requests are clearly defined? That will help both sides avoid confusion later."
        ),
        miss_script="No change needed here.",
    ),
    AnalysisRule(
        title="Defined scope and deliverables",
        category=FindingCategory.scope_risk,
        risk=RiskLevel.safe,
        patterns=("scope of work", "deliverables", "timeline", "milestone"),
        penalty=9,
        priority=52,
        fallback_snippet="Scope details are thin or missing.",
        hit_explanation=(
            "Clear scope language reduces disputes and gives the freelancer a stronger position "
            "when requesting payment or approving revisions."
        ),
        miss_explanation=(
            "The agreement would be safer if it clearly named deliverables, revision limits, and deadlines."
        ),
        hit_script=(
            "Hi, to avoid confusion for both sides, could we add a brief scope section that lists deliverables, "
            "revision limits, and milestone dates?"
        ),
        miss_script=(
            "Hi, to avoid confusion for both sides, could we add a brief scope section that lists deliverables, "
            "revision limits, and milestone dates?"
        ),
    ),
    AnalysisRule(
        title="Revision limits",
        category=FindingCategory.scope_risk,
        risk=RiskLevel.safe,
        patterns=("rounds of revisions", "revision rounds", "two rounds of revisions", "revision limit"),
        penalty=8,
        priority=46,
        fallback_snippet="No revision limits detected.",
        hit_explanation=(
            "Defined revision limits help stop open-ended scope creep and make approval cycles easier to manage."
        ),
        miss_explanation=(
            "Without revision limits, the freelancer may be pulled into unlimited change requests "
            "that were never priced into the project."
        ),
        hit_script=(
            "Hi, could we add a revision limit so the scope stays predictable? For example, two rounds of revisions "
            "are included, with additional changes billed separately."
        ),
        miss_script=(
            "Hi, could we add a revision limit so the scope stays predictable? For example, two rounds of revisions "
            "are included, with additional changes billed separately."
        ),
    ),
    AnalysisRule(
        title="Acceptance criteria clarity",
        category=FindingCategory.scope_risk,
        risk=RiskLevel.safe,
        patterns=("acceptance criteria", "deemed accepted", "approval timeline", "acceptance period"),
        penalty=8,
        priority=48,
        fallback_snippet="No acceptance criteria detected.",
        hit_explanation=(
            "Clear acceptance language helps stop projects from staying open indefinitely after delivery."
        ),
        miss_explanation=(
            "The agreement does not clearly say when work is deemed accepted. That can lead to delays, open-ended revisions, or payment disputes."
        ),
        hit_script=(
            "Hi, could we add a short acceptance clause so deliverables are approved within a defined number of business days unless specific feedback is provided?"
        ),
        miss_script=(
            "Hi, could we add a short acceptance clause so deliverables are approved within a defined number of business days unless specific feedback is provided?"
        ),
    ),
    AnalysisRule(
        title="Confidentiality coverage",
        category=FindingCategory.ip_legal_risk,
        risk=RiskLevel.safe,
        patterns=("confidential information", "confidentiality", "non-disclosure", "nda"),
        penalty=8,
        priority=42,
        fallback_snippet="No confidentiality clause detected.",
        hit_explanation=(
            "A basic confidentiality clause is normal and can protect both sides as long as "
            "it is not overly broad or permanent in an unreasonable way."
        ),
        miss_explanation=(
            "There is no obvious confidentiality language. Many client projects benefit from "
            "a simple mutual confidentiality clause."
        ),
        hit_script=(
            "Hi, if this project involves internal materials or unreleased assets, we can add a simple confidentiality "
            "clause that protects both sides without expanding the rest of the agreement."
        ),
        miss_script=(
            "Hi, if this project involves internal materials or unreleased assets, we can add a simple confidentiality "
            "clause that protects both sides without expanding the rest of the agreement."
        ),
    ),
    AnalysisRule(
        title="Late fee or overdue payment remedy",
        category=FindingCategory.money_risk,
        risk=RiskLevel.safe,
        patterns=("late fee", "interest on overdue", "overdue amount", "past due"),
        penalty=7,
        priority=44,
        fallback_snippet="No overdue-payment remedy detected.",
        hit_explanation=(
            "An overdue-payment clause helps discourage late invoices and gives the freelancer clearer leverage if payment drifts."
        ),
        miss_explanation=(
            "There is no obvious overdue-payment remedy. A simple late-fee or interest clause can improve payment discipline."
        ),
        hit_script=(
            "Hi, could we add a simple overdue-payment clause so delayed invoices are handled clearly? A modest late fee or interest term would work."
        ),
        miss_script=(
            "Hi, could we add a simple overdue-payment clause so delayed invoices are handled clearly? A modest late fee or interest term would work."
        ),
    ),
)
