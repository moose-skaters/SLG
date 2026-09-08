"""Resume-safe, serial extraction of every source capture using the live MCP bridge."""
import json
import pathlib
import re
import time
from capture_client import call

ROOT = pathlib.Path('D:/Last-Z/Reconstruction')
sources = sorted(pathlib.Path('D:/LastZ').glob('*.rdc'), key=lambda p: int(re.search(r'frame(\d+)', p.name)[1]))
report = []
for source in sources:
    frame = re.search(r'frame(\d+)', source.name)[1]
    start = time.time()
    print('Opening frame', frame, flush=True)
    status = call('get_capture_status')
    if status.get('filename', '').replace('\\', '/') != str(source).replace('\\', '/'):
        opened = call('open_capture', capture_path=str(source))
        print('Open result', opened, flush=True)
    summary = call('get_frame_summary')
    ROOT.joinpath('Raw', 'Frame_' + frame).mkdir(parents=True, exist_ok=True)
    ROOT.joinpath('Raw', 'Frame_' + frame, 'summary.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
    actions = call('get_draw_calls', only_actions=True, flags_filter=['Drawcall'])['actions']
    errors = []
    for offset in range(0, len(actions), 80):
        batch = actions[offset:offset + 80]
        response = call('lastz_export_capture', frame=frame, first=batch[0]['event_id'], last=batch[-1]['event_id'], reference=offset == 0)
        errors.extend(response.get('errors', []))
        print('Frame', frame, 'draws', min(offset + 80, len(actions)), '/', len(actions), 'new', response.get('exported'), 'errors', len(response.get('errors', [])), flush=True)
        if response.get('errors'):
            print(json.dumps(response['errors'])[:2000], flush=True)
    entry = {'frame': frame, 'draws': len(actions), 'errors': errors, 'seconds': time.time() - start}
    report.append(entry)
    ROOT.joinpath('Reports').mkdir(exist_ok=True)
    ROOT.joinpath('Reports', 'extraction.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    print('Finished', frame, round(entry['seconds'], 1), 'seconds', flush=True)
