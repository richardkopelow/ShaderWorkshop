Shader "Custom/Combustible" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_HotColor ("Hot Color", Color) = (1,1,0,1)
		_CoolColor ("Cool Color", Color) = (1,0,0,1)
		_CharDarkness ("Char Darkness", Float) = 0.3
		_FuelMap ("Fuel", 2D) = "black" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _FuelMap;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _HotColor;
		fixed4 _CoolColor;
		float _CharDarkness;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			float4 fuel = tex2D (_FuelMap, IN.uv_MainTex);
			float burn = fuel.a;

			fixed4 burnCol = lerp(_CoolColor, _HotColor, burn);
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			if (fuel.b == 0)
			{
				o.Albedo = lerp(c.rgb, burnCol, burn);
			}
			else
			{
				o.Albedo = lerp(c.rgb * (_CharDarkness + (1 - _CharDarkness) * fuel.r/fuel.b), burnCol, burn);
			}
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
			o.Emission = burn * burnCol;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
