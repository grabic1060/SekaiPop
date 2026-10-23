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
    float travel;
    vec4 color1;
    vec4 color2;
    vec4 color3;
    vec4 ink;
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
} ubuf;

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

vec3 rgb(vec4 c)
{
    return vec3(c.x, c.y, c.z);
}

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

float bsp(float f, float s, float nb)
{
    float g = f / s;
    float i = floor(g);
    float t = g - i;
    float t2 = t * t;
    float t3 = t2 * t;
    float w0 = (((1.0 - t) * (1.0 - t)) * (1.0 - t)) / 6.0;
    float w1 = (((3.0 * t3) - (6.0 * t2)) + 4.0) / 6.0;
    float w2 = (((((-3.0) * t3) + (3.0 * t2)) + (3.0 * t)) + 1.0) / 6.0;
    float w3 = t3 / 6.0;
    float param = (i - 1.0) * s;
    float param_1 = nb;
    float param_2 = i * s;
    float param_3 = nb;
    float param_4 = (i + 1.0) * s;
    float param_5 = nb;
    float param_6 = (i + 2.0) * s;
    float param_7 = nb;
    return (((w0 * lvAt(param, param_1)) + (w1 * lvAt(param_2, param_3))) + (w2 * lvAt(param_4, param_5))) + (w3 * lvAt(param_6, param_7));
}

float shape(float lv, float d)
{
    return (lv * (1.0 + ((1.0 - d) * 1.2999999523162841796875))) * 1.12000000476837158203125;
}

float sc(float x)
{
    float x2 = x * x;
    return x / sqrt(sqrt(1.0 + (x2 * x2)));
}

float hash(float n)
{
    return fract(sin((n * 127.09999847412109375) + 311.70001220703125) * 43758.546875);
}

vec4 pm(vec3 c, float a)
{
    return vec4(c.x * a, c.y * a, c.z * a, a);
}

vec4 speedLines(vec2 p, float W, float H, float bs, float t)
{
    float qx = (p.x - (0.5 * W)) * 0.4199999868869781494140625;
    float qy = p.y - (0.5 * H);
    float r = sqrt((qx * qx) + (qy * qy));
    float a = (atan(qy, qx) / 6.283185482025146484375) + 0.5;
    float n = 84.0;
    float k = floor(a * n);
    float fr = fract(a * n) - 0.5;
    float param = k + 17.0;
    float h1 = hash(param);
    float param_1 = k + 53.0;
    float h2 = hash(param_1);
    float wd = 0.070000000298023223876953125 + (0.17000000178813934326171875 * h1);
    float cov = 1.0 - smoothstep(wd * 0.550000011920928955078125, wd, abs(fr));
    float r0 = (H * (0.319999992847442626953125 + (0.89999997615814208984375 * h2))) * (1.0 - (0.300000011920928955078125 * bs));
    float len = smoothstep(r0, r0 + (0.3499999940395355224609375 * H), r);
    float ls = (t * 1.60000002384185791015625) + (h2 * 6.0);
    float lf = fract(ls);
    lf = (lf * lf) * (3.0 - (2.0 * lf));
    float param_2 = (k * 1.7000000476837158203125) + floor(ls);
    float param_3 = ((k * 1.7000000476837158203125) + floor(ls)) + 1.0;
    float live = 0.5 + (0.5 * mix(hash(param_2), hash(param_3), lf));
    float al = ((cov * len) * live) * (0.23999999463558197021484375 + (0.300000011920928955078125 * bs));
    vec4 param_4 = ubuf.ink;
    vec3 param_5 = rgb(param_4);
    float param_6 = al;
    return pm(param_5, param_6);
}

vec4 over(vec4 src, vec4 dst)
{
    return src + (dst * (1.0 - src.w));
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

float edge(float d)
{
    return clamp((d / ubuf.px) + 0.5, 0.0, 1.0);
}

float halftone(vec2 p, float sp, float shade)
{
    float qx = ((p.x + p.y) * 0.707106769084930419921875) / sp;
    float qy = ((p.y - p.x) * 0.707106769084930419921875) / sp;
    float fx = fract(qx) - 0.5;
    float fy = fract(qy) - 0.5;
    float r = mix(0.12999999523162841796875, 0.5, shade);
    float param = (r - sqrt((fx * fx) + (fy * fy))) * sp;
    return edge(param);
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
    if (hash(param) < 0.7799999713897705078125)
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
    float tr = ubuf.travel;
    float bs = ubuf.bass;
    bool lite = ubuf.lite > 0.5;
    float fadeIn = min(1.0, ubuf.fade);
    vec2 p = qt_TexCoord0 * res;
    p.y -= (((1.0 - fadeIn) * 0.180000007152557373046875) * H);
    float yc = 0.5 * H;
    float dy = p.y - yc;
    float u = p.x / W;
    float d = abs(u - 0.5) * 2.0;
    float so = (u < 0.5) ? 0.0 : 0.89999997615814208984375;
    float _1163;
    if (ubuf.bandCount > 1.0)
    {
        _1163 = ubuf.bandCount;
    }
    else
    {
        _1163 = 50.0;
    }
    float nb = _1163;
    float lw = max(1.60000002384185791015625, H / 150.0);
    float Hh = 0.449999988079071044921875 * H;
    float sq = sqrt(d + 0.014999999664723873138427734375);
    float base = (0.5 / sq) * (2.0 / W);
    float TAU = 6.283185482025146484375;
    vec4 param = ubuf.color1;
    vec3 c1 = rgb(param);
    vec4 param_1 = ubuf.color2;
    vec3 c2 = rgb(param_1);
    vec4 param_2 = ubuf.color3;
    vec3 c3 = rgb(param_2);
    float fA = ((1.0 - d) * (nb - 1.0)) * 0.7799999713897705078125;
    float fB = ((1.0 - (d * 0.85000002384185791015625)) * (nb - 1.0)) * 0.62000000476837158203125;
    float fC = ((1.0 - (d * 0.699999988079071044921875)) * (nb - 1.0)) * 0.449999988079071044921875;
    float _1234;
    if (lite)
    {
        float param_3 = fA;
        float param_4 = nb;
        _1234 = lvAt(param_3, param_4);
    }
    else
    {
        float param_5 = fA;
        float param_6 = 1.0;
        float param_7 = nb;
        _1234 = bsp(param_5, param_6, param_7);
    }
    float lA = _1234;
    float _1252;
    if (lite)
    {
        float param_8 = fB;
        float param_9 = nb;
        _1252 = lvAt(param_8, param_9);
    }
    else
    {
        float param_10 = fB;
        float param_11 = 1.7000000476837158203125;
        float param_12 = nb;
        _1252 = bsp(param_10, param_11, param_12);
    }
    float lB = _1252;
    float _1270;
    if (lite)
    {
        float param_13 = fC;
        float param_14 = nb;
        _1270 = lvAt(param_13, param_14);
    }
    else
    {
        float param_15 = fC;
        float param_16 = 2.599999904632568359375;
        float param_17 = nb;
        _1270 = bsp(param_15, param_16, param_17);
    }
    float lC = _1270;
    float param_18 = lA;
    float param_19 = d;
    float eA = shape(param_18, param_19);
    float param_20 = lB;
    float param_21 = d;
    float eB = shape(param_20, param_21);
    float param_22 = lC;
    float param_23 = d;
    float eC = shape(param_22, param_23);
    float pinch = 0.100000001490116119384765625 + (0.89999997615814208984375 * smoothstep(0.0199999995529651641845703125, 0.60000002384185791015625, d));
    float pump = 1.0 + (0.25 * bs);
    float param_24 = 0.100000001490116119384765625 + ((0.949999988079071044921875 * eA) * pump);
    float ampA = (Hh * pinch) * sc(param_24);
    float param_25 = 0.07999999821186065673828125 + ((0.949999988079071044921875 * eB) * pump);
    float ampB = ((Hh * 0.89999997615814208984375) * pinch) * sc(param_25);
    float param_26 = 0.07999999821186065673828125 + ((0.949999988079071044921875 * eC) * pump);
    float ampC = ((Hh * 0.75) * pinch) * sc(param_26);
    float cA = 3.099999904632568359375;
    float cB = 4.400000095367431640625;
    float cC = 2.2999999523162841796875;
    float phA = (((TAU * cA) * sq) - (tr * 2.099999904632568359375)) + so;
    float phB = ((((TAU * cB) * sq) - (tr * 1.60000002384185791015625)) + 2.099999904632568359375) + so;
    float phC = ((((TAU * cC) * sq) - (tr * 1.10000002384185791015625)) + 4.0) + so;
    float twist = 1.14999997615814208984375 + (0.949999988079071044921875 * sin(((tr * 0.699999988079071044921875) + (d * 4.0)) + so));
    float yA1 = ampA * sin(phA);
    float yA2 = ampA * sin(phA + twist);
    float sA1 = (((ampA * cos(phA)) * TAU) * cA) * base;
    float sA2 = (((ampA * cos(phA + twist)) * TAU) * cA) * base;
    float yB = ampB * sin(phB);
    float sB = (((ampB * cos(phB)) * TAU) * cB) * base;
    float yC = ampC * sin(phC);
    float sC = (((ampC * cos(phC)) * TAU) * cC) * base;
    vec4 acc = vec4(0.0);
    float glow = 1.0 + (0.60000002384185791015625 * bs);
    if (!lite)
    {
        vec2 param_27 = p;
        float param_28 = W;
        float param_29 = H;
        float param_30 = bs;
        float param_31 = t;
        vec4 param_32 = speedLines(param_27, param_28, param_29, param_30, param_31);
        vec4 param_33 = acc;
        acc = over(param_32, param_33);
    }
    float param_34 = dy;
    float param_35 = yC;
    float param_36 = sC;
    float param_37 = 0.0;
    float param_38 = 0.0;
    float sdC = spanSd(param_34, param_35, param_36, param_37, param_38);
    if (sdC > (-2.0))
    {
        float param_39 = sdC;
        float cov = edge(param_39);
        float shade = clamp(abs(dy) / max(1.0, ampC * 0.89999997615814208984375), 0.0, 1.0);
        vec3 param_40 = c3;
        float param_41 = 0.17000000178813934326171875 * cov;
        vec4 param_42 = pm(param_40, param_41);
        vec4 param_43 = acc;
        acc = over(param_42, param_43);
        if (!lite)
        {
            float sp = max(4.0, H / 40.0);
            vec2 param_44 = vec2(p.x - (t * 2.5), p.y);
            float param_45 = sp;
            float param_46 = shade;
            float dots = halftone(param_44, param_45, param_46) * cov;
            vec3 param_47 = c3 * 0.85000002384185791015625;
            float param_48 = 0.699999988079071044921875 * dots;
            vec4 param_49 = pm(param_47, param_48);
            vec4 param_50 = acc;
            acc = over(param_49, param_50);
        }
    }
    float param_51 = dy;
    float param_52 = yB;
    float param_53 = sB;
    float param_54 = 0.0;
    float param_55 = 0.0;
    float sdB = spanSd(param_51, param_52, param_53, param_54, param_55);
    if (sdB > (-2.0))
    {
        float param_56 = sdB;
        float cov_1 = edge(param_56);
        float shade_1 = clamp(abs(dy) / max(1.0, ampB * 0.89999997615814208984375), 0.0, 1.0);
        vec3 param_57 = c2;
        float param_58 = 0.20000000298023223876953125 * cov_1;
        vec4 param_59 = pm(param_57, param_58);
        vec4 param_60 = acc;
        acc = over(param_59, param_60);
        if (!lite)
        {
            float sp_1 = max(3.5, H / 52.0);
            vec2 param_61 = vec2(p.x + (t * 3.5), p.y);
            float param_62 = sp_1;
            float param_63 = shade_1;
            float dots_1 = halftone(param_61, param_62, param_63) * cov_1;
            vec3 param_64 = c2 * 0.85000002384185791015625;
            float param_65 = 0.7200000286102294921875 * dots_1;
            vec4 param_66 = pm(param_64, param_65);
            vec4 param_67 = acc;
            acc = over(param_66, param_67);
        }
    }
    float param_68 = dy;
    float param_69 = yA1;
    float param_70 = sA1;
    float param_71 = yA2;
    float param_72 = sA2;
    float sdA = spanSd(param_68, param_69, param_70, param_71, param_72);
    if (sdA > (-2.0))
    {
        float param_73 = sdA;
        float covA = edge(param_73);
        float rim = exp((-max(sdA, 0.0)) / (lw * 5.0));
        vec3 param_74 = c1;
        float param_75 = 0.300000011920928955078125 * covA;
        vec4 param_76 = pm(param_74, param_75);
        vec4 param_77 = acc;
        acc = over(param_76, param_77);
        vec3 param_78 = mix(c1, vec3(1.0), vec3(0.550000011920928955078125));
        float param_79 = (0.20000000298023223876953125 * rim) * covA;
        vec4 param_80 = pm(param_78, param_79);
        vec4 param_81 = acc;
        acc = over(param_80, param_81);
    }
    if (!lite)
    {
        float phS1 = ((((TAU * 5.599999904632568359375) * sq) - (tr * 2.599999904632568359375)) + 1.2999999523162841796875) + so;
        float yS1 = (0.85000002384185791015625 * ampB) * sin(phS1);
        float sS1 = ((((0.85000002384185791015625 * ampB) * cos(phS1)) * TAU) * 5.599999904632568359375) * base;
        float dS1 = abs(dy - yS1) / sqrt(1.0 + (sS1 * sS1));
        float param_82 = dS1;
        vec3 param_83 = c2;
        float param_84 = lw * 0.4000000059604644775390625;
        float param_85 = 0.800000011920928955078125 * glow;
        vec4 param_86 = neon(param_82, param_83, param_84, param_85);
        vec4 param_87 = acc;
        acc = over(param_86, param_87);
        float phS2 = ((((TAU * 1.89999997615814208984375) * sq) - (tr * 0.89999997615814208984375)) + 3.2999999523162841796875) + so;
        float yS2 = (1.0499999523162841796875 * ampC) * sin(phS2);
        float sS2 = ((((1.0499999523162841796875 * ampC) * cos(phS2)) * TAU) * 1.89999997615814208984375) * base;
        float dS2 = abs(dy - yS2) / sqrt(1.0 + (sS2 * sS2));
        float param_88 = dS2;
        vec3 param_89 = c1;
        float param_90 = lw * 0.4000000059604644775390625;
        float param_91 = 0.800000011920928955078125 * glow;
        vec4 param_92 = neon(param_88, param_89, param_90, param_91);
        vec4 param_93 = acc;
        acc = over(param_92, param_93);
    }
    float dC = abs(dy - yC) / sqrt(1.0 + (sC * sC));
    float param_94 = dC;
    vec3 param_95 = c3;
    float param_96 = lw * 0.60000002384185791015625;
    float param_97 = 0.89999997615814208984375 * glow;
    vec4 param_98 = neon(param_94, param_95, param_96, param_97);
    vec4 param_99 = acc;
    acc = over(param_98, param_99);
    float dB = abs(dy - yB) / sqrt(1.0 + (sB * sB));
    float param_100 = dB;
    vec3 param_101 = c2;
    float param_102 = lw * 0.949999988079071044921875;
    float param_103 = glow;
    vec4 param_104 = neon(param_100, param_101, param_102, param_103);
    vec4 param_105 = acc;
    acc = over(param_104, param_105);
    float dA1 = abs(dy - yA1) / sqrt(1.0 + (sA1 * sA1));
    float dA2 = abs(dy - yA2) / sqrt(1.0 + (sA2 * sA2));
    float param_106 = dA2;
    vec3 param_107 = c1;
    float param_108 = lw * 1.10000002384185791015625;
    float param_109 = glow;
    vec4 param_110 = neon(param_106, param_107, param_108, param_109);
    vec4 param_111 = acc;
    acc = over(param_110, param_111);
    float param_112 = dA1;
    vec3 param_113 = c1;
    float param_114 = lw * 1.25;
    float param_115 = glow;
    vec4 param_116 = neon(param_112, param_113, param_114, param_115);
    vec4 param_117 = acc;
    acc = over(param_116, param_117);
    float br = clamp((0.3499999940395355224609375 + ((0.64999997615814208984375 * (1.0 - d)) * (1.0 - d))) + (0.5 * bs), 0.0, 1.0);
    vec3 axisCol = mix(vec3(1.0), mix(c1, c2, vec3(d)), vec3(0.550000011920928955078125 * d));
    float param_118 = abs(dy);
    vec3 param_119 = axisCol;
    float param_120 = lw * 0.89999997615814208984375;
    float param_121 = glow * br;
    vec4 axis = neon(param_118, param_119, param_120, param_121);
    vec4 param_122 = axis * br;
    vec4 param_123 = acc;
    acc = over(param_122, param_123);
    float fx = p.x - (0.5 * W);
    float fr = sqrt((fx * fx) + (dy * dy));
    float hot = 0.4000000059604644775390625 + (0.60000002384185791015625 * bs);
    float flare = ((exp((-fr) / (H * 0.070000000298023223876953125)) * 0.89999997615814208984375) + ((exp((-fr) / (H * 0.300000011920928955078125)) * 0.3499999940395355224609375) * hot)) + (((exp((-abs(fx)) / (lw * 1.2000000476837158203125)) * exp((-abs(dy)) / (H * 0.300000011920928955078125))) * 0.60000002384185791015625) * hot);
    vec3 param_124 = mix(vec3(1.0), c2, vec3(0.20000000298023223876953125));
    float param_125 = clamp(flare, 0.0, 1.0);
    vec4 param_126 = pm(param_124, param_125);
    vec4 param_127 = acc;
    acc = over(param_126, param_127);
    float act = 0.3499999940395355224609375 + (0.89999997615814208984375 * clamp(max(eA, eB), 0.0, 1.0));
    vec2 param_128 = p;
    float param_129 = H * 0.300000011920928955078125;
    float param_130 = 11.0;
    float param_131 = t;
    float param_132 = act;
    vec3 param_133 = c1;
    vec4 param_134 = starAt(param_128, param_129, param_130, param_131, param_132, param_133);
    vec4 param_135 = acc;
    acc = over(param_134, param_135);
    if (!lite)
    {
        vec2 param_136 = p;
        float param_137 = H * 0.17000000178813934326171875;
        float param_138 = 71.0;
        float param_139 = t;
        float param_140 = act * 0.85000002384185791015625;
        vec3 param_141 = c2;
        vec4 param_142 = starAt(param_136, param_137, param_138, param_139, param_140, param_141);
        vec4 param_143 = acc;
        acc = over(param_142, param_143);
        vec2 param_144 = p;
        float param_145 = H * 0.119999997317790985107421875;
        float param_146 = 5.0;
        float param_147 = t;
        float param_148 = 0.800000011920928955078125;
        vec4 param_149 = speckAt(param_144, param_145, param_146, param_147, param_148);
        vec4 param_150 = acc;
        acc = over(param_149, param_150);
    }
    float vm = smoothstep(0.0, 0.100000001490116119384765625 * H, p.y) * (1.0 - smoothstep(0.89999997615814208984375 * H, H, p.y));
    float param_151 = ((p.x * 0.731000006198883056640625) + (p.y * 1.9170000553131103515625)) + (fract(t) * 13.0);
    float dn = (hash(param_151) - 0.5) * 0.0058823530562222003936767578125;
    acc = vec4(clamp(acc.x + (dn * acc.w), 0.0, acc.w), clamp(acc.y + (dn * acc.w), 0.0, acc.w), clamp(acc.z + (dn * acc.w), 0.0, acc.w), acc.w);
    fragColor = acc * ((vm * min(1.0, ubuf.fade * 2.0)) * ubuf.qt_Opacity);
}
