/*
Copyright 2017 Richard Kopelow

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

Shader "Custom/SphericalDestruction" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}

		_MetallicGlossMap("Metallic", 2D) = "black" {}

		_BumpMap("Normal Map", 2D) = "bump" {}

		_EmissionMap("Emission", 2D) = "white" {}
		_DestructionColor("Disintegration Color", Color) = (1,0.5,0,1)
		_FinishRadius("Finish Radius", Float) = 1
		_DestructionThickness("Disintegration Thickness", Float) = 0.1
		_Expansion("Expansion", Range(0,1)) = 0
		_OrbsLength("Orbs Length", Int) = 0
	}
	SubShader{
		Tags { "RenderType" = "Opaque" }
		Cull Off
		LOD 200

		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Custom fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MetallicGlossMap;
		sampler2D _BumpMap;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
			float3 viewDir;
			float3 worldNormal; INTERNAL_DATA
		};

		fixed4 _Color;
		fixed4 _DestructionColor;
		float _FinishRadius;
		uniform float3 _Position;
		uniform float _DestructionThickness;
		uniform float _Expansion;
		uniform int _OrbsLength;
		uniform float4 _Orbs[10];
		int destroying;
		float3 viewDir;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf(Input IN, inout SurfaceOutputStandard o) 
		{
			viewDir = IN.viewDir;
			destroying = 0;
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			if (_Expansion > 0)
			{
				for (int i = 0; i < 4; i++)
				{
					float dist = distance(IN.worldPos - _Position, _Orbs[i].xyz);
					float destructionDistance = _Expansion * _FinishRadius + sin((IN.worldPos.x + IN.worldPos.y + IN.worldPos.z) * 30 + _Time.y * 5 + o.Normal)*0.01;
					if (dist < destructionDistance)
					{
						discard;
					}
					if (dist < destructionDistance + _DestructionThickness)
					{
						destroying = 1;
					}
				}
			}
			if (dot(o.Normal, viewDir) < -0.1)
			{
				destroying = 1;
			}

			// Albedo comes from a texture tinted by color
			
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			float4 m = tex2D(_MetallicGlossMap, IN.uv_MainTex);
			o.Metallic = m.r;
			o.Smoothness = m.a;
			//o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
			o.Alpha = c.a;
		}

		half4 LightingCustom(SurfaceOutputStandard s, half3 lightDir, UnityGI gi)
		{
			if (destroying == 1)
			{
				return _DestructionColor;
			}
			return LightingStandard(s, lightDir, gi);
		}

		void LightingCustom_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
			LightingStandard_GI(s, data, gi);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
