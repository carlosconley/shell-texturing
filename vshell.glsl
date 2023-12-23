uniform int shellID;
uniform float shellHeight;
uniform int shellCount;
uniform float time;
uniform float furDirectionX;
uniform float furDirectionY;
uniform float furDirectionZ;

out vec3 vnormal;
out vec2 vuv;

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
	vec4 pos4 = vec4(position, 1);
	float h = float(shellID) / float(shellCount);
	pos4.xyz += normal.xyz * float(shellHeight) * h;
	gl_Position = projectionMatrix * modelViewMatrix * pos4;

	vnormal = mat3(modelViewMatrix) * normal;
	vuv = uv;
}