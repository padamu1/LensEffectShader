Shader "SimulFactory/Shader/LensEffectMaterial"
{
    Properties
    {
        [PerRendererData]_MainTex ("Sprite Texture", 2D) = "white" {}
	    _LensXY ("LensXY", vector) = (0, 0, 0, 0)
        _LensSize ("LensSize", float) = 10
        _LensMaxSize ("LensMaxSize", float) = 10
        _LensGradientSize ("LensGradientSize", float) = 3
        _ScreenWidth ("ScreenWidth", float) = 3
        _ScreenHeight ("ScreenHeight", float) = 3
    }

    SubShader
    {
        Tags {
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }
        
        Pass
        {
            Name "LensEffect"
            Tags { "LightMode"="SRPDefaultUnlit" }

            Stencil
            {
                Ref 0
                Comp Always
                Pass Keep
            }

            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGBA

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct vert_input 
            { 
                float4 vertex : POSITION; 
                float2 uv : TEXCOORD0;                 
			    half4 color : COLOR;
            };
            struct pixel_input
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                half4 color : COLOR;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            float4 _LensXY;
            float _LensSize;
            float _LensMaxSize;
            float _LensGradientSize;
            float _ScreenWidth;
            float _ScreenHeight;

            pixel_input vert(vert_input v)
            {
                pixel_input o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            half4 frag(pixel_input i) : SV_Target
            {
                float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * i.color;

                float2 lensCenter = _LensXY.xy;
                float2 screenUV = i.uv;
                

                if (_ScreenHeight > _ScreenWidth)
                {
                    float aspect = _ScreenHeight / _ScreenWidth;
                    screenUV.x /= aspect;
                    lensCenter.x /= aspect;
                }
                else
                {
                    float aspect = _ScreenHeight / _ScreenWidth;
                    screenUV.x /= aspect;
                    lensCenter.x /= aspect;
                }

                float dist = distance(screenUV, lensCenter);

                float radius = (_LensSize - _LensGradientSize * 0.1) / _LensMaxSize;

                float alpha = smoothstep(radius, radius + (_LensGradientSize * 0.01), dist);

                texColor.a = alpha;

                return texColor;
            }
            ENDHLSL
        }
    }
}
