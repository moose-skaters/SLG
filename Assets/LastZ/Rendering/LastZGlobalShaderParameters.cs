using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// Supplies the shared game shader uniforms recovered from RenderDoc.
/// The original GLSL places these values in $Globals rather than in
/// UnityPerMaterial. Keeping them on one scene component makes the same
/// values available to every restored material and avoids per-material drift.
/// </summary>
[ExecuteAlways]
[DisallowMultipleComponent]
[DefaultExecutionOrder(-10000)]
public sealed class LastZGlobalShaderParameters : MonoBehaviour
{
    [Header("场景与角色光照")]
    [SerializeField] private Vector4 lightColor1 =
        new Vector4(0.999986529f, 0.999987841f, 0.999995470f, 1f);
    [SerializeField] private float lightIntensity1 = 1.003173828f;
    [SerializeField] private Vector4 lightColor2 =
        new Vector4(0.999990225f, 0.999992967f, 1f, 1f);
    [SerializeField] private float lightIntensity2 = 1.000047922f;

    [Header("昼夜与共享参数")]
    [Range(0f, 1f)] [SerializeField] private float timeline = 1f;
    [SerializeField] private Vector4 fogWorldParams = new Vector4(0f, 0f, 0.0025f, 1f);
    [SerializeField] private float flyOffset = 0f;

    private static readonly int LightColor1Id = Shader.PropertyToID("_LightColor1");
    private static readonly int LightIntensity1Id = Shader.PropertyToID("_LightIntensity1");
    private static readonly int LightColor2Id = Shader.PropertyToID("_LightColor2");
    private static readonly int LightIntensity2Id = Shader.PropertyToID("_LightIntensity2");
    private static readonly int TimelineId = Shader.PropertyToID("_Timeline");
    private static readonly int FogWorldParamsId = Shader.PropertyToID("_Params");
    private static readonly int FlyOffsetId = Shader.PropertyToID("_FlyOffset");

    private void OnEnable()
    {
        RenderPipelineManager.beginCameraRendering += BeforeCameraRendering;
        Apply();
    }

    private void OnDisable()
    {
        RenderPipelineManager.beginCameraRendering -= BeforeCameraRendering;
    }

    private void OnValidate() => Apply();
    private void LateUpdate() => Apply();

    private void BeforeCameraRendering(ScriptableRenderContext context, Camera camera) => Apply();

    public void Apply()
    {
        Shader.SetGlobalVector(LightColor1Id, lightColor1);
        Shader.SetGlobalFloat(LightIntensity1Id, lightIntensity1);
        Shader.SetGlobalVector(LightColor2Id, lightColor2);
        Shader.SetGlobalFloat(LightIntensity2Id, lightIntensity2);
        Shader.SetGlobalFloat(TimelineId, timeline);
        Shader.SetGlobalVector(FogWorldParamsId, fogWorldParams);
        Shader.SetGlobalFloat(FlyOffsetId, flyOffset);
    }
}
