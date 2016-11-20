attribute vec2     a_texCoord;
attribute vec4     a_position;
varying vec2    v_texCoord;
void main()
{
    v_texCoord  = a_texCoord;
    gl_Position = (CC_PMatrix * CC_MVMatrix) * a_position;
    //gl_Position = CC_PMatrix * a_position;
}