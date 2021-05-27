using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPUInstancingTest : MonoBehaviour
{

    public Transform prefab;

    public int instance = 5000;

    public float radius = 50f;

    // Start is called before the first frame update
    void Start()
    {
        MaterialPropertyBlock propertys = new MaterialPropertyBlock();
        for (int i = 0; i < instance; i++)
        {
            Transform t = Instantiate(prefab);
            t.localPosition = Random.insideUnitSphere * radius;
            t.SetParent(transform);

            propertys.SetColor("_Color",new Color(Random.value, Random.value, Random.value));
            //t.GetComponent<MeshRenderer>().SetPropertyBlock(propertys);
            MeshRenderer r = t.GetComponent<MeshRenderer>();
            if (r)
            {
                r.SetPropertyBlock(propertys);
            }
            else
            {
                for (int j = 0; j < t.childCount; j++)
                {
                    r = t.GetChild(j).GetComponent<MeshRenderer>();
                    if (r)
                    {
                        r.SetPropertyBlock(propertys);
                    }
                }
            }    
        }
    }

    
}
