-- Vertex

#extension GL_ARB_explicit_attrib_location : enable

layout(location = 0) in vec3 vertex;

out vec2 texCoord;

void main()
{
	gl_Position = vec4(vertex, 1);
	texCoord = vec2((vertex.x + 1) * 0.5, (vertex.y + 1) * 0.5);
}


-- Fragment

uniform sampler2D frontFaces;
uniform sampler2D backFaces;
uniform sampler3D volume;

uniform int renderingMode;

in vec2 texCoord;
out vec4 fragColor;

void main()
{
	vec3 frontTex = texture(frontFaces, texCoord).rgb;
	vec3 backTex = texture(frontFaces, texCoord).rgb;
	
	switch(renderingMode)
	{
		case 0: //render front faces
		{
			fragColor = vec4(frontTexture, 1);
			break;
		}
		
		case 1: //render back faces
		{
			fragColor = vec4(backTexture, 1);
			break;
		}
		
		case 2: //render volume (MIP)
		{
			
			
	
			break;
		}
		case 3: //render volume (Alpha-Compositing)
		{
			break;
		}
	}
}