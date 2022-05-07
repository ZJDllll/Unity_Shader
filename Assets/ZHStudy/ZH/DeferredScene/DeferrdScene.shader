Shader "Unlit/DeferrdScene"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off
        ZTest Always
        ZWrite off
        

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram
            // make fog work
            #pragma multi_compile_fog

           // #define FOG_DISTANCE

            #include "UnityCG.cginc"

            struct VertexData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                #if defined(FOG_DISTANCE)
                    float3 ray : TEXCOORD1;
                #endif
            };

            sampler2D _MainTex,_CameraDepthTexture;
            float3 _FrustumCorners[4];

            Interpolators VertexProgram(VertexData v)
            {
                Interpolators i;
                i.vertex = UnityObjectToClipPos(v.vertex);
                i.uv = v.uv;
                #if defined(FOG_DISTANCE)
                    i.ray = _FrustumCorners[v.uv.x + 2*v.uv.y];
                #endif
                return i;
            }

            fixed4 FragmentProgram(Interpolators i) : SV_Target
            {
                fixed3 sourceColor = tex2D(_MainTex, i.uv).rgb;
                float3 foggedColor = sourceColor;
                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    
                    float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv);
                    depth = Linear01Depth(depth);
                    float viewDistance = depth * _ProjectionParams.z-_ProjectionParams.y;
                    
                    #if defined(FOG_DISTANCE)
                        viewDistance = length(i.ray* depth);
                    #endif
                    UNITY_CALC_FOG_FACTOR_RAW(viewDistance);
                    unityFogFactor = saturate(unityFogFactor);
                    #if !defined(FOG_SKYBOX)
                        if(depth>0.9999){
                            unityFogFactor =1;  
                        }
                    #endif
                    // sample the texture
                    

                    foggedColor = lerp(unity_FogColor.rgb,sourceColor,unityFogFactor);
                #endif
                return float4(foggedColor,1);
            }
            ENDCG
        }
    }
}
