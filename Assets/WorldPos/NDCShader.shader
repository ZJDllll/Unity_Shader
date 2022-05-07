Shader "Unlit/NDCShader"
{
    CGINCLUDE


#include "UnityCG.cginc"

        struct v2f
    {
        float4 vertex : SV_POSITION;
        float4 screenPos : TEXCOORD0;
        float3 ndcPos : TEXCOORD1;
        float3 viewVec : TEXCOORD2;
        float2 uv :TEXCOORD3;
    };

    v2f vert(appdata_base v)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord;
        // Compute texture coordinate
        o.screenPos = ComputeScreenPos(o.vertex);

        // NDC position
        float3 ndcPos = ((o.screenPos / o.screenPos.w) * 2 - 1).xyz;
        o.ndcPos = ndcPos;
        // Camera parameter
        float far = _ProjectionParams.z;

        // View space vector pointing to the far plane
        float3 clipVec = float3(ndcPos.x, ndcPos.y, 1.0) * far;
        o.viewVec = mul(unity_CameraInvProjection, clipVec.xyzz).xyz;

        return o;
    }

    sampler2D _CameraDepthTexture;
    float4x4 _InverseVPMatrix;

    half4 frag(v2f i) : SV_Target
    {
        // Sample the depth texture to get the linear 01 depth
        float depthTextureValue = UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, i.screenPos));
        float depth = Linear01Depth(depthTextureValue);
        
        #if defined(UNITY_REVERSED_Z)
        depthTextureValue = 1 - depthTextureValue;
        #endif

        float4 ndc = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, depthTextureValue * 2 - 1, 1);

        float4 worldPos = mul(_InverseVPMatrix, ndc);
        worldPos /= worldPos.w;
        //return worldPos;

        ndc = float4(i.ndcPos.x, i.ndcPos.y, depthTextureValue * 2 - 1, 1);








        // View space position
        float3 viewPos = i.viewVec * depth;

        // Pixel world position
        worldPos = mul(UNITY_MATRIX_I_V, float4(viewPos, 1)).xyzz;

        return float4(worldPos.xyz, 1.0);
    }
        ENDCG

        SubShader
    {
        Pass
        {
            ZTest Off
            Cull Off
            ZWrite Off
            Fog{ Mode Off }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
