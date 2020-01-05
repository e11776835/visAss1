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
	vec3 backTex = texture(backFaces, texCoord).rgb;

	vec3 ray = frontTex - backTex;
	vec3 reverse_ray = backTex - frontTex;

	float stepRate = 0.001;
	vec3 step = stepRate * normalize(reverse_ray);
	
	switch(renderingMode)
	{
		// --------------------------------------------
		case 0: //render front faces
		{
			fragColor = vec4(frontTex, 1);
			break;
		}
		
		// --------------------------------------------
		case 1: //render back faces
		{
			fragColor = vec4(backTex, 1);
			break;
		}
		
		// --------------------------------------------
		case 2: //render volume (MIP)
		{
			float max = 0.0;

			for(float len = length(reverse_ray); len > 0; len -= stepRate) {
				float src = (texture(volume, frontTex)).r;

				if(src > max) {
					max = src;
				}

				frontTex += step;
			}

			fragColor = vec4(max, max, max, 1);
			break;
		}

		// --------------------------------------------
		case 3: //render volume (Alpha-Compositing)
		{
			vec4 color = vec4(0, 0, 0, 0);

			for(float len = length(reverse_ray); len > 0; len -= stepRate) {
				float src = (texture(volume, frontTex)).r;

				vec3 color_1 = vec3(0, 0, 0);
				vec3 color_2 = vec3(0, 0, 0);
				float temp;

				if(src <= 0.1) {
					temp = 0.0;
				} else if (src < 0.3) {
					color_1 = vec3(0, 0, 0);
					color_2 = vec3(1, 0, 0);
					temp = 0.002;

				} else if (src < 0.5) {
					color_1 = vec3(1, 0, 0);
					color_2 = vec3(0, 1, 0);
					temp = 0.03;

				}  else if (src < 0.6) {
					color_1 = vec3(0, 0, 1);
					color_2 = vec3(0, 1, 0);
					temp = 0.08;

				}  else if (src < 0.8) {
					color_1 = vec3(0, 1, 0);
					color_2 = vec3(1, 1, 1);
					temp = 0.01;

				} else {
					temp = 0;
				}

				vec3 colorValue = mix(color_1, color_2, src);
				vec4 alpha = vec4(colorValue, temp);

				color = alpha.a * alpha + (1 - alpha.a) * color;
				
				if (color.a >= 1) {
					break;
				} else {
					frontTex += step;
				}
			}

			fragColor = vec4(color.rgb, 1);
			break;
		}
	}
}