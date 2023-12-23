uniform int shellID;
uniform vec3 color;
uniform float density;
uniform int shellCount;
uniform vec3 dirLight;
uniform float time;
uniform float furDirectionX;
uniform float furDirectionY;
uniform float shellHeight;
uniform float thickness;
uniform bool tapered;


in vec3 vnormal;
in vec2 vuv;
#define hashi(x)   triple32(x) 

#define hash(x)  ( float( hashi(x) ) / float( 0xffffffffU ) )

mat2 rot2D(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

// This is a hashing function that takes in an unsigned integer seed and shuffles it around to make it seem random
// The output is in the range 0 to 1, so you do not have to worry about that and can easily convert it to any other
// range you desire by multiplying the output with any number.
uint triple32(uint x)
{
    x ^= x >> 17;
    x *= 0xed5ad4bbU;
    x ^= x >> 11;
    x *= 0xac4c1b51U;
    x ^= x >> 15;
    x *= 0x31848babU;
    x ^= x >> 14;
    return x;
}


void main() {

	float h = float(shellID) / float(shellCount);
    vec2 furDirection = (h * vec2(furDirectionX, furDirectionY)) * density * shellHeight;
    // we need to add 0.5 to ensure we don't get negative values when we 
    // displace with our fur direction
    uvec2 tid = uvec2((vuv + 0.5) * density + furDirection);
    //uvec2 tid = uvec2((vuv + 0.5) * density);

	// ripped from acerola
	uint seed = tid.x + uint(100) * tid.y + uint(100 * 10);
	float rand = hash(seed);

    vec2 newUV = vuv * density;

    // In order to operate in the local space uv coordinates after expanding them to a wider range, we take the fractional component
    // since uv coordinates by default range from 0 to 1 so then the fractional part is in 0 to 1 so it just works (tm) also we multiply
    // by 2 and subtract 1 to convert from 0 to 1 to -1 to 1 in order to shift the origin of these local uvs to the center for a calculation below
    vec2 localUV = fract(newUV) * 2. - 1.;
    
    // This is the local distance from the local center, the pythagorean distance technically
    float localDistanceFromCenter = length(localUV);
    bool outsideThickness = tapered ? (localDistanceFromCenter) > (thickness * (rand - h)) : h > rand;

	if (outsideThickness && shellID > 0) discard;

    vec3 n = normalize(vnormal);
    vec3 l = mat3(viewMatrix) * dirLight;
    float lambert = dot(n, l) / 2.0 + 0.5;
    float occlusion = pow(h, 0.8);

	gl_FragColor = vec4(color * lambert * occlusion, 1);
	

}

