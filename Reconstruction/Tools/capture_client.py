"""Serial client for the installed RenderDoc MCP file IPC transport.

Uses the same live replay controller as MCP tools. Do not run two clients at once.
"""
import argparse
import json
import os
import pathlib
import tempfile
import time
import uuid

IPC = pathlib.Path(tempfile.gettempdir()) / 'renderdoc_mcp'


def call(method, **params):
    request_id = str(uuid.uuid4())
    request = IPC / 'request.json'
    response = IPC / 'response.json'
    if request.exists() or (IPC / 'lock').exists():
        raise RuntimeError('MCP bridge busy; refusing concurrent request')
    if response.exists():
        response.unlink()
    temp = IPC / ('lastz-' + request_id + '.tmp')
    temp.write_text(json.dumps({'id': request_id, 'method': method, 'params': params}), encoding='utf-8')
    os.replace(str(temp), str(request))
    end = time.monotonic() + 900
    while time.monotonic() < end:
        if response.exists():
            try:
                data = json.loads(response.read_text(encoding='utf-8'))
            except (PermissionError, json.JSONDecodeError):
                time.sleep(0.02)
                continue
            if data.get('id') != request_id:
                raise RuntimeError('Unexpected response: another client is active')
            response.unlink()
            if 'error' in data:
                raise RuntimeError(data['error'])
            return data['result']
        time.sleep(0.02)
    raise TimeoutError(method)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('method')
    parser.add_argument('params', nargs='?', default='{}')
    args = parser.parse_args()
    print(json.dumps(call(args.method, **json.loads(args.params)), ensure_ascii=False))
