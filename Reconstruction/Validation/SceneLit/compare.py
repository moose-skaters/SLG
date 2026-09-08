from pathlib import Path
import json
import numpy as np
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parent
rows=json.loads((ROOT/"source_materials.json").read_text(encoding="utf-8"))
lit_ids={r["eid"] for r in rows}
ids=sorted(int(f.stem.split("_")[1]) for f in ROOT.glob("renderdoc_[0-9]*.png"))
def read(name):
    return np.asarray(Image.open(ROOT/name).convert("RGB"),dtype=np.float64)
def measure(error):
    if not error.size: return None
    return {"rgb_mae_0_255":float(error.mean()),"rgb_rmse_0_255":float(np.sqrt(np.mean(error**2))),
            "max_channel_error_0_255":float(error.max()),"p99_channel_error_0_255":float(np.percentile(error,99)),
            "exact_rgb_pixel_percent":float(100*np.mean(np.all(error==0,axis=-1))),
            "pixels_with_channel_error_over_20":int(np.count_nonzero(error.max(axis=-1)>20))}
previous_ref=None
previous_actual=None
union=np.zeros((1280,720),dtype=bool)
draws=[]
for eid in ids:
    r=read(f"renderdoc_{eid}.png")
    u=read(f"unity_{eid}.png")
    if previous_ref is not None and eid in lit_ids:
        mask=np.any(r!=previous_ref,axis=2)
        actual_mask=np.any(u!=previous_actual,axis=2)
        union|=mask
        draws.append({"eid":eid,"reference_changed_pixels":int(mask.sum()),
                      "unity_changed_pixels":int(actual_mask.sum()),"change_mask_mismatch":int(np.count_nonzero(mask!=actual_mask)),
                      "metrics_on_reference_changed_pixels":measure(np.abs(r-u)[mask])})
    previous_ref=r
    previous_actual=u
reference=read("renderdoc_1523.png")
actual=read("unity_final.png")
error=np.abs(reference-actual)
report={"resolution":[720,1280],
        "scope":"Ground + SceneSimple + SceneLit; other 4 compiled programs discarded only for reference replay.",
        "scene_lit_draw_count":66,"scene_lit_touched_union_pixels":int(union.sum()),
        "final_metrics_on_scene_lit_touched_union":measure(error[union]),
        "final_full_frame_metrics":measure(error),"draws":draws,
        "branch_tests":{},
        "geometry":json.loads((ROOT/"geometry_validation.json").read_text(encoding="utf-8")),
        "final_status":json.loads((ROOT/"final_status.json").read_text(encoding="utf-8"))}
for case in ["lighting_fresnel_emission","sheet_alpha_height"]:
    r=read("renderdoc_"+case+".png")
    u=read("unity_"+case+".png")
    report["branch_tests"][case]={"parameters":json.loads((ROOT/(case+".json")).read_text(encoding="utf-8")),
                                 "full_frame_metrics":measure(np.abs(r-u))}
(ROOT/"metrics.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
print(json.dumps({k:v for k,v in report.items() if k not in ["draws","geometry","branch_tests"]},indent=2))
print("invisible_lit_draws",[d["eid"] for d in draws if not d["reference_changed_pixels"]])
Image.fromarray(np.clip(error*16,0,255).astype(np.uint8)).save(ROOT/"difference_x16.png")
w,h=432,768
board=Image.new("RGB",(w*3+64,h+106),(28,30,34));draw=ImageDraw.Draw(board)
font=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",20);small=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",16)
images=[Image.fromarray(reference.astype(np.uint8)),Image.fromarray(actual.astype(np.uint8)),Image.open(ROOT/"difference_x16.png")]
for i,(im,label) in enumerate(zip(images,["RenderDoc - restored groups","Unity URP - restored groups","Absolute RGB difference x16"])):
    x=16+i*(w+16);board.paste(im.resize((w,h),Image.Resampling.LANCZOS),(x,46));draw.text((x,14),label,font=font,fill="white")
draw.text((16,h+64),f"720 x 1280 | full RGB MAE {error.mean():.5f}/255 | SceneLit touched-union MAE {error[union].mean():.5f}/255 | before post-processing",font=small,fill=(210,213,218))
board.save(ROOT/"comparison.png")

