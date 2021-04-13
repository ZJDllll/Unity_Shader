using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class CreateAssetBundle
{
    [MenuItem("Tools/CreateAB")]
    static void CreateAssetBuilds()
    {
        string path = "AssetBundle";
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
        BuildPipeline.BuildAssetBundles(path,BuildAssetBundleOptions.None,BuildTarget.StandaloneWindows64);
        EditorUtility.DisplayDialog("提示","打包完成","确定");
    }
}
