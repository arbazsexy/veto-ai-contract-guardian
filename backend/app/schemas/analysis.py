from datetime import datetime
from enum import Enum

from pydantic import BaseModel, Field


class InputQuality(str, Enum):
    typed = "typed"
    digital_pdf = "digital_pdf"
    ocr_pdf = "ocr_pdf"


class RiskLevel(str, Enum):
    danger = "danger"
    negotiable = "negotiable"
    safe = "safe"


class FindingConfidence(str, Enum):
    high = "high"
    medium = "medium"
    review = "review"


class FindingCategory(str, Enum):
    money_risk = "money_risk"
    ip_legal_risk = "ip_legal_risk"
    scope_risk = "scope_risk"
    client_control_risk = "client_control_risk"


class Verdict(str, Enum):
    signable = "signable"
    signable_after_edits = "signable_after_edits"
    high_risk = "high_risk"


class AnalysisRequest(BaseModel):
    contract_text: str = Field(..., min_length=1)
    document_label: str = Field(default="Untitled contract")
    input_quality: InputQuality = InputQuality.typed
    locale: str = Field(default="en-IN")


class Finding(BaseModel):
    title: str
    category: FindingCategory
    risk: RiskLevel
    confidence: FindingConfidence
    matched_snippet: str
    explanation: str
    negotiation_script: str


class AnalysisResponse(BaseModel):
    document_label: str
    analyzed_at: datetime
    input_quality: InputQuality
    verdict: Verdict
    guardian_score: int
    top_issue: str
    red_count: int
    orange_count: int
    green_count: int
    summary: str
    findings: list[Finding]
