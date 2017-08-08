Shader "CustomRenderTexture/Combustion"
{
    Properties
    {
		_AccelFactor ("Accel Factor", Float) = 2
		_ConsumptionRate ("Consumption Rate", Float) = 0.01
		_GrowthRate ("Growth Rate", Float) = 1.1
		_BurnCapacity ("Burn Capacity", Float) = 2
		_Diffusion ("Diffusion", Float) = 0.1
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
			uniform float _Diffusion;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
				float tw = 1 / _CustomRenderTextureWidth;
        		float th = 1 / _CustomRenderTextureHeight;
				float4 duv = float4(tw, th, -tw, 0);
				float2 uv = IN.localTexcoord.xy;
		
                float4 c = tex2D(_SelfTexture2D, uv);
				c.a = c.a * _GrowthRate * (1 + c.g * (_AccelFactor - 1))
					+ tex2D(_SelfTexture2D, uv - duv.xy).a * _Diffusion
					+ tex2D(_SelfTexture2D, uv - duv.wy).a * _Diffusion
					+ tex2D(_SelfTexture2D, uv - duv.zy).a * _Diffusion
					+ tex2D(_SelfTexture2D, uv + duv.zw).a * _Diffusion
					+ tex2D(_SelfTexture2D, uv + duv.xw).a * _Diffusion
					+ tex2D(_SelfTexture2D, uv + duv.zy).a * _Diffusion
					+ tex2D(_SelfTexture2D, uv + duv.wy).a * _Diffusion
					+ tex2D(_SelfTexture2D, uv + duv.xy).a * _Diffusion;
				if (c.a > 0)
				{
					c.r -= _ConsumptionRate;
				}
				c.a = clamp(c.a,0,_BurnCapacity * c.r);
				return c;
            }
            ENDCG
        }
    }
}