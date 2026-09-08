from pathlib import Path
import json
import numpy as np
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parent
def read(name):return np.asarray(Image.open(ROOT/name).convert("RGB"),dtype=np.float64)
def metrics(e):
    return {"rgb_mae_0_255":float(e.mean()),"rgb_rmse_0_255":float(np.sqrt(np.mean(e*e))),
            "max_channel_error_0_255":float(e.max()),"exact_rgb_pixel_percent":float(100*np.mean(np.all(e==0,axis=-1)))}
before=read("renderdoc_997.png")
reference=read("renderdoc_1016.png")
actual=read("unity_1016.png")
mask=np.any(reference!=before,axis=2)
actual_mask=np.any(actual!=read("unity_997.png"),axis=2)
reverse=read("renderdoc_reversed.png")
reverse_actual=read("unity_reversed.png")
reverse_mask=np.any(reverse!=before,axis=2)
full_ref=read("renderdoc_1523.png")
full_actual=read("unity_1523.png")
report={"resolution":[720,1280],"eid":1016,"scope":"EID1016 changed RGB region in cumulative draw; full image includes Ground, SceneSimple, SceneLit and HeightGradient.",
        "affected_pixels":int(mask.sum()),"changed_region_mask_mismatch":int(np.count_nonzero(mask!=actual_mask)),
        "default":metrics(abs(reference-actual)[mask]),
        "reversed_interval_test":{"parameters":{"start":2,"end":0.5,"power":2,"gradientColor":[0.03,0.12,0.05,0.4],"color":[0.75,0.6,0.8,0.7],"intensity":0.8},"metrics":metrics(abs(reverse-reverse_actual)[reverse_mask])},
        "full_restored_groups":metrics(abs(full_ref-full_actual)),
        "final_status":json.loads((ROOT/"final_status.json").read_text(encoding="utf-8"))}
(ROOT/"metrics.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
print(json.dumps(report,indent=2))
w,h=432,768
board=Image.new("RGB",(3*w+64,h+106),(28,30,34));draw=ImageDraw.Draw(board)
font=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",20);small=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",16)
diff=Image.fromarray(np.clip(abs(full_ref-full_actual)*16,0,255).astype(np.uint8));diff.save(ROOT/"difference_x16.png")
for i,(im,label) in enumerate(zip([Image.fromarray(full_ref.astype(np.uint8)),Image.fromarray(full_actual.astype(np.uint8)),diff],["RenderDoc - restored groups","Unity URP - restored groups","Absolute RGB difference x16"])):
    x=16+i*(w+16);board.paste(im.resize((w,h),Image.Resampling.LANCZOS),(x,46));draw.text((x,14),label,font=font,fill="white")
draw.text((16,h+64),f"EID1016 affected area: {mask.sum()} px | RGB MAE {abs(reference-actual)[mask].mean():.8f}/255 | 720 x 1280 before post-processing",font=small,fill=(212,215,220))
board.save(ROOT/"comparison.png")
ys,xs=np.where(mask);box=(max(0,int(xs.min())-10),max(0,int(ys.min())-10),min(720,int(xs.max())+11),min(1280,int(ys.max())+11))
cropboard=Image.new("RGB",(660,250),(28,30,34));draw=ImageDraw.Draw(cropboard)
for i,(arr,label) in enumerate([(reference,"RenderDoc - EID1016"),(actual,"Unity - HeightGradient")]):
    im=Image.fromarray(arr.astype(np.uint8)).crop(box);scale=min(315/im.width,200/im.height);im=im.resize((round(im.width*scale),round(im.height*scale)),Image.Resampling.NEAREST);cropboard.paste(im,(i*330+8,44));draw.text((i*330+8,12),label,font=font,fill="white")
cropboard.save(ROOT/"gradient_crop_comparison.png")

