using UnityEngine;

public class EmissiveOscillator : MonoBehaviour
{
    public Color color;

    MeshRenderer emissiveRenderer;
    Material emissiveMaterial;

    // Start is called before the first frame update
    void Start()
    {
        emissiveRenderer = GetComponent<MeshRenderer>();
        emissiveMaterial = emissiveRenderer.material;
    }

    // Update is called once per frame
    void Update()
    {
        Color c = Color.Lerp(Color.white, Color.black,Mathf.Sin(Time.time * Mathf.PI)*0.5f+0.5f);
        emissiveMaterial.SetColor("_Emission", c);
        //emissiveRenderer.UpdateGIMaterials(); //������������
        DynamicGI.SetEmissive(emissiveRenderer,c);//ֻ������ɫ
    }
}
