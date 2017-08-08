Shader "CustomRenderTexture/Combustion"
{
    Properties
    {
		_AccelFactor ("Accel Factor", Float) = 2
		_ConsumptionRate ("Consumption Rate", Float) = 0.01
		_GrowthRate ("Growth Rate", Float) = 1.1
		_BurnCapacity ("Burn Capacity", Float) = 2
    }
     SubShader
     {
		Name "Update"
        Lighting Off
        Blend One Zero

        Pass
        {
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 3.0

			uniform float _AccelFactor;
			uniform float _GrowthRate;
			uniform float _ConsumptionRate;
			uniform float _BurnCapacity;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
				float tw = 1 / _CustomRenderTextureWidth;
        		float th = 1 / _CustomRenderTextureHeight;
				float4 duv = float4(tw, th, -tw, 0);
				float2 uv = IN.localTexcoord.xy;
		
                float4 c = tex2D(_SelfTexture2D, uv);
				c.a = c.a * _GrowthRate * (1 + c.g * (_AccelFactor - 1))
					+ tex2D(_SelfTexture2D, uv - duv.xy).a * 0.05
					+ tex2D(_SelfTexture2D, uv - duv.wy).a * 0.10
					+ tex2D(_SelfTexture2D, uv - duv.zy).a * 0.05
					+ tex2D(_SelfTexture2D, uv + duv.zw).a * 0.10
					+ tex2D(_SelfTexture2D, uv + duv.xw).a * 0.10
					+ tex2D(_SelfTexture2D, uv + duv.zy).a * 0.05
					+ tex2D(_SelfTexture2D, uv + duv.wy).a * 0.10
					+ tex2D(_SelfTexture2D, uv + duv.xy).a * 0.05;
				c.r -= c.a * _ConsumptionRate;
				c.a = clamp(c.a,0,_BurnCapacity * c.r);
				return c;
            }
            ENDCG
        }
    }
}