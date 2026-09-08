"""Supplement draw extraction with integer/nonfinite uniforms and framebuffer operations."""
import pathlib
import re
import json
from capture_client import call

root=pathlib.Path('D:/Last-Z/Reconstruction')
report=[]
for source in sorted(pathlib.Path('D:/LastZ').glob('*.rdc')):
    frame=re.search(r'frame(\d+)',source.name)[1]
    print('Repairing',frame,flush=True)
    call('open_capture',capture_path=str(source))
    repaired=call('lastz_export_capture',frame=frame,repair_uniforms=True,force_all=True)
    supplement=call('lastz_export_capture',frame=frame,supplement=True)
    entry={'frame':frame,'repaired':len(repaired.get('repaired',[])), 'operations':supplement.get('operations'), 'error':supplement.get('error')}
    report.append(entry)
    (root/'Reports/repair.json').write_text(json.dumps(report,indent=2))
    print(entry,flush=True)
call('open_capture',capture_path='D:/LastZ/Last-Z-frame10105.rdc')
