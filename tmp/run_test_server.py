"""Spin up the HTTP server with auth mocked, for local endpoint testing."""
import sys
import asyncio
from unittest.mock import AsyncMock, patch

sys.argv = ["server.py", "--http", "--host", "127.0.0.1", "--port", "18765",
            "--base-path", "/paprika"]
sys.path.insert(0, "src")

import os
os.environ["PAPRIKA_USERNAME"] = "fake@example.com"
os.environ["PAPRIKA_PASSWORD"] = "fake"

with patch("paprika_client.PaprikaClient.authenticate", new=AsyncMock(return_value=None)), \
     patch("paprika_client.PaprikaClient.close", new=AsyncMock(return_value=None)):
    import server
    result = asyncio.run(server.main())
    if result:
        import uvicorn
        app, host, port = result
        uvicorn.run(app, host=host, port=port)
