//自定义光照模型版本
Shader "Custom/URP/CustomLightingSnow"
{
    Properties
    {
        _Ramp ("Shade (RGB)", 2D) = "white" {}
        _RampPower ("Shade Intensity", Range(0.0, 1.0)) = 1.0
        _MainTex ("Base Color (RGB)", 2D) = "white" {}
        _GlitterTex ("Specular Map (RGB)", 2D) = "black" {}
        _Specular ("Specular Intensity", Range (0.0, 5.0)) = 1.0
        _Shininess ("Shininess", Range (0.01, 1.0)) = 0.08
        _Aniso ("Anisotropic Mask", Range (0.0, 1.0)) = 0.0
        _Glitter ("Anisotropic Intensity", Range (0.0, 15.0)) = 0.5
        _BumpTex ("Normal (RGB)", 2D) = "bump" {}
        _DepthTex ("Depth (R)", 2D) = "white" {}
        _Depth ("Translucency", Range(-2.0, 1.0)) = 1.0
        _Coverage ("Coverage", Range (-0.01, 1.001)) = 0.5
        _SubNormal ("SubNormal (RGB)", 2D) = "bump" {}
        _Spread ("Spread", Range (0.0, 1.0)) = 1.0
        _Smooth ("Smooth", Range (0.01, 5.0)) = 0.5
        _Transition ("Transition", Range (-1.0, 1.0)) = 0.5
        _TransitionSmooth ("Transition Smoothness", Range (0.0, 2.0)) = 0.5
        _Direction ("Direction", Vector) = (0, 1, 0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }
            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag
			#define SNOW_BLEND_ADVANCED
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // 定义属性和全局变量
            TEXTURE2D(_Ramp);
            SAMPLER(sampler_Ramp);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_GlitterTex);
            SAMPLER(sampler_GlitterTex);
            TEXTURE2D(_BumpTex);
            SAMPLER(sampler_BumpTex);
            TEXTURE2D(_DepthTex);
            SAMPLER(sampler_DepthTex);
            TEXTURE2D(_SubNormal);
            SAMPLER(sampler_SubNormal);

            half 		_RampPower;
			half		_Glitter;
			half		_Aniso;
			half		_Shininess;
			half		_Specular;
			float		_Depth;
			#ifdef SNOW_BLEND_ADVANCED
				half4		_Direction;
				half		_Coverage;
			#endif
			#ifdef SNOW_BLEND_HEIGHT
				half		_Height;
			#endif
			#if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
				half		_Spread;
				half		_Smooth;
				half		_Transition;
				half		_TransitionSmooth;
			#endif
			#ifdef SNOW_REFLECTION
				half		_Reflection;
				half		_Falloff;
			#endif
			#ifdef SNOW_GLITTER
				half4		_SpecularColor;
				half		_Speed;
				half		_Density;
				half		_DensityStatic;
				half		_Power;
			#endif


            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_BumpTex : TEXCOORD5;
                float2 uv_GlitterTex : TEXCOORD6;
				float2	uv_SubNormal: TEXCOORD7;
                float3 normalWS : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                float3 tangentWS : TEXCOORD4;
            };

            struct SnowOutput
            {
                half3 Albedo;
                half3 Normal;
                half3 Emission;
                half3 Specular;
                half Alpha;
                half Depth;
            };

            Varyings Vert(Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS);
                o.uv_MainTex = v.uv;
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.worldPos = TransformObjectToWorld(v.positionOS.xyz);
                o.viewDirWS = GetCameraPositionWS() - o.worldPos;
                o.tangentWS = TransformObjectToWorldNormal(v.tangentOS.xyz);
                return o;
            }

            SnowOutput SnowSurface(Varyings IN)
            {
                SnowOutput output;
                //以下是原版SnowSurface
                half3 normal	= UnpackNormal(SAMPLE_TEXTURE2D(_BumpTex, sampler_BumpTex, IN.uv_BumpTex));	// Base Normal map
		        half4 albedo	=SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv_MainTex);
		
		        #if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
			        half3 depth		=SAMPLE_TEXTURE2D(_DepthTex, sampler_DepthTex, IN.uv_SubNormal).rgb;// tex2D(_DepthTex, IN.uv_SubNormal);
		        #else
			        half3 depth		=SAMPLE_TEXTURE2D(_DepthTex, sampler_DepthTex, IN.uv_MainTex).rgb;// tex2D(_DepthTex, IN.uv_MainTex);
		        #endif
		
		        #if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
			        // Sub-Normal map (you don't need to convert texture to Normal because of the * 2 - 1 trick. Then you can use alpha)
			        half3 subnormal		= UnpackNormal(SAMPLE_TEXTURE2D(_SubNormal, sampler_SubNormal, IN.uv_SubNormal));
			        #if defined(SNOW_BLEND_ADVANCED)
				        float3 NdotD	=dot(IN.normalWS, normalize(_Direction.xyz)); //dot(WorldNormalVector(IN, float3(0, 0, 1)), normalize(_Direction.xyz));	// Cross product for WorldNormal and Direction
				        half coverage	= NdotD - lerp(1, -1, _Coverage);											// Blending for general coverage
				        coverage		= saturate(coverage / _Spread);
				        half subheightcoverage	= depth.g - lerp(1, -1, coverage);									// Blending for Sub-Height
				        half subnormalcoverage	= NdotD - lerp(1, -1, subheightcoverage + _Transition);				// Blending for Sub-Normal
			        #elif defined(SNOW_BLEND_TEXTURE)
				        half coverage			= albedo.a;
				        coverage				= saturate(coverage / _Spread);
				        half subheightcoverage	= depth.g - lerp(1, -1, coverage);
				        half subnormalcoverage	= 1 - lerp(1, -1, subheightcoverage + _Transition);
			        #elif defined(SNOW_BLEND_HEIGHT)
				        half coverage	= lerp(-1, 1 + _Height, albedo.a);
				        coverage		= saturate(coverage / _Spread);
				        half subheightcoverage	= depth.g - lerp(1, -1, coverage);
				        half subnormalcoverage	= 1 - lerp(1, -1, subheightcoverage + _Transition);
			        #endif
			        subnormalcoverage = saturate(subnormalcoverage / _TransitionSmooth);
			        subheightcoverage = saturate(subheightcoverage / _Smooth);
		            #endif
		
		            output.Albedo = albedo.rgb;
		
		            #if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
			            output.Normal		= lerp(subnormal, normal, subnormalcoverage);
		            #else
			            output.Normal		= normal;
		            #endif
		
		            #ifndef SNOW_GLITTER
			            output.Specular		=SAMPLE_TEXTURE2D(_GlitterTex, sampler_GlitterTex, IN.uv_GlitterTex);// tex2D(_GlitterTex, IN.uv_GlitterTex);
		            #else
			            output.Specular		= UnpackNormal(SAMPLE_TEXTURE2D(_GlitterTex, sampler_GlitterTex, IN.uv_GlitterTex););
		            #endif
		
		            #ifdef SNOW_BLEND_ADVANCED
			            output.Alpha		= subheightcoverage * (_Coverage <= 0.0 ? 0 : 1);		// Avoids antialias glitch on low coverage value
		            #elif defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
			            output.Alpha		= subheightcoverage;
		            #endif
		
		            output.Depth		= depth.r;
		
		            #ifdef SNOW_REFLECTION
			            half falloff = 1.0 - saturate(dot(o.Normal, normalize(IN.viewDir)));
			            falloff = pow(falloff, _Falloff);
			            output.Emission = (texCUBE(_Cube, WorldReflectionVector(IN, o.Normal)).rgb * _Reflection) * falloff;
		            #endif

                return output;
            }

            float4 Frag(Varyings i) : SV_Target
            {
                SnowOutput snowOutput = SnowSurface(i);

				float3 lightDir = normalize(_MainLightPosition.xyz);

                // 漫反射光照计算
                // float3 lightDir = normalize(_Direction.xyz);
                // float3 normalWS = normalize(i.normalWS);
                // float NdotL = max(0.0, dot(normalWS, lightDir));
                // float3 diffuse = snowOutput.Albedo * NdotL;

                // 镜面反射
                float3 viewDir = normalize(i.viewDirWS);
                // float3 halfDir = normalize(lightDir + viewDir);
                // float NdotH = max(0.0, dot(normalWS, halfDir));
                // float3 specular = snowOutput.Specular * pow(NdotH, _Shininess) * _Smooth;

                //====以下是原版LightingSnow算法部分
                half3 H	= normalize(lightDir + viewDir);
		        half NdotH = max(0, dot(snowOutput.Normal, H));
		        half NdotL = dot(snowOutput.Normal, lightDir);
		        half NdotV = dot(snowOutput.Normal, viewDir);
		
				float atten=1;

		        #if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
			        float3 shadow = atten * _MainLightColor.rgb * snowOutput.Alpha;
		        #else
			        float3 shadow = atten * _MainLightColor.rgb;
		        #endif
		
		        half3 albedo = snowOutput.Albedo * _MainLightColor.rgb;
		        float y = NdotL * shadow;
		        half2 uv_Ramp = half2(_RampPower * NdotV, y);
		        half3 ramp = SAMPLE_TEXTURE2D(_Ramp, sampler_Ramp, uv_Ramp.xy);
		
		        half ssatten = 1.0;
		
		        if (0.0 != _MainLightPosition.w) {
			        half depth		= clamp(snowOutput.Depth + _Depth, -1, 1);
			        half ssdepth	= lerp(NdotL, 1, depth + saturate(dot(snowOutput.Normal, -NdotL)));
			        #if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
				        ssatten = atten * ssdepth * snowOutput.Alpha;
			        #else
				        ssatten = atten * ssdepth;
			        #endif
			        ramp = ramp * ssatten;
		        }
		
		        #ifdef SNOW_GLITTER
			        half3 view			= mul((float3x3)UNITY_MATRIX_V, snowOutput.Normal);
			        half3 glitter		= frac(0.7 * snowOutput.Normal + 9 * snowOutput.Specular + _Speed * viewDir * lightDir * view);
			        glitter 			*= (_Density - glitter);
			        glitter 			= saturate(1 - _DensityStatic * (glitter.x + glitter.y + glitter.z));
			        glitter				= (glitter * _SpecularColor.rgb) * _SpecularColor.a + half3(Overlay(glitter, snowOutput.Specular.rgb * _Power)) * (1 - _SpecularColor.a);
			
			        half3 specular		= saturate(pow(NdotH, _Shininess * 128.0) * _Specular * glitter);
			
			        half3 anisotropic	= max(0, sin(radians((NdotH + _Aniso) * 180))) * ssatten;
			        anisotropic			= saturate(glitter * anisotropic * _Glitter);
		        #else
			        half3 specular 		= saturate(pow(NdotH, _Shininess * 128.0) * _Specular * snowOutput.Specular.rgb);
			        half3 anisotropic	= max(0, sin(radians((NdotH + _Aniso) * 180))) * ssatten;
			        anisotropic			= saturate(snowOutput.Specular.rgb * anisotropic * _Glitter);
		        #endif
		
		        half4 c = half4(1, 1, 1, 1);
		        #ifdef SNOW_REFLECTION
			        c.rgb	= ramp * albedo + (anisotropic + specular + snowOutput.Emission) * shadow;
		        #else
			        c.rgb	= ramp * albedo + (anisotropic + specular) * shadow;
		        #endif
		        #if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
			        c.a		= snowOutput.Alpha;
		        #endif
		        return c;
            }

            ENDHLSL
        }
    }
}