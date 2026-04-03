from contextlib import asynccontextmanager
import logging
import time

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from starlette.responses import JSONResponse

from app.api.routes.analysis import router as analysis_router
from app.core.config import get_settings
from app.core.error_handlers import register_error_handlers
from app.core.logging import configure_logging
from app.core.rate_limit import InMemoryRateLimiter


settings = get_settings()
configure_logging(settings)
logger = logging.getLogger("contract_guardian.app")
rate_limiter = InMemoryRateLimiter(
    max_requests=settings.analyze_rate_limit,
    window_seconds=settings.analyze_rate_window_seconds,
)


@asynccontextmanager
async def lifespan(_: FastAPI):
    logger.info("Starting %s v%s in %s", settings.app_name, settings.app_version, settings.env)
    yield
    logger.info("Stopping %s", settings.app_name)


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="Production-oriented backend service for contract risk analysis.",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def request_timing_middleware(request: Request, call_next):
    if request.url.path == "/api/v1/analyze":
        client_host = request.client.host if request.client else "unknown"
        rate_limit = rate_limiter.check(client_host)
        if not rate_limit.allowed:
            retry_after = str(rate_limit.retry_after_seconds or 1)
            return JSONResponse(
                status_code=429,
                content={
                    "detail": "Rate limit reached. Please wait before sending another analysis request.",
                },
                headers={"Retry-After": retry_after},
            )

    started_at = time.perf_counter()
    response = await call_next(request)
    duration_ms = round((time.perf_counter() - started_at) * 1000, 2)
    response.headers["X-Process-Time-Ms"] = str(duration_ms)
    logger.info("%s %s -> %s in %sms", request.method, request.url.path, response.status_code, duration_ms)
    return response


register_error_handlers(app)


@app.get("/")
def root() -> JSONResponse:
    return JSONResponse(
        {
            "name": settings.app_name,
            "version": settings.app_version,
            "environment": settings.env,
            "status": "online",
        }
    )


@app.get("/health")
def healthcheck() -> dict[str, str | bool]:
    return {
        "status": "ok",
        "environment": settings.env,
        "debug": settings.debug,
        "version": settings.app_version,
    }


app.include_router(analysis_router, prefix="/api/v1", tags=["analysis"])
