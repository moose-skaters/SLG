using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.Universal.Internal;

/// <summary>
/// Recreates Frame4414 EID1550: copy the completed first scene pass depth at half resolution.
/// Ground / EID496..1523 use ordered queues 2000..2083; Pass6 uses ordered queues 3100+.
/// Original blend and depth-write states stay on the materials. The queue boundary only
/// provides a scheduling point between the two captured colour passes.
/// </summary>
public sealed class FogDepthSnapshotFeature : ScriptableRendererFeature
{
    [SerializeField] private Shader depthCopyShader;

    private Material depthCopyMaterial;
    private FogDepthSnapshotPass depthSnapshotPass;

    public override void Create()
    {
        depthSnapshotPass?.Dispose();
        CoreUtils.Destroy(depthCopyMaterial);

        if (depthCopyShader == null)
            depthCopyShader = Shader.Find("Hidden/LastZ/FogDepthSnapshot");
        if (depthCopyShader == null)
            return;

        depthCopyMaterial = CoreUtils.CreateEngineMaterial(depthCopyShader);
        depthSnapshotPass = new FogDepthSnapshotPass(depthCopyMaterial);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (depthSnapshotPass == null || renderingData.cameraData.cameraType == CameraType.Preview)
            return;

        // This declares the need for a readable depth attachment. It does not make fog use
        // URP's earlier _CameraDepthTexture; our pass copies the current attachment itself.
        depthSnapshotPass.ConfigureInput(ScriptableRenderPassInput.Depth);
        renderer.EnqueuePass(depthSnapshotPass);
    }

    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
    {
        if (depthSnapshotPass == null || renderingData.cameraData.cameraType == CameraType.Preview)
            return;

        // URP14 creates camera targets after AddRenderPasses; access them only here.
        depthSnapshotPass.SetSource(renderer.cameraDepthTargetHandle);
    }

    protected override void Dispose(bool disposing)
    {
        depthSnapshotPass?.Dispose();
        depthSnapshotPass = null;
        CoreUtils.Destroy(depthCopyMaterial);
        depthCopyMaterial = null;
    }

    private sealed class FogDepthSnapshotPass : CopyDepthPass
    {
        private static readonly int SnapshotId = Shader.PropertyToID("_FogSceneDepthTexture");
        private static readonly int SnapshotTexelSizeId = Shader.PropertyToID("_FogSceneDepthTexture_TexelSize");
        private RTHandle sourceDepth;
        private RTHandle snapshotDepth;

        public FogDepthSnapshotPass(Material material)
            : base(RenderPassEvent.BeforeRenderingTransparents, material, copyToDepth: true)
        {
            profilingSampler = new ProfilingSampler("EID1550 Fog Depth Snapshot");
        }

        public void SetSource(RTHandle source)
        {
            sourceDepth = source;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.width = Mathf.Max(1, (descriptor.width + 1) / 2);
            descriptor.height = Mathf.Max(1, (descriptor.height + 1) / 2);
            descriptor.msaaSamples = 1;
            descriptor.bindMS = false;
            descriptor.graphicsFormat = GraphicsFormat.None;
            descriptor.depthStencilFormat = GraphicsFormat.D32_SFloat;
            descriptor.useMipMap = false;
            descriptor.autoGenerateMips = false;
            descriptor.enableRandomWrite = false;

            // Original Texture30002 is a 360x640 depth texture, nearest sampling + clamp.
            // Store native device depth. FogOfWar decodes it using the current camera's
            // _ZBufferParams, so OpenGL and reversed-Z D3D use the same eye-distance formula.
            RenderingUtils.ReAllocateIfNeeded(ref snapshotDepth, descriptor,
                FilterMode.Point, TextureWrapMode.Clamp, name: "_FogSceneDepthTexture");
            Setup(sourceDepth, snapshotDepth);
            base.OnCameraSetup(cmd, ref renderingData);
            cmd.SetGlobalTexture(SnapshotId, snapshotDepth.nameID);
            cmd.SetGlobalVector(SnapshotTexelSizeId, new Vector4(
                1f / descriptor.width, 1f / descriptor.height, descriptor.width, descriptor.height));
        }

        public void Dispose()
        {
            snapshotDepth?.Release();
            snapshotDepth = null;
        }
    }
}
