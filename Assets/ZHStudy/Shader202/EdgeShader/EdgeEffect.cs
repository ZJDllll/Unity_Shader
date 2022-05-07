using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
public class EdgeEffect : MonoBehaviour
{
    [Range(0, 1)]
    public float edgeOnly = 0.0f;
 
    public Color edgeColor = Color.black;
 
    public Color backgroundColor = Color.white;

    [SerializeField]
    Material edgeMaterial;
    // Start is called before the first frame update
    void Start()
    {

    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (edgeMaterial != null)
        {
            //edgeMaterial.SetFloat("_EdgeFloat", 0.2f);
            edgeMaterial.SetFloat("_EdgeOnly", edgeOnly);
            edgeMaterial.SetColor("_EdgeColor", edgeColor);
            edgeMaterial.SetColor("_BackgroundColor", backgroundColor);

            Graphics.Blit(source, destination, edgeMaterial);
        }
        else
            Graphics.Blit(source, destination);
    }
}
