Shader "Unlit/NDCWorld"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScanWidth("ScanWidth",float) = 1.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 viewVec : TEXCOORD0;
                half2 uv[9] : TEXCOORD1;
            };

            float4x4 _InvProjection;
            float4x4 _ViewToWorld;

            sampler2D _MainTex;
             //纹理映射到[0,1]之后的大小,用于计算相邻区域的纹理坐标
             half4 _MainTex_TexelSize;

            //计算对应像素的最低灰度值并返回
             fixed minGrayCompute(v2f i,int idx) 
             {
                 return Luminance(tex2D(_MainTex, i.uv[idx]));
             }
            //利用Sobel算子计算最终梯度值
             half sobel(v2f i) 
             {
                 const half Gx[9] = {
                     - 1,0,1,
                     - 2,0,2,
                     - 1,0,1
                 };
                 const half Gy[9] = {
                     -1,-2,-1,
                      0, 0, 0,
                      1, 2, 1
                 };
                 //分别计算横向和纵向的梯度值，方法为各项对应元素相乘并相加
                 half graX = 0;
                 half graY = 0;
 
                 for (int it = 0; it < 9; it++) 
                 {
                     graX += Gx[it] * minGrayCompute(i, it);
                     graY += Gy[it] * minGrayCompute(i, it);
                 }
                 //绝对值相加近似模拟最终梯度值
                 return abs(graX) + abs(graY);
              }


            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // Compute texture coordinate
                float4 screenPos = ComputeScreenPos(o.vertex);

                // NDC position
                float4 ndcPos = (screenPos / screenPos.w) * 2 - 1;

                // Camera parameter
                float far = _ProjectionParams.z;

                // View space vector pointing to the far plane
                float3 clipVec = float3(ndcPos.x, ndcPos.y, 1.0) * far;
                o.viewVec = mul(_InvProjection, clipVec.xyzz).xyz;



                half2 uv = screenPos.xy;
                 half2 size = _MainTex_TexelSize.xy;
                 //float2 size = float2(1.0/1920.0,1.0/1080);
                 //计算周围像素的纹理坐标位置，其中4为原始点，右侧乘积因子为偏移的像素单位，坐标轴为左下角原点，右上为+x,+y方向，与uv的坐标轴匹配
                 o.uv[0] = uv + size * half2(-1, 1);
                 o.uv[1] = uv + size * half2(0, 1);
                 o.uv[2] = uv + size * half2(1, 1);
                 o.uv[3] = uv + size * half2(-1, 0);
                 o.uv[4] = uv + size * half2(0, 0);
                 o.uv[5] = uv + size * half2(1, 0);
                 o.uv[6] = uv + size * half2(-1, -1);
                 o.uv[7] = uv + size * half2(0, -1);
                 o.uv[8] = uv + size * half2(1, -1);


                return o;
            }

            sampler2D _CameraDepthTexture;

            float4 _WorldSpaceScannerPos;
	        float _ScanDistance;
            
            float _ScanWidth;
            float _Temp1;
            float _Temp2;


            float GetSinLine(float pixelDistance)
            {
               return 1-saturate(round(sin(pixelDistance * _Temp1)+_Temp2));
            }

            //可视化线条样式
            float4 VisualizePosition(float3 pos)
            {
                const float grid  = 5;
                const float width = 3;

                pos *= grid;

                // Detect borders with using derivatives.
                float3 fw = fwidth(pos);
                float3 bc = saturate(width - abs(1 - 2 * frac(pos)) / fw);

                // Frequency filter
                float3 f1 = smoothstep(1 / grid, 2 / grid, fw);
                float3 f2 = smoothstep(2 / grid, 4 / grid, fw);
                bc = lerp(lerp(bc, 0.5, f1), 0, f2);

                // Blend with the source color.
                //half4 c = SAMPLE_TEXTURE2D(_MainTex, sampler_linear_repeat , texcoord);
                //c.rgb = SRGBToLinear(lerp(LinearToSRGB(c.rgb), bc, 0.3));

                return float4(bc,1);
            }

            half4 frag(v2f i) : SV_Target
            {
                float4 outColor = tex2D(_MainTex,i.uv[4]);
                // Sample the depth texture to get the linear 01 depth
                float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv[4]));
                depth = Linear01Depth(depth);

                // View space position
                float3 viewPos = i.viewVec * depth;

                // Pixel world position
                float3 worldPos = mul(_ViewToWorld, float4(viewPos, 1)).xyz;

                float gra = sobel(i);

                float dis = distance(worldPos,_WorldSpaceScannerPos);
                float4 lineValue = VisualizePosition(worldPos);

                
                //float percent = 0;
                //if (_ScanDistance - dis > 0 && depth < 1)
                //{
                //    float scanPercent = 1 - (_ScanDistance - dis) / _ScanWidth;
                //    float maxPercent = 1 - (100 - dis) / _ScanWidth;
                //    percent = lerp(1, 0, saturate(scanPercent / maxPercent));
                //}

                float4 scannerCol = float4(0,0,0,0);

                float percent = 0;
                if(dis<_ScanDistance)
                {
                    if(dis>_ScanDistance - _ScanWidth)
                    {
                        float diff = 1 - (_ScanDistance - dis)/(_ScanWidth);
                        float4 edge = lerp(float4(1,0,0,1),float4(0,1,0,1),pow(diff,3));
                        scannerCol = lerp(float4(0,0,1,1),edge,diff);
                        scannerCol *=diff;
                    }
                    float diss = _ScanDistance - dis;
                    diss /=20;
                    percent = 1 - smoothstep(0.9,1,diss);

                }

                //return lineValue;
                
                
                float4 _lineColor = float4(0,1,0,0);

                float centerCircleMask = saturate(pow(dis / 5, 2));//中间透明区

                //扩散颜色 + 原本颜色 + 全屏特效颜色(圆环或网格) + 边缘检测颜色
                return scannerCol+ outColor; //+ percent * lineValue * centerCircleMask + percent * gra *  float4(1,0.1,0.2,1);
                //扩散颜色 + 圆环颜色 + 边缘检测颜色 + 原本颜色
                //return pow(percent,30) * _lineColor * centerCircleMask + pow(percent,10) * lineValue* centerCircleMask + percent * gra *  float4(1,0.1,0.2,1) + outColor;





                return float4(gra,gra,gra, 1.0);
            }
            ENDCG
        }
    }
}
