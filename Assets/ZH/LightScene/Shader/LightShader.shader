// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"GT/My First Light Shader"{
	
	Properties{
		_Tint("Tint",Color) = (1,1,1,1)
		_MainTex("Albedo",2D) = "white"{}

		_SpecularTint("Specular",Color) = (0.5,0.5,0.5)
		[NoScaleOffset]_NormalMap("Normal",2D)="bump"{}
		_BumpScale("Bump Scale",Float) = 1

		[NoScaleOffset]_MetallicMap("Metallic",2D)="white"{}
		[Gamma]_Metallic("Metallic",Range(0,1)) = 0
		_Smoothness("Smoothness",Range(0,1))=0.1

		_DetailTex("Detail Albedo",2D) = "gray"{}
		[NoScaleOffset]_DetailNormalMap("Detail Normal",2D)="bump"{}
		_DetailBumpScale("Detial Bump Scale",Float)=1

		[NoScaleOffset]_EmissionMap("Emission",2D) = "black"{}
		_Emission("Emission",Color) = (0,0,0)
	}

	SubShader{
		Pass{

			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma target 3.0

			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ SHADOWS_SCREEN
			#pragma shader_feature _METALLIC_MAP
			#pragma shader_feature _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC
			#pragma shader_feature _EMISSION_MAP

			#define FORWARD_BASE_PASS

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgrm
			
			#include "MyLighting.cginc"

			ENDCG
		}
		Pass{

			Tags{"LightMode"="ForwardAdd"}
			Blend One One
			ZWrite Off
			CGPROGRAM

			#pragma target 3.0

			//#pragma multi_compile DIRECTIONAL DIRECTIONAL_COOKIE POINT SPOT
			#pragma multi_compile_fwdadd_fullshadows
			//#pragma multi_compile _ _METALLIC_MAP
			#pragma shader_feature _METALLIC_MAP
			#pragma shader_feature _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgrm
			
			#include "MyLighting.cginc"
	
			ENDCG
		}

		Pass{

			Tags{"LightMode" = "ShadowCaster"}
			CGPROGRAM

			#pragma multi_compile_shadowcaster

			#pragma vertex MyShadowVertexProgram
			#pragma fragment MyShadowFragmentProgram
			#include "My Shadows.cginc"
			ENDCG
		}

	}
	CustomEditor"MyLightingShaderGUI"
}
