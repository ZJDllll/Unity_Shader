using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AssetBundleDemo : MonoBehaviour
{
    public GameObject gameObject;
    // Start is called before the first frame update
    void Start()
    {
        Debug.Log("哈喽我的宝贝"+ gameObject.name);
        Debug.Log("哈喽我的宝贝，你终于来了"+ gameObject.name);
    }

    
}
