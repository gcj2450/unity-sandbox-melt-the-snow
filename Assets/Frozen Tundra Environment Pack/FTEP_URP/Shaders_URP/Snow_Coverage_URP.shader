// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Snow Coverage URP"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_BaseColor("Base Color", Color) = (1,1,1,0)
		_BaseColorMap("Base Map", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_MaskMap("Mask Map", 2D) = "white" {}
		_Snow_DetailMap("Snow_DetailMap", 2D) = "white" {}
		_DetailMap("Detail Map", 2D) = "gray" {}
		_SnowMultiplier("Snow Multiplier", Range( 0 , 1)) = 1
		_SnowCoverageMin("Snow Coverage Min", Range( -12 , 0)) = -4.1
		_SnowCoverageMax("Snow Coverage Max", Range( -1 , 12)) = 1.9
		_SnowCoverNormalInfluence("Snow Cover Normal Influence", Range( 0 , 3)) = 3
		_SnowSplash("Snow Splash", Range( 0 , 3)) = 1
		_SnowSplashNormalInfluence("Snow Splash Normal Influence", Range( 0 , 1)) = 1
		_DetailAlbedoScale("Detail Albedo Scale", Range( 0 , 1)) = 1
		_DetailNormalScale("Detail Normal Scale", Range( 0 , 1)) = 1
		_GroundSnowIntensity("Ground Snow Intensity", Range( 0 , 2)) = 0
		_GroundSnowDetail("Ground Snow Detail", Range( 0 , 2)) = 2
		_GroundSnowPosition("Ground Snow Position", Range( -2 , 2)) = 2
		_SnowSplashOcclusionInfluence("Snow Splash Occlusion Influence", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Cull Back
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend One Zero , One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT


			sampler2D _DetailMap;
			sampler2D _BaseColorMap;
			sampler2D _Snow_DetailMap;
			sampler2D _NormalMap;
			sampler2D _MaskMap;
			CBUFFER_START( UnityPerMaterial )
			float4 _DetailMap_ST;
			float4 _BaseColorMap_ST;
			float _DetailAlbedoScale;
			float4 _BaseColor;
			float4 _Snow_DetailMap_ST;
			float4 _NormalMap_ST;
			float _DetailNormalScale;
			float _SnowCoverNormalInfluence;
			float _SnowCoverageMin;
			float _SnowCoverageMax;
			float _SnowSplash;
			float _SnowSplashNormalInfluence;
			float4 _MaskMap_ST;
			float _SnowSplashOcclusionInfluence;
			float _GroundSnowPosition;
			float _GroundSnowDetail;
			float _GroundSnowIntensity;
			float _SnowMultiplier;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				o.ase_texcoord8 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 WorldNormal = normalize( IN.tSpace0.xyz );
				float3 WorldTangent = IN.tSpace1.xyz;
				float3 WorldBiTangent = IN.tSpace2.xyz;
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif
	
				#if SHADER_HINT_NICE_QUALITY
					WorldViewDirection = SafeNormalize( WorldViewDirection );
				#endif

				float2 uv_DetailMap = IN.ase_texcoord7.xy * _DetailMap_ST.xy + _DetailMap_ST.zw;
				float4 tex2DNode19 = tex2D( _DetailMap, uv_DetailMap );
				float4 temp_cast_0 = (tex2DNode19.r).xxxx;
				float2 uv_BaseColorMap = IN.ase_texcoord7.xy * _BaseColorMap_ST.xy + _BaseColorMap_ST.zw;
				float4 blendOpSrc24 = temp_cast_0;
				float4 blendOpDest24 = tex2D( _BaseColorMap, uv_BaseColorMap );
				float4 lerpBlendMode24 = lerp(blendOpDest24,(( blendOpDest24 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest24 ) * ( 1.0 - blendOpSrc24 ) ) : ( 2.0 * blendOpDest24 * blendOpSrc24 ) ),_DetailAlbedoScale);
				float2 uv_Snow_DetailMap = IN.ase_texcoord7.xy * _Snow_DetailMap_ST.xy + _Snow_DetailMap_ST.zw;
				float4 tex2DNode150 = tex2D( _Snow_DetailMap, uv_Snow_DetailMap );
				float4 temp_cast_1 = (tex2DNode150.r).xxxx;
				float2 uv_NormalMap = IN.ase_texcoord7.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float4 appendResult102 = (float4(tex2DNode19.a , tex2DNode19.g , 1.0 , 1.0));
				float3 temp_output_96_0 = BlendNormal( UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap ), 1.0f ) , UnpackNormalScale( appendResult102, _DetailNormalScale ) );
				float4 appendResult152 = (float4(tex2DNode150.a , tex2DNode150.g , 1.0 , 1.0));
				float saferPower39 = max( WorldNormal.y , 0.0001 );
				float3 lerpResult34 = lerp( temp_output_96_0 , UnpackNormalScale( appendResult152, 1.0 ) , saturate( (0.0 + (pow( saferPower39 , _SnowCoverNormalInfluence ) - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ));
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal30 = lerpResult34;
				float3 worldNormal30 = float3(dot(tanToWorld0,tanNormal30), dot(tanToWorld1,tanNormal30), dot(tanToWorld2,tanNormal30));
				float temp_output_32_0 = saturate( (_SnowCoverageMin + (worldNormal30.y - 0.0) * (_SnowCoverageMax - _SnowCoverageMin) / (1.0 - 0.0)) );
				float saferPower69 = max( WorldNormal.y , 0.0001 );
				float3 lerpResult78 = lerp( temp_output_96_0 , UnpackNormalScale( appendResult152, 1.0 ) , saturate( (0.0 + (( pow( saferPower69 , _SnowSplashNormalInfluence ) * _SnowSplash ) - 0.27) * (0.85 - 0.0) / (0.77 - 0.27)) ));
				float3 tanNormal73 = lerpResult78;
				float3 worldNormal73 = float3(dot(tanToWorld0,tanNormal73), dot(tanToWorld1,tanNormal73), dot(tanToWorld2,tanNormal73));
				float2 uv_MaskMap = IN.ase_texcoord7.xy * _MaskMap_ST.xy + _MaskMap_ST.zw;
				float4 tex2DNode15 = tex2D( _MaskMap, uv_MaskMap );
				float temp_output_183_0 = saturate( (0.0 + (tex2DNode19.r - 0.24) * (1.0 - 0.0) / (0.4 - 0.24)) );
				float temp_output_238_0 = ( ( ( temp_output_32_0 + ( saturate( (0.0 + (( _SnowSplash * -worldNormal73.y ) - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ) * saturate( ( saturate( (-5.38 + (( tex2DNode15.g / _SnowSplashOcclusionInfluence ) - 0.0) * (1.0 - -5.38) / (1.0 - 0.0)) ) * temp_output_183_0 ) ) ) ) + ( saturate( ( (_GroundSnowPosition + (( 1.0 - IN.ase_texcoord8.xyz.z ) - 0.0) * (1.0 - _GroundSnowPosition) / (1.0 - 0.0)) - ( temp_output_183_0 * _GroundSnowDetail ) ) ) * _GroundSnowIntensity ) ) * _SnowMultiplier );
				float4 lerpResult22 = lerp( ( lerpBlendMode24 * _BaseColor ) , temp_cast_1 , temp_output_238_0);
				
				float3 lerpResult138 = lerp( temp_output_96_0 , UnpackNormalScale( appendResult152, 1.0 ) , temp_output_238_0);
				
				float blendOpSrc142 = tex2DNode15.a;
				float blendOpDest142 = tex2DNode19.b;
				float lerpResult112 = lerp( (( blendOpDest142 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest142 ) * ( 1.0 - blendOpSrc142 ) ) : ( 2.0 * blendOpDest142 * blendOpSrc142 ) ) , tex2DNode150.b , temp_output_238_0);
				
				float3 Albedo = lerpResult22.rgb;
				float3 Normal = lerpResult138;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = lerpResult112;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				
				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal )));
				#else
					#if !SHADER_HINT_NICE_QUALITY
						inputData.normalWS = WorldNormal;
					#else
						inputData.normalWS = normalize( WorldNormal );
					#endif
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif
				half4 color = UniversalFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);

				#ifdef _REFRACTION_ASE
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, WorldNormal ).xyz * ( 1.0 / ( ScreenPos.z + 1.0 ) ) * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					float2 cameraRefraction = float2( refractionOffset.x, -( refractionOffset.y * _ProjectionParams.x ) );
					projScreenPos.xy += cameraRefraction;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif
				
				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment

			#define SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			CBUFFER_START( UnityPerMaterial )
			float4 _DetailMap_ST;
			float4 _BaseColorMap_ST;
			float _DetailAlbedoScale;
			float4 _BaseColor;
			float4 _Snow_DetailMap_ST;
			float4 _NormalMap_ST;
			float _DetailNormalScale;
			float _SnowCoverNormalInfluence;
			float _SnowCoverageMin;
			float _SnowCoverageMax;
			float _SnowSplash;
			float _SnowSplashNormalInfluence;
			float4 _MaskMap_ST;
			float _SnowSplashOcclusionInfluence;
			float _GroundSnowPosition;
			float _GroundSnowDetail;
			float _GroundSnowIntensity;
			float _SnowMultiplier;
			CBUFFER_END


			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			float3 _LightDirection;

			VertexOutput ShadowPassVertex( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;
				return o;
			}

			half4 ShadowPassFragment(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			CBUFFER_START( UnityPerMaterial )
			float4 _DetailMap_ST;
			float4 _BaseColorMap_ST;
			float _DetailAlbedoScale;
			float4 _BaseColor;
			float4 _Snow_DetailMap_ST;
			float4 _NormalMap_ST;
			float _DetailNormalScale;
			float _SnowCoverNormalInfluence;
			float _SnowCoverageMin;
			float _SnowCoverageMax;
			float _SnowSplash;
			float _SnowSplashNormalInfluence;
			float4 _MaskMap_ST;
			float _SnowSplashOcclusionInfluence;
			float _GroundSnowPosition;
			float _GroundSnowDetail;
			float _GroundSnowIntensity;
			float _SnowMultiplier;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL


			sampler2D _DetailMap;
			sampler2D _BaseColorMap;
			sampler2D _Snow_DetailMap;
			sampler2D _NormalMap;
			sampler2D _MaskMap;
			CBUFFER_START( UnityPerMaterial )
			float4 _DetailMap_ST;
			float4 _BaseColorMap_ST;
			float _DetailAlbedoScale;
			float4 _BaseColor;
			float4 _Snow_DetailMap_ST;
			float4 _NormalMap_ST;
			float _DetailNormalScale;
			float _SnowCoverNormalInfluence;
			float _SnowCoverageMin;
			float _SnowCoverageMax;
			float _SnowSplash;
			float _SnowSplashNormalInfluence;
			float4 _MaskMap_ST;
			float _SnowSplashOcclusionInfluence;
			float _GroundSnowPosition;
			float _GroundSnowDetail;
			float _GroundSnowIntensity;
			float _SnowMultiplier;
			CBUFFER_END


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord6 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_DetailMap = IN.ase_texcoord2.xy * _DetailMap_ST.xy + _DetailMap_ST.zw;
				float4 tex2DNode19 = tex2D( _DetailMap, uv_DetailMap );
				float4 temp_cast_0 = (tex2DNode19.r).xxxx;
				float2 uv_BaseColorMap = IN.ase_texcoord2.xy * _BaseColorMap_ST.xy + _BaseColorMap_ST.zw;
				float4 blendOpSrc24 = temp_cast_0;
				float4 blendOpDest24 = tex2D( _BaseColorMap, uv_BaseColorMap );
				float4 lerpBlendMode24 = lerp(blendOpDest24,(( blendOpDest24 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest24 ) * ( 1.0 - blendOpSrc24 ) ) : ( 2.0 * blendOpDest24 * blendOpSrc24 ) ),_DetailAlbedoScale);
				float2 uv_Snow_DetailMap = IN.ase_texcoord2.xy * _Snow_DetailMap_ST.xy + _Snow_DetailMap_ST.zw;
				float4 tex2DNode150 = tex2D( _Snow_DetailMap, uv_Snow_DetailMap );
				float4 temp_cast_1 = (tex2DNode150.r).xxxx;
				float2 uv_NormalMap = IN.ase_texcoord2.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float4 appendResult102 = (float4(tex2DNode19.a , tex2DNode19.g , 1.0 , 1.0));
				float3 temp_output_96_0 = BlendNormal( UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap ), 1.0f ) , UnpackNormalScale( appendResult102, _DetailNormalScale ) );
				float4 appendResult152 = (float4(tex2DNode150.a , tex2DNode150.g , 1.0 , 1.0));
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float saferPower39 = max( ase_worldNormal.y , 0.0001 );
				float3 lerpResult34 = lerp( temp_output_96_0 , UnpackNormalScale( appendResult152, 1.0 ) , saturate( (0.0 + (pow( saferPower39 , _SnowCoverNormalInfluence ) - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ));
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal30 = lerpResult34;
				float3 worldNormal30 = float3(dot(tanToWorld0,tanNormal30), dot(tanToWorld1,tanNormal30), dot(tanToWorld2,tanNormal30));
				float temp_output_32_0 = saturate( (_SnowCoverageMin + (worldNormal30.y - 0.0) * (_SnowCoverageMax - _SnowCoverageMin) / (1.0 - 0.0)) );
				float saferPower69 = max( ase_worldNormal.y , 0.0001 );
				float3 lerpResult78 = lerp( temp_output_96_0 , UnpackNormalScale( appendResult152, 1.0 ) , saturate( (0.0 + (( pow( saferPower69 , _SnowSplashNormalInfluence ) * _SnowSplash ) - 0.27) * (0.85 - 0.0) / (0.77 - 0.27)) ));
				float3 tanNormal73 = lerpResult78;
				float3 worldNormal73 = float3(dot(tanToWorld0,tanNormal73), dot(tanToWorld1,tanNormal73), dot(tanToWorld2,tanNormal73));
				float2 uv_MaskMap = IN.ase_texcoord2.xy * _MaskMap_ST.xy + _MaskMap_ST.zw;
				float4 tex2DNode15 = tex2D( _MaskMap, uv_MaskMap );
				float temp_output_183_0 = saturate( (0.0 + (tex2DNode19.r - 0.24) * (1.0 - 0.0) / (0.4 - 0.24)) );
				float temp_output_238_0 = ( ( ( temp_output_32_0 + ( saturate( (0.0 + (( _SnowSplash * -worldNormal73.y ) - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ) * saturate( ( saturate( (-5.38 + (( tex2DNode15.g / _SnowSplashOcclusionInfluence ) - 0.0) * (1.0 - -5.38) / (1.0 - 0.0)) ) * temp_output_183_0 ) ) ) ) + ( saturate( ( (_GroundSnowPosition + (( 1.0 - IN.ase_texcoord6.xyz.z ) - 0.0) * (1.0 - _GroundSnowPosition) / (1.0 - 0.0)) - ( temp_output_183_0 * _GroundSnowDetail ) ) ) * _GroundSnowIntensity ) ) * _SnowMultiplier );
				float4 lerpResult22 = lerp( ( lerpBlendMode24 * _BaseColor ) , temp_cast_1 , temp_output_238_0);
				
				
				float3 Albedo = lerpResult22.rgb;
				float3 Emission = 0;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero , One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70108

			#pragma enable_d3d11_debug_symbols
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#define ASE_NEEDS_VERT_NORMAL


			sampler2D _DetailMap;
			sampler2D _BaseColorMap;
			sampler2D _Snow_DetailMap;
			sampler2D _NormalMap;
			sampler2D _MaskMap;
			CBUFFER_START( UnityPerMaterial )
			float4 _DetailMap_ST;
			float4 _BaseColorMap_ST;
			float _DetailAlbedoScale;
			float4 _BaseColor;
			float4 _Snow_DetailMap_ST;
			float4 _NormalMap_ST;
			float _DetailNormalScale;
			float _SnowCoverNormalInfluence;
			float _SnowCoverageMin;
			float _SnowCoverageMax;
			float _SnowSplash;
			float _SnowSplashNormalInfluence;
			float4 _MaskMap_ST;
			float _SnowSplashOcclusionInfluence;
			float _GroundSnowPosition;
			float _GroundSnowDetail;
			float _GroundSnowIntensity;
			float _SnowMultiplier;
			CBUFFER_END


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord6 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_DetailMap = IN.ase_texcoord2.xy * _DetailMap_ST.xy + _DetailMap_ST.zw;
				float4 tex2DNode19 = tex2D( _DetailMap, uv_DetailMap );
				float4 temp_cast_0 = (tex2DNode19.r).xxxx;
				float2 uv_BaseColorMap = IN.ase_texcoord2.xy * _BaseColorMap_ST.xy + _BaseColorMap_ST.zw;
				float4 blendOpSrc24 = temp_cast_0;
				float4 blendOpDest24 = tex2D( _BaseColorMap, uv_BaseColorMap );
				float4 lerpBlendMode24 = lerp(blendOpDest24,(( blendOpDest24 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest24 ) * ( 1.0 - blendOpSrc24 ) ) : ( 2.0 * blendOpDest24 * blendOpSrc24 ) ),_DetailAlbedoScale);
				float2 uv_Snow_DetailMap = IN.ase_texcoord2.xy * _Snow_DetailMap_ST.xy + _Snow_DetailMap_ST.zw;
				float4 tex2DNode150 = tex2D( _Snow_DetailMap, uv_Snow_DetailMap );
				float4 temp_cast_1 = (tex2DNode150.r).xxxx;
				float2 uv_NormalMap = IN.ase_texcoord2.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float4 appendResult102 = (float4(tex2DNode19.a , tex2DNode19.g , 1.0 , 1.0));
				float3 temp_output_96_0 = BlendNormal( UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap ), 1.0f ) , UnpackNormalScale( appendResult102, _DetailNormalScale ) );
				float4 appendResult152 = (float4(tex2DNode150.a , tex2DNode150.g , 1.0 , 1.0));
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float saferPower39 = max( ase_worldNormal.y , 0.0001 );
				float3 lerpResult34 = lerp( temp_output_96_0 , UnpackNormalScale( appendResult152, 1.0 ) , saturate( (0.0 + (pow( saferPower39 , _SnowCoverNormalInfluence ) - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ));
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal30 = lerpResult34;
				float3 worldNormal30 = float3(dot(tanToWorld0,tanNormal30), dot(tanToWorld1,tanNormal30), dot(tanToWorld2,tanNormal30));
				float temp_output_32_0 = saturate( (_SnowCoverageMin + (worldNormal30.y - 0.0) * (_SnowCoverageMax - _SnowCoverageMin) / (1.0 - 0.0)) );
				float saferPower69 = max( ase_worldNormal.y , 0.0001 );
				float3 lerpResult78 = lerp( temp_output_96_0 , UnpackNormalScale( appendResult152, 1.0 ) , saturate( (0.0 + (( pow( saferPower69 , _SnowSplashNormalInfluence ) * _SnowSplash ) - 0.27) * (0.85 - 0.0) / (0.77 - 0.27)) ));
				float3 tanNormal73 = lerpResult78;
				float3 worldNormal73 = float3(dot(tanToWorld0,tanNormal73), dot(tanToWorld1,tanNormal73), dot(tanToWorld2,tanNormal73));
				float2 uv_MaskMap = IN.ase_texcoord2.xy * _MaskMap_ST.xy + _MaskMap_ST.zw;
				float4 tex2DNode15 = tex2D( _MaskMap, uv_MaskMap );
				float temp_output_183_0 = saturate( (0.0 + (tex2DNode19.r - 0.24) * (1.0 - 0.0) / (0.4 - 0.24)) );
				float temp_output_238_0 = ( ( ( temp_output_32_0 + ( saturate( (0.0 + (( _SnowSplash * -worldNormal73.y ) - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ) * saturate( ( saturate( (-5.38 + (( tex2DNode15.g / _SnowSplashOcclusionInfluence ) - 0.0) * (1.0 - -5.38) / (1.0 - 0.0)) ) * temp_output_183_0 ) ) ) ) + ( saturate( ( (_GroundSnowPosition + (( 1.0 - IN.ase_texcoord6.xyz.z ) - 0.0) * (1.0 - _GroundSnowPosition) / (1.0 - 0.0)) - ( temp_output_183_0 * _GroundSnowDetail ) ) ) * _GroundSnowIntensity ) ) * _SnowMultiplier );
				float4 lerpResult22 = lerp( ( lerpBlendMode24 * _BaseColor ) , temp_cast_1 , temp_output_238_0);
				
				
				float3 Albedo = lerpResult22.rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				half4 color = half4( Albedo, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}
		
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18000
-1816;434;1632;979;4952.37;3383.784;5.484902;True;True
Node;AmplifyShaderEditor.WorldNormalVector;67;-2980.009,557.1442;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;66;-3044.199,722.25;Float;False;Property;_SnowSplashNormalInfluence;Snow Splash Normal Influence;11;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;19;-2973.522,-1782.278;Inherit;True;Property;_DetailMap;Detail Map;5;0;Create;False;0;0;False;0;-1;256a83e41a4f66f4aa4cc143d792174b;256a83e41a4f66f4aa4cc143d792174b;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;68;-2833.116,827.502;Float;False;Property;_SnowSplash;Snow Splash;10;0;Create;True;0;0;False;0;1;3;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;69;-2727.978,650.3314;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;150;-2708.614,-2400.578;Inherit;True;Property;_Snow_DetailMap;Snow_DetailMap;4;0;Create;True;0;0;False;0;-1;ae59db58aaea44d489d6c8b0dcb269a7;ae59db58aaea44d489d6c8b0dcb269a7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;226;-2249.358,-2302.192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;102;-1052.859,-1176.389;Inherit;True;COLOR;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-2520.685,755.3959;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-1089.98,-932.675;Inherit;False;Property;_DetailNormalScale;Detail Normal Scale;13;0;Create;False;0;0;False;0;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;106;-785.7685,-1160.928;Inherit;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;14;-833.2664,-1391.579;Inherit;True;Property;_NormalMap;Normal Map;2;0;Create;False;0;0;False;0;-1;dd1f2af6401691a42aa424d2d3b3cb1a;635d171f852c07f41af5151df895a7eb;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;71;-2271.71,646.4595;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0.27;False;2;FLOAT;0.77;False;3;FLOAT;0;False;4;FLOAT;0.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;152;-2146.557,-2374.365;Inherit;True;COLOR;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;72;-1993.842,647.7413;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;96;-466.489,-1200.005;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;151;-1910.097,-2385.105;Inherit;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;144;-803.2163,1017.219;Inherit;False;Property;_SnowSplashOcclusionInfluence;Snow Splash Occlusion Influence;17;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;15;-1062.516,1355.75;Inherit;True;Property;_MaskMap;Mask Map;3;0;Create;False;0;0;False;0;-1;58747150f8709cb4cb5cb00ad8403bd7;3af1d0db7e7961c46917ed44ab18c838;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;78;-1830.647,595.5366;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;179;-2525.054,-1750.317;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0.24;False;2;FLOAT;0.4;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-3182.173,-243.5246;Float;False;Property;_SnowCoverNormalInfluence;Snow Cover Normal Influence;9;0;Create;True;0;0;False;0;3;1.2;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;73;-1648.885,596.718;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;183;-2236.434,-1750.377;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;26;-3125.623,-414.675;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;147;-465.5513,999.8862;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;83;-1453.94,648.2489;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;39;-2833.684,-312.133;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;224;-1331.64,-1756.432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;233;-111.7009,-1070.318;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;90;-222.7031,1003.607;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-5.38;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;52;-2644.15,-310.8754;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-1279.223,827.4261;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;91;75.78976,1002.216;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;222;-1301.064,-1771.72;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;234;-189.3383,-959.6417;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;76;-1111.892,828.916;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;225;-1301.064,-2401.078;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;232;-2239.357,-411.2635;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;188;-1184.205,-2747.392;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;28;-2336.731,-304.8477;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;294.0173,1005.771;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-1131.978,-2575.871;Inherit;False;Property;_GroundSnowPosition;Ground Snow Position;16;0;Create;True;0;0;False;0;2;2;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;165;511.9221,1006.86;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;77;-822.3085,828.2149;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;221;-1278.132,-2426.557;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;192;-975.7153,-2677.914;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;208;-1065.939,-2383.297;Inherit;False;Property;_GroundSnowDetail;Ground Snow Detail;15;0;Create;True;0;0;False;0;2;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;34;-2128.884,-346.531;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;30;-1945.506,-341.8684;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;223;-2317.064,-2354.827;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-766.2324,-2473.668;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-2104.756,-162.4897;Float;False;Property;_SnowCoverageMin;Snow Coverage Min;7;0;Create;True;0;0;False;0;-4.1;-4.1;-12;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;210;-787.5848,-2675.811;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;658.2478,938.022;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-2105.77,-69.7412;Float;False;Property;_SnowCoverageMax;Snow Coverage Max;8;0;Create;True;0;0;False;0;1.9;1.73;-1;12;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;207;-546.847,-2576.778;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;53;-1676.646,-292.8416;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1.3;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;227;-2307.454,-2380.781;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;236;840.9927,865.4614;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;228;-2306.853,-2884.984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;193;-388.493,-2576.177;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;32;-1383.069,-291.2069;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;235;-1079.629,76.73599;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-571.9435,-2438.476;Inherit;False;Property;_GroundSnowIntensity;Ground Snow Intensity;14;0;Create;True;0;0;False;0;0;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;-214.9665,-2527.317;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-924.1898,-2077.674;Inherit;True;Property;_BaseColorMap;Base Map;1;0;Create;False;0;0;False;0;-1;None;e2a54cbdf2f3310468963aaeefd25bbd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;186;-874.6737,-1865.069;Inherit;False;Property;_DetailAlbedoScale;Detail Albedo Scale;12;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;229;-2271.35,-2884.983;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;-959.7559,-287.7622;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;107;-553.9965,-1948.527;Inherit;False;Property;_BaseColor;Base Color;0;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;24;-566.2275,-2093.006;Inherit;False;Overlay;False;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;231;518.1074,-2864.703;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;171.7616,-2557.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;109.1342,-2325.262;Inherit;False;Property;_SnowMultiplier;Snow Multiplier;6;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;238;398.2061,-2438.075;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-325.2322,-2075.307;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;230;570.9496,-2812.694;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;161;-474.466,-266.653;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;142;-661.8717,1452.504;Inherit;True;Overlay;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;138;45.08826,-1185.455;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;112;612.2045,-253.7133;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;22;844.8288,-2293.098;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;44;-586.8294,1315.403;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;240;1558.696,30.25881;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;242;1558.696,30.25881;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;244;1558.696,30.25881;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;243;1558.696,30.25881;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;241;1558.696,30.25881;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;Snow Coverage URP;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;14;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;14;Workflow;1;Surface;0;  Refraction Model;0;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;1;Built-in Fog;1;Meta Pass;1;Override Baked GI;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;6;False;True;True;True;True;True;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;245;1558.696,30.25881;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;69;0;67;2
WireConnection;69;1;66;0
WireConnection;226;0;150;4
WireConnection;102;0;19;4
WireConnection;102;1;19;2
WireConnection;70;0;69;0
WireConnection;70;1;68;0
WireConnection;106;0;102;0
WireConnection;106;1;110;0
WireConnection;71;0;70;0
WireConnection;152;0;226;0
WireConnection;152;1;150;2
WireConnection;72;0;71;0
WireConnection;96;0;14;0
WireConnection;96;1;106;0
WireConnection;151;0;152;0
WireConnection;78;0;96;0
WireConnection;78;1;151;0
WireConnection;78;2;72;0
WireConnection;179;0;19;1
WireConnection;73;0;78;0
WireConnection;183;0;179;0
WireConnection;147;0;15;2
WireConnection;147;1;144;0
WireConnection;83;0;73;2
WireConnection;39;0;26;2
WireConnection;39;1;38;0
WireConnection;224;0;183;0
WireConnection;233;0;96;0
WireConnection;90;0;147;0
WireConnection;52;0;39;0
WireConnection;75;0;68;0
WireConnection;75;1;83;0
WireConnection;91;0;90;0
WireConnection;222;0;224;0
WireConnection;234;0;233;0
WireConnection;76;0;75;0
WireConnection;225;0;222;0
WireConnection;232;0;234;0
WireConnection;28;0;52;0
WireConnection;89;0;91;0
WireConnection;89;1;183;0
WireConnection;165;0;89;0
WireConnection;77;0;76;0
WireConnection;221;0;225;0
WireConnection;192;0;188;3
WireConnection;34;0;232;0
WireConnection;34;1;151;0
WireConnection;34;2;28;0
WireConnection;30;0;34;0
WireConnection;223;0;150;1
WireConnection;209;0;221;0
WireConnection;209;1;208;0
WireConnection;210;0;192;0
WireConnection;210;3;211;0
WireConnection;184;0;77;0
WireConnection;184;1;165;0
WireConnection;207;0;210;0
WireConnection;207;1;209;0
WireConnection;53;0;30;2
WireConnection;53;3;93;0
WireConnection;53;4;95;0
WireConnection;227;0;223;0
WireConnection;236;0;184;0
WireConnection;228;0;227;0
WireConnection;193;0;207;0
WireConnection;32;0;53;0
WireConnection;235;0;236;0
WireConnection;198;0;193;0
WireConnection;198;1;124;0
WireConnection;229;0;228;0
WireConnection;85;0;32;0
WireConnection;85;1;235;0
WireConnection;24;0;19;1
WireConnection;24;1;11;0
WireConnection;24;2;186;0
WireConnection;231;0;229;0
WireConnection;118;0;85;0
WireConnection;118;1;198;0
WireConnection;238;0;118;0
WireConnection;238;1;148;0
WireConnection;115;0;24;0
WireConnection;115;1;107;0
WireConnection;230;0;231;0
WireConnection;161;0;150;3
WireConnection;142;0;15;4
WireConnection;142;1;19;3
WireConnection;138;0;96;0
WireConnection;138;1;151;0
WireConnection;138;2;238;0
WireConnection;112;0;142;0
WireConnection;112;1;161;0
WireConnection;112;2;238;0
WireConnection;22;0;115;0
WireConnection;22;1;230;0
WireConnection;22;2;238;0
WireConnection;44;0;15;2
WireConnection;44;2;32;0
WireConnection;241;0;22;0
WireConnection;241;1;138;0
WireConnection;241;4;112;0
ASEEND*/
//CHKSM=CBB5B492C788634758D94761F9C44B55D2281EAC