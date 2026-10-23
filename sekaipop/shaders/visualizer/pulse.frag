#version 440

layout(std140, binding = 0) uniform buf
{
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 resolution;
    float time;
    float bass;
    float fade;
    float bandCount;
    float px;
    float lite;
    vec4 color1;
    vec4 color2;
    vec4 color3;
    vec4 b0;
    vec4 b1;
    vec4 b2;
    vec4 b3;
    vec4 b4;
    vec4 b5;
    vec4 b6;
    vec4 b7;
    vec4 b8;
    vec4 b9;
    vec4 b10;
    vec4 b11;
    vec4 b12;
    vec4 p0;
    vec4 p1;
    vec4 p2;
    vec4 p3;
    vec4 p4;
    vec4 p5;
    vec4 p6;
    vec4 p7;
    vec4 p8;
    vec4 p9;
    vec4 p10;
    vec4 p11;
    vec4 p12;
} ubuf;

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

vec4 bchunk(int j)
{
    if (j <= 6)
    {
        if (j <= 3)
        {
            if (j <= 1)
            {
                if (j <= 0)
                {
                    return ubuf.b0;
                }
                return ubuf.b1;
            }
            if (j <= 2)
            {
                return ubuf.b2;
            }
            return ubuf.b3;
        }
        if (j <= 5)
        {
            if (j <= 4)
            {
                return ubuf.b4;
            }
            return ubuf.b5;
        }
        return ubuf.b6;
    }
    if (j <= 9)
    {
        if (j <= 8)
        {
            if (j <= 7)
            {
                return ubuf.b7;
            }
            return ubuf.b8;
        }
        return ubuf.b9;
    }
    if (j <= 11)
    {
        if (j <= 10)
        {
            return ubuf.b10;
        }
        return ubuf.b11;
    }
    return ubuf.b12;
}

float pick(vec4 c, int r)
{
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

float levelAt(int idx)
{
    int i = int(clamp(float(idx), 0.0, 51.0));
    int j = i / 4;
    int param = j;
    vec4 param_1 = bchunk(param);
    int param_2 = i - (j * 4);
    return pick(param_1, param_2);
}

float lvAt(float f, float nb)
{
    float g = clamp(f, 0.0, nb - 1.0);
    int i0 = int(floor(g));
    int i1 = int(min(nb - 1.0, float(i0) + 1.0));
    float t = g - float(i0);
    t = (t * t) * (3.0 - (2.0 * t));
    int param = i0;
    int param_1 = i1;
    return mix(levelAt(param), levelAt(param_1), t);
}

float sc(float x)
{
    float x2 = x * x;
    return x / sqrt(sqrt(1.0 + (x2 * x2)));
}

vec3 rgb(vec4 c)
{
    return vec3(c.x, c.y, c.z);
}

float edge(float d)
{
    return clamp((d / ubuf.px) + 0.5, 0.0, 1.0);
}

vec4 pm(vec3 c, float a)
{
    return vec4(c.x * a, c.y * a, c.z * a, a);
}

vec4 over(vec4 src, vec4 dst)
{
    return src + (dst * (1.0 - src.w));
}

vec4 pchunk(int j)
{
    if (j <= 6)
    {
        if (j <= 3)
        {
            if (j <= 1)
            {
                if (j <= 0)
                {
                    return ubuf.p0;
                }
                return ubuf.p1;
            }
            if (j <= 2)
            {
                return ubuf.p2;
            }
            return ubuf.p3;
        }
        if (j <= 5)
        {
            if (j <= 4)
            {
                return ubuf.p4;
            }
            return ubuf.p5;
        }
        return ubuf.p6;
    }
    if (j <= 9)
    {
        if (j <= 8)
        {
            if (j <= 7)
            {
                return ubuf.p7;
            }
            return ubuf.p8;
        }
        return ubuf.p9;
    }
    if (j <= 11)
    {
        if (j <= 10)
        {
            return ubuf.p10;
        }
        return ubuf.p11;
    }
    return ubuf.p12;
}

float peakAt(int idx)
{
    int i = int(clamp(float(idx), 0.0, 51.0));
    int j = i / 4;
    int param = j;
    vec4 param_1 = pchunk(param);
    int param_2 = i - (j * 4);
    return pick(param_1, param_2);
}

float lvAtP(float f, float nb)
{
    float g = clamp(f, 0.0, nb - 1.0);
    int i0 = int(floor(g));
    int i1 = int(min(nb - 1.0, float(i0) + 1.0));
    float t = g - float(i0);
    t = (t * t) * (3.0 - (2.0 * t));
    int param = i0;
    int param_1 = i1;
    return mix(peakAt(param), peakAt(param_1), t);
}

void main()
{
    vec2 res = ubuf.resolution;
    float W = res.x;
    float H = res.y;
    float bs = ubuf.bass;
    bool lite = ubuf.lite > 0.5;
    float fadeIn = min(1.0, ubuf.fade);
    vec2 p = qt_TexCoord0 * res;
    p.y -= (((1.0 - fadeIn) * 0.180000007152557373046875) * H);
    float sp = H / 20.0;
    float xr = p.x - (0.5 * W);
    float cxr = floor(xr / sp);
    float cx = (cxr + 0.5) * sp;
    float lx = xr - cx;
    float dyc = p.y - (0.5 * H);
    float ay = abs(dyc);
    float ry = ay / sp;
    float rr = floor(ry);
    float ly = ((ry - rr) - 0.5) * sp;
    float dd = sqrt((lx * lx) + (ly * ly));
    float dotY = (rr + 0.5) * sp;
    float _595;
    if (ubuf.bandCount > 1.0)
    {
        _595 = ubuf.bandCount;
    }
    else
    {
        _595 = 50.0;
    }
    float nb = _595;
    float u = min(1.0, abs(cx) / (0.5 * W));
    float f = (u * (nb - 1.0)) * 0.85000002384185791015625;
    float boost = (1.0 + (u * 0.89999997615814208984375)) * (1.0 + (0.3499999940395355224609375 * bs));
    float param = f;
    float param_1 = nb;
    float L = lvAt(param, param_1);
    float param_2 = (L * 1.14999997615814208984375) * boost;
    float L2 = sc(param_2);
    float hgt = max((H * 0.4600000083446502685546875) * L2, 0.60000002384185791015625 * sp);
    float lit = clamp(((hgt - dotY) / (sp * 0.699999988079071044921875)) + 0.5, 0.0, 1.0);
    float tt = clamp(dotY / max(hgt, sp), 0.0, 1.0);
    vec4 param_3 = ubuf.color1;
    vec3 c1 = rgb(param_3);
    vec4 param_4 = ubuf.color2;
    vec3 c2 = rgb(param_4);
    vec4 param_5 = ubuf.color3;
    vec3 c3 = rgb(param_5);
    float ring = 0.0;
    if (!lite)
    {
        float hx = cx / (0.5 * W);
        float hy = (dotY / (0.5 * W)) * 3.2000000476837158203125;
        float dist = sqrt((hx * hx) + (hy * hy));
        float ur = 0.0500000007450580596923828125 + ((1.0 - min(1.0, bs / 0.89999997615814208984375)) * 0.949999988079071044921875);
        ring = exp((-((dist - ur) * (dist - ur))) / 0.0040000001899898052215576171875) * clamp(bs * 1.2999999523162841796875, 0.0, 1.0);
    }
    float radOn = sp * (0.1599999964237213134765625 + ((0.300000011920928955078125 * (0.3499999940395355224609375 + (0.64999997615814208984375 * tt))) * (0.550000011920928955078125 + (0.449999988079071044921875 * L2))));
    float radOff = sp * (0.070000000298023223876953125 + (0.20000000298023223876953125 * ring));
    float rad = min(mix(radOff, radOn, lit) * (1.0 + ((0.5 * ring) * lit)), 0.4799999892711639404296875 * sp);
    vec3 onCol = mix(c1, c2, vec3(smoothstep(0.300000011920928955078125, 0.85000002384185791015625, tt)));
    onCol = mix(onCol, vec3(1.0), vec3(smoothstep(0.87999999523162841796875, 1.0, tt) * 0.3499999940395355224609375));
    vec3 col = mix(c3 * 0.550000011920928955078125, onCol, vec3(lit));
    col = mix(col, vec3(1.0), vec3((0.25 * bs) * lit));
    float a = mix(0.550000011920928955078125 + (0.449999988079071044921875 * ring), 1.0, lit);
    float param_6 = rad - dd;
    float cov = edge(param_6);
    vec3 param_7 = col;
    float param_8 = cov * a;
    vec4 acc = pm(param_7, param_8);
    if (!lite)
    {
        float halo = (lit * 0.550000011920928955078125) * exp((-dd) / (sp * 0.699999988079071044921875));
        vec3 param_9 = onCol;
        float param_10 = halo;
        vec4 param_11 = acc;
        vec4 param_12 = pm(param_9, param_10);
        acc = over(param_11, param_12);
        float cm = cxr - (3.0 * floor(cxr / 3.0));
        if (cm < 0.5)
        {
            float param_13 = f;
            float param_14 = nb;
            float P = lvAtP(param_13, param_14);
            if (P > 0.20000000298023223876953125)
            {
                float param_15 = (P * 1.14999997615814208984375) * boost;
                float hp = ((H * 0.4600000083446502685546875) * sc(param_15)) + (0.75 * sp);
                float qx = abs(lx) / (sp * 0.550000011920928955078125);
                float qy = abs(ay - hp) / (sp * 0.550000011920928955078125);
                float star = clamp((1.0 - (sqrt(qx) + sqrt(qy))) * 4.0, 0.0, 1.0) * clamp(P * 3.0, 0.0, 1.0);
                vec3 param_16 = vec3(1.0);
                float param_17 = star;
                vec4 param_18 = pm(param_16, param_17);
                vec4 param_19 = acc;
                acc = over(param_18, param_19);
            }
        }
    }
    fragColor = acc * (min(1.0, ubuf.fade * 2.0) * ubuf.qt_Opacity);
}
