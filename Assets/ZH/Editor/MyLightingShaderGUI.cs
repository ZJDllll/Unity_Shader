using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
public enum  SmoothnessSource
{
    Uniform,Albedo,Metallic
}

enum RenderingMode
{
    Opaque,Cutout,Fade,Transparent
}

struct RenderingSettings
{
    public RenderQueue queue;
    public string renderType;
    public BlendMode srcBlend, dstBlend;
    public bool zWrite;

    public static RenderingSettings[] modes =
    {
        new RenderingSettings()
        {
            queue = RenderQueue.Geometry,
            renderType = "",
            srcBlend = BlendMode.One,
            dstBlend = BlendMode.Zero,
            zWrite = true
        },
        new RenderingSettings()
        {
            queue = RenderQueue.AlphaTest,
            renderType = "TransparentCutot",
            srcBlend = BlendMode.One,
            dstBlend = BlendMode.Zero,
            zWrite = true
        },
        new RenderingSettings()
        {
            queue = RenderQueue.Transparent,
            renderType ="Transparent",
            srcBlend = BlendMode.SrcAlpha,
            dstBlend = BlendMode.OneMinusSrcAlpha,
            zWrite = false
        },
        new RenderingSettings()
        {
            queue = RenderQueue.Transparent,
            renderType ="Transparent",
            srcBlend = BlendMode.One,
            dstBlend = BlendMode.OneMinusSrcAlpha,
            zWrite = false
        }
    };
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
        DoAdvanced();
    }
    
    bool shouldShowAlphaCutoff=false;
    void DoMain()
    {
        DoRenderingMode();
        GUILayout.Label("Main Maps",EditorStyles.boldLabel);
        MaterialProperty mainTex = FindProperty("_MainTex");
        editor.TexturePropertySingleLine(MakeLabel(mainTex, "Albedo (RGB)"), mainTex, FindProperty("_Color"));
        if (shouldShowAlphaCutoff)
        {
            DoAlphaCutoff();
        }
        DoMetallic();
        DoSmoothness();
        DoNormals();
        DoParallax();
        DoOcclusion();
        DoEmission();
        editor.TextureScaleOffsetProperty(mainTex);
    }

    void DoAdvanced()
    {
        GUILayout.Label("Advanced Options",EditorStyles.boldLabel);
        editor.EnableInstancingField();
    }

    void DoParallax()
    {
        MaterialProperty map = FindProperty("_ParallaxMap");
        Texture tex = map.textureValue;
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertySingleLine(MakeLabel(map, "Parallax(G)"), map, tex ? FindProperty("_ParallaxStrength") : null);
        if (EditorGUI.EndChangeCheck()&&tex!=map.textureValue)
        {
            SetKeyword("_PARALLAX_MAP", map.textureValue);
        }
    }

    void DoRenderingMode()
    {
        RenderingMode mode = RenderingMode.Opaque;
        shouldShowAlphaCutoff = false;
        if (IsKeywordEnable("_RENDERING_CUTOUT"))
        {
            mode = RenderingMode.Cutout;
            shouldShowAlphaCutoff = true;
        }
        else if (IsKeywordEnable("_RENDERING_FADE"))
        {
            mode = RenderingMode.Fade;
        }
        else if (IsKeywordEnable("_RENDERING_TRANSPARENT"))
        {
            mode = RenderingMode.Transparent;
        }
        EditorGUI.BeginChangeCheck();
        mode = (RenderingMode)EditorGUILayout.EnumPopup(MakeLabel("Rendering Mode"), mode);
        if (EditorGUI.EndChangeCheck())
        {
            RecordAction("Rendering Mode");
            SetKeyword("_RENDERING_CUTOUT", mode == RenderingMode.Cutout);
            SetKeyword("_RENDERING_FADE", mode == RenderingMode.Fade);
            SetKeyword("_RENDERING_TRANSPARENT", mode == RenderingMode.Transparent);

            RenderingSettings settings = RenderingSettings.modes[(int)mode];

            foreach (Material m in editor.targets)
            {
                m.renderQueue = (int)settings.queue;
                m.SetOverrideTag("RenderType", settings.renderType);
                m.SetInt("_SrcBlend", (int)settings.srcBlend);
                m.SetInt("_DstBlend", (int)settings.dstBlend);
                m.SetInt("_ZWrite", settings.zWrite ? 1 : 0);
            }
        }

        if (mode == RenderingMode.Fade ||mode == RenderingMode.Transparent)
        {
            DoSemitransparentShadows();
        }
    }

    void DoSemitransparentShadows()
    {
        EditorGUI.BeginChangeCheck();
        bool semitransparentShadows = EditorGUILayout.Toggle(MakeLabel("Semitransp.Shadows", "Semitransparent Shadows"),IsKeywordEnable("_SEMITRANSPARENT_SHADOWS"));
        if (EditorGUI.EndChangeCheck())
        {
            SetKeyword("_SEMITRANSPARENT_SHADOWS", semitransparentShadows);
        }

        if (!semitransparentShadows)
        {
            shouldShowAlphaCutoff = true;
        }
    }

    void DoAlphaCutoff()
    {
        MaterialProperty slider = FindProperty("_Cutoff");
        EditorGUI.indentLevel += 2;
        editor.ShaderProperty(slider, MakeLabel(slider));
        EditorGUI.indentLevel -= 2;
    }

    void DoNormals()
    {
        MaterialProperty map = FindProperty("_NormalMap");
        var tex = map.textureValue;
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertySingleLine(MakeLabel(map), map,map.textureValue?FindProperty("_BumpScale"):null);
        if(EditorGUI.EndChangeCheck()&&tex!=map.textureValue){
            SetKeyword("_NORMAL_MAP",map.textureValue);
        }
    }

    void DoMetallic()
    {
        // MaterialProperty slider = FindProperty("_Metallic");
        // EditorGUI.indentLevel += 2;
        // editor.ShaderProperty(slider, MakeLabel(slider));
        // EditorGUI.indentLevel -= 2;
        MaterialProperty map =FindProperty("_MetallicMap");
        var tex = map.textureValue;
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertySingleLine(MakeLabel(map,"Metallic (R)"),map,map.textureValue?null:FindProperty("_Metallic"));
        if (EditorGUI.EndChangeCheck()&& tex!=map.textureValue)
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
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertySingleLine(MakeLabel(detailTex, "Albedo (RGB) multiplied by 2"), detailTex);
        if(EditorGUI.EndChangeCheck()){
            SetKeyword("_DETAIL_ALBEDO_MAP",detailTex.textureValue);
        }
        DoSecondaryNormals();
        DoDetailMask();
        editor.TextureScaleOffsetProperty(detailTex);
    }

    void DoSecondaryNormals()
    {
        MaterialProperty map = FindProperty("_DetailNormalMap");
        var tex = map.textureValue;
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertySingleLine(MakeLabel(map), map, map.textureValue ? FindProperty("_DetailBumpScale") : null);
        if(EditorGUI.EndChangeCheck()&&tex!=map.textureValue){
            SetKeyword("_DETAIL_NORMAL_MAP",map.textureValue);
        }
    }

    //static ColorPickerHDRConfig emissionConfig = new ColorPickerHDRConfig(0f,99f,1f/99f,3f);
    void DoEmission(){
        MaterialProperty map = FindProperty("_EmissionMap");
        var tex = map.textureValue;
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertyWithHDRColor(MakeLabel(map,"Emission (RGB)"),map,FindProperty("_Emission"),false);
        editor.LightmapEmissionProperty(2);
        if (EditorGUI.EndChangeCheck())
        {
            if(tex!=map.textureValue){
            SetKeyword("_EMISSION_MAP",map.textureValue);
            }
            foreach (Material m in editor.targets)
            {
                m.globalIlluminationFlags &= ~MaterialGlobalIlluminationFlags.EmissiveIsBlack;
            }
        }
    }
    
    void DoOcclusion(){
        MaterialProperty map = FindProperty("_OcclusionMap");
        var tex = map.textureValue;
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertySingleLine(MakeLabel(map,"Occlusion (G)"),map,map.textureValue?FindProperty("_OcclusionStrength"):null);
        if (EditorGUI.EndChangeCheck()&&tex!=map.textureValue)
        {
            SetKeyword("_OCCLUSION_MAP",map.textureValue);
        }
    }

    void DoDetailMask(){
        MaterialProperty mask = FindProperty("_DetailMask");
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertySingleLine(MakeLabel(mask,"Detail Mask (a)"),mask);
        if(EditorGUI.EndChangeCheck()){
            SetKeyword("_DETAIL_MASK",mask.textureValue);
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
            foreach (Material m in editor.targets)
            {
                m.EnableKeyword(keyword);
            }
            
        }else{
            foreach (Material m in editor.targets)
            {
                m.DisableKeyword(keyword);
            }
            
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
