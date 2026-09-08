from pathlib import Path
import json
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
EIDS = [496,505,514,523,532,541,1041,1050,1453,1460,1467]
def read(name):
    return np.asarray(Image.open(ROOT/name).convert("RGB"),dtype=np.float64)
def metrics(error):
    if error.size == 0:
        return None
    return {"rgb_mae_0_255": float(error.mean()),
            "rgb_rmse_0_255": float(np.sqrt(np.mean(error**2))),
            "rgb_max_error_0_255": float(error.max()),
            "exact_rgb_pixel_percent": float(100*np.mean(np.all(error==0,axis=1)))}
base = read("renderdoc_ground.png")
previous_reference = base
previous_unity = read("unity_466.png")
draws = []
for eid in EIDS:
    reference = read(f"renderdoc_{eid}.png")
    actual = read(f"unity_{eid}.png")
    touched = np.any(reference != previous_reference, axis=2)
    changed_actual = np.any(actual != previous_unity, axis=2)
    draws.append({"eid": eid, "reference_changed_pixels": int(touched.sum()),
                  "unity_changed_pixels": int(changed_actual.sum()),
                  "changed_region_mask_mismatch": int(np.count_nonzero(touched != changed_actual)),
                  "rgb_error_on_reference_changed_pixels": metrics(np.abs(reference-actual)[touched]),
                  "no_rgb_change_in_either": bool(not touched.any() and not changed_actual.any())})
    previous_reference = reference
    previous_unity = actual
mask = np.any(reference != base, axis=2)
final_error = np.abs(reference-actual)
branch_reference = read("renderdoc_alpha_shadow.png")
branch_actual = read("unity_alpha_shadow.png")
branch_mask = np.any(branch_reference != base, axis=2)
report = {
    "resolution": [720,1280],
    "comparison_scope": "Ground + SceneSimple; other shader families discarded only during reference replay.",
    "default_scene_simple_changed_pixel_count": int(mask.sum()),
    "default_scene_simple_metrics": metrics(final_error[mask]),
    "ground_and_scene_simple_full_frame_rgb_mae_0_255": float(final_error.mean()),
    "draws": draws,
    "alpha_from_red_and_plane_shadow_branch": {
        "parameters": {"_AlphaIsR":1,"_Color":[0.65,0.8,0.9,0.7],"_BlurPlaneShadowOn":1},
        "changed_pixel_count": int(branch_mask.sum()),
        "metrics": metrics(np.abs(branch_reference-branch_actual)[branch_mask])
    },
    "geometry": json.loads((ROOT/"geometry_validation.json").read_text(encoding="utf-8")),
}
(ROOT/"metrics.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
print(json.dumps({k:v for k,v in report.items() if k not in ["draws","geometry"]},indent=2))
Image.fromarray(np.clip(final_error*16,0,255).astype(np.uint8)).save(ROOT/"difference_x16.png")
w,h=432,768
board=Image.new("RGB",(w*3+64,h+106),(28,30,34))
draw=ImageDraw.Draw(board)
font=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",20)
small=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",16)
images=[Image.fromarray(reference.astype(np.uint8)),Image.fromarray(actual.astype(np.uint8)),Image.open(ROOT/"difference_x16.png")]
labels=["RenderDoc - Ground + Simple","Unity URP - Ground + Simple","Absolute RGB difference x16"]
for i,(im,label) in enumerate(zip(images,labels)):
    x=16+i*(w+16);board.paste(im.resize((w,h),Image.Resampling.LANCZOS),(x,46))
    draw.text((x,14),label,font=font,fill="white")
draw.text((16,h+64),f"720 x 1280 | SceneSimple affected area: {mask.sum()} px | RGB MAE {final_error[mask].mean():.6f}/255 | isolated shader families",font=small,fill=(206,210,216))
board.save(ROOT/"comparison.png")

