// CM
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//Number of iterations to power and convolute a complex point, it specifies the "detail" of fractal. Higher values are more taxing
const float max_iters = 50.;

//Number of "heads" or power each complex point is evaluated at,change to select heads. More heads reduces fractal mobility
const int heads = 2;

vec2 comp_mult(vec2 a, vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 cpow(vec2 c){
    vec2 res = c;
    for(int i = 1; i < heads; i++){
        res = comp_mult(res, c);
    }
    return res;
}

vec2 shape(float a1, float a2, float a3, float a4, float intensity){
    return (
        intensity * 
        (vec2(
            cos(a1  * sin(a2 * u_time)), 
            cos(a2  * sin(a1 * u_time))
        ) 
        - 
        sqrt(2.) * 
        vec2(
            sin(a3  * cos(a4 * u_time)), 
            sin(a4  * cos(a3 * u_time))
        ))
    );
}

bool char(vec2 v, float i, float max){
    //Character criteria, this decides whether a point should be drawn, i.e it is "significant"
    //This is dramatically change the fractal, i.e try changing the first cos for a sin, or tan!
    return cos(log(length(v))) > cos(i/max);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  vec2 v = (gl_FragCoord.xy/u_resolution*2.4) - vec2(1.2);
    if(u_resolution.y > u_resolution.x) {
      v *= vec2(1, u_resolution.y / u_resolution.x);
    } else v *= vec2(u_resolution.x / u_resolution.y, 1);
    float n = 0.;
    for(float i = 0.; i < max_iters; i++) {
        if(n == 0.) {            
            // Shape is important, you can modify values here too, to obtain new patterns
            vec2 c = shape(0.4, 1., .5, -.2, -.5) + 3. * (u_mouse.xy - vec2(u_resolution.x/2., u_resolution.y/2.)) / u_resolution;
            
            // Modify how v is updated to change convergence. Remove multiplication by i to obtain pattern similar to julia set
            v = cpow(v) + c*i;
            if(char(v, i, max_iters)) n = i;
        }
    }
    if(n != 0.) {
        //Colour formula changable here
      float col = u_time / float(n) / float(max_iters);
      col = sqrt(col);
    
    gl_FragColor = vec4(hsv2rgb(vec3(col, 1, 1)), 1);
    } else {
        gl_FragColor = vec4(0);
    }
}

