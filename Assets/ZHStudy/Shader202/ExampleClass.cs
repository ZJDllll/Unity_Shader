using UnityEngine;
using System.Collections;
 
public class ExampleClass : MonoBehaviour {
    public Material mat;
    private bool flagTex = true;
    void Update() {
        if (Input.GetKeyDown(KeyCode.Space))
            if (flagTex)
                flagTex = false;
            else
                flagTex = true;
 
    }
    void OnPostRender() {
        if (!mat) {
            Debug.LogError("Please Assign a material on the inspector");
            return;
        }
        GL.PushMatrix();
        mat.SetPass(0);
        GL.LoadOrtho();
        GL.Begin(GL.QUADS);
        if (flagTex)
            GL.MultiTexCoord(0, new Vector3(0, 0, 0));
        else
            GL.MultiTexCoord(1, new Vector3(0, 0, 0));
        GL.Vertex3(0, 0, 0);
        if (flagTex)
            GL.MultiTexCoord(0, new Vector3(0, 1, 0));
        else
            GL.MultiTexCoord(1, new Vector3(0, 1, 0));
        GL.Vertex3(1f, 0, 0);
        if (flagTex)
            GL.MultiTexCoord(0, new Vector3(1, 1, 0));
        else
            GL.MultiTexCoord(1, new Vector3(1, 1, 0));
        GL.Vertex3(0f, 0f, 0);
        if (flagTex)
            GL.MultiTexCoord(0, new Vector3(1, 0, 0));
        else
            GL.MultiTexCoord(1, new Vector3(1, 0, 0));
        GL.Vertex3(0, 0f, 0);
        GL.End();
        GL.PopMatrix();
    }
}