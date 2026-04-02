from dataclasses import dataclass

from app.schemas.analysis import FindingCategory, RiskLevel


@dataclass(frozen=True)
class AnalysisRule:
    title: str
    category: FindingCategory
    risk: RiskLevel
    patterns: tuple[str, ...]
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
        patterns=("indemnify", "hold harmless", "all claims"),
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
        title="Exclusivity or non-compete restriction",
        category=FindingCategory.client_control_risk,
        risk=RiskLevel.danger,
        patterns=(
            "exclusive basis",
            "non-compete",
            "shall not provide services to any competitor",
            "may not work with competing businesses",
        ),
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
        title="Late payment window",
        category=FindingCategory.money_risk,
        risk=RiskLevel.negotiable,
        patterns=("net 60", "net-60", "60 days", "within sixty"),
        fallback_snippet="No extended payment window detected.",
        hit_explanation=(
            "A 60-day payment cycle can create cash flow pressure and is usually worth "
            "negotiating down to net 15 or net 30."
        ),
        miss_explanation="The payment timing does not show a clearly delayed payout pattern.",
        hit_script=(
            "Hi, could we revise the payment term from net 60 to net 15 or net 30? "
            "That would make the project workable on my side while keeping delivery timelines unchanged."
        ),
        miss_script="No change needed here.",
    ),
    AnalysisRule(
        title="Missing upfront deposit",
        category=FindingCategory.money_risk,
        risk=RiskLevel.negotiable,
        patterns=("50% upfront", "advance payment", "deposit", "retainer"),
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
        title="Full IP transfer",
        category=FindingCategory.ip_legal_risk,
        risk=RiskLevel.danger,
        patterns=("work made for hire", "all rights title and interest", "assigns all intellectual property"),
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
        title="Termination for convenience",
        category=FindingCategory.client_control_risk,
        risk=RiskLevel.negotiable,
        patterns=("terminate at any time", "without cause", "for convenience"),
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
        title="No kill fee or cancellation payment",
        category=FindingCategory.money_risk,
        risk=RiskLevel.negotiable,
        patterns=("kill fee", "cancellation fee", "payment for work performed", "non-refundable"),
        fallback_snippet="No kill-fee protection detected.",
        hit_explanation=(
            "The contract includes at least some payment protection if the project is canceled "
            "after work has already been scheduled or started."
        ),
        miss_explanation=(
            "If the client cancels mid-project, the freelancer may lose reserved time and partial "
            "work value without a kill fee or non-refundable milestone."
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
        title="Confidentiality coverage",
        category=FindingCategory.ip_legal_risk,
        risk=RiskLevel.safe,
        patterns=("confidential information", "confidentiality", "non-disclosure", "nda"),
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
        title="Revision limits",
        category=FindingCategory.scope_risk,
        risk=RiskLevel.safe,
        patterns=("rounds of revisions", "revision rounds", "two rounds of revisions", "revision limit"),
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
        title="Defined scope and deliverables",
        category=FindingCategory.scope_risk,
        risk=RiskLevel.safe,
        patterns=("scope of work", "deliverables", "timeline", "milestone"),
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
)
