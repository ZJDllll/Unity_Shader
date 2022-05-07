using UnityEngine;
using static UnityEngine.Mathf;

public static class FunctionLibrary
{
    public delegate Vector3 Function(float u, float v, float t);

    public enum FunctionName { Wave,MultiWave,Ripple, Sphere , Torus }

    static Function[] functions = { Wave,MultiWave, Ripple, Sphere, Torus };

    public static Function GetFunction(int index)
    {
        return functions[index];
    }

    public static Vector3 Wave(float u, float v, float t)
    {
        Vector3 p;
        p.x = u;
        p.y = Sin(PI * (u + v + t));
        p.z = v;

        return p;
    }

    public static Vector3 MultiWave(float u, float v, float t)
    {
        float y = Sin(PI * (u + 0.5f*t));
        y += 0.5f*Sin(2f * PI * (v + t));
        y += Sin(2f * PI * (u + v + 0.25f*t));
        Vector3 p;
        p.x = u;
        p.y = y * (1f / 2.5f);
        p.z = v;
        return p;
    }

    public static Vector3 Ripple(float u, float v, float t)
    {
        float d = Sqrt(u*u+v*v);
        float y = Sin(PI * (4f *  d - t));

        Vector3 p;
        p.x = u;
        p.y = y / (1 + 10 * d);
        p.z = v;
        return p;
    }

    public static Vector3 Sphere(float u,float v,float t)
    {
        float r = 0.9f + 0.1f * Sin(PI * (3f * u + 6f * v + (t * 1.2f)));
        //float r = 1;
        float s = r * Cos(0.5f * PI * v);

        Vector3 p;
        p.x = s * Sin(PI * u);
        p.y = r * Sin(PI * v *0.5f) ;
        p.z = s * Cos(PI * u);
        return p;
    }
    public static float r1;
    public static float r2;
    public static Vector3 Torus(float u, float v, float t)
    {
        //float r = 0.9f + 0.1f * Sin(PI * (3f * u + 6f * v + (t * 1.2f)));
        //float r1 = 0.8f;
        //float r2 = 0.20f;
        float r1 = 0.7f+0.1f*Sin(PI *(6f*u+0.5f*t));
        float r2 = 0.15f+0.05f*Sin(PI *(8f * u + 4f * v + 2f *t));
        float s = r1 + r2 * Cos(1f * PI * v);

        Vector3 p;
        p.x = s * Sin(PI * u);
        p.y = r2 * Sin(PI * v * 1f);
        p.z = s * Cos(PI * u);
        return p;
    }
}
