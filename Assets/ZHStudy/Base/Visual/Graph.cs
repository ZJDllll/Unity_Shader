using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Graph : MonoBehaviour
{
    public Transform pointPrefab;
    [SerializeField,Range(10,100)]
    int resolution=10;

    [SerializeField]
    FunctionLibrary.FunctionName function = default;

    //[SerializeField, Range(0.1f, 1f)]
    //float r1 = 0.75f;

    //[SerializeField, Range(0.1f, 1f)]
    //float r2 = 0.25f;

    Transform[] points;
    // Start is called before the first frame update
    private void Awake()
    {
        points = new Transform[resolution * resolution];
        float step = 2f / resolution;
        Vector3 scale = Vector3.one * step;
        for (int i = 0,x=0,z=0; i < points.Length; i++,x++)
        {

            Transform point = Instantiate(pointPrefab);
            point.localScale = scale;
            point.SetParent(transform,false);
            points[i] = point;
        }
    }

    private void Update()
    {
        //FunctionLibrary.r1 = this.r1;
        //FunctionLibrary.r2 = this.r2;

        FunctionLibrary.Function f = FunctionLibrary.GetFunction((int)function);
        float time = Time.time;
        float step = 2f / resolution;
        float v = 0.5f * step - 1f;
        for (int i = 0,x=0,z=0; i < points.Length; i++,x++)
        {
            if (x == resolution)
            {
                x = 0;
                z += 1;
                v = ((z + 0.5f) * step - 1f);
            }
            float u = ((x + 0.5f) * step - 1f);
            points[i].localPosition = f(u, v, Time.time);
        }
    }
}
