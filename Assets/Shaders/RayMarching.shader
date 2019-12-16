Shader "RayMarching"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}

		SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"

			uniform float _CameraMaxDistance;
			uniform float4x4 _CameraToWorldMartix;
			uniform float4x4 _CameraFrustrum;
			uniform float _RayMarchAccuracy = 0.001;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 ray : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				half index = v.vertex.z;
				v.vertex.z = 0;

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.ray = _CameraFrustrum[(int)index].xyz;
				o.ray /= abs(o.ray.z);
				o.ray = mul(_CameraToWorldMartix, o.ray);

				return o;
			}

			float Sphere(float3 p, float s)
			{
				return length(p) - s;
			}

			float GetDistance(float3 p)
			{
				float3 pos = p - float3(0, sin(_Time.z), 0);

				pos = fmod(abs(pos), .45 + sin(_Time.z / 2) * .2) + .5;

				float sphere1 = Sphere(pos, 0.05);
				float sphere2 = Sphere(p - float3(0, -sin(_Time.z), 0), 4.25);
				return lerp(sphere1, sphere2, .35 + sin(_Time.z * 3) / 3.14 * .25);
			}

			float3 GetNormal(float3 p)
			{
				float d = GetDistance(p);
				float2 e = float2(_RayMarchAccuracy, 0);

				return normalize(d - float3 (GetDistance(p - e.xyy), GetDistance(p - e.yxy), GetDistance(p - e.yyx)));
			}

			float GetLigth(float3 p)
			{
				float3 lp = float3(0, 2, 0);
				
				float3 l = normalize(lp - p);
				float3 n = GetNormal(p);

				return abs(dot(n, 1));
			}

			fixed4 RayMarching(float3 ro, float3 rd)
			{
				fixed4 result = fixed4(1, 1, 1, 1);
				const int max_iteration = 128;

				float t = 0;

				for (int i = 0; i < max_iteration; i++)
				{
					if (t > _CameraMaxDistance)
					{
						result = fixed4(rd, 1);
						break;
					}

					float3 p = ro + rd * t;
					float d = GetDistance(p);
					if (d < _RayMarchAccuracy)
					{
						float light = GetLigth(p);
						result = fixed4(light, light, light, 1);
						break;
					}

					t += d;
				}

				return result;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 rayDir = normalize(i.ray);
				float3 rayOrigin = _WorldSpaceCameraPos;

				return RayMarching(rayOrigin, rayDir);
			}
			ENDCG
		}
	}
}
