//改编自Snow_Coverage_URP，打算简化shader
Shader "Snow Coverage URP Simple"
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