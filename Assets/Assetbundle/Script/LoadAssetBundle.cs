using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public class LoadAssetBundle : MonoBehaviour
{
    UnityWebRequest requestAssetBundle;
    private void Start()
    {
        StartCoroutine(LoadFromWebRequest());
    }
    
    IEnumerator LoadFromWebRequest()
    {
        string path = @"http://localhost:8080/AssetBundle/model.u3d";
        requestAssetBundle = UnityWebRequestAssetBundle.GetAssetBundle(path);
        yield return requestAssetBundle.SendWebRequest();
        
        if (!string.IsNullOrEmpty(requestAssetBundle.error))
        {
            Debug.Log("加载出错:"+ requestAssetBundle.error);
            yield break;
        }
        AssetBundle assetBundle = DownloadHandlerAssetBundle.GetContent(requestAssetBundle);
        var objects=assetBundle.LoadAllAssets();
        foreach (var obj in objects)
        {
            Instantiate((GameObject)obj);
        }

    }
}
