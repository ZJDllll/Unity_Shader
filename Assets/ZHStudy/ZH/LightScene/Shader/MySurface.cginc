#if !defined(MY_SURFACE_INCLUDE)
#define MY_SURFACE_INCLUDE
struct SurfaceData{
    float3 albedo,emission,normal;
    float alpha,metallic,occlusion,smoothness;
};
struct SurfaceParameters{
    float3 normal,position;
    float4 uv;
};
#endif