Shader "RetroGeometry/Lambert"

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
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

            struct v2f

            {
			    float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            float4 _MainColor;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _GeoRes;
			float _Posterize;
			float _Pixelate;
		    float _UVPixalate;

            v2f vert(appdata v)

            {
                v2f o;
                //o.vertex = UnityObjectToClipPos(v.vertex);
				float4 wp = mul(UNITY_MATRIX_MV, v.vertex);
                wp.xyz = floor(wp.xyz * _GeoRes) / _GeoRes;
                float4 sp = mul(UNITY_MATRIX_P, wp);
				o.vertex = sp;

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

			float3 posterize(float3 color, float power)
			{
                float div= 256.0 / power;
                float3 pos = ( floor( color * div ) / div );
                return pos;
            }



            fixed4 frag(v2f i) : SV_Target
            {
				float2 uv = i.uv;
				float s = _Pixelate;
				uv = floor(uv*s)/s;

                float3 normal = normalize(i.normal);
                float3 light  = normalize(_WorldSpaceLightPos0.xyz);
                //float  diffuse = saturate(dot(normal, light));
		float  diffuse = saturate(dot(normal, light))*0.5+0.5;

                float3 ambient = ShadeSH9(half4(normal, 1));
				float4 tex = 0.0;
			    if( _UVPixalate <= 0.5 )
				tex = tex2D(_MainTex, i.uv) * _MainColor;
			    else
				tex = tex2D(_MainTex, uv) * _MainColor;

				//float4 tex = tex2D(_MainTex, uv) * _MainColor;
				tex.rgb = posterize(tex.rgb,_Posterize);

				float4 lightcol = clamp(_LightColor0,0.0,1.0);

                float4 color = tex * (diffuse * lightcol);

                color.rgb += tex.rgb * ambient;
                return color;
            }

            ENDCG

        }

    }

}
