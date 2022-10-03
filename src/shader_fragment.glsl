#version 330 core
// Leonardo Barros Bilhalva 00315758

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define SPHERE 0
#define BUNNY  1
#define PLANE  2
#define BALOON_RED 3
#define MFOUR  4
#define BULLET 5
#define WALL 6
#define BALOON_YELLOW 7
#define BALOON_BLUE 8
uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D MFOUR_TEXTURE1;
uniform sampler2D BULLET_TEXTURE1;
uniform sampler2D WALL_TEXTURE1;
uniform sampler2D TextureImage1;
uniform sampler2D WALL_TEXTURE2;
uniform sampler2D BALOON_TEXTURE_RED;
uniform sampler2D BALOON_TEXTURE_YELLOW;
uniform sampler2D BALOON_TEXTURE_BLUE;
uniform sampler2D SPHERE_TEXTURE;

// uniform sampler2D TextureImage2;

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec3 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

void main()
{
    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    vec4 l = normalize(vec4(1.0,1.0,0.5,0.0));

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflexão especular ideal.
    vec4 r = -l + 2 * n * dot(n,l); // PREENCHA AQUI o vetor de reflexão especular ideal

    // Parâmetros que definem as propriedades espectrais da superfície
    vec3 Kd; // Refletância difusa
    vec3 Ks; // Refletância especular
    vec3 Ka; // Refletância ambiente
    float q; // Expoente especular para o modelo de iluminação de Phong

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    if ( object_id == SPHERE )
     {// projeção esférica

        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;
        vec4 new_vector = position_model - bbox_center;
        float vx = new_vector.x;
        float vy = new_vector.y;
        float vz = new_vector.z;
        float rho = length(new_vector);
        float theta = atan(vx, vz);
        float phi = asin(vy / rho);
        U = (theta + M_PI) / (2 * M_PI);
        V = (phi + M_PI_2) / M_PI;

        Kd = vec3(0.8,0.4,0.08);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.4,0.2,0.04);
        q = 1.0;
    }
    else if ( object_id == BUNNY )
    {
        // projeção planar

        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx) / (maxx - minx);
        V = (position_model.y - miny) / (maxy - miny);

        Kd = vec3(0.08,0.4,0.8);
        Ks = vec3(0.8,0.8,0.8);
        Ka = vec3(0.04,0.2,0.4);
        q = 32.0;

    }    
    if ( object_id == BULLET ||  object_id == BALOON_RED  ||  object_id == PLANE ||  object_id == WALL || object_id ==  MFOUR ||  object_id == BUNNY ||  object_id == BALOON_YELLOW   ||  object_id == BALOON_BLUE  )
    {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;
    }

    // Obtemos a refletância difusa a partir da leitura da imagem TextureImage0
    vec3 Kd_MFOUR1 = texture(MFOUR_TEXTURE1, vec2(U,V)).rgb;
    vec3 Kd_BULLET1 = texture(BULLET_TEXTURE1, vec2(U,V)).rgb;
    vec3 Kd_WALL1 = texture(WALL_TEXTURE1, vec2(U,V)).rgb;
    vec3 Kd_BLACK1 = texture(TextureImage1, vec2(U,V)).rgb;
    vec3 Kd_WALL2 = texture(WALL_TEXTURE2, vec2(U,V)).rgb;
    vec3 Kd_BALOON_RED = texture(BALOON_TEXTURE_RED, vec2(U,V)).rgb;
    vec3 Kd_BALOON_YELLOW = texture(BALOON_TEXTURE_YELLOW, vec2(U,V)).rgb;
    vec3 Kd_BALOON_BLUE= texture(BALOON_TEXTURE_BLUE, vec2(U,V)).rgb;


    // MODELO DE ILUMINAÇÃO DE PHONG:

    // Espectro da fonte de iluminação
    vec3 I = vec3(1.0,1.0,1.0);
    // Espectro da luz ambiente
    vec3 Ia = vec3(0.2,0.2,0.2);
    // Termo difuso utilizando a lei dos cossenos de Lambert
    float lambert = max(0,dot(n,l));
    // Termo ambiente
    vec3 ambient_term = Ka * Ia;
    // Termo especular utilizando o modelo de iluminação de Phong
    float phong_specular_term  = pow(max(0,dot(r,v)),q); // PREENCH AQUI o termo especular de Phong
   

    switch (object_id)
    {
        case MFOUR:
        color = Kd_MFOUR1;
        break;

        case BULLET:
        color = Kd_BULLET1;
        break;

        case PLANE:	
        color = Kd_WALL2 ;
        break;

        case BALOON_RED:
        color = Kd_BALOON_RED * (pow(lambert, 1) + 0.01) + Kd_BLACK1 * (1 - (pow(lambert, 0.2)) + 0.01); 
        break;

        case BALOON_YELLOW:
        color = Kd_BALOON_YELLOW * (pow(lambert, 1) + 0.01) + Kd_BLACK1 * (1 - (pow(lambert, 0.2)) + 0.01); 
        break;

        case BALOON_BLUE:
        color = Kd_BALOON_BLUE * (pow(lambert, 1) + 0.01) + Kd_BLACK1 * (1 - (pow(lambert, 0.2)) + 0.01); 
        break;

        case BUNNY:
        color = Kd * I * lambert + ambient_term + Ks * I * phong_specular_term;
        break;

        case WALL:
        color = Kd_WALL1;
        break;

        case SPHERE:
        color = Kd * I * lambert + ambient_term + Ks * I * phong_specular_term;
        break;

        default:
        color = Kd_BLACK1;
    }

    // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);
} 
