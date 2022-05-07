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
             //����ӳ�䵽[0,1]֮��Ĵ�С,���ڼ��������������������
             half4 _MainTex_TexelSize;
             //������ƽű��ж�Ӧ�Ĳ���
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
                 //������Χ���ص���������λ�ã�����4Ϊԭʼ�㣬�Ҳ�˻�����Ϊƫ�Ƶ����ص�λ��������Ϊ���½�ԭ�㣬����Ϊ+x,+y������uv��������ƥ��
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
             //�����Ӧ���ص���ͻҶ�ֵ������
             fixed minGrayCompute(v2f i,int idx) 
             {
                 return Luminance(tex2D(_MainTex, i.uv[idx]));
             }
             //����Sobel���Ӽ��������ݶ�ֵ
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
                 //�ֱ��������������ݶ�ֵ������Ϊ�����ӦԪ����˲����
                 half graX = 0;
                 half graY = 0;
 
                 for (int it = 0; it < 9; it++) 
                 {
                     graX += Gx[it] * minGrayCompute(i, it);
                     graY += Gy[it] * minGrayCompute(i, it);
                 }
                 //����ֵ��ӽ���ģ�������ݶ�ֵ
                 return abs(graX) + abs(graY);
              }
 
             fixed4 frag (v2f i) : SV_Target
             {
                 half gra = sobel(i);
                 fixed4 col = tex2D(_MainTex, i.uv[4]);
                 //���õõ����ݶ�ֵ���в�ֵ�����������ݶ�ֵԽ��Խ�ӽ���Ե����ɫ
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
