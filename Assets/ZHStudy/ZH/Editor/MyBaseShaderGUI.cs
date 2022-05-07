using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class MyBaseShaderGUI : ShaderGUI
{
    protected Material target;
    protected MaterialEditor editor;
    MaterialProperty[] propertys;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.editor = materialEditor;
        this.propertys = properties;
        this.target = editor.target as Material;
    }

    #region tool
    protected MaterialProperty FindProperty(string name)
    {
        return FindProperty(name, propertys);
    }

    static GUIContent staticLabel = new GUIContent();
    protected static GUIContent MakeLabel(string text, string tooltip = null)
    {
        staticLabel.text = text;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

    protected static GUIContent MakeLabel(MaterialProperty property, string tooltip = null)
    {
        staticLabel.text = property.displayName;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

    protected void SetKeyword(string keyword, bool state)
    {
        if (state)
        {
            foreach (Material m in editor.targets)
            {
                m.EnableKeyword(keyword);
            }

        }
        else
        {
            foreach (Material m in editor.targets)
            {
                m.DisableKeyword(keyword);
            }

        }
    }

    protected bool IsKeywordEnable(string keyword)
    {
        return target.IsKeywordEnabled(keyword);
    }
    protected void RecordAction(string label)
    {
        editor.RegisterPropertyChangeUndo(label);
    }
    #endregion
}
