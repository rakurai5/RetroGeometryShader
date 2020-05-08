Shader "Unlit/RetroGeometric"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (0.5, 0.5, 0.5, 1)
		_GeoRes("Geometric Resolution", Float) = 40
		_Pixels("Pixels", Float) = 500
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _GeoRes;
			float _Pixels;
			
			v2f vert (appdata v)
			{
				v2f o;

				float4 wp = mul(UNITY_MATRIX_MV, v.vertex);
                wp.xyz = floor(wp.xyz * _GeoRes) / _GeoRes;
                float4 sp = mul(UNITY_MATRIX_P, wp);
				o.vertex = sp;

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				UNITY_TRANSFER_FOG(o,o.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 finalColor;
                float2 uv08 =  i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float pixelWidth7 =  1.0f / _Pixels;
				float pixelHeight7 = 1.0f / _Pixels;
				half2 pixelateduv7 = half2((int)(uv08.x / pixelWidth7) * pixelWidth7, (int)(uv08.y / pixelHeight7) * pixelHeight7);
				
				finalColor = ( tex2D( _MainTex, pixelateduv7 ) * _Color );
				return finalColor;
			}
			ENDCG
		}
	}
}
