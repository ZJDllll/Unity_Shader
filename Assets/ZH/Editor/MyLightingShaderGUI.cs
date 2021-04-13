using UnityEngine;
using UnityEditor;
public enum  SmoothnessSource
{
    Uniform,Albedo,Metallic
}
public class MyLightingShaderGUI : ShaderGUI
{
    Material target;
    MaterialEditor editor;
    MaterialProperty[] propertys;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.editor = materialEditor;
        this.propertys = properties;
        this.target =editor.target as Material;
        DoMain();
        DoSecondary();
    }

    void DoMain()
    {
        GUILayout.Label("Main Maps",EditorStyles.boldLabel);
        MaterialProperty mainTex = FindProperty("_MainTex");
        editor.TexturePropertySingleLine(MakeLabel(mainTex, "Albedo (RGB)"), mainTex, FindProperty("_Tint"));
        DoMetallic();
        DoSmoothness();
        DoNormals();
        DoEmission();
        editor.TextureScaleOffsetProperty(mainTex);
    }

    void DoNormals()
    {
        MaterialProperty map = FindProperty("_NormalMap");
        editor.TexturePropertySingleLine(MakeLabel(map), map,map.textureValue?FindProperty("_BumpScale"):null);
    }

    void DoMetallic()
    {
        // MaterialProperty slider = FindProperty("_Metallic");
        // EditorGUI.indentLevel += 2;
        // editor.ShaderProperty(slider, MakeLabel(slider));
        // EditorGUI.indentLevel -= 2;
        MaterialProperty map =FindProperty("_MetallicMap");
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertySingleLine(MakeLabel(map,"Metallic (R)"),map,map.textureValue?null:FindProperty("_Metallic"));
        if (EditorGUI.EndChangeCheck())
        {
            SetKeyword("_METALLIC_MAP",map.textureValue);
        }
    }
    void DoSmoothness()
    {
        SmoothnessSource source = SmoothnessSource.Uniform;
        if (IsKeywordEnable("_SMOOTHNESS_ALBEDO"))
        {
            source = SmoothnessSource.Albedo;
        }else if(IsKeywordEnable("_SMOOTHNESS_METALLIC")){
            source = SmoothnessSource.Metallic;
        }
        MaterialProperty slider = FindProperty("_Smoothness");
        EditorGUI.indentLevel += 2;
        editor.ShaderProperty(slider, MakeLabel(slider));
        EditorGUI.indentLevel += 1;
        EditorGUI.BeginChangeCheck();
        source=(SmoothnessSource)EditorGUILayout.EnumPopup(MakeLabel("Source"),source);
        if (EditorGUI.EndChangeCheck())
        {
            RecordAction("Smothness source");
            SetKeyword("_SMOOTHNESS_ALBEDO",source == SmoothnessSource.Albedo);
            SetKeyword("_SMOOTHNESS_METALLIC",source == SmoothnessSource.Metallic);
        }
        EditorGUI.indentLevel -= 3;
    }

    void DoSecondary()
    {
        GUILayout.Label("Secondary Maps", EditorStyles.boldLabel);
        MaterialProperty detailTex = FindProperty("_DetailTex");
        editor.TexturePropertySingleLine(MakeLabel(detailTex, "Albedo (RGB) multiplied by 2"), detailTex);
        DoSecondaryNormals();
        editor.TextureScaleOffsetProperty(detailTex);
    }

    void DoSecondaryNormals()
    {
        MaterialProperty map = FindProperty("_DetailNormalMap");
        editor.TexturePropertySingleLine(MakeLabel(map), map, map.textureValue ? FindProperty("_DetailBumpScale") : null);
    }

    //static ColorPickerHDRConfig emissionConfig = new ColorPickerHDRConfig(0f,99f,1f/99f,3f);
    void DoEmission(){
        MaterialProperty map = FindProperty("_EmissionMap");
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertyWithHDRColor(MakeLabel(map,"Emission (RGB)"),map,FindProperty("_Emission"),false);
        if (EditorGUI.EndChangeCheck())
        {
            SetKeyword("_EMISSION_MAP",map.textureValue);
        }
    }
        
    #region tool
    MaterialProperty FindProperty(string name)
    {
        return FindProperty(name, propertys);
    }

    static GUIContent staticLabel = new GUIContent();
    static GUIContent MakeLabel(string text,string tooltip = null)
    {
        staticLabel.text = text;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

    static GUIContent MakeLabel(MaterialProperty property,string tooltip = null)
    {
        staticLabel.text = property.displayName;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

    void SetKeyword(string keyword,bool state){
        if (state)
        {
            target.EnableKeyword(keyword);
        }else{
            target.DisableKeyword(keyword);
        }
    }

    bool IsKeywordEnable(string keyword){
        return target.IsKeywordEnabled(keyword);
    }
    void RecordAction(string label){
        editor.RegisterPropertyChangeUndo(label);
    }
    #endregion
}