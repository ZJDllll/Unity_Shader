#if !defined(MY_TRIPLANAR_MAPPING_INCLUDE)
#define MY_TRIPLANNAR_MAPPING_INCLUDED
#define NO_DEFAULT_UV

#include "Assets/ZH/LightScene/Shader/MyLightInput.cginc"

sampler2D _MOHSMap;
sampler2D _TopMainTex,_TopMOHSMap,_TopNormalMap;
//sampler2D _NormalMap;
float _MapScale;
float _BlendOffset,_BlendExponent,_BlendHeightStrength;


struct TriplanarUV{
    float2 x,y,z;
};

TriplanarUV GetTriplanarUV(SurfaceParameters parameters){
    TriplanarUV triUV;
    float3 p = parameters.position * _MapScale;
    triUV.x = p.zy;
    triUV.y = p.xz;
    triUV.z = p.xy;
    if(parameters.normal.x < 0){
        triUV.x.x = -triUV.x.x;
    }
    if(parameters.normal.y < 0){
        triUV.y.x = -triUV.y.x;
    }
    if(parameters.normal.z >= 0){
        triUV.z.x = -triUV.z.x;
    }

    triUV.x.y += 0.5;
    triUV.z.x += 0.5;
    return triUV;
}

float3 GetTriplanarWeights(SurfaceParameters parameters,float heightX,float heightY,float heightZ)
{
    float3 triw = abs(parameters.normal);
    triw = saturate(triw - _BlendOffset);
    triw *= lerp(1,float3(heightX,heightY,heightZ),_BlendHeightStrength);
    triw = pow(triw,_BlendExponent);
    return triw/(triw.x + triw.y+triw.z);
}

float3 BlendTriplanarNormal(float3 mappedNormal,float3 surfaceNormal){
    float3 n;
    n.xy = mappedNormal.xy + surfaceNormal.xy;
    n.z = mappedNormal.z * surfaceNormal.z;
    return n;
}

void MyTriPlanarSurfaceFunction(inout SurfaceData surface,SurfaceParameters parameters)
{
    TriplanarUV triUV = GetTriplanarUV(parameters);

    float3 albedoX = tex2D(_MainTex,triUV.x).rgb;
    float3 albedoY = tex2D(_MainTex,triUV.y).rgb;
    float3 albedoZ = tex2D(_MainTex,triUV.z).rgb;

    float4 mohsX = tex2D(_MOHSMap,triUV.x);
    float4 mohsY = tex2D(_MOHSMap,triUV.y);
    float4 mohsZ = tex2D(_MOHSMap,triUV.z);

    float3 tangentNormalX = UnpackNormal(tex2D(_NormalMap,triUV.x));
    float4 rawNormalY = tex2D(_NormalMap,triUV.y);
    float3 tangentNormalZ = UnpackNormal(tex2D(_NormalMap,triUV.z));

    #if defined(_SEPARATE_TOP_MAPS)
        if(parameters.normal.y > 0){
            albedoY = tex2D(_TopMainTex,triUV.y).rgb;
            mohsY = tex2D(_TopMOHSMap,triUV.y);
            rawNormalY = tex2D(_TopNormalMap,triUV.y);
        }
    #endif

    float3 tangentNormalY = UnpackNormal(rawNormalY);

    if(parameters.normal.x<0){
        tangentNormalX.x = -tangentNormalX.x;
        //tangentNormalX.z = -tangentNormalX.z;
    }
    if(parameters.normal.y<0){
        tangentNormalY.x = -tangentNormalY.x;
        //tangentNormalY.z = -tangentNormalY.z;
    }
    if(parameters.normal.z>=0){
        tangentNormalZ.x = -tangentNormalZ.x;
        //tangentNormalZ.z = -tangentNormalZ.z;
    }

    float3 worldNormalX = BlendTriplanarNormal(tangentNormalX,parameters.normal.zyx).zyx;
    float3 worldNormalY = BlendTriplanarNormal(tangentNormalY,parameters.normal.xzy).xzy;
    float3 worldNormalZ = BlendTriplanarNormal(tangentNormalZ,parameters.normal);

    float3 triw = GetTriplanarWeights(parameters,mohsX.z,mohsY.z,mohsZ.z);

    surface.normal = normalize(worldNormalX * triw.x +worldNormalY * triw.y +worldNormalZ * triw.z );

    surface.albedo = (albedoX * triw.x + albedoY * triw.y + albedoZ * triw.z);
    //surface.albedo = triw;
    float4 mohs  = mohsX *triw.x + mohsY * triw.y + mohsZ * triw.z;
    surface.metallic = mohs.x;
    surface.occlusion = mohs.y;
    surface.smoothness = mohs.a;
    //surface.albedo = (albedoX  + albedoY  + albedoZ )/3;
    surface.normal = normalize(
		worldNormalX * triw.x + worldNormalY * triw.y + worldNormalZ * triw.z
	);
}

#define SURFACE_FUNCTION MyTriPlanarSurfaceFunction

#endif