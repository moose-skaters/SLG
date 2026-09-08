from pathlib import Path
import json
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
pairs = {
    "scene_lighting": ("../renderdoc_eid466.png", "unity_eid466.png"),
}
results = {}
for name, (ref_name, actual_name) in pairs.items():
    reference = np.asarray(Image.open(ROOT / ref_name).convert("RGB"), dtype=np.float64)
    actual = np.asarray(Image.open(ROOT / actual_name).convert("RGB"), dtype=np.float64)
    assert reference.shape == actual.shape == (1280, 720, 3)
    mask = reference.max(axis=2) > 0
    actual_mask = actual.max(axis=2) > 0
    delta = np.abs(reference - actual)
    error = delta[mask]
    rmse = float(np.sqrt(np.mean(error**2)))
    results[name] = {
        "resolution": [720, 1280],
        "ground_pixel_count": int(mask.sum()),
        "coverage_mismatch_pixels": int(np.count_nonzero(mask != actual_mask)),
        "rgb_mae_0_255": float(error.mean()),
        "rgb_rmse_0_255": rmse,
        "rgb_max_error_0_255": float(error.max()),
        "rgb_p99_error_0_255": float(np.percentile(error, 99)),
        "exact_ground_rgb_pixel_percent": float(100*np.mean(np.all(delta[mask] == 0, axis=1))),
        "psnr_db_ground": float(20*np.log10(255/rmse)),
    }
(ROOT / "metrics.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
print(json.dumps(results, indent=2))
reference = Image.open(ROOT / "../renderdoc_eid466.png").convert("RGB")
actual = Image.open(ROOT / "unity_eid466.png").convert("RGB")
diff = np.abs(np.asarray(reference,dtype=float)-np.asarray(actual,dtype=float))
Image.fromarray(np.clip(diff*16,0,255).astype(np.uint8)).save(ROOT / "difference_x16.png")
width, height = 432, 768
board = Image.new("RGB", (width*3+64, height+106), (28,30,34))
draw = ImageDraw.Draw(board)
font_path = Path("C:/Windows/Fonts/arial.ttf")
font = ImageFont.truetype(str(font_path), 20) if font_path.exists() else ImageFont.load_default()
small = ImageFont.truetype(str(font_path), 16) if font_path.exists() else ImageFont.load_default()
images = [reference, actual, Image.open(ROOT / "difference_x16.png")]
labels = ["RenderDoc - EID466", "Unity URP - scene lighting", "Absolute RGB difference x16"]
for i, (im, label) in enumerate(zip(images, labels)):
    x = 16 + i*(width+16)
    board.paste(im.resize((width,height),Image.Resampling.LANCZOS), (x,46))
    draw.text((x,14),label,font=font,fill="white")
metric=results["scene_lighting"]
draw.text((16,height+64),f"720 x 1280 | identical coverage | ground RGB MAE {metric['rgb_mae_0_255']:.5f}/255 | raw draw, post-processing disabled",font=small,fill=(206,210,216))
board.save(ROOT / "comparison.png")
