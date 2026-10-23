#version 440

layout(std140, binding = 0) uniform buf
{
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 resolution;
    float ncols;
    float padX;
    float lineW;
    float shadowOff;
    float px;
    vec4 inkCol;
    vec4 shadowCol;
    vec4 fill0;
    vec4 fill1;
    vec4 fill2;
    vec4 pin0;
    vec4 pin1;
    vec4 pin2;
    vec4 pin3;
    vec4 pin4;
    vec4 pin5;
    vec4 pin6;
    vec4 pin7;
    vec4 pin8;
    vec4 pinS0;
    vec4 pinS1;
    vec4 pinS2;
    vec4 h0_0;
    vec4 h0_1;
    vec4 h0_2;
    vec4 h0_3;
    vec4 h0_4;
    vec4 h0_5;
    vec4 h0_6;
    vec4 h0_7;
    vec4 h0_8;
    vec4 h0_9;
    vec4 h0_10;
    vec4 h0_11;
    vec4 h0_12;
    vec4 h0_13;
    vec4 h0_14;
    vec4 h0_15;
    vec4 h0_16;
    vec4 h0_17;
    vec4 h0_18;
    vec4 h0_19;
    vec4 h0_20;
    vec4 h1_0;
    vec4 h1_1;
    vec4 h1_2;
    vec4 h1_3;
    vec4 h1_4;
    vec4 h1_5;
    vec4 h1_6;
    vec4 h1_7;
    vec4 h1_8;
    vec4 h1_9;
    vec4 h1_10;
    vec4 h1_11;
    vec4 h1_12;
    vec4 h1_13;
    vec4 h1_14;
    vec4 h1_15;
    vec4 h1_16;
    vec4 h1_17;
    vec4 h1_18;
    vec4 h1_19;
    vec4 h1_20;
    vec4 h2_0;
    vec4 h2_1;
    vec4 h2_2;
    vec4 h2_3;
    vec4 h2_4;
    vec4 h2_5;
    vec4 h2_6;
    vec4 h2_7;
    vec4 h2_8;
    vec4 h2_9;
    vec4 h2_10;
    vec4 h2_11;
    vec4 h2_12;
    vec4 h2_13;
    vec4 h2_14;
    vec4 h2_15;
    vec4 h2_16;
    vec4 h2_17;
    vec4 h2_18;
    vec4 h2_19;
    vec4 h2_20;
} _91;

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

vec4 chunk0(int j)
{
    if (j <= 10)
    {
        if (j <= 5)
        {
            if (j <= 2)
            {
                if (j <= 1)
                {
                    if (j <= 0)
                    {
                        return _91.h0_0;
                    }
                    else
                    {
                        return _91.h0_1;
                    }
                }
                else
                {
                    return _91.h0_2;
                }
            }
            else
            {
                if (j <= 4)
                {
                    if (j <= 3)
                    {
                        return _91.h0_3;
                    }
                    else
                    {
                        return _91.h0_4;
                    }
                }
                else
                {
                    return _91.h0_5;
                }
            }
        }
        else
        {
            if (j <= 8)
            {
                if (j <= 7)
                {
                    if (j <= 6)
                    {
                        return _91.h0_6;
                    }
                    else
                    {
                        return _91.h0_7;
                    }
                }
                else
                {
                    return _91.h0_8;
                }
            }
            else
            {
                if (j <= 9)
                {
                    return _91.h0_9;
                }
                else
                {
                    return _91.h0_10;
                }
            }
        }
    }
    else
    {
        if (j <= 15)
        {
            if (j <= 13)
            {
                if (j <= 12)
                {
                    if (j <= 11)
                    {
                        return _91.h0_11;
                    }
                    else
                    {
                        return _91.h0_12;
                    }
                }
                else
                {
                    return _91.h0_13;
                }
            }
            else
            {
                if (j <= 14)
                {
                    return _91.h0_14;
                }
                else
                {
                    return _91.h0_15;
                }
            }
        }
        else
        {
            if (j <= 18)
            {
                if (j <= 17)
                {
                    if (j <= 16)
                    {
                        return _91.h0_16;
                    }
                    else
                    {
                        return _91.h0_17;
                    }
                }
                else
                {
                    return _91.h0_18;
                }
            }
            else
            {
                if (j <= 19)
                {
                    return _91.h0_19;
                }
                else
                {
                    return _91.h0_20;
                }
            }
        }
    }
}

vec4 chunk1(int j)
{
    if (j <= 10)
    {
        if (j <= 5)
        {
            if (j <= 2)
            {
                if (j <= 1)
                {
                    if (j <= 0)
                    {
                        return _91.h1_0;
                    }
                    else
                    {
                        return _91.h1_1;
                    }
                }
                else
                {
                    return _91.h1_2;
                }
            }
            else
            {
                if (j <= 4)
                {
                    if (j <= 3)
                    {
                        return _91.h1_3;
                    }
                    else
                    {
                        return _91.h1_4;
                    }
                }
                else
                {
                    return _91.h1_5;
                }
            }
        }
        else
        {
            if (j <= 8)
            {
                if (j <= 7)
                {
                    if (j <= 6)
                    {
                        return _91.h1_6;
                    }
                    else
                    {
                        return _91.h1_7;
                    }
                }
                else
                {
                    return _91.h1_8;
                }
            }
            else
            {
                if (j <= 9)
                {
                    return _91.h1_9;
                }
                else
                {
                    return _91.h1_10;
                }
            }
        }
    }
    else
    {
        if (j <= 15)
        {
            if (j <= 13)
            {
                if (j <= 12)
                {
                    if (j <= 11)
                    {
                        return _91.h1_11;
                    }
                    else
                    {
                        return _91.h1_12;
                    }
                }
                else
                {
                    return _91.h1_13;
                }
            }
            else
            {
                if (j <= 14)
                {
                    return _91.h1_14;
                }
                else
                {
                    return _91.h1_15;
                }
            }
        }
        else
        {
            if (j <= 18)
            {
                if (j <= 17)
                {
                    if (j <= 16)
                    {
                        return _91.h1_16;
                    }
                    else
                    {
                        return _91.h1_17;
                    }
                }
                else
                {
                    return _91.h1_18;
                }
            }
            else
            {
                if (j <= 19)
                {
                    return _91.h1_19;
                }
                else
                {
                    return _91.h1_20;
                }
            }
        }
    }
}

vec4 chunk2(int j)
{
    if (j <= 10)
    {
        if (j <= 5)
        {
            if (j <= 2)
            {
                if (j <= 1)
                {
                    if (j <= 0)
                    {
                        return _91.h2_0;
                    }
                    else
                    {
                        return _91.h2_1;
                    }
                }
                else
                {
                    return _91.h2_2;
                }
            }
            else
            {
                if (j <= 4)
                {
                    if (j <= 3)
                    {
                        return _91.h2_3;
                    }
                    else
                    {
                        return _91.h2_4;
                    }
                }
                else
                {
                    return _91.h2_5;
                }
            }
        }
        else
        {
            if (j <= 8)
            {
                if (j <= 7)
                {
                    if (j <= 6)
                    {
                        return _91.h2_6;
                    }
                    else
                    {
                        return _91.h2_7;
                    }
                }
                else
                {
                    return _91.h2_8;
                }
            }
            else
            {
                if (j <= 9)
                {
                    return _91.h2_9;
                }
                else
                {
                    return _91.h2_10;
                }
            }
        }
    }
    else
    {
        if (j <= 15)
        {
            if (j <= 13)
            {
                if (j <= 12)
                {
                    if (j <= 11)
                    {
                        return _91.h2_11;
                    }
                    else
                    {
                        return _91.h2_12;
                    }
                }
                else
                {
                    return _91.h2_13;
                }
            }
            else
            {
                if (j <= 14)
                {
                    return _91.h2_14;
                }
                else
                {
                    return _91.h2_15;
                }
            }
        }
        else
        {
            if (j <= 18)
            {
                if (j <= 17)
                {
                    if (j <= 16)
                    {
                        return _91.h2_16;
                    }
                    else
                    {
                        return _91.h2_17;
                    }
                }
                else
                {
                    return _91.h2_18;
                }
            }
            else
            {
                if (j <= 19)
                {
                    return _91.h2_19;
                }
                else
                {
                    return _91.h2_20;
                }
            }
        }
    }
}

float ysample(int k, int idx)
{
    int j = idx / 4;
    int r = idx - (j * 4);
    vec4 c;
    if (k == 0)
    {
        int param = j;
        c = chunk0(param);
    }
    else
    {
        if (k == 1)
        {
            int param_1 = j;
            c = chunk1(param_1);
        }
        else
        {
            int param_2 = j;
            c = chunk2(param_2);
        }
    }
    if (r == 0)
    {
        return c.x;
    }
    if (r == 1)
    {
        return c.y;
    }
    if (r == 2)
    {
        return c.z;
    }
    return c.w;
}

vec2 crest(int k, float x)
{
    float span = _91.resolution.x + (2.0 * _91.padX);
    float cf = ((x + _91.padX) / span) * _91.ncols;
    float fi = clamp(floor(cf), 0.0, _91.ncols - 1.0);
    float t = cf - fi;
    int i = int(fi);
    int i0 = int(max(0.0, float(i - 1)));
    int i2 = i + 1;
    int i3 = int(min(floor(_91.ncols), float(i + 2)));
    int param = k;
    int param_1 = i0;
    float y0 = ysample(param, param_1);
    int param_2 = k;
    int param_3 = i;
    float y1 = ysample(param_2, param_3);
    int param_4 = k;
    int param_5 = i2;
    float y2 = ysample(param_4, param_5);
    int param_6 = k;
    int param_7 = i3;
    float y3 = ysample(param_6, param_7);
    float c1 = y1 + ((y2 - y0) / 6.0);
    float c2 = y2 - ((y3 - y1) / 6.0);
    float u = 1.0 - t;
    float y = (((((u * u) * u) * y1) + ((((3.0 * u) * u) * t) * c1)) + ((((3.0 * u) * t) * t) * c2)) + (((t * t) * t) * y2);
    float dy = 3.0 * ((((u * u) * (c1 - y1)) + (((2.0 * u) * t) * (c2 - c1))) + ((t * t) * (y2 - c2)));
    return vec2(y, dy / (span / _91.ncols));
}

float edge(float d)
{
    return clamp((d / _91.px) + 0.5, 0.0, 1.0);
}

vec4 pm(vec4 c, float cov)
{
    return vec4(c.xyz * c.w, c.w) * cov;
}

vec4 over(vec4 src, vec4 dst)
{
    return src + (dst * (1.0 - src.w));
}

vec4 sheet(int k, vec4 fillc, vec2 p, inout vec4 acc)
{
    int param = k;
    float param_1 = p.x;
    vec2 cr = crest(param, param_1);
    float norm = sqrt(1.0 + (cr.y * cr.y));
    float sd = (p.y - cr.x) / norm;
    float param_2 = ((p.y - cr.x) - _91.shadowOff) / norm;
    vec4 param_3 = _91.shadowCol;
    float param_4 = edge(param_2);
    vec4 param_5 = pm(param_3, param_4);
    vec4 param_6 = acc;
    acc = over(param_5, param_6);
    float param_7 = sd;
    vec4 param_8 = fillc;
    float param_9 = edge(param_7);
    vec4 param_10 = pm(param_8, param_9);
    vec4 param_11 = acc;
    acc = over(param_10, param_11);
    float param_12 = (0.5 * _91.lineW) - abs(sd);
    vec4 param_13 = _91.inkCol;
    float param_14 = edge(param_12);
    vec4 param_15 = pm(param_13, param_14);
    vec4 param_16 = acc;
    acc = over(param_15, param_16);
    float fd = ((p.y - cr.x) - (1.89999997615814208984375 * _91.lineW)) / norm;
    vec4 foam = vec4(1.0, 1.0, 1.0, (k == 2) ? 0.85000002384185791015625 : 0.550000011920928955078125);
    float param_17 = (0.4000000059604644775390625 * _91.lineW) - abs(fd);
    vec4 param_18 = foam;
    float param_19 = edge(param_17);
    vec4 param_20 = pm(param_18, param_19);
    vec4 param_21 = acc;
    acc = over(param_20, param_21);
    return acc;
}

vec4 pinAt(vec4 A, float s, vec2 p, inout vec4 acc)
{
    float a = A.w;
    if (a <= 0.0199999995529651641845703125)
    {
        return acc;
    }
    vec2 c = A.xy;
    float sh = max(0.0, (A.z - c.y) - 4.0);
    float y0 = c.y + 6.0;
    float param = 1.0 - abs(p.x - c.x);
    float cx = edge(param);
    float param_1 = p.y - y0;
    float param_2 = (y0 + sh) - p.y;
    float cyv = edge(param_1) * edge(param_2);
    vec4 param_3 = _91.inkCol;
    float param_4 = (cx * cyv) * a;
    vec4 param_5 = pm(param_3, param_4);
    vec4 param_6 = acc;
    acc = over(param_5, param_6);
    float size = 9.0 + (8.0 * s);
    vec2 d = p - c;
    vec2 q = vec2(d.x + d.y, d.y - d.x) * 0.707106769084930419921875;
    float dsq = (0.5 * size) - max(abs(q.x), abs(q.y));
    float param_7 = dsq;
    vec4 param_8 = _91.inkCol;
    float param_9 = edge(param_7) * a;
    vec4 param_10 = pm(param_8, param_9);
    vec4 param_11 = acc;
    acc = over(param_10, param_11);
    float param_12 = dsq - 2.0;
    vec4 param_13 = vec4(1.0);
    float param_14 = edge(param_12) * a;
    vec4 param_15 = pm(param_13, param_14);
    vec4 param_16 = acc;
    acc = over(param_15, param_16);
    return acc;
}

void main()
{
    vec2 p = qt_TexCoord0 * _91.resolution;
    vec4 acc = vec4(0.0);
    int param = 0;
    vec4 param_1 = _91.fill0;
    vec2 param_2 = p;
    vec4 param_3 = acc;
    vec4 _1159 = sheet(param, param_1, param_2, param_3);
    acc = _1159;
    int param_4 = 1;
    vec4 param_5 = _91.fill1;
    vec2 param_6 = p;
    vec4 param_7 = acc;
    vec4 _1168 = sheet(param_4, param_5, param_6, param_7);
    acc = _1168;
    int param_8 = 2;
    vec4 param_9 = _91.fill2;
    vec2 param_10 = p;
    vec4 param_11 = acc;
    vec4 _1177 = sheet(param_8, param_9, param_10, param_11);
    acc = _1177;
    vec4 param_12 = _91.pin0;
    float param_13 = _91.pinS0.x;
    vec2 param_14 = p;
    vec4 param_15 = acc;
    vec4 _1189 = pinAt(param_12, param_13, param_14, param_15);
    acc = _1189;
    vec4 param_16 = _91.pin1;
    float param_17 = _91.pinS0.y;
    vec2 param_18 = p;
    vec4 param_19 = acc;
    vec4 _1200 = pinAt(param_16, param_17, param_18, param_19);
    acc = _1200;
    vec4 param_20 = _91.pin2;
    float param_21 = _91.pinS0.z;
    vec2 param_22 = p;
    vec4 param_23 = acc;
    vec4 _1211 = pinAt(param_20, param_21, param_22, param_23);
    acc = _1211;
    vec4 param_24 = _91.pin3;
    float param_25 = _91.pinS0.w;
    vec2 param_26 = p;
    vec4 param_27 = acc;
    vec4 _1222 = pinAt(param_24, param_25, param_26, param_27);
    acc = _1222;
    vec4 param_28 = _91.pin4;
    float param_29 = _91.pinS1.x;
    vec2 param_30 = p;
    vec4 param_31 = acc;
    vec4 _1234 = pinAt(param_28, param_29, param_30, param_31);
    acc = _1234;
    vec4 param_32 = _91.pin5;
    float param_33 = _91.pinS1.y;
    vec2 param_34 = p;
    vec4 param_35 = acc;
    vec4 _1245 = pinAt(param_32, param_33, param_34, param_35);
    acc = _1245;
    vec4 param_36 = _91.pin6;
    float param_37 = _91.pinS1.z;
    vec2 param_38 = p;
    vec4 param_39 = acc;
    vec4 _1256 = pinAt(param_36, param_37, param_38, param_39);
    acc = _1256;
    vec4 param_40 = _91.pin7;
    float param_41 = _91.pinS1.w;
    vec2 param_42 = p;
    vec4 param_43 = acc;
    vec4 _1268 = pinAt(param_40, param_41, param_42, param_43);
    acc = _1268;
    vec4 param_44 = _91.pin8;
    float param_45 = _91.pinS2.x;
    vec2 param_46 = p;
    vec4 param_47 = acc;
    vec4 _1281 = pinAt(param_44, param_45, param_46, param_47);
    acc = _1281;
    fragColor = acc * _91.qt_Opacity;
}
