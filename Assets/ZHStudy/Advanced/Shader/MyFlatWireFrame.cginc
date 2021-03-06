#if !defined(FLAT_WIREFRAME_INCLUDED)
#define FLAT_WIREFRAME_INCLUDED
#define CUSTOM_GEOMETRY_INTERPOLATORS \
    float2 barycentricCoordinates:TEXCOORD9;

#include "Assets/ZH/LightScene/Shader/MyLightInput.cginc"

float3 _WireframeColor;
float _WireframeSmoothing;
float _WireframeThickness;

float3 GetAlbedoWithWireframe(Interpolators i){
    float3 albedo = GetAlbedo(i);
    float3 barys;
    barys.xy = i.barycentricCoordinates;
    barys.z = 1-barys.x-barys.y;
    //float delta = abs(ddx(minBary))+abs(ddy(minBary));
    float3 delta = fwidth(barys);
    float3 smoothing = delta * _WireframeSmoothing;
    float3 thickness = delta * _WireframeThickness;
    barys = smoothstep(thickness,thickness+smoothing,barys);
    float minBary = min(barys.x,min(barys.y,barys.z));
    return lerp(_WireframeColor,albedo , minBary);
}

#define ALBEDO_FUNCTION GetAlbedoWithWireframe
#include "Assets/ZH/LightScene/Shader/MyLighting.cginc"

struct InterpolatorsGeometry{
    InterpolatorsVertex data;
    CUSTOM_GEOMETRY_INTERPOLATORS
};

[maxvertexcount(3)]
void MyGeometryProgram(triangle InterpolatorsVertex i[3],inout TriangleStream<InterpolatorsGeometry> stream){
    
    float3 p0 = i[0].worldPos.xyz;
    float3 p1 = i[1].worldPos.xyz;
    float3 p2 = i[2].worldPos.xyz;

    float3 triangleNormal = normalize(cross(p1-p0,p2-p0));
    i[0].normal = triangleNormal;
    i[1].normal = triangleNormal;
    i[2].normal = triangleNormal;

    InterpolatorsGeometry g0,g1,g2;
    g0.data = i[0];
    g1.data = i[1];
    g2.data = i[2];
    g0.barycentricCoordinates = float2(1,0);
    g1.barycentricCoordinates = float2(0,1);
    g2.barycentricCoordinates = float2(0,0);
    stream.Append(g0);
    stream.Append(g1);
    stream.Append(g2);
}
#endif