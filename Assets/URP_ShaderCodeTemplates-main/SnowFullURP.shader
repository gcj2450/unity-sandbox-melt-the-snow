//HuggingFace翻译的Snow Shader
Shader "Custom/CustomSnowShaderURP" {
    Properties {
        _Ramp("Shade (RGB)", 2D) = "white" {}
        _RampPower("Shade Intensity", Range(0.0, 1.0)) = 1.0
        _MainTex("Diffuse (RGB)", 2D) = "white" {}
        _GlitterTex("Specular (RGB)", 2D) = "black" {}
        _Specular("Specular Intensity", Range(0.0, 5.0)) = 1.0
        _Shininess("Shininess", Range(0.01, 1.0)) = 0.08
        _Aniso("Anisotropic Mask", Range(0.0, 1.0)) = 0.0
        _Glitter("Anisotropic Intensity", Range(0.0, 15.0)) = 0.5
        _BumpTex("Normal (RGB)", 2D) = "bump" {}
        _DepthTex("Depth (R)", 2D) = "white" {}
        _Depth("Translucency", Range(-2.0, 1.0)) = 1.0
        _Coverage("Coverage", Range(-0.01, 1.001)) = 0.5
        _SubNormal("SubNormal (RGB)", 2D) = "bump" {}
        _Spread("Spread", Range(0.0, 1.0)) = 1.0
        _Smooth("Smooth", Range(0.01, 5.0)) = 0.5
        _Transition("Transition", Range(-1.0, 1.0)) = 0.5
        _TransitionSmooth("Transition Smoothness", Range(0.0, 2.0)) = 0.5
        _Direction("Direction", Vector) = (0, 1, 0)
        _Cube				("Cubemap (RGB)", CUBE)						= "" {}
        _Reflection			("Reflection Intensity", Range(0.0, 1.0))	= 0.5
        _Falloff			("Reflection Falloff", Range(0.1, 3.0))		= 0.5
    }

    SubShader {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags { "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" "IgnoreProjector"="True" }
        Offset 0, -1
        ZWrite Off
        LOD 300

        Pass {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _ADDITIONAL_LIGHTS _ADDITIONAL_LIGHT_SHADOWS _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            #pragma multi_compile _ _DIRLIGHTMAP_COMBINED _DIRLIGHTMAP_SEPARATE
            #pragma multi_compile _ _LIGHTMAP_ON
            #pragma multi_compile _ _DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ _SHADOWS_SHADOWMASK
            #pragma multi_compile _ _VERTEX_LIGHTS
            #pragma multi_compile _ _NORMALMAP
            #pragma multi_compile _ _SPECULAR_SETUP

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_BumpTex : TEXCOORD1;
                float2 uv_GlitterTex : TEXCOORD2;
                float2 uv_SubNormal : TEXCOORD3;
                float3 worldNormal : TEXCOORD4;
                float3 viewDirWS : TEXCOORD5;
                float3 worldRefl : TEXCOORD6;
                float3 worldPos : TEXCOORD7;
            };

            TEXTURE2D(_Ramp);
            SAMPLER(sampler_Ramp);

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_BumpTex);
            SAMPLER(sampler_BumpTex);

            TEXTURE2D(_DepthTex);
            SAMPLER(sampler_DepthTex);

            TEXTURE2D(_SubNormal);
            SAMPLER(sampler_SubNormal);

            TEXTURE2D(_GlitterTex);
            SAMPLER(sampler_GlitterTex);

            TEXTURECUBE(_Cube);           // 声明立方体贴图
            SAMPLER(sampler_Cube);        // 声明立方体贴图的采样器

            float _RampPower;
            float _Glitter;
            float _Aniso;
            float _Shininess;
            float _Specular;
            float _Depth;
            float _Coverage;
            float _Spread;
            float _Smooth;
            float _Transition;
            float _TransitionSmooth;
            float3 _Direction;
            float _Reflection;
            float _Falloff;

            Varyings Vert(Attributes input) {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.uv = input.uv;
                output.uv_BumpTex = input.uv;
                output.uv_GlitterTex = input.uv;
                output.uv_SubNormal = input.uv;
                output.worldNormal = TransformObjectToWorldNormal(input.normalOS);
                output.viewDirWS = GetWorldSpaceViewDir(input.positionOS);
                output.worldRefl = reflect(-output.viewDirWS, output.worldNormal);
                output.worldPos = mul(unity_ObjectToWorld, input.positionOS).xyz;
                return output;
            }

            half4 Frag(Varyings input) : SV_Target {
                half3 normal = UnpackNormal(SAMPLE_TEXTURE2D(_BumpTex, sampler_BumpTex, input.uv_BumpTex));
                half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                half3 depth = SAMPLE_TEXTURE2D(_DepthTex, sampler_DepthTex, input.uv_SubNormal);
                half3 subnormal = UnpackNormal(SAMPLE_TEXTURE2D(_SubNormal, sampler_SubNormal, input.uv_SubNormal));
                half3 glitter = SAMPLE_TEXTURE2D(_GlitterTex, sampler_GlitterTex, input.uv_GlitterTex);

                half3 worldNormal = input.worldNormal;
                half3 viewDirWS = normalize(input.viewDirWS);
                half3 lightDirWS = normalize(_MainLightPosition.xyz);
                half3 H = normalize(lightDirWS + viewDirWS);
                half NdotH = max(0, dot(worldNormal, H));
                half NdotL = dot(worldNormal, lightDirWS);
                half NdotV = dot(worldNormal, viewDirWS);

                half3 shadow = _MainLightColor.rgb * NdotL;

                half3 albedoColor = albedo.rgb * _MainLightColor.rgb;
                half2 uv_Ramp = half2(_RampPower * NdotV, NdotL);
                half3 ramp = SAMPLE_TEXTURE2D(_Ramp, sampler_Ramp, uv_Ramp);

                half ssatten = 1.0;

                if (0.0 != _MainLightPosition.w) {
                    half depthValue = clamp(_Depth + _Depth, -1, 1);
                    half ssdepth = lerp(NdotL, 1, depthValue + saturate(dot(worldNormal, -NdotL)));
                    ssatten = shadow * ssdepth;
                    ramp = ramp * ssatten;
                }

                half3 specular = saturate(pow(NdotH, _Shininess * 128.0) * _Specular * glitter);
                half3 anisotropic = max(0, sin(radians((NdotH + _Aniso) * 180))) * ssatten;
                anisotropic = saturate(glitter * anisotropic * _Glitter);

                half3 finalColor = albedoColor * ramp + (anisotropic + specular) * shadow;

                half3 worldRefl = normalize(input.worldRefl);
                half falloff = 1.0 - saturate(dot(worldNormal, normalize(input.viewDirWS)));
                falloff = pow(falloff, _Falloff);
                half3 reflection = (SAMPLE_TEXTURECUBE(_Cube, sampler_Cube, worldRefl).rgb * _Reflection) * falloff;
                finalColor += reflection;

                float3 NdotD	= dot(worldNormal, normalize(_Direction.xyz));	// Cross product for WorldNormal and Direction
                
                half coverage	= NdotD - lerp(1, -1, _Coverage);
                // half coverage = dot(worldNormal, normalize(_Direction));
                coverage = saturate(coverage / _Spread);
                half subheightcoverage = depth.g - lerp(1, -1, coverage);
                half subnormalcoverage = NdotD - lerp(1, -1, subheightcoverage + _Transition);
                subnormalcoverage = saturate(subnormalcoverage / _TransitionSmooth);
                subheightcoverage = saturate(subheightcoverage / _Smooth);

                half3 finalNormal = lerp(subnormal, normal, subnormalcoverage);

                return half4(finalColor, subheightcoverage);
            }

            ENDHLSL
        }
    }
    // FallBack "VertexLit"
}