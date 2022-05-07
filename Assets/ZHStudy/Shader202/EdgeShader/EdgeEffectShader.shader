Shader "Hidden/EdgeEffectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            ZTest always
             Cull off
             ZWrite off
 
             CGPROGRAM
             #pragma vertex vert
             #pragma fragment frag
             
             #pragma multi_compile_fog
 
             #include "UnityCG.cginc"
 
             struct appdata
             {
                 float4 vertex : POSITION;
                 float2 uv : TEXCOORD0;
             };
 
             struct v2f
             {
                 half2 uv[9] : TEXCOORD0;
                 UNITY_FOG_COORDS(1)
                 float4 pos : SV_POSITION;
             };
 
             sampler2D _MainTex;
             //纹理映射到[0,1]之后的大小,用于计算相邻区域的纹理坐标
             half4 _MainTex_TexelSize;
             //定义控制脚本中对应的参数
             fixed _EdgeOnly;
             fixed4 _EdgeColor;
             fixed4 _BackgroundColor;
 
             v2f vert (appdata v)
             {
                 v2f o;
                 o.pos = UnityObjectToClipPos(v.vertex);
 
                 half2 uv = v.uv;
                 //half2 size = _MainTex_TexelSize.xy;
                 float2 size = float2(1.0/1920.0,1.0/1080);
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
 
                 UNITY_TRANSFER_FOG(o,o.pos);
                 return o;
             }
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
 
             fixed4 frag (v2f i) : SV_Target
             {
                 half gra = sobel(i);
                 fixed4 col = tex2D(_MainTex, i.uv[4]);
                 //利用得到的梯度值进行插值操作，其中梯度值越大，越接近边缘的颜色
                 fixed4 withEdgeColor = lerp( col, _EdgeColor, gra);
                 fixed4 onlyEdgeColor = lerp( _BackgroundColor, _EdgeColor, gra);
                 fixed4 color = lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
                    
                 //return float4(gra,gra,gra,1);
                 UNITY_APPLY_FOG(i.fogCoord, color);
                 return color;
             }
             ENDCG
         }
    }
}
