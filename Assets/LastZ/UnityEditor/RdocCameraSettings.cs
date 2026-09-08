using UnityEngine;
using UnityEngine.Rendering;

// Keep this script outside an Editor-only folder so the restored camera also works in Play mode.
[ExecuteAlways, RequireComponent(typeof(Camera))]
public sealed class RdocCameraSettings : MonoBehaviour
{
    [SerializeField] private Matrix4x4 capturedProjection = Matrix4x4.identity;
    [SerializeField] private int captureWidth = 720;
    [SerializeField] private int captureHeight = 1280;
    [SerializeField] private bool configured;

    public int CaptureWidth => captureWidth;
    public int CaptureHeight => captureHeight;

    public void Configure(Matrix4x4 projection, int width, int height)
    {
        capturedProjection = projection;
        captureWidth = Mathf.Max(1, width);
        captureHeight = Mathf.Max(1, height);
        configured = true;
        Apply();
    }

    private void OnEnable()
    {
        RenderPipelineManager.beginCameraRendering += BeforeCameraRendering;
        Apply();
    }

    private void OnDisable()
    {
        RenderPipelineManager.beginCameraRendering -= BeforeCameraRendering;
        var camera = GetComponent<Camera>();
        if (camera != null)
        {
            camera.ResetProjectionMatrix();
            camera.ResetAspect();
            camera.rect = new Rect(0, 0, 1, 1);
        }
    }

    private void OnValidate() => Apply();
    private void LateUpdate() => Apply();
    private void OnPreCull() => Apply();
    private void BeforeCameraRendering(ScriptableRenderContext context, Camera camera)
    {
        if (camera == GetComponent<Camera>()) Apply();
    }

    public void Apply()
    {
        if (!configured) return;
        var camera = GetComponent<Camera>();
        if (camera == null) return;
        float aspect = (float)captureWidth / captureHeight;
        float outputAspect = camera.targetTexture != null
            ? (float)camera.targetTexture.width / camera.targetTexture.height
            : (float)Mathf.Max(1, Screen.width) / Mathf.Max(1, Screen.height);
        float width = Mathf.Min(1f, aspect / outputAspect);
        float height = Mathf.Min(1f, outputAspect / aspect);
        camera.rect = new Rect((1f - width) * 0.5f, (1f - height) * 0.5f, width, height);
        camera.aspect = aspect;
        camera.projectionMatrix = capturedProjection;
    }
}
