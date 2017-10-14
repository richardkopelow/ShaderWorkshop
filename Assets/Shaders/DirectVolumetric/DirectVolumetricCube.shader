Shader "Custom/DirectVolumetricCube" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_AlphaScale("Alpha Scale", Float) = 1
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Position("Position", Vector) = (0,0,0,0)
		_Dimensions("Dimensions", Vector) = (0,0,0,0)
	}
	SubShader {
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alpha:fade

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
			float3 viewDir;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _AlphaScale;
		float3 _Position;
		float3 _Dimensions;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

			void surf(Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			//o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;

			float3 localPos = IN.worldPos - _Position;
			float3 halfDim = _Dimensions / 2;
			float3 posCof = (halfDim - localPos) / -IN.viewDir;
			float3 negCof = (-halfDim - localPos) / -IN.viewDir;
			float d = 10;
			if (posCof.x>0.001)
			{
				d = posCof.x;
			}
			if (posCof.y>0.001&&posCof.y<d)
			{
				d = posCof.y;
			}
			if (posCof.z>0.001 && posCof.z<d)
			{
				d = posCof.z;
			}
			if (negCof.x>0.001 && negCof.x<d)
			{
				d = negCof.x;
			}
			if (negCof.y>0.001 && negCof.y<d)
			{
				d = negCof.y;
			}
			if (negCof.z>0.001 && negCof.z<d)
			{
				d = negCof.z;
			}
			if (d == 10)
			{
				d = 0;
			}
			o.Alpha = clamp(c.a *d*_AlphaScale, 0, 1);
			o.Albedo = c.rgb;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
