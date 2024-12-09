
//修改自SnowFull.shader,打算改造为urp版本
Shader "Custom/CustomSnowShader" {
	Properties {
		_Ramp				("Shade (RGB)", 2D) 						= "white" {}
		_RampPower			("Shade Intensity", Range (0.0, 1.0))		= 1.0
		_MainTex			("Diffuse (RGB)", 2D) 						= "white" {}
		_GlitterTex			("Specular (RGB)", 2D)						= "black" {}
		_Specular			("Specular Intensity", Range (0.0, 5.0))	= 1.0
		_Shininess			("Shininess", Range (0.01, 1.0))			= 0.08
		_Aniso				("Anisotropic Mask", Range (0.0, 1.0))		= 0.0
		_Glitter			("Anisotropic Intensity", Range (0.0, 15.0))= 0.5
		_BumpTex			("Normal (RGB)", 2D)						= "bump" {}
		_DepthTex			("Depth (R)", 2D)							= "white" {}
		_Depth				("Translucency", Range(-2.0, 1.0))			= 1.0
		_Coverage			("Coverage", Range (-0.01, 1.001))			= 0.5
		_SubNormal			("SubNormal (RGB)", 2D)						= "bump" {}
		_Spread				("Spread", Range (0.0, 1.0))				= 1.0
		_Smooth				("Smooth", Range (0.01, 5.0))				= 0.5
		_Transition			("Transition", Range (-1.0, 1.0))			= 0.5
		_TransitionSmooth	("Transition Smoothness", Range (0.0, 2.0))	= 0.5
		_Direction			("Direction", Vector)						= (0, 1, 0)
	}
	
	SubShader {
		Blend SrcAlpha OneMinusSrcAlpha
		Tags { "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" "IgnoreProjector"="True" }
		Offset 0, -1
		ZWrite Off
		LOD 400
		
		CGPROGRAM
		#pragma target 3.0
		#pragma surface SnowSurface Snow decal:blend
		
		#ifdef SHADER_API_OPENGL	
			#pragma glsl
		#endif
		
		#define SNOW_BLEND_ADVANCED

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

		sampler2D	_Ramp;
		sampler2D	_MainTex;
		sampler2D	_BumpTex;
		sampler2D	_DepthTex;
		#if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
			sampler2D	_SubNormal;
		#endif
		sampler2D	_GlitterTex;
		#ifdef SNOW_REFLECTION
			samplerCUBE	_Cube;
		#endif
	
		struct Input
		{
			float2	uv_MainTex;
			//// This might cause problems for marmoset, rtp, terrain or lightmap integration just use uv_MainTex
			float2	uv_BumpTex;
			float2	uv_GlitterTex;
			////
			#if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
				float2	uv_SubNormal;
				float3	worldNormal;
			#endif
			#ifdef SNOW_REFLECTION
				float3 worldRefl;
				float3 viewDir;
			#endif
			INTERNAL_DATA
		};
	
		struct SnowOutput
		{
			half3 	Albedo;
			half3	Normal;
			half3 	Emission;
			half3	Specular;
			half 	Alpha;
			half	Depth;
		};

		// forward rendering
		inline half4 LightingSnow (SnowOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half3 H	= normalize(lightDir + viewDir);
			half NdotH = max(0, dot(s.Normal, H));
			half NdotL = dot(s.Normal, lightDir);
			half NdotV = dot(s.Normal, viewDir);
		
			#if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
				float3 shadow = atten * _LightColor0.rgb * s.Alpha;
			#else
				float3 shadow = atten * _LightColor0.rgb;
			#endif
		
			half3 albedo = s.Albedo * _LightColor0.rgb;
			float y = NdotL * shadow;
			half2 uv_Ramp = half2(_RampPower * NdotV, y);
			half3 ramp = tex2D(_Ramp, uv_Ramp.xy);
		
			half ssatten = 1.0;
		
			if (0.0 != _WorldSpaceLightPos0.w) {
				half depth		= clamp(s.Depth + _Depth, -1, 1);
				half ssdepth	= lerp(NdotL, 1, depth + saturate(dot(s.Normal, -NdotL)));
				#if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
					ssatten = atten * ssdepth * s.Alpha;
				#else
					ssatten = atten * ssdepth;
				#endif
				ramp = ramp * ssatten;
			}
		
			#ifdef SNOW_GLITTER
				half3 view			= mul((float3x3)UNITY_MATRIX_V, s.Normal);
				half3 glitter		= frac(0.7 * s.Normal + 9 * s.Specular + _Speed * viewDir * lightDir * view);
				glitter 			*= (_Density - glitter);
				glitter 			= saturate(1 - _DensityStatic * (glitter.x + glitter.y + glitter.z));
				glitter				= (glitter * _SpecularColor.rgb) * _SpecularColor.a + half3(Overlay(glitter, s.Specular.rgb * _Power)) * (1 - _SpecularColor.a);
			
				half3 specular		= saturate(pow(NdotH, _Shininess * 128.0) * _Specular * glitter);
			
				half3 anisotropic	= max(0, sin(radians((NdotH + _Aniso) * 180))) * ssatten;
				anisotropic			= saturate(glitter * anisotropic * _Glitter);
			#else
				half3 specular 		= saturate(pow(NdotH, _Shininess * 128.0) * _Specular * s.Specular.rgb);
				half3 anisotropic	= max(0, sin(radians((NdotH + _Aniso) * 180))) * ssatten;
				anisotropic			= saturate(s.Specular.rgb * anisotropic * _Glitter);
			#endif
		
			half4 c = half4(1, 1, 1, 1);
			#ifdef SNOW_REFLECTION
				c.rgb	= ramp * albedo + (anisotropic + specular + s.Emission) * shadow;
			#else
				c.rgb	= ramp * albedo + (anisotropic + specular) * shadow;
			#endif
			#if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
				c.a		= s.Alpha;
			#endif
			return c;
		}
			void SnowSurface(Input IN, inout SnowOutput o)
		{
			half3 normal	= UnpackNormal(tex2D(_BumpTex, IN.uv_BumpTex));	// Base Normal map
			half4 albedo	= tex2D(_MainTex, IN.uv_MainTex);
		
			#if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
				half3 depth		= tex2D(_DepthTex, IN.uv_SubNormal);
			#else
				half3 depth		= tex2D(_DepthTex, IN.uv_MainTex);
			#endif
		
			#if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
				// Sub-Normal map (you don't need to convert texture to Normal because of the * 2 - 1 trick. Then you can use alpha)
				half3 subnormal		= UnpackNormal(tex2D(_SubNormal, IN.uv_SubNormal));
				#if defined(SNOW_BLEND_ADVANCED)
					float3 NdotD	= dot(WorldNormalVector(IN, float3(0, 0, 1)), normalize(_Direction.xyz));	// Cross product for WorldNormal and Direction
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
		
			o.Albedo = albedo.rgb;
		
			#if defined(SNOW_BLEND_ADVANCED) || defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
				o.Normal		= lerp(subnormal, normal, subnormalcoverage);
			#else
				o.Normal		= normal;
			#endif
		
			#ifndef SNOW_GLITTER
				o.Specular		= tex2D(_GlitterTex, IN.uv_GlitterTex);
			#else
				o.Specular		= UnpackNormal(tex2D(_GlitterTex, IN.uv_GlitterTex));
			#endif
		
			#ifdef SNOW_BLEND_ADVANCED
				o.Alpha		= subheightcoverage * (_Coverage <= 0.0 ? 0 : 1);		// Avoids antialias glitch on low coverage value
			#elif defined(SNOW_BLEND_TEXTURE) || defined(SNOW_BLEND_HEIGHT)
				o.Alpha		= subheightcoverage;
			#endif
		
			o.Depth		= depth.r;
		
			#ifdef SNOW_REFLECTION
				half falloff = 1.0 - saturate(dot(o.Normal, normalize(IN.viewDir)));
				falloff = pow(falloff, _Falloff);
				o.Emission = (texCUBE(_Cube, WorldReflectionVector(IN, o.Normal)).rgb * _Reflection) * falloff;
			#endif
		}

		ENDCG
	}
	FallBack "VertexLit"
}