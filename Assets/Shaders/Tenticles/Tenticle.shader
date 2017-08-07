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

Shader "Unlit/Tenticle"
{
	Properties
	{
		_Color("Color", Color) = (0,0,0,0.5)
		_AlphaScale("Alpha Scale", Float) = 1
		_Tentacles("Tentacles", Int) = 5
	}
		SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 100

		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
		// make fog work
#pragma multi_compile_fog

#include "UnityCG.cginc"

	struct v2f
	{
		float2 uv : TEXCOORD0;
		UNITY_FOG_COORDS(1)
		float4 vertex : SV_POSITION;
		float3 wPos : TEXCOORD1;
	};

	float4 _Color;
	float _AlphaScale;
	int _Tentacles;
	uniform float3 _Position;

	float box(float3 p, float3 b)
	{
		return length(max(abs(p) - b, 0.0));
	}

	float cone(float3 p, float2 c)
	{
		// c must be normalized
		float q = length(p.xz);
		return dot(c, float2(q, p.y));
	}
	float tentacles(float3 p, float2 c)
	{
		float d = 400;
		for (int i = 0; i < _Tentacles; i++)
		{
			float angle = 6.28318 * (float)i / _Tentacles;
			float tangentAngle = angle + 1.570795;
			float3 circlePos = float3(cos(angle), 0, sin(angle));
			float3 conePoint = p + circlePos*2/5 + float3(cos(tangentAngle), 0, sin(tangentAngle))*sin(_Time.w+p.y*4)*0.1;
			d = min(d, cone(conePoint, c));
		}
		return d;
	}

	float getAlpha(float3 pos, float3 dir)
	{
		int count = 0;
		int alphaCount = 0;
		float3 step = dir*0.01;
		float3 p = pos + (step*count);
		float d = box(p, 0.6);
		while (d <= 0)
		{
			if (tentacles(p, normalize(float2(0.5, 0.1))) <= 0)
			{
				alphaCount++;
			}
			count++;
			p = pos + (step*count);
			d = box(p, 0.5);
		}
		return _Color.a*_AlphaScale*0.02*alphaCount;
	}

	v2f vert(appdata_base v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		//float wave = sin((_Time.y + o.vertex.x) * 5) + -sin((-_Time.y + o.vertex.x) * 5);
		//o.vertex.xyz += v.normal*0.1*wave;
		o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		UNITY_TRANSFER_FOG(o, o.vertex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		float3 viewDir = normalize(i.wPos - _WorldSpaceCameraPos);
		// sample the texture
		fixed4 col = _Color;
		col.a = getAlpha(i.wPos - _Position, viewDir);
		if (col.a > 1)
		{
			col.a = 1;
		}
		// apply fog
		UNITY_APPLY_FOG(i.fogCoord, col);
		return col;
	}

		ENDCG
	}
	}
}
