from typing import Optional
import uvicorn
from fastapi import FastAPI, Request
from subprocess import call

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.post("/run/{keyword}/{t_id}/{w_id}/")
async def run_robot(request: Request, keyword, t_id, w_id):
    config = ""
    client_host = request.client.host

    try:
        json_body = await request.json()
        config = " ".join([
            f"--variable {k}:{v}" for k, v in json_body.items()
        ])
        print(config)
    except Exception:
        pass
    print(t_id)
    print(keyword)

    command = f"rcc task run --task {keyword} -- --listener workspace_listener.py --variable id_t:{t_id} {config} tasks.robot"

    call(
        command,
        shell=True,
    )

    return {}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
