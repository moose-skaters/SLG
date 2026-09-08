from pathlib import Path
import json
import numpy as np
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parent
def read(name):return np.asarray(Image.open(ROOT/name).convert("RGB"),dtype=np.float64)
def measure(e):
    return {"rgb_mae_0_255":float(e.mean()),"rgb_rmse_0_255":float(np.sqrt(np.mean(e*e))),
            "max_channel_error_0_255":float(e.max()),"exact_rgb_pixel_percent":float(100*np.mean(np.all(e==0,axis=-1))),
            "pixels_with_error_over_5":int(np.count_nonzero(e.max(axis=-1)>5))}
report={"resolution":[720,1280],"scope":"Original RenderDoc color target through EID1523, with no draws disabled; Unity includes all six restored shader families.","default":[],"branches":{}}
base=read("renderdoc_1084.png");masks={}
for case,key in [("","default"),("metal_reflection_rim_","metal_reflection_rim"),("uv1_emission_map_","uv1_emission_map")]:
    previous=base
    results=[]
    for eid in [1122,1137]:
        r=read(f"renderdoc_{case}{eid}.png");u=read(f"unity_{case}{eid}.png");m=np.any(r!=previous,axis=2)
        results.append({"eid":eid,"affected_pixels":int(m.sum()),"metrics":measure(abs(r-u)[m])})
        if not case:masks[eid]=m
        previous=r
    if case:report["branches"][key]={"configuration":json.loads((ROOT/(key+".json")).read_text(encoding="utf-8")),"draws":results}
    else:report["default"]=results
reference=read("renderdoc_1523.png");actual=read("unity_final.png");error=abs(reference-actual)
report["full_range_through_1523"]=measure(error)
report["final_status"]=json.loads((ROOT/"final_status.json").read_text(encoding="utf-8"))
(ROOT/"metrics.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
print(json.dumps({k:v for k,v in report.items() if k not in ["branches","final_status"]},indent=2))
w,h=432,768
board=Image.new("RGB",(3*w+64,h+106),(28,30,34));draw=ImageDraw.Draw(board)
font=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",20);small=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",16)
diff=Image.fromarray(np.clip(error*16,0,255).astype(np.uint8));diff.save(ROOT/"difference_x16.png")
for i,(im,label) in enumerate(zip([Image.fromarray(reference.astype(np.uint8)),Image.fromarray(actual.astype(np.uint8)),diff],["RenderDoc - through EID1523","Unity URP - all six shaders","Absolute RGB difference x16"])):
    x=16+i*(w+16);board.paste(im.resize((w,h),Image.Resampling.LANCZOS),(x,46));draw.text((x,14),label,font=font,fill="white")
draw.text((16,h+64),f"720 x 1280 | no reference draws disabled | full RGB MAE {error.mean():.5f}/255 | before post-processing",font=small,fill=(213,216,220))
board.save(ROOT/"comparison.png")
cropboard=Image.new("RGB",(1000,900),(28,30,34));draw=ImageDraw.Draw(cropboard)
for col,eid in enumerate([1122,1137]):
    ys,xs=np.where(masks[eid]);box=(max(0,int(xs.min())-5),max(0,int(ys.min())-5),min(720,int(xs.max())+6),min(1280,int(ys.max())+6))
    for row,prefix in enumerate(["renderdoc_","unity_"]):
        im=Image.open(ROOT/(prefix+str(eid)+".png")).convert("RGB").crop(box);scale=min(480/im.width,390/im.height);im=im.resize((round(im.width*scale),round(im.height*scale)),Image.Resampling.NEAREST)
        x=col*500+(500-im.width)//2;y=row*450+44;cropboard.paste(im,(x,y));draw.text((col*500+12,row*450+12),("RenderDoc" if row==0 else "Unity")+f" - EID{eid}",font=font,fill="white")
cropboard.save(ROOT/"monster_crop_comparison.png")

