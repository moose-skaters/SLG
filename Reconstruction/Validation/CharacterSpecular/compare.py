from pathlib import Path
import json
import numpy as np
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parent
PAIRS=[(1050,1084),(1222,1255),(1282,1313)]
def read(name):return np.asarray(Image.open(ROOT/name).convert("RGB"),dtype=np.float64)
def measure(e):
    return {"rgb_mae_0_255":float(e.mean()),"rgb_rmse_0_255":float(np.sqrt(np.mean(e*e))),
            "max_channel_error_0_255":float(e.max()),"exact_rgb_pixel_percent":float(100*np.mean(np.all(e==0,axis=-1))),
            "pixels_over_5":int(np.count_nonzero(e.max(axis=-1)>5))}
report={"resolution":[720,1280],"scope":"All restored groups; CharacterMetallic discarded only during RenderDoc replay.","default_draws":[],"branch_draws":[],"cubemap_probes":[]}
masks={}
for before,eid in PAIRS:
    for branch,key in [("","default_draws"),("branch_","branch_draws")]:
        r=read(f"renderdoc_{branch}{eid}.png");b=read(f"renderdoc_{branch}{before}.png");u=read(f"unity_{branch}{eid}.png")
        mask=np.any(r!=b,axis=2);error=np.abs(r-u)[mask]
        report[key].append({"eid":eid,"reference_affected_pixels":int(mask.sum()),"metrics":measure(error)})
        if not branch:masks[eid]=mask
base=read("renderdoc_1050.png")
for i in range(6):
    r=read(f"renderdoc_probe_{i}.png");u=read(f"unity_probe_{i}.png");mask=np.any(r!=base,axis=2)
    report["cubemap_probes"].append({"index":i,"rgb_output_packs":"cube R, alpha, B","lod":2.35,"metrics":measure(abs(r-u)[mask])})
reference=read("renderdoc_1523.png");actual=read("unity_final.png");error=abs(reference-actual)
report["full_restored_groups"]=measure(error)
report["final_status"]=json.loads((ROOT/"final_status.json").read_text(encoding="utf-8"))
(ROOT/"metrics.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
print(json.dumps({k:v for k,v in report.items() if k not in ["cubemap_probes","final_status"]},indent=2))
w,h=432,768
board=Image.new("RGB",(3*w+64,h+106),(28,30,34));draw=ImageDraw.Draw(board)
font=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",20);small=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",16)
diff=Image.fromarray(np.clip(error*16,0,255).astype(np.uint8));diff.save(ROOT/"difference_x16.png")
for i,(im,label) in enumerate(zip([Image.fromarray(reference.astype(np.uint8)),Image.fromarray(actual.astype(np.uint8)),diff],["RenderDoc - restored groups","Unity URP - restored groups","Absolute RGB difference x16"])):
    x=16+i*(w+16);board.paste(im.resize((w,h),Image.Resampling.LANCZOS),(x,46));draw.text((x,14),label,font=font,fill="white")
draw.text((16,h+64),"CharacterSpecular per-draw MAE: gun 0 | body 0.216 | hair 0.675 (0-255 RGB) | 720 x 1280 before post-processing",font=small,fill=(215,218,222))
board.save(ROOT/"comparison.png")
crops=Image.new("RGB",(1000,650),(28,30,34));draw=ImageDraw.Draw(crops)
for i,(_,eid) in enumerate(PAIRS):
    ys,xs=np.where(masks[eid]);box=(max(0,int(xs.min())-3),max(0,int(ys.min())-3),min(720,int(xs.max())+4),min(1280,int(ys.max())+4))
    for row,prefix in enumerate(["renderdoc_","unity_"]):
        im=Image.open(ROOT/(prefix+str(eid)+".png")).convert("RGB").crop(box)
        scale=min(310/im.width,255/im.height);im=im.resize((round(im.width*scale),round(im.height*scale)),Image.Resampling.NEAREST)
        x=i*333+(333-im.width)//2;y=row*320+42;crops.paste(im,(x,y));draw.text((i*333+12,row*320+12),("RenderDoc" if row==0 else "Unity")+f" - EID{eid}",font=font,fill="white")
crops.save(ROOT/"character_crop_comparison.png")

