Shader "GT/DefferredShading"
{
    Properties
    {
        
    }
    SubShader
    {

        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            //Blend DstColor Zero
            //Cull Off
            //ZTest always
            ZWrite Off

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram
            
            #pragma exclude_renderers nomrt
            
            #pragma multi_compile_lightpass
			#pragma multi_compile _ UNITY_HDR_ON


            #include "MyDeferredShading.cginc"
            ENDCG
        }

        Pass
        {
            Cull Off
            ZTest always
            ZWrite Off

            Stencil{
                Ref[_StencilNonBackground]
                ReadMask[_StencilNonBackground]
                CompBack Equal
                CompFront Equal
            }

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram
            
            #pragma exclude_renderers nomrt

            #include "UnityCG.cginc"

            struct VertexData
            {
                float4 vertex : POSITION;
                float2 uv :TEXCOORD;
            };

            struct Interpolators
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD;
            };

            sampler2D _LightBuffer;

            Interpolators VertexProgram (VertexData v)
            {
                Interpolators i;
                i.pos = UnityObjectToClipPos(v.vertex);
                i.uv = v.uv;
                return i;
            }

            fixed4 FragmentProgram (Interpolators i) : SV_Target
            {
                float4 color = tex2D(_LightBuffer,i.uv);
                return -log2(color);
            }
            ENDCG
        }
    }
}
