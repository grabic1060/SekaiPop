#version 440

layout(std140, binding = 0) uniform buf
{
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 resolution;
    float time;
    float bass;
    float fade;
    float px;
    float lite;
    vec4 color1;
    vec4 color2;
    vec4 color3;
    vec4 s0_0;
    vec4 s0_1;
    vec4 s0_2;
    vec4 s0_3;
    vec4 s0_4;
    vec4 s0_5;
    vec4 s0_6;
    vec4 s0_7;
    vec4 s0_8;
    vec4 s0_9;
    vec4 s0_10;
    vec4 s0_11;
    vec4 s1_0;
    vec4 s1_1;
    vec4 s1_2;
    vec4 s1_3;
    vec4 s1_4;
    vec4 s1_5;
    vec4 s1_6;
    vec4 s1_7;
    vec4 s1_8;
    vec4 s1_9;
    vec4 s1_10;
    vec4 s1_11;
    vec4 s2_0;
    vec4 s2_1;
    vec4 s2_2;
    vec4 s2_3;
    vec4 s2_4;
    vec4 s2_5;
    vec4 s2_6;
    vec4 s2_7;
    vec4 s2_8;
    vec4 s2_9;
    vec4 s2_10;
    vec4 s2_11;
    vec4 s3_0;
    vec4 s3_1;
    vec4 s3_2;
    vec4 s3_3;
    vec4 s3_4;
    vec4 s3_5;
    vec4 s3_6;
    vec4 s3_7;
    vec4 s3_8;
    vec4 s3_9;
    vec4 s3_10;
    vec4 s3_11;
} ubuf;

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

vec3 rgb(vec4 c)
{
    return vec3(c.x, c.y, c.z);
}

float edge(float d)
{
    return clamp((d / ubuf.px) + 0.5, 0.0, 1.0);
}

float gridLine(float v, float pitch, float w)
{
    float dd = abs(fract((v / pitch) + 0.5) - 0.5) * pitch;
    float param = (0.5 * w) - dd;
    return edge(param);
}

vec4 pm(vec3 c, float a)
{
    return vec4(c.x * a, c.y * a, c.z * a, a);
}

vec4 over(vec4 src, vec4 dst)
{
    return src + (dst * (1.0 - src.w));
}

vec4 sChunk(int n)
{
    if (n <= 23)
    {
        if (n <= 11)
        {
            if (n <= 5)
            {
                if (n <= 2)
                {
                    if (n <= 1)
                    {
                        if (n <= 0)
                        {
                            return ubuf.s0_0;
                        }
                        return ubuf.s0_1;
                    }
                    return ubuf.s0_2;
                }
                if (n <= 4)
                {
                    if (n <= 3)
                    {
                        return ubuf.s0_3;
                    }
                    return ubuf.s0_4;
                }
                return ubuf.s0_5;
            }
            if (n <= 8)
            {
                if (n <= 7)
                {
                    if (n <= 6)
                    {
                        return ubuf.s0_6;
                    }
                    return ubuf.s0_7;
                }
                return ubuf.s0_8;
            }
            if (n <= 10)
            {
                if (n <= 9)
                {
                    return ubuf.s0_9;
                }
                return ubuf.s0_10;
            }
            return ubuf.s0_11;
        }
        if (n <= 17)
        {
            if (n <= 14)
            {
                if (n <= 13)
                {
                    if (n <= 12)
                    {
                        return ubuf.s1_0;
                    }
                    return ubuf.s1_1;
                }
                return ubuf.s1_2;
            }
            if (n <= 16)
            {
                if (n <= 15)
                {
                    return ubuf.s1_3;
                }
                return ubuf.s1_4;
            }
            return ubuf.s1_5;
        }
        if (n <= 20)
        {
            if (n <= 19)
            {
                if (n <= 18)
                {
                    return ubuf.s1_6;
                }
                return ubuf.s1_7;
            }
            return ubuf.s1_8;
        }
        if (n <= 22)
        {
            if (n <= 21)
            {
                return ubuf.s1_9;
            }
            return ubuf.s1_10;
        }
        return ubuf.s1_11;
    }
    if (n <= 35)
    {
        if (n <= 29)
        {
            if (n <= 26)
            {
                if (n <= 25)
                {
                    if (n <= 24)
                    {
                        return ubuf.s2_0;
                    }
                    return ubuf.s2_1;
                }
                return ubuf.s2_2;
            }
            if (n <= 28)
            {
                if (n <= 27)
                {
                    return ubuf.s2_3;
                }
                return ubuf.s2_4;
            }
            return ubuf.s2_5;
        }
        if (n <= 32)
        {
            if (n <= 31)
            {
                if (n <= 30)
                {
                    return ubuf.s2_6;
                }
                return ubuf.s2_7;
            }
            return ubuf.s2_8;
        }
        if (n <= 34)
        {
            if (n <= 33)
            {
                return ubuf.s2_9;
            }
            return ubuf.s2_10;
        }
        return ubuf.s2_11;
    }
    if (n <= 41)
    {
        if (n <= 38)
        {
            if (n <= 37)
            {
                if (n <= 36)
                {
                    return ubuf.s3_0;
                }
                return ubuf.s3_1;
            }
            return ubuf.s3_2;
        }
        if (n <= 40)
        {
            if (n <= 39)
            {
                return ubuf.s3_3;
            }
            return ubuf.s3_4;
        }
        return ubuf.s3_5;
    }
    if (n <= 44)
    {
        if (n <= 43)
        {
            if (n <= 42)
            {
                return ubuf.s3_6;
            }
            return ubuf.s3_7;
        }
        return ubuf.s3_8;
    }
    if (n <= 46)
    {
        if (n <= 45)
        {
            return ubuf.s3_9;
        }
        return ubuf.s3_10;
    }
    return ubuf.s3_11;
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

float smp(int tr, int idx)
{
    int i = int(clamp(float(idx), 0.0, 47.0));
    int c = i / 4;
    int param = (tr * 12) + c;
    vec4 param_1 = sChunk(param);
    int param_2 = i - (c * 4);
    return pick(param_1, param_2);
}

vec2 curve(int tr, float g)
{
    float gi = min(floor(g), 46.0);
    float t = g - gi;
    int i = int(gi);
    int param = tr;
    int param_1 = i - 1;
    float p0 = smp(param, param_1);
    int param_2 = tr;
    int param_3 = i;
    float p1 = smp(param_2, param_3);
    int param_4 = tr;
    int param_5 = i + 1;
    float p2 = smp(param_4, param_5);
    int param_6 = tr;
    int param_7 = i + 2;
    float p3 = smp(param_6, param_7);
    float a = (((-p0) + (3.0 * p1)) - (3.0 * p2)) + p3;
    float b = (((2.0 * p0) - (5.0 * p1)) + (4.0 * p2)) - p3;
    float c = p2 - p0;
    float y = 0.5 * ((((2.0 * p1) + (c * t)) + ((b * t) * t)) + (((a * t) * t) * t));
    float dy = 0.5 * ((c + ((2.0 * b) * t)) + (((3.0 * a) * t) * t));
    return vec2(y, dy);
}

float spanSd(float dy, float ya, float sa, float yb, float sb)
{
    float lo = min(ya, yb);
    float hi = max(ya, yb);
    float slo = (ya < yb) ? sa : sb;
    float shi = (ya < yb) ? sb : sa;
    float dl = (dy - lo) / sqrt(1.0 + (slo * slo));
    float dh = (hi - dy) / sqrt(1.0 + (shi * shi));
    return min(dl, dh);
}

vec4 neon(float dist, vec3 col, float w, float glow)
{
    if (dist > (w * 14.0))
    {
        return vec4(0.0);
    }
    float param = w - dist;
    float body = edge(param);
    float param_1 = (0.37999999523162841796875 * w) - dist;
    float core = edge(param_1);
    float halo = (glow * 0.5) * exp((-dist) / (w * 3.2000000476837158203125));
    float a = clamp(max(body, halo), 0.0, 1.0);
    vec3 c = mix(col, vec3(1.0), vec3(core * 0.920000016689300537109375));
    vec3 param_2 = c;
    float param_3 = a;
    return pm(param_2, param_3);
}

float hash(float n)
{
    return fract(sin((n * 127.09999847412109375) + 311.70001220703125) * 43758.546875);
}

vec4 starAt(vec2 p, float cs, float seed, float t, float gain, vec3 tint)
{
    float cx = floor(p.x / cs);
    float cy = floor(p.y / cs);
    float id = ((cx * 37.0) + (cy * 91.0)) + seed;
    float param = id;
    if (hash(param) < 0.839999973773956298828125)
    {
        return vec4(0.0);
    }
    float param_1 = id + 1.0;
    float sx = ((cx + 0.20000000298023223876953125) + (0.60000002384185791015625 * hash(param_1))) * cs;
    float param_2 = id + 2.0;
    float sy = ((cy + 0.20000000298023223876953125) + (0.60000002384185791015625 * hash(param_2))) * cs;
    float param_3 = id + 3.0;
    float sz = cs * (0.12999999523162841796875 + (0.17000000178813934326171875 * hash(param_3)));
    float param_4 = id + 4.0;
    float param_5 = id + 5.0;
    float tw = max(0.0, sin((t * (1.2000000476837158203125 + (2.400000095367431640625 * hash(param_4)))) + (6.283185482025146484375 * hash(param_5))));
    tw = (tw * tw) * tw;
    float qx = abs(p.x - sx) / (sz * (0.3499999940395355224609375 + (0.64999997615814208984375 * tw)));
    float qy = abs(p.y - sy) / (sz * (0.3499999940395355224609375 + (0.64999997615814208984375 * tw)));
    float cov = clamp((1.0 - (sqrt(qx) + sqrt(qy))) * 4.0, 0.0, 1.0);
    float r = sqrt(((p.x - sx) * (p.x - sx)) + ((p.y - sy) * (p.y - sy)));
    float glow = exp((-r) / (sz * 0.550000011920928955078125)) * 0.550000011920928955078125;
    float a = (clamp(max(cov, glow), 0.0, 1.0) * tw) * gain;
    vec3 param_6 = mix(vec3(1.0), tint, vec3(0.25));
    float param_7 = a;
    return pm(param_6, param_7);
}

vec4 speckAt(vec2 p, float cs, float seed, float t, float gain)
{
    float cx = floor(p.x / cs);
    float cy = floor(p.y / cs);
    float id = ((cx * 53.0) + (cy * 29.0)) + seed;
    float param = id;
    if (hash(param) < 0.800000011920928955078125)
    {
        return vec4(0.0);
    }
    float param_1 = id + 1.0;
    float sx = ((cx + 0.1500000059604644775390625) + (0.699999988079071044921875 * hash(param_1))) * cs;
    float param_2 = id + 2.0;
    float sy = ((cy + 0.1500000059604644775390625) + (0.699999988079071044921875 * hash(param_2))) * cs;
    float r = sqrt(((p.x - sx) * (p.x - sx)) + ((p.y - sy) * (p.y - sy)));
    float param_3 = id + 3.0;
    float rad = cs * (0.0350000001490116119384765625 + (0.0500000007450580596923828125 * hash(param_3)));
    float param_4 = id + 4.0;
    float param_5 = id + 5.0;
    float tw = 0.449999988079071044921875 + (0.550000011920928955078125 * sin((t * (0.800000011920928955078125 + (1.60000002384185791015625 * hash(param_4)))) + (6.283185482025146484375 * hash(param_5))));
    float param_6 = rad - r;
    float a = (edge(param_6) * tw) * gain;
    vec3 param_7 = vec3(1.0);
    float param_8 = a;
    return pm(param_7, param_8);
}

void main()
{
    vec2 res = ubuf.resolution;
    float W = res.x;
    float H = res.y;
    float t = ubuf.time;
    float bs = ubuf.bass;
    bool lite = ubuf.lite > 0.5;
    float fadeIn = min(1.0, ubuf.fade);
    vec2 p = qt_TexCoord0 * res;
    p.y -= (((1.0 - fadeIn) * 0.180000007152557373046875) * H);
    float dy = p.y - (0.5 * H);
    float lw = max(1.60000002384185791015625, H / 150.0);
    float Hh = 0.439999997615814208984375 * H;
    float g = clamp(p.x / W, 0.0, 1.0) * 47.0;
    float ss = (Hh * 47.0) / W;
    vec4 param = ubuf.color1;
    vec3 c1 = rgb(param);
    vec4 param_1 = ubuf.color2;
    vec3 c2 = rgb(param_1);
    vec4 param_2 = ubuf.color3;
    vec3 c3 = rgb(param_2);
    float glow = 1.0 + (0.60000002384185791015625 * bs);
    vec4 acc = vec4(0.0);
    float gw = max(1.0, ubuf.px * 1.5);
    vec3 gc = mix(c3, vec3(1.0), vec3(0.4000000059604644775390625));
    float param_3 = p.x - (0.5 * W);
    float param_4 = H * 0.319999992847442626953125;
    float param_5 = gw;
    float param_6 = dy;
    float param_7 = H * 0.1599999964237213134765625;
    float param_8 = gw;
    float gl = max(gridLine(param_3, param_4, param_5), gridLine(param_6, param_7, param_8));
    vec3 param_9 = gc;
    float param_10 = gl * (0.07999999821186065673828125 + (0.100000001490116119384765625 * bs));
    vec4 param_11 = pm(param_9, param_10);
    vec4 param_12 = acc;
    acc = over(param_11, param_12);
    float param_13 = (0.5 * gw) - abs(dy);
    float ax = edge(param_13);
    float param_14 = p.x - (0.5 * W);
    float param_15 = H * 0.07999999821186065673828125;
    float param_16 = gw;
    float tick = gridLine(param_14, param_15, param_16) * (1.0 - smoothstep(H * 0.01200000010430812835693359375, H * 0.01400000043213367462158203125, abs(dy)));
    vec3 param_17 = gc;
    float param_18 = max(ax * 0.2199999988079071044921875, tick * 0.300000011920928955078125);
    vec4 param_19 = pm(param_17, param_18);
    vec4 param_20 = acc;
    acc = over(param_19, param_20);
    int param_21 = 0;
    float param_22 = g;
    vec2 cm = curve(param_21, param_22);
    float ym = Hh * cm.x;
    float sm = cm.y * ss;
    float param_23 = dy;
    float param_24 = ym;
    float param_25 = sm;
    float param_26 = 0.0;
    float param_27 = 0.0;
    float sdm = spanSd(param_23, param_24, param_25, param_26, param_27);
    if (!lite)
    {
        float param_28 = sdm;
        vec3 param_29 = c1;
        float param_30 = (0.070000000298023223876953125 * edge(param_28)) * exp((-max(sdm, 0.0)) / (H * 0.20000000298023223876953125));
        vec4 param_31 = pm(param_29, param_30);
        vec4 param_32 = acc;
        acc = over(param_31, param_32);
    }
    if (!lite)
    {
        float _1404;
        for (int k = 3; k >= 1; k--)
        {
            int param_33 = k;
            float param_34 = g;
            vec2 cg = curve(param_33, param_34);
            float yg = Hh * cg.x;
            float sg = cg.y * ss;
            float dg = abs(dy - yg) / sqrt(1.0 + (sg * sg));
            if (k == 1)
            {
                _1404 = 0.5;
            }
            else
            {
                _1404 = (k == 2) ? 0.300000011920928955078125 : 0.17000000178813934326171875;
            }
            float fk = _1404;
            float param_35 = dg;
            vec3 param_36 = c2;
            float param_37 = lw * 0.75;
            float param_38 = 0.89999997615814208984375 * glow;
            vec4 param_39 = neon(param_35, param_36, param_37, param_38) * fk;
            vec4 param_40 = acc;
            acc = over(param_39, param_40);
        }
    }
    float dm = abs(dy - ym) / sqrt(1.0 + (sm * sm));
    float param_41 = dm;
    vec3 param_42 = c1;
    float param_43 = (lw * 1.35000002384185791015625) * (1.0 + (0.20000000298023223876953125 * bs));
    float param_44 = glow;
    vec4 param_45 = neon(param_41, param_42, param_43, param_44);
    vec4 param_46 = acc;
    acc = over(param_45, param_46);
    float act = 0.5 + (0.699999988079071044921875 * clamp(abs(cm.x) * 1.39999997615814208984375, 0.0, 1.0));
    if (!lite)
    {
        vec2 param_47 = p;
        float param_48 = H * 0.300000011920928955078125;
        float param_49 = 11.0;
        float param_50 = t;
        float param_51 = act;
        vec3 param_52 = c1;
        vec4 param_53 = starAt(param_47, param_48, param_49, param_50, param_51, param_52);
        vec4 param_54 = acc;
        acc = over(param_53, param_54);
        vec2 param_55 = p;
        float param_56 = H * 0.119999997317790985107421875;
        float param_57 = 5.0;
        float param_58 = t;
        float param_59 = 0.60000002384185791015625;
        vec4 param_60 = speckAt(param_55, param_56, param_57, param_58, param_59);
        vec4 param_61 = acc;
        acc = over(param_60, param_61);
    }
    float vm = smoothstep(0.0, 0.100000001490116119384765625 * H, p.y) * (1.0 - smoothstep(0.89999997615814208984375 * H, H, p.y));
    float param_62 = ((p.x * 0.731000006198883056640625) + (p.y * 1.9170000553131103515625)) + (fract(t) * 13.0);
    float dn = (hash(param_62) - 0.5) * 0.0058823530562222003936767578125;
    acc = vec4(clamp(acc.x + (dn * acc.w), 0.0, acc.w), clamp(acc.y + (dn * acc.w), 0.0, acc.w), clamp(acc.z + (dn * acc.w), 0.0, acc.w), acc.w);
    fragColor = acc * ((vm * min(1.0, ubuf.fade * 2.0)) * ubuf.qt_Opacity);
}
