// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"Custom/Textured With Detail"{

	Properties{
		_Tint("Tint",Color) = (1,1,1,1)
		_MainTex("Texture",2D)="white"{}
		_DetailTex("Detail",2D)="gray"{}
	}

	SubShader{
		Pass{
			
			CGPROGRAM
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgrm
			
			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex;
			sampler2D _DetailTex;
			float4 _MainTex_ST;
			float4 _DetailTex_ST;

			struct VertedData{
				float4 position:POSITION;
				float2 uv:TEXCOORD0;
				
			};

			struct Interpolators{
				float4 position : SV_POSITION;
				float2 uv:TEXCOORD0;
				float2 uvDetail:TEXCOORD1;
			};

			Interpolators MyVertexProgram(VertedData v){
				Interpolators i;
				//i.localposition = position.xyz;
				i.uv=v.uv * _MainTex_ST.xy+_MainTex_ST.zw;
				i.uvDetail=v.uv * _DetailTex_ST.xy+_DetailTex_ST.zw;
				i.position = UnityObjectToClipPos(v.position);
				return i;
			}
			float4 MyFragmentProgrm(Interpolators i):SV_TARGET{
				
				float4 color = tex2D(_MainTex,i.uv) * _Tint;
				color *= tex2D(_DetailTex,i.uvDetail) * 4.59;//unity_ColorSpaceDouble;
				return color;
			}
	
			ENDCG
		}
	}
}