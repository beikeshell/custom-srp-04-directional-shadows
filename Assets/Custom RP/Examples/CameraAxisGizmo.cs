using UnityEngine;

[ExecuteAlways]
public class CameraAxisGizmo : MonoBehaviour
{
    public float axisLength = 2.0f;

    void OnDrawGizmos()
    {
        if (Camera.main == null) return;
        Transform camTrans = Camera.main.transform;
        Vector3 pos = camTrans.position;

        // X轴：红色
        Gizmos.color = Color.red;
        Gizmos.DrawLine(pos, pos + camTrans.right * axisLength);

        // Y轴：绿色
        Gizmos.color = Color.green;
        Gizmos.DrawLine(pos, pos + camTrans.up * axisLength);

        // Z轴：蓝色
        Gizmos.color = Color.blue;
        Gizmos.DrawLine(pos, pos + camTrans.forward * axisLength);
    }
}