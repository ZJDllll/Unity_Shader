using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
public class NDCCamera : MonoBehaviour
{
    [HideInInspector]
    public Vector3 ScannerOrigin;
    [HideInInspector]
    public float ScanDistance = 0;

	public float temp1;
	public float temp2;

    bool _scanning;

	Camera _camera;
    [SerializeField]
    Material ndcMaterial;
    // Start is called before the first frame update
    void Start()
    {
		_camera = GetComponent<Camera>();
        ScanDistance = 0;
    }

	void Update()
	{

		if (_scanning)
		{
			ScanDistance += Time.deltaTime * 10;
			//foreach (Scannable s in _scannables)
			//{
			//	if (Vector3.Distance(ScannerOrigin.position, s.transform.position) <= ScanDistance)
			//		s.Ping();
			//}
		}

		if (Input.GetKeyDown(KeyCode.C))
		{
			_scanning = true;
			ScanDistance = 0;
			ScannerOrigin = Vector3.zero;
		}

		if (Input.GetMouseButtonDown(0))
		{
			Ray ray = _camera.ScreenPointToRay(Input.mousePosition);
			RaycastHit hit;

			if (Physics.Raycast(ray, out hit))
			{
				_scanning = true;
				ScanDistance = 0;
				ScannerOrigin = hit.point;
			}
		}
	}

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (ndcMaterial!=null)
        {
            var cam = Camera.current;
            var _InvProjection = cam.projectionMatrix.inverse;
            var _ViewToWorld = cam.cameraToWorldMatrix;
            ndcMaterial.SetMatrix("_InvProjection", _InvProjection);
            ndcMaterial.SetMatrix("_ViewToWorld", _ViewToWorld);
			ndcMaterial.SetVector("_WorldSpaceScannerPos", ScannerOrigin);
			ndcMaterial.SetFloat("_ScanDistance", ScanDistance);

			ndcMaterial.SetFloat("_Temp1", temp1);
			ndcMaterial.SetFloat("_Temp2", temp2);


			Graphics.Blit(source, destination, ndcMaterial);
        }
    }
}
