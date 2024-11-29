// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Snow Coverage Translucent Standard"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			half filler;
		};

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
-1913;402;1632;985;470.5969;741.5236;2.298595;True;True
Node;AmplifyShaderEditor.WorldNormalVector;67;-2980.009,557.1442;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;193;-388.493,-2576.177;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-571.9435,-2438.476;Inherit;False;Property;_GroundSnowIntensity;Ground Snow Intensity;16;0;Create;True;0;0;False;0;0;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;32;-1383.069,-291.2069;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;227;-2307.454,-2380.781;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;235;-1079.629,76.73599;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;236;840.9927,865.4614;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;223;-2317.064,-2354.827;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;207;-546.847,-2576.778;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;228;-2306.853,-2884.984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;53;-1676.646,-292.8416;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1.3;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;658.2478,938.022;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-2105.77,-69.7412;Float;False;Property;_SnowCoverageMax;Snow Coverage Max;9;0;Create;True;0;0;False;0;1.9;1.73;-1;12;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-2104.756,-162.4897;Float;False;Property;_SnowCoverageMin;Snow Coverage Min;8;0;Create;True;0;0;False;0;-4.1;-4.1;-12;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-766.2324,-2473.668;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;30;-1945.506,-341.8684;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;208;-1065.939,-2383.297;Inherit;False;Property;_GroundSnowDetail;Ground Snow Detail;17;0;Create;True;0;0;False;0;2;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;192;-975.7153,-2677.914;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;77;-822.3085,828.2149;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;210;-787.5848,-2675.811;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;165;511.9221,1006.86;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;-1039.244,-290.4118;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;109.1342,-2325.262;Inherit;False;Property;_SnowMultiplier;Snow Multiplier;7;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;22;844.8288,-2293.098;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;138;45.08826,-1185.455;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;44;-586.8294,1315.403;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-325.2322,-2075.307;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;116;1332.561,880.5891;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;161;-474.466,-266.653;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;142;-661.8717,1452.504;Inherit;True;Overlay;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;230;570.9496,-2812.694;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;-214.9665,-2527.317;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;231;518.1074,-2864.703;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;238;398.2061,-2438.075;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;107;-553.9965,-1948.527;Inherit;False;Property;_BaseColor;Base Color;0;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;114;983.9135,876.8727;Inherit;True;Property;_ThicknessMap;Thickness Map;6;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;117;1063.89,1094.549;Inherit;False;Property;_CoverageSSSThickness;Coverage SSS Thickness;15;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;229;-2271.35,-2884.983;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-924.1898,-2077.674;Inherit;True;Property;_BaseColorMap;Base Map;1;0;Create;False;0;0;False;0;-1;None;e2a54cbdf2f3310468963aaeefd25bbd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;118;171.7616,-2557.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;186;-874.6737,-1865.069;Inherit;False;Property;_DetailAlbedoScale;Detail Albedo Scale;13;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;24;-566.2275,-2093.006;Inherit;False;Overlay;False;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;221;-1278.132,-2426.557;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-1131.978,-2575.871;Inherit;False;Property;_GroundSnowPosition;Ground Snow Position;18;0;Create;True;0;0;False;0;2;2;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;34;-2128.884,-346.531;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;15;-1062.516,1355.75;Inherit;True;Property;_MaskMap;Mask Map;3;0;Create;False;0;0;False;0;-1;58747150f8709cb4cb5cb00ad8403bd7;3af1d0db7e7961c46917ed44ab18c838;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;144;-803.2163,1017.219;Inherit;False;Property;_SnowSplashOcclusionInfluence;Snow Splash Occlusion Influence;19;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;151;-1910.097,-2385.105;Inherit;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BlendNormalsNode;96;-466.489,-1200.005;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;72;-1993.842,647.7413;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;152;-2146.557,-2374.365;Inherit;True;COLOR;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;71;-2271.71,646.4595;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0.27;False;2;FLOAT;0.77;False;3;FLOAT;0;False;4;FLOAT;0.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-833.2664,-1391.579;Inherit;True;Property;_NormalMap;Normal Map;2;0;Create;False;0;0;False;0;-1;dd1f2af6401691a42aa424d2d3b3cb1a;635d171f852c07f41af5151df895a7eb;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;78;-1830.647,595.5366;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;106;-785.7685,-1160.928;Inherit;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-2520.685,755.3959;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;102;-1052.859,-1176.389;Inherit;True;COLOR;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;226;-2249.358,-2302.192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;150;-2708.614,-2400.578;Inherit;True;Property;_Snow_DetailMap;Snow_DetailMap;4;0;Create;True;0;0;False;0;-1;ae59db58aaea44d489d6c8b0dcb269a7;ae59db58aaea44d489d6c8b0dcb269a7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;69;-2727.978,650.3314;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-2833.116,827.502;Float;False;Property;_SnowSplash;Snow Splash;11;0;Create;True;0;0;False;0;1;3;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;19;-2973.522,-1782.278;Inherit;True;Property;_DetailMap;Detail Map;5;0;Create;False;0;0;False;0;-1;256a83e41a4f66f4aa4cc143d792174b;256a83e41a4f66f4aa4cc143d792174b;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;66;-3044.199,722.25;Float;False;Property;_SnowSplashNormalInfluence;Snow Splash Normal Influence;12;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-1089.98,-932.675;Inherit;False;Property;_DetailNormalScale;Detail Normal Scale;14;0;Create;False;0;0;False;0;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;179;-2525.054,-1750.317;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0.24;False;2;FLOAT;0.4;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;26;-3125.623,-414.675;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;38;-3182.173,-243.5246;Float;False;Property;_SnowCoverNormalInfluence;Snow Cover Normal Influence;10;0;Create;True;0;0;False;0;3;1.2;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;28;-2336.731,-304.8477;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;294.0173,1005.771;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;76;-1111.892,828.916;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;232;-2239.357,-411.2635;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;225;-1301.064,-2401.078;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;188;-1184.205,-2747.392;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;234;-189.3383,-959.6417;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;222;-1301.064,-1771.72;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;91;75.78976,1002.216;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-1279.223,827.4261;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;52;-2644.15,-310.8754;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;90;-222.7031,1003.607;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-5.38;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;233;-111.7009,-1070.318;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;224;-1331.64,-1756.432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;39;-2833.684,-312.133;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;83;-1453.94,648.2489;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;147;-465.5513,999.8862;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;73;-1648.885,596.718;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;183;-2236.434,-1750.377;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;112;612.2045,-253.7133;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;239;1558.696,30.25881;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Snow Coverage Translucent Standard;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;193;0;207;0
WireConnection;32;0;53;0
WireConnection;227;0;223;0
WireConnection;235;0;236;0
WireConnection;236;0;184;0
WireConnection;223;0;150;1
WireConnection;207;0;210;0
WireConnection;207;1;209;0
WireConnection;228;0;227;0
WireConnection;53;0;30;2
WireConnection;53;3;93;0
WireConnection;53;4;95;0
WireConnection;184;0;77;0
WireConnection;184;1;165;0
WireConnection;209;0;221;0
WireConnection;209;1;208;0
WireConnection;30;0;34;0
WireConnection;192;0;188;3
WireConnection;77;0;76;0
WireConnection;210;0;192;0
WireConnection;210;3;211;0
WireConnection;165;0;89;0
WireConnection;85;0;32;0
WireConnection;85;1;235;0
WireConnection;22;0;115;0
WireConnection;22;1;230;0
WireConnection;22;2;238;0
WireConnection;138;0;96;0
WireConnection;138;1;151;0
WireConnection;138;2;238;0
WireConnection;44;0;15;2
WireConnection;44;2;32;0
WireConnection;115;0;24;0
WireConnection;115;1;107;0
WireConnection;116;0;114;0
WireConnection;116;1;117;0
WireConnection;116;2;238;0
WireConnection;161;0;150;3
WireConnection;142;0;15;4
WireConnection;142;1;19;3
WireConnection;230;0;231;0
WireConnection;198;0;193;0
WireConnection;198;1;124;0
WireConnection;231;0;229;0
WireConnection;238;0;118;0
WireConnection;238;1;148;0
WireConnection;229;0;228;0
WireConnection;118;0;85;0
WireConnection;118;1;198;0
WireConnection;24;0;19;1
WireConnection;24;1;11;0
WireConnection;24;2;186;0
WireConnection;221;0;225;0
WireConnection;34;0;232;0
WireConnection;34;1;151;0
WireConnection;34;2;28;0
WireConnection;151;0;152;0
WireConnection;96;0;14;0
WireConnection;96;1;106;0
WireConnection;72;0;71;0
WireConnection;152;0;226;0
WireConnection;152;1;150;2
WireConnection;71;0;70;0
WireConnection;78;0;96;0
WireConnection;78;1;151;0
WireConnection;78;2;72;0
WireConnection;106;0;102;0
WireConnection;106;1;110;0
WireConnection;70;0;69;0
WireConnection;70;1;68;0
WireConnection;102;0;19;4
WireConnection;102;1;19;2
WireConnection;226;0;150;4
WireConnection;69;0;67;2
WireConnection;69;1;66;0
WireConnection;179;0;19;1
WireConnection;28;0;52;0
WireConnection;89;0;91;0
WireConnection;89;1;183;0
WireConnection;76;0;75;0
WireConnection;232;0;234;0
WireConnection;225;0;222;0
WireConnection;234;0;233;0
WireConnection;222;0;224;0
WireConnection;91;0;90;0
WireConnection;75;0;68;0
WireConnection;75;1;83;0
WireConnection;52;0;39;0
WireConnection;90;0;147;0
WireConnection;233;0;96;0
WireConnection;224;0;183;0
WireConnection;39;0;26;2
WireConnection;39;1;38;0
WireConnection;83;0;73;2
WireConnection;147;0;15;2
WireConnection;147;1;144;0
WireConnection;73;0;78;0
WireConnection;183;0;179;0
WireConnection;112;0;142;0
WireConnection;112;1;161;0
WireConnection;112;2;238;0
ASEEND*/
//CHKSM=379B1D8DA395F6F4D53EDF0C1C08ECBF6E4138B4