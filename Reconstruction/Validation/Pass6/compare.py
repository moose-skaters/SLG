from pathlib import Path
import json
import numpy as np
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parent
STAGES=[1523,1600,1912,2101,3047,3081,3106,3129,3151,3176,3213,3253,3331,3356,3369,3479]
def read(name):return np.asarray(Image.open(ROOT/name).convert('RGB'),dtype=np.float64)
def metrics(error):
    return {'mae_0_255':float(error.mean()),'rmse_0_255':float(np.sqrt(np.mean(error**2))),
            'max_channel_error_0_255':float(error.max()),
            'exact_rgb_pixel_percent':float(100*np.mean(np.all(error==0,axis=-1))),
            'pixels_any_channel_over_5':int(np.count_nonzero(error.max(axis=-1)>5))}
ref=read('renderdoc_3479.png');actual=read('unity_final.png');error=abs(ref-actual)
first=read('renderdoc_1523.png');scope=np.any(ref!=first,axis=2)
result={'resolution':[720,1280],
        'scope':'RenderDoc original RT through EID3479 vs Unity, no reference draws hidden. RGB8 before post-processing. Background included in full-frame metric.',
        'full_frame':metrics(error),
        'pass6_changed_region_pixels':int(scope.sum()),
        'pass6_changed_region':metrics(error[scope]),
        'stage_checkpoints':[],
        'branch_tests':[],
        'audit':json.loads((ROOT/'final_audit.json').read_text(encoding='utf-8')),
        'depth_snapshot':json.loads((ROOT/'depth_snapshot_info.json').read_text(encoding='utf-8'))}
for eid in STAGES:
    r=read(f'renderdoc_{eid}.png');u=read(f'unity_{eid}.png')
    result['stage_checkpoints'].append({'eid':eid,'metrics':metrics(abs(r-u))})
for name in ['general_branches','particle_flow_branches','fog_branches']:
    config=json.loads((ROOT/(name+'.json')).read_text(encoding='utf-8'));checks=[]
    for eid in config['stages']:
        r=read(f'renderdoc_{name}_{eid}.png');u=read(f'unity_{name}_{eid}.png');baseline=read(f'renderdoc_{eid}.png')
        changed=np.any(r!=baseline,axis=2)
        checks.append({'eid':eid,'test_changed_pixels':int(changed.sum()),'full_frame':metrics(abs(r-u)),
                       'test_changed_region':metrics(abs(r-u)[changed]) if changed.any() else None})
    result['branch_tests'].append({'name':name,'configuration':config,'checks':checks})
(ROOT/'metrics.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in result.items() if k not in ['audit','stage_checkpoints','branch_tests']},indent=2))
w,h=432,768
board=Image.new('RGB',(3*w+64,h+106),(28,30,34));draw=ImageDraw.Draw(board)
font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',20);small=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',16)
diff=Image.fromarray(np.clip(error*16,0,255).astype(np.uint8));diff.save(ROOT/'difference_x16.png')
for i,(im,label) in enumerate(zip([Image.fromarray(ref.astype(np.uint8)),Image.fromarray(actual.astype(np.uint8)),diff],['RenderDoc - through EID3479','Unity - restored scene + VFX','Absolute RGB difference x16'])):
    x=16+i*(w+16);board.paste(im.resize((w,h),Image.Resampling.LANCZOS),(x,46));draw.text((x,14),label,font=font,fill='white')
draw.text((16,h+64),f'720 x 1280 | RGB MAE {error.mean():.5f}/255 | no reference draws disabled | before post-processing',font=small,fill=(215,218,222))
board.save(ROOT/'comparison.png')

