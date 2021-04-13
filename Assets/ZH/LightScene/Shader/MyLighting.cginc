// Upgrade NOTE: replaced 'UNITY_PASS_TEXCUBE(unity_SpecCube1)' with 'UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0)'

// Upgrade NOTE: replaced 'UNITY_PASS_TEXCUBE(unity_SpecCube1)' with 'UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0)'

#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

float4 _Tint;
float4 _SpecularTint;
sampler2D _MainTex,_DetailTex;
float4 _MainTex_ST,_DetailTex_ST;
sampler2D _NormalMap,_DetailNormalMap;
float _Smoothness;
sampler2D _MetallicMap;
float _Metallic;
float _BumpScale,_DetailBumpScale;

sampler2D _EmissionMap;
float3 _Emission;

struct VertedData{
    float4 vertex:POSITION;
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
    float2 uv:TEXCOORD0;
};

struct Interpolators{
    float4 pos : SV_POSITION;
    float4 uv:TEXCOORD0;
    float3 normal:TEXCOORD1;
    float4 tangent:TEXCOORD2;
    float3 worldPos:TEXCOORD3;
    #if defined(VERTEXLIGHT_ON)
        float3 vertexLightColor:TEXCOORD4;
    #endif
    // #if defined(SHADOWS_SCREEN)
    //     float4 shadowCoordinates:TEXCOOR5;
    // #endif
    SHADOW_COORDS(5)
};

//从金属贴图R通道取出当前像素点是否是金属
float GetMetallic(Interpolators i){
    #if defined(_METALLIC_MAP)
        return tex2D(_MetallicMap,i.uv.xy).r;
    #else
        return _Metallic;
    #endif
}

float GetSmoothness(Interpolators i){
    float smoothness =1;
    #if defined(_SMOOTHNESS_ALBEDO)
        smoothness = tex2D(_MainTex,i.uv.xy).a;
    #elif defined(_SMOOTHNESS_METALLIC) && defined(_METALLIC_MAP)
        smoothness = tex2D(_MetallicMap,i.uv.xy).a;
    #endif

    return smoothness * _Smoothness;
}

//返回值是颜色 float3类型，谨记不要float
float3 GetEmission (Interpolators i) {
    #if defined(FORWARD_BASE_PASS)
        #if defined(_EMISSION_MAP)
            return tex2D(_EmissionMap,i.uv.xy)*_Emission;
        #else
            return _Emission;
        #endif
    #else
        return 0;
    #endif
}

void ComputeVertexLightColor(inout Interpolators i){
    #if defined(VERTEXLIGHT_ON)
        // float3 lightPos = float3(unity_4LightPosX0.x,unity_4LightPosY0.x,unity_4LightPosZ0.x);
        // float3 lightVec = lightPos - i.worldPos;
        // float3 lightDir = normalize(lightVec);
        // float ndotl = DotClamped(i.normal,lightDir);
        // float attenuation = 1/(1+dot(lightVec,lightVec)*unity_4LightAtten0);
        // i.vertexLightColor = unity_LightColor[0].rgb*ndotl*attenuation;
        i.vertexLightColor = Shade4PointLights(
            unity_4LightPosX0,unity_4LightPosY0,unity_4LightPosZ0,
            unity_LightColor[0].rgb,unity_LightColor[1].rgb,
            unity_LightColor[2].rgb,unity_LightColor[3].rgb,
            unity_4LightAtten0,i.worldPos,i.normal
        );
    #endif
}
Interpolators MyVertexProgram(VertedData v){
    Interpolators i;
    //i.localposition = position.xyz;
    i.uv.xy=v.uv * _MainTex_ST.xy+_MainTex_ST.zw;
    //i.uv.zw=v.uv * _DetailTex.xy+_DetailTex.zw;
    i.uv.zw = TRANSFORM_TEX(v.uv,_DetailTex);
    i.pos = UnityObjectToClipPos(v.vertex);
    //i.normal = mul(transpose((float3x3)unity_WorldToObject),v.normal);
    //i.normal = mul(transpose(unity_WorldToObject),float4(v.normal,0));编译后与上一行相同。
    i.normal = UnityObjectToWorldNormal(v.normal);//与上效果相同，使用unity内置方法
    i.normal = normalize(i.normal);
    i.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz),v.tangent.w);
    i.worldPos = mul(unity_ObjectToWorld,v.vertex);
    // #if defined(SHADOWS_SCREEN)
    //     i.shadowCoordinates = ComputeScreenPos(i.position);
    // #endif
    TRANSFER_SHADOW(i);
    ComputeVertexLightColor(i);
    return i;
}

UnityLight CreateLight(Interpolators i){
    UnityLight light;
    #if defined(POINT) ||defined(SPOT) ||defined(POINT_COOKIE)
        light.dir=normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
    #else
        light.dir = _WorldSpaceLightPos0.xyz;
    #endif

   // #if defined(SHADOWS_SCREEN)
        //float attenuation=tex2D(_ShadowMapTexture,i.shadowCoordinates.xy/i.shadowCoordinates.w);
       // float attenuation = SHADOW_ATTENUATION(i);
    //#else
    UNITY_LIGHT_ATTENUATION(attenuation,i,i.worldPos);
    //#endif
    light.color = _LightColor0.rgb * attenuation;
    light.ndotl = DotClamped(i.normal,light.dir);
    return light;
}

float3 BoxProjection(float3 direction,float3 position,float4 cubemapPosition,float3 boxMin,float3 boxMax){
    // boxMin -=position;
    // boxMax -=position;
    // float x = (direction.x>0?boxMax.x:boxMin.x)/direction.x;
    // float y = (direction.y>0?boxMax.y:boxMin.y)/direction.y;
    // float z = (direction.z>0?boxMax.z:boxMin.z)/direction.z;
    // float scalar = min(x,min(y,z));
    #if UNITY_SPECCUBE_BOX_PROJECTION
    UNITY_BRANCH
        if(cubemapPosition.w>0){
            float3 factors = ((direction>0?boxMax:boxMin)-position)/direction;
            float scalar = min(factors.x,min(factors.y,factors.z));
            direction = direction*scalar +(position - cubemapPosition);
        }
    #endif
    return direction;

}

UnityIndirect CreateIndirectLight(Interpolators i,float3 viewDir){
    UnityIndirect indirectLight;
    indirectLight.diffuse = 0;
    indirectLight.specular = 0;
    #if defined(VERTEXLIGHT_ON)
        indirectLight.diffuse = i.vertexLightColor;
    #endif

    #if defined(FORWARD_BASE_PASS)
        indirectLight.diffuse += max(0,ShadeSH9(float4(i.normal,1)));
        float3 reflectionDir = reflect(-viewDir,i.normal);
        // float roughness = 1-_Smoothness;
        // roughness *= 1.7 - 0.7*roughness;
        // float4 envSample = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0,reflectionDir,roughness*UNITY_SPECCUBE_LOD_STEPS);//UNITY_SPECCUBE_LOD_STEPS 如果没有定义默认定义为6;
        // indirectLight.specular = DecodeHDR(envSample,unity_SpecCube0_HDR);
        Unity_GlossyEnvironmentData envData;
        envData.roughness = 1-GetSmoothness(i);
        //采样第一个反射球贴图数据
        envData.reflUVW = BoxProjection(
			reflectionDir, i.worldPos,
			unity_SpecCube0_ProbePosition,
			unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax
		);
		float3 probe0 = Unity_GlossyEnvironment(
			UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData
		);
        #if UNITY_SPECCUBE_BLENDING
            float interpolator = unity_SpecCube0_BoxMin.w;
            UNITY_BRANCH
            if(interpolator<0.99999){
                envData.reflUVW = BoxProjection(
                    reflectionDir, i.worldPos,
                    unity_SpecCube1_ProbePosition,
                    unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax
                );
                float3 probe1 = Unity_GlossyEnvironment(
                    UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0),
                    unity_SpecCube0_HDR, envData
                );
                indirectLight.specular = lerp(probe1,probe0,interpolator);
            }else{
                indirectLight.specular = probe0;
            }
        #else
            indirectLight.specular = probe0;
        #endif
    #endif
    return indirectLight;
}

// float4 MyFragmentProgrm(Interpolators i):SV_TARGET{
    
//   //return float4(i.normal*0.5+0.5,1);//可视化法线
//   //return float4(i.uv,1,1);//可视化uv
//   //return max(0,dot(float3(0,1,0),i.normal));//法线与光照方向进行点积计算当前面的光照强度，直接返回表示。
//   //return DotClamped(i.normal,lightDir);//与max方法相同，使用unity内部封装好的方法
  
//   i.normal = normalize(i.normal);//不执行这一步误差很小，对于移动端和低性能平台，可以考虑优化。
//   //float3 lightDir = _WorldSpaceLightPos0.xyz;
//   float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
//   //float3 lightColor = _LightColor0.rgb;
//   //float3 reflectionDir = reflect(-lightDir,i.normal);
//   //float3 halfDir  = normalize(lightDir + viewDir);
//   //return float4(reflectionDir,1);//反射方向可视化
//   //float3 specular = _SpecularTint.rgb*lightColor * pow(
//   //DotClamped(halfDir,i.normal),
//   //_Smoothness*100);
//   //return float4(specular,1);
//   float3 albedo = tex2D(_MainTex,i.uv).rgb * _Tint.rgb;
//   // albedo *= 1-max(_SpecularTint.r,max(_SpecularTint.g,_SpecularTint.b));
//   float3 specularTint; //= albedo * _Metallic;
//   float oneMinusReflectivity; //= 1- _Metallic;
//   //albedo *=oneMinusReflectivity;
//   albedo = DiffuseAndSpecularFromMetallic(albedo,_Metallic,specularTint,oneMinusReflectivity);
//   //float3 diffuse = albedo * lightColor * DotClamped(lightDir,i.normal);
//   //float3 specular = specularTint * lightColor*pow(DotClamped(halfDir,i.normal),_Smoothness *100);
//   //return float4(diffuse+specular,1);
//   //UnityLight light;
//   //light.color = lightColor;
//   //light.dir = lightDir;
//   //light.ndotl = DotClamped(i.normal,lightDir);
//   // UnityIndirect indirectLight;
//   // indirectLight.diffuse = 0;
//   // indirectLight.specular = 0;
//   // float3 shColor = ShadeSH9(float4(i.normal,1));
//   // return float4(shColor,1);
//   return UNITY_BRDF_PBS(albedo,specularTint,oneMinusReflectivity,_Smoothness,i.normal,viewDir,CreateLight(i),CreateIndirectLight(i));
    
// }
void InitializeFragmentNormal(inout Interpolators i){
    // float2 du = float2(_HeightMap_TexelSize.x*0.5,0);
    // float u1 =tex2D(_HeightMap,i.uv-du);
    // float u2 =tex2D(_HeightMap,i.uv+du);
    // //float3 tu = float3(1,u2-u1,0);

    // float2 dv = float2(0,_HeightMap_TexelSize.y*0.5);
    // float v1 =tex2D(_HeightMap,i.uv-dv);
    // float v2 =tex2D(_HeightMap,i.uv+dv);
    // float3 tv = float3(0,v2-v1,1);
    // i.normal = float3(u1-u2,1,v1-v2);
    // i.normal.xy = tex2D(_NormalMap,i.uv).wy*2 - 1;
    // i.normal.xy *=_BumpScale;
    // i.normal.z= sqrt(1-saturate(dot(i.normal.xy,i.normal.xy)));
    float3 mainNormal = UnpackScaleNormal(tex2D(_NormalMap,i.uv.xy),_BumpScale);
    float3 detailNormal = UnpackScaleNormal(tex2D(_DetailNormalMap,i.uv.zw),_DetailBumpScale);
    float3 tangentSpaceNormal = BlendNormals(mainNormal,detailNormal);
    //tangentSpaceNormal = i.normal.xzy;
    float3 binormal = cross(i.normal,i.tangent.xyz)*(i.tangent.w*unity_WorldTransformParams.w);
    i.normal = normalize(tangentSpaceNormal.x * i.tangent + //根据切线空间中计算的法线，将各个分量乘以世界坐标的各个轴
                         tangentSpaceNormal.y * binormal +
                         tangentSpaceNormal.z * i.normal);
}
float4 MyFragmentProgrm(Interpolators i):SV_TARGET{
    InitializeFragmentNormal(i);
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
    
    float3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Tint.rgb;
    albedo *= tex2D(_DetailTex,i.uv.zw) * unity_ColorSpaceDouble;
    //albedo *=tex2D(_HeightMap,i.uv);
    float3 specularTint; //= albedo * _Metallic;
    float oneMinusReflectivity; //= 1- _Metallic;
   
    albedo = DiffuseAndSpecularFromMetallic(albedo,GetMetallic(i),specularTint,oneMinusReflectivity);
    
    float4 color = UNITY_BRDF_PBS(albedo,specularTint,oneMinusReflectivity,GetSmoothness(i),i.normal,viewDir,CreateLight(i),CreateIndirectLight(i,viewDir));
    color.rgb +=GetEmission(i);
    return color;
}

#endif