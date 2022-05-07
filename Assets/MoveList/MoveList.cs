using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;

public class MoveList : MonoBehaviour
{
    public RectTransform content;

    public Image itemPrefab;

    private List<GameObject> itemlist = new List<GameObject>();
    // Start is called before the first frame update
    void Start()
    {
        SetData();
    }


    bool status = false;

    void SetData()
    {
        status = false;
        var streamUrl = $"{Application.streamingAssetsPath}/Partner/";
        var pngs = Directory.GetFiles(streamUrl).Where((item)=> {
            return !item.Contains("meta");
        }).ToArray();

        StartCoroutine(WebRequestLoadTexture(pngs));
    }

    IEnumerator WebRequestLoadTexture(string[] Paths)
    {
        foreach (var Path in Paths)
        {
            UnityWebRequest _unityWebRequest = new UnityWebRequest(Path);
            DownloadHandlerTexture texDl = new DownloadHandlerTexture(true);
            _unityWebRequest.downloadHandler = texDl;
            yield return _unityWebRequest.SendWebRequest();
            //加载出来的图片分辨率
            //int width = 1920;
            //int high = 1080;

            if (_unityWebRequest.isHttpError || _unityWebRequest.isNetworkError)
            {
                //如果加载报错，打印出错误
                Debug.Log(_unityWebRequest.error);
            }
            else
            {
                Texture2D tex = new Texture2D(texDl.texture.width, texDl.texture.height);
                tex = texDl.texture;
                Sprite sprite = Sprite.Create(tex, new Rect(0, 0, tex.width, tex.height), new Vector2(0.5f, 0.5f));
                CreatImageItem(sprite);
            }
            _unityWebRequest.Dispose();
        }
        //全部加载完成，如果个数大于8个，执行移动步骤
        if (Paths.Length>8)
        {

        }

        StopAllCoroutines();
    }

    private void CreatImageItem(Sprite sprite)
    {
        var temp = Instantiate(itemPrefab,content);
        temp.gameObject.SetActive(true);
        temp.sprite = sprite;
        itemlist.Add(temp.gameObject);
    }

    private void ClearList()
    {
        foreach (var item in itemlist)
        {
            Destroy(item);
        }
        itemlist.Clear();

    }
}
