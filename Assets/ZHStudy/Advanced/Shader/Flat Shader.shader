// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"GT/Flat Wireframe"{
	
	Properties{
		_Color("Tint",Color) = (1,1,1,1)
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

		[NoScaleOffset]_ParallaxMap("Parallax",2D) = "black"{}
		_ParallaxStrength("Parallax Strength",Range(0,0.1)) = 0

		[NoScaleOffset]_EmissionMap("Emission",2D) = "black"{}
		_Emission("Emission",Color) = (0,0,0)

		[NoScaleOffset] _OcclusionMap("Occlusion",2D) = "white"{}
		_OcclusionStrength("Occlusion Strength",Range(0,1))=1

		[NoScaleOffset] _DetailMask("Detail Mask",2D)="White"{}

		_Cutoff("Alpha Cutoff",Range(0.01,1)) = 0.5

		[HideInInspector]_SrcBlend("_SrcBlend",Float) = 1
		[HideInInspector]_DstBlend("_DstBlend",Float) = 0
		[HideInInspector]_ZWrite("_ZWrite",Float) = 1

		_WireframeColor("Wireframe Color",Color) = (0,0,0)
		_WireframeSmoothing("Wireframe Smoothing",Range(0,10)) = 1
		_WireframeThickness("Wireframe Thickness",Range(0,10)) = 1
	}

	SubShader{
		Pass{

			Tags{"LightMode"="ForwardBase"}

			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]
			CGPROGRAM

			#pragma target 4.0

			//#pragma multi_compile _ VERTEXLIGHT_ON LIGHTMAP_ON
			//#pragma multi_compile _ SHADOWS_SCREEN
			#pragma multi_compile_fwdbase

			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_instancing
			#pragma instancing_options lodfade


			#pragma shader_feature _ _RENDERING_CUTOUT _RENDERING_FADE _RENDERING_TRANSPARENT
			#pragma shader_feature _METALLIC_MAP
			#pragma shader_feature _ _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC
			#pragma shader_feature _EMISSION_MAP
			#pragma shader_feature _OCCLUSION_MAP
			#pragma shader_feature _DETAIL_MASK
			#pragma shader_feature _NORMAL_MAP
			#pragma shader_feature _DETAIL_ALBEDO_MAP
			#pragma shader_feature _DETAIL_NORMAL_MAP
			#pragma shader_feature _PARALLAX_MAP
			#pragma multi_compile_fog

			// #define PARALLAX_BIAS 0
			//#define PARALLAX_OFFSET_LIMITING
			//#define FOG_DISTANCE
			#define PARALLAX_FUNCTION ParallaxRaymarching
			#define FORWARD_BASE_PASS
			#define PARALLAX_RAYMARCHING_STEPS 10
			#define PARALLAX_RAYMARCHING_INTERPOLATE
			//#define PARALLAX_RAYMARCHING_SEARCH_STEPS 6
			//#define PARALLAX_SUPPORT_SCALED_DYNAMIC_BATCHING

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgrm
			#pragma geometry MyGeometryProgram
			
			//#include "Assets/ZH/LightScene/Shader/MyLighting.cginc"
			#include "MyFlatWireframe.cginc"

			ENDCG
		}

		Pass{

			Tags{"LightMode"="ForwardAdd"}
			Blend [_SrcBlend] One
			ZWrite Off
			CGPROGRAM

			#pragma target 4.0

			//#pragma multi_compile DIRECTIONAL DIRECTIONAL_COOKIE POINT SPOT
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			//#pragma multi_compile _ _METALLIC_MAP
			#pragma shader_feature _METALLIC_MAP
			#pragma shader_feature _ _RENDERING_CUTOUT _RENDERING_FADE _RENDERING_TRANSPARENT
			#pragma shader_feature _DETAIL_MASK
			#pragma shader_feature _ _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC
			#pragma shader_feature _NORMAL_MAP
			#pragma shader_feature _DETAIL_ALBEDO_MAP
			#pragma shader_feature _DETAIL_NORMAL_MAP
			#pragma shader_feature _PARALLAX_MAP

			#pragma multi_compile_fog

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgrm
			#pragma geometry MyGeometryProgram
			
			//#include "Assets/ZH/LightScene/Shader/MyLighting.cginc"
			#include "MyFlatWireframe.cginc"
	
			ENDCG
		}

		Pass{
			Tags{
				"LightMode" = "Deferred"
			}
			CGPROGRAM

			#pragma target 4.0
			#pragma exclude_renderers nomrt
			

			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_instancing
			#pragma instancing_options lodfade

			#pragma shader_feature _ _RENDERING_CUTOUT
			#pragma shader_feature _METALLIC_MAP
			#pragma shader_feature _ _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC
			#pragma shader_feature _EMISSION_MAP
			#pragma shader_feature _OCCLUSION_MAP
			#pragma shader_feature _DETAIL_MASK
			#pragma shader_feature _NORMAL_MAP
			#pragma shader_feature _DETAIL_ALBEDO_MAP
			#pragma shader_feature _DETAIL_NORMAL_MAP
			#pragma shader_feature _PARALLAX_MAP
			
			//#pragma multi_compile _ UNITY_HDR_ON
			//#pragma multi_compile _ LIGHTMAP_ON

			#pragma multi_compile_prepassfinal
			
			#define DEFERRED_PASS

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgrm
			#pragma geometry MyGeometryProgram
			
			//#include "Assets/ZH/LightScene/Shader/MyLighting.cginc"
			#include "MyFlatWireframe.cginc"

			ENDCG
		}

		Pass{

			Tags{"LightMode" = "ShadowCaster"}
			CGPROGRAM


			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing
			#pragma instancing_options lodfade

			#pragma shader_feature _ _RENDERING_CUTOUT _RENDERING_FADE _RENDERING_TRANSPARENT
			#pragma shader_feature _SMOOTHNESS_ALBEDO
			#pragma shader_feature _SEMITRANSPARENT_SHADOWS

			#pragma vertex MyShadowVertexProgram
			#pragma fragment MyShadowFragmentProgram
			#include "Assets/ZH/LightScene/Shader/My Shadows.cginc"
			ENDCG
		}

		Pass{
			Tags{"LightMode" = "Meta"}

			Cull Off

			CGPROGRAM
			#pragma vertex MyLightmappingVertexProgram
			#pragma fragment MyLightmappingFragmentProgram

			#pragma shader_feature _METALLIC_MAP
			#pragma shader_feature _ _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC
			#pragma shader_feature _EMISSION_MAP
			#pragma shader_feature _DETAIL_MASK
			#pragma shader_feature _DETAIL_ALBEDO_MAP

			#include "Assets/ZH/LightScene/Shader/MyLightmapping.cginc"
			ENDCG
		}

	}
	CustomEditor"MyLightingShaderGUI"
}
