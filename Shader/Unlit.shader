Shader "RetroGeometry/Unlit"
{
	Properties
	{
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
		_GeoRes("Geometric Resolution", Float) = 150
		[IntRange]_Posterize("Posterize", Range (1, 256) )  = 1
		[Toggle]_UVPixalate("Use UVPixalate", Float) = 0
		_Pixelate("UV Pixelate", float) = 200
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			float4 _MainColor;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _GeoRes;
			float _Posterize;
			float _Pixelate;
		    float _UVPixalate;
			
			v2f vert (appdata v)
			{
				v2f o;
                //o.vertex = UnityObjectToClipPos(v.vertex);
				float4 wp = mul(UNITY_MATRIX_MV, v.vertex);
                wp.xyz = floor(wp.xyz * _GeoRes) / _GeoRes;
                float4 sp = mul(UNITY_MATRIX_P, wp);
				o.vertex = sp;

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
			}

			float3 posterize(float3 color, float power)
			{
                float div= 256.0 / power;
                float3 pos = ( floor( color * div ) / div );
                return pos;
            }
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv;
				float s = _Pixelate;
				uv = floor(uv*s)/s;


				float4 col = 0;
			    if( _UVPixalate <= 0.5 )
				col = tex2D(_MainTex, i.uv) * _MainColor;
			    else
				col = tex2D(_MainTex, uv) * _MainColor;

				col.rgb = posterize(col.rgb,_Posterize);

                return col;
			}
			ENDCG
		}
	}
}
