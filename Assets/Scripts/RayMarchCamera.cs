using UnityEngine;

[ExecuteInEditMode]
public class RayMarchCamera : MonoBehaviour
{
    #region Data
#pragma warning disable 0649

    [SerializeField] Shader _shader;
    [SerializeField] Material _material;
    [SerializeField] Camera _camera;

    [SerializeField] float _rayMarchAccuracy;

#pragma warning restore 0649\
    #endregion

    public Shader Shader => _shader;
    public Material Material => _material;
    public Camera Camera => _camera;

    public float RayMarchAccuracy => _rayMarchAccuracy;

    int PropertyIdCameraFrustrum { get; } = Shader.PropertyToID("_CameraFrustrum");
    int PropertyIdCameraToWorldMartix { get; } = Shader.PropertyToID("_CameraToWorldMartix");
    int PropertyIdCameraMaxDistance { get; } = Shader.PropertyToID("_CameraMaxDistance");
    int PropertyIdRayMarchAccuracy { get; } = Shader.PropertyToID("_RayMarchAccuracy");

    Vector3[] Quadpositions { get; } = new Vector3[]
    {
        new Vector3(0, 0, 3 ),
        new Vector3(1, 0, 2 ),
        new Vector3(1, 1, 1 ),
        new Vector3(0, 1, 0 ),
    };

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Material.SetMatrix(PropertyIdCameraFrustrum, Frustrum);
        Material.SetMatrix(PropertyIdCameraToWorldMartix, Camera.cameraToWorldMatrix);
        Material.SetFloat(PropertyIdCameraMaxDistance, Camera.farClipPlane);
        Material.SetFloat(PropertyIdRayMarchAccuracy, RayMarchAccuracy);

        RenderTexture.active = destination;
        GL.PushMatrix();
        GL.LoadOrtho();
        Material.SetPass(0);
        GL.Begin(GL.QUADS);

        //down left
        GL.MultiTexCoord2(0, 0, 0);
        GL.Vertex(Quadpositions[0]);
        //down right
        GL.MultiTexCoord2(0, 1, 0);
        GL.Vertex(Quadpositions[1]);
        //up right
        GL.MultiTexCoord2(0, 1, 1);
        GL.Vertex(Quadpositions[2]);
        //up left
        GL.MultiTexCoord2(0, 0, 1);
        GL.Vertex(Quadpositions[3]);

        GL.End();
        GL.PopMatrix();
    }

    Matrix4x4 Frustrum
    {
        get
        {
            const float DEG2RAD_HALF = Mathf.Deg2Rad * 0.5f;

            var up = Mathf.Tan(Camera.fieldOfView * DEG2RAD_HALF);
            var right = up * Camera.aspect;

            return new Matrix4x4()
            {
                m00 = -right,
                m01 = up,
                m02 = -1,

                m10 = right,
                m11 = up,
                m12 = -1,

                m20 = right,
                m21 = -up,
                m22 = -1,

                m30 = -right,
                m31 = -up,
                m32 = -1,
            };
        }
    }
}
