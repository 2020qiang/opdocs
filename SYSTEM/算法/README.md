# AES

高级加密标准 <https://en.wikipedia.org/wiki/Advanced_Encryption_Standard>

AES描述的算法是[对称密钥算法](https://en.wikipedia.org/wiki/Symmetric-key_algorithm)，意味着同一密钥用于加密和解密数据。

*   区块长度固定为128位
*   具有三个不同的密钥长度：128、192和256位
    *   10/12/14轮



# 一、密钥扩展

```c
typedef unsigned char **aes_key_t;

aes_key_t key_create(const unsigned char pass[4][4])
{
#define malloc_error(c) if (c==NULL){ perror("malloc");exit(1);}

    unsigned char **returnData = NULL;

    returnData = (unsigned char **) malloc(sizeof(unsigned char **) * 4);
    malloc_error(returnData);
    for (uint8_t i = 0; i < 4; i++) {
        returnData[i] = (unsigned char *) malloc(sizeof(unsigned char *) * 4);
        malloc_error(returnData[i]);

        if (pass == NULL) {
            memset(returnData[i], 0, sizeof(unsigned char *) * 4);
        } else {
            for (uint8_t j = 0; j < 4; j++)
                returnData[i][j] = pass[i][j];
        }
    }

#undef malloc_error
    return returnData;
}

void key_delete(aes_key_t key)
{
    for (uint8_t i = 0; i < 4; i++) {
        free(key[i]);
    }
    free(key);
}
```

```c
void rotWord(aes_key_t set, aes_key_t raw)
{
    set[0][0] = raw[1][3];
    set[1][0] = raw[2][3];
    set[2][0] = raw[3][3];
    set[3][0] = raw[0][3];
}
```

```c
static const unsigned char sbox[16][16] = {
        {0x63,0x7c,0x77,0x7b,0xf2,0x6b,0x6f,0xc5,0x30,0x01,0x67,0x2b,0xfe,0xd7,0xab,0x76},
        {0xca,0x82,0xc9,0x7d,0xfa,0x59,0x47,0xf0,0xad,0xd4,0xa2,0xaf,0x9c,0xa4,0x72,0xc0},
        {0xb7,0xfd,0x93,0x26,0x36,0x3f,0xf7,0xcc,0x34,0xa5,0xe5,0xf1,0x71,0xd8,0x31,0x15},
        {0x04,0xc7,0x23,0xc3,0x18,0x96,0x05,0x9a,0x07,0x12,0x80,0xe2,0xeb,0x27,0xb2,0x75},
        {0x09,0x83,0x2c,0x1a,0x1b,0x6e,0x5a,0xa0,0x52,0x3b,0xd6,0xb3,0x29,0xe3,0x2f,0x84},
        {0x53,0xd1,0x00,0xed,0x20,0xfc,0xb1,0x5b,0x6a,0xcb,0xbe,0x39,0x4a,0x4c,0x58,0xcf},
        {0xd0,0xef,0xaa,0xfb,0x43,0x4d,0x33,0x85,0x45,0xf9,0x02,0x7f,0x50,0x3c,0x9f,0xa8},
        {0x51,0xa3,0x40,0x8f,0x92,0x9d,0x38,0xf5,0xbc,0xb6,0xda,0x21,0x10,0xff,0xf3,0xd2},
        {0xcd,0x0c,0x13,0xec,0x5f,0x97,0x44,0x17,0xc4,0xa7,0x7e,0x3d,0x64,0x5d,0x19,0x73},
        {0x60,0x81,0x4f,0xdc,0x22,0x2a,0x90,0x88,0x46,0xee,0xb8,0x14,0xde,0x5e,0x0b,0xdb},
        {0xe0,0x32,0x3a,0x0a,0x49,0x06,0x24,0x5c,0xc2,0xd3,0xac,0x62,0x91,0x95,0xe4,0x79},
        {0xe7,0xc8,0x37,0x6d,0x8d,0xd5,0x4e,0xa9,0x6c,0x56,0xf4,0xea,0x65,0x7a,0xae,0x08},
        {0xba,0x78,0x25,0x2e,0x1c,0xa6,0xb4,0xc6,0xe8,0xdd,0x74,0x1f,0x4b,0xbd,0x8b,0x8a},
        {0x70,0x3e,0xb5,0x66,0x48,0x03,0xf6,0x0e,0x61,0x35,0x57,0xb9,0x86,0xc1,0x1d,0x9e},
        {0xe1,0xf8,0x98,0x11,0x69,0xd9,0x8e,0x94,0x9b,0x1e,0x87,0xe9,0xce,0x55,0x28,0xdf},
        {0x8c,0xa1,0x89,0x0d,0xbf,0xe6,0x42,0x68,0x41,0x99,0x2d,0x0f,0xb0,0x54,0xbb,0x16},
};

void subWord(aes_key_t set)
{
    set[0][1] = sbox[(uint8_t) set[0][0] / 16][set[0][0] % 16];
    set[1][1] = sbox[(uint8_t) set[1][0] / 16][set[1][0] % 16];
    set[2][1] = sbox[(uint8_t) set[2][0] / 16][set[2][0] % 16];
    set[3][1] = sbox[(uint8_t) set[3][0] / 16][set[3][0] % 16];
}
```

```c
static const unsigned char rc[10] = {
        0x01, 0x02, 0x04, 0x08, 0x10,
        0x20, 0x40, 0x80, 0x1B, 0x36,
};

void rcon(aes_key_t set, unsigned char con)
{
    set[0][2] = con;
    set[1][2] = 0;
    set[2][2] = 0;
    set[3][2] = 0;
}
```

```c
void xorRcon(aes_key_t set)
{
    set[0][3] = set[0][1]^set[0][2];
    set[1][3] = set[1][1];
    set[2][3] = set[2][1];
    set[3][3] = set[3][1];
}
```

```c
void key_merge(aes_key_t set, aes_key_t tmp)
{
    for (uint8_t i = 0; i < 4; i++)
        for (uint8_t j = 0; j < 4; j++)
            if (!i) set[j][i] ^= tmp[j][3];
            else set[j][i] ^= set[j][i-1];
}
```

```c
aes_key_t aes_key_init(const unsigned char pass[4][4])
{
    aes_key_t returnData = key_create(pass);
    aes_key_t tmp = key_create(NULL);

    for (uint8_t i = 0; i < 10; i++) {
        rotWord(tmp, returnData);
        subWord(tmp);
        rcon(tmp, rc[i]);
        xorRcon(tmp);
        key_merge(returnData, tmp);
    }
    key_delete(tmp);
    return returnData;
}
```



# 二、加密解密



##  有限域算数

有限域算术是一种在有限域之内的算术，因为域仅包括有限数量的元素



#### 二进制表示为表达式

$$
\begin{eqnarray}
&&\nonumber\quad\ [1,0,0,1,1,0,0,1]Binary\\
&&\nonumber =1x^7+0x^6+0x^5+1x^4+1x^3+0x^2+0x^1+1x^0\\
&&\nonumber =1x^7+1x^4+1x^3+1x^0\\
&&\nonumber =x^7+x^4+x^3+1
\end{eqnarray}\nonumber
$$



#### 加法

$$
\begin{eqnarray}
&&\nonumber\quad (0x^7+0x^6+1x^5+0x^4+0x^3+1x^2+1x^1+0x^0)\oplus\\
&&\nonumber\quad (0x^7+0x^6+0x^5+0x^4+1x^3+1x^2+0x^1+1x^0)\\
&&\nonumber =0x^7+0x^6+1x^5+0x^4+1x^3+0x^2+1x^1+1x^0\\
&&\nonumber =1x^5+1x^3+1x^0\\
&&\nonumber =x^5+x^3+x+1
\end{eqnarray}\nonumber
$$

```c
/* Exclusive_or */

unsigned char ffa_addition(const unsigned char a, const unsigned char b)
{
    return a^b;
}
```



#### 乘法

$$
\begin{eqnarray}
&&\nonumber\quad (x^5+x^2+x)\otimes(x^7+x^4+x^3+x^2+x)\\
&&\nonumber =x^5(x^7+x^4+x^3+x^2+x)+x^2(x^7+x^4+x^3+x^2+x)+x(x^7+x^4+x^3+x^2+x)\\
&&\nonumber =x^{12}+x^9+x^8+x^7+x^6+x^9+x^6+x^5+x^4+x^3+x^8+x^5+x^4+x^3+x^2\\
&&\nonumber =x^{12}+x^9+x^9+x^8+x^8+x^7+x^6+x^6+x^5+x^5+x^4+x^4+x^3+x^3+x^2\\
&&\nonumber =x^{12}+x^7+x^2\\
&&\nonumber =(x^{12}+x^7+x^2)mod(x^8+x^4+x^3+x+1)\\
&&\nonumber =?\\
&&\nonumber =x^5+x^3+x^2+x+1
\end{eqnarray}\nonumber
$$

mod
$$
\nonumber
\qquad\qquad\qquad\qquad\qquad x^4+1\\
x^8+x^4+x^3+x+1\arrowvert\overline{x^{12}+x^7+x^2}\\
\qquad\qquad\qquad\qquad\qquad\qquad\qquad x^{12}+x^8+x^7+x^5+x^4\\
\qquad\qquad\qquad\qquad\qquad\qquad \overline{x^8+x^5+x^4+x^2}\\
\qquad\qquad\qquad\qquad\qquad\qquad\quad x^8+x^4+x^3+x+1\\
\qquad\qquad\qquad\quad remainder \quad \overline{x^5+x^3+x^2+x+1}
$$

```c
/* Finite field arithmetic Multiplication
         17
       -----
   283 |4228
        4528
        ----xor
        308
        283
        ---xor
        47
*/
unsigned char ffa_mult(const unsigned char _a, const unsigned char _b)
{
    unsigned char a = _a;
    unsigned char b = _b;

    unsigned char p = '\000';
    unsigned char hiBitSet;

    for (uint8_t i = 0; i < 8; i++) {
        if ((b&((unsigned char) 0x01)) == 0x01) {
            p ^= a;
        }
        hiBitSet = (a&((unsigned char) 0x80));
        a <<= ((unsigned char) 0x01);
        if (hiBitSet == 0x80) {
            a ^= ((unsigned char) 0x1B);
        }
        b >>= ((unsigned char) 0x01);
    }
    return p % 0x100;
}
```

>   <http://netzts.in/cryptography-blog-downloads>