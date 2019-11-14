//
//  BarcodeGen128.m
//  ScannerSDKApp
//
//  Created by pqj647 on 6/27/16.
//  Copyright © 2016 Alexei Igumnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define CODE1(a) (a%10-1)
#define CODE2(a) ((a/10)%10-1)
#define CODE3(a) ((a/100)%10-1)
#define CODE4(a) ((a/1000)%10-1)
#define CODE5(a) ((a/10000)%10-1)
#define CODE6(a) ((a/100000)%10-1)
#define CODE7(a) ((a/1000000)%10-1)

#define BARCODE128(a) (CODE6(a) | (CODE5(a)*4) | (CODE4(a)*16) | (CODE3(a)*64) | (CODE2(a)*256) | (CODE1(a)*1024))

#define BARCODE128STARTB BARCODE128(211214)
#define BARCODE128STARTBWIDTH (2+1+1+2+1+4)
#define BARCODE128STARTBNO 104
#define BARCODE128STOP (CODE7(2331112) | (CODE6(2331112)*4) | (CODE5(2331112)*16) | (CODE4(2331112)*64) | (CODE3(2331112)*256) | (CODE2(2331112)*1024) | (CODE1(2331112)*4096))
#define BARCODE128STOPWIDTH (2+3+3+1+1+1+2)

static const unsigned short s_bc128Bcodes[128] =
{
    0,
    BARCODE128(411131), // FNC1
    BARCODE128(411113), // FNC2
    BARCODE128(114311), // FNC3
    BARCODE128(114131), // FNC4
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    BARCODE128(212222), //	space
    BARCODE128(222122), //	!
    BARCODE128(222221), //	"
    BARCODE128(121223), //	#
    BARCODE128(121322), //	$
    BARCODE128(131222), //	%
    BARCODE128(122213), //	&
    BARCODE128(122312), //	'
    BARCODE128(132212), //	(
    BARCODE128(221213), //	)
    BARCODE128(221312), //	*
    BARCODE128(231212), //	+
    BARCODE128(112232), //	,
    BARCODE128(122132), //	-
    BARCODE128(122231), //	.
    BARCODE128(113222), //	/
    BARCODE128(123122), //	0
    BARCODE128(123221), //	1
    BARCODE128(223211), //	2
    BARCODE128(221132), //	3
    BARCODE128(221231), //	4
    BARCODE128(213212), //	5
    BARCODE128(223112), //	6
    BARCODE128(312131), //	7
    BARCODE128(311222), //	8
    BARCODE128(321122), //	9
    BARCODE128(321221), //	:
    BARCODE128(312212), //	;
    BARCODE128(322112), //	<
    BARCODE128(322211), //	=
    BARCODE128(212123), //	>
    BARCODE128(212321), //	?
    BARCODE128(232121), //	@
    BARCODE128(111323), //	A
    BARCODE128(131123), //	B
    BARCODE128(131321), //	C
    BARCODE128(112313), //	D
    BARCODE128(132113), //	E
    BARCODE128(132311), //	F
    BARCODE128(211313), //	G
    BARCODE128(231113), //	H
    BARCODE128(231311), //	I
    BARCODE128(112133), //	J
    BARCODE128(112331), //	K
    BARCODE128(132131), //	L
    BARCODE128(113123), //	M
    BARCODE128(113321), //	N
    BARCODE128(133121), //	O
    BARCODE128(313121), //	P
    BARCODE128(211331), //	Q
    BARCODE128(231131), //	R
    BARCODE128(213113), //	S
    BARCODE128(213311), //	T
    BARCODE128(213131), //	U
    BARCODE128(311123), //	V
    BARCODE128(311321), //	W
    BARCODE128(331121), //	X
    BARCODE128(312113), //	Y
    BARCODE128(312311), //	Z
    BARCODE128(332111), //	[
    BARCODE128(314111), //	\
    
    BARCODE128(221411), //	]
    BARCODE128(431111), //	^
    BARCODE128(111224), //	_
    BARCODE128(111422), //	`
    BARCODE128(121124), //	a
    BARCODE128(121421), //	b
    BARCODE128(141122), //	c
    BARCODE128(141221), //	d
    BARCODE128(112214), //	e
    BARCODE128(112412), //	f
    BARCODE128(122114), //	g
    BARCODE128(122411), //	h
    BARCODE128(142112), //	i
    BARCODE128(142211), //	j
    BARCODE128(241211), //	k
    BARCODE128(221114), //	l
    BARCODE128(413111), //	m
    BARCODE128(241112), //	n
    BARCODE128(134111), //	o
    BARCODE128(111242), //	p
    BARCODE128(121142), //	q
    BARCODE128(121241), //	r
    BARCODE128(114212), //	s
    BARCODE128(124112), //	t
    BARCODE128(124211), //	u
    BARCODE128(411212), //	v
    BARCODE128(421112), //	w
    BARCODE128(421211), //	x
    BARCODE128(212141), //	y
    BARCODE128(214121), //	z
    BARCODE128(412121), //	{
    BARCODE128(111143), //	|
    BARCODE128(111341), //	}
    BARCODE128(131141), //	~
    BARCODE128(114113), //	DEL
};

static const unsigned char s_bc128Bcode_widths[128] =
{
    0,
    (4+1+1+1+3+1), // FNC1
    (4+1+1+1+1+3), // FNC2
    (1+1+4+3+1+1), // FNC3
    (1+1+4+1+3+1), // FNC4
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    (2+1+2+2+2+2), //	space
    (2+2+2+1+2+2), //	!
    (2+2+2+2+2+1), //	"
    (1+2+1+2+2+3), //	#
    (1+2+1+3+2+2), //	$
    (1+3+1+2+2+2), //	%
    (1+2+2+2+1+3), //	&
    (1+2+2+3+1+2), //	'
    (1+3+2+2+1+2), //	(
    (2+2+1+2+1+3), //	)
    (2+2+1+3+1+2), //	*
    (2+3+1+2+1+2), //	+
    (1+1+2+2+3+2), //	,
    (1+2+2+1+3+2), //	-
    (1+2+2+2+3+1), //	.
    (1+1+3+2+2+2), //	/
    (1+2+3+1+2+2), //	0
    (1+2+3+2+2+1), //	1
    (2+2+3+2+1+1), //	2
    (2+2+1+1+3+2), //	3
    (2+2+1+2+3+1), //	4
    (2+1+3+2+1+2), //	5
    (2+2+3+1+1+2), //	6
    (3+1+2+1+3+1), //	7
    (3+1+1+2+2+2), //	8
    (3+2+1+1+2+2), //	9
    (3+2+1+2+2+1), //	:
    (3+1+2+2+1+2), //	;
    (3+2+2+1+1+2), //	<
    (3+2+2+2+1+1), //	=
    (2+1+2+1+2+3), //	>
    (2+1+2+3+2+1), //	?
    (2+3+2+1+2+1), //	@
    (1+1+1+3+2+3), //	A
    (1+3+1+1+2+3), //	B
    (1+3+1+3+2+1), //	C
    (1+1+2+3+1+3), //	D
    (1+3+2+1+1+3), //	E
    (1+3+2+3+1+1), //	F
    (2+1+1+3+1+3), //	G
    (2+3+1+1+1+3), //	H
    (2+3+1+3+1+1), //	I
    (1+1+2+1+3+3), //	J
    (1+1+2+3+3+1), //	K
    (1+3+2+1+3+1), //	L
    (1+1+3+1+2+3), //	M
    (1+1+3+3+2+1), //	N
    (1+3+3+1+2+1), //	O
    (3+1+3+1+2+1), //	P
    (2+1+1+3+3+1), //	Q
    (2+3+1+1+3+1), //	R
    (2+1+3+1+1+3), //	S
    (2+1+3+3+1+1), //	T
    (2+1+3+1+3+1), //	U
    (3+1+1+1+2+3), //	V
    (3+1+1+3+2+1), //	W
    (3+3+1+1+2+1), //	X
    (3+1+2+1+1+3), //	Y
    (3+1+2+3+1+1), //	Z
    (3+3+2+1+1+1), //	[
    (3+1+4+1+1+1), //	\
    
    (2+2+1+4+1+1), //	]
    (4+3+1+1+1+1), //	^
    (1+1+1+2+2+4), //	_
    (1+1+1+4+2+2), //	`
    (1+2+1+1+2+4), //	a
    (1+2+1+4+2+1), //	b
    (1+4+1+1+2+2), //	c
    (1+4+1+2+2+1), //	d
    (1+1+2+2+1+4), //	e
    (1+1+2+4+1+2), //	f
    (1+2+2+1+1+4), //	g
    (1+2+2+4+1+1), //	h
    (1+4+2+1+1+2), //	i
    (1+4+2+2+1+1), //	j
    (2+4+1+2+1+1), //	k
    (2+2+1+1+1+4), //	l
    (4+1+3+1+1+1), //	m
    (2+4+1+1+1+2), //	n
    (1+3+4+1+1+1), //	o
    (1+1+1+2+4+2), //	p
    (1+2+1+1+4+2), //	q
    (1+2+1+2+4+1), //	r
    (1+1+4+2+1+2), //	s
    (1+2+4+1+1+2), //	t
    (1+2+4+2+1+1), //	u
    (4+1+1+2+1+2), //	v
    (4+2+1+1+1+2), //	w
    (4+2+1+2+1+1), //	x
    (2+1+2+1+4+1), //	y
    (2+1+4+1+2+1), //	z
    (4+1+2+1+2+1), //	{
    (1+1+1+1+4+3), //	|
    (1+1+1+3+4+1), //	}
    (1+3+1+1+4+1), //	~
    (1+1+4+1+1+3), //	DEL
};

static const unsigned short s_bc128Bnum_codes[107] =
{
    BARCODE128(212222), //	space
    BARCODE128(222122), //	!
    BARCODE128(222221), //	"
    BARCODE128(121223), //	#
    BARCODE128(121322), //	$
    BARCODE128(131222), //	%
    BARCODE128(122213), //	&
    BARCODE128(122312), //	'
    BARCODE128(132212), //	(
    BARCODE128(221213), //	)
    BARCODE128(221312), //	*
    BARCODE128(231212), //	+
    BARCODE128(112232), //	,
    BARCODE128(122132), //	-
    BARCODE128(122231), //	.
    BARCODE128(113222), //	/
    BARCODE128(123122), //	0
    BARCODE128(123221), //	1
    BARCODE128(223211), //	2
    BARCODE128(221132), //	3
    BARCODE128(221231), //	4
    BARCODE128(213212), //	5
    BARCODE128(223112), //	6
    BARCODE128(312131), //	7
    BARCODE128(311222), //	8
    BARCODE128(321122), //	9
    BARCODE128(321221), //	:
    BARCODE128(312212), //	;
    BARCODE128(322112), //	<
    BARCODE128(322211), //	=
    BARCODE128(212123), //	>
    BARCODE128(212321), //	?
    BARCODE128(232121), //	@
    BARCODE128(111323), //	A
    BARCODE128(131123), //	B
    BARCODE128(131321), //	C
    BARCODE128(112313), //	D
    BARCODE128(132113), //	E
    BARCODE128(132311), //	F
    BARCODE128(211313), //	G
    BARCODE128(231113), //	H
    BARCODE128(231311), //	I
    BARCODE128(112133), //	J
    BARCODE128(112331), //	K
    BARCODE128(132131), //	L
    BARCODE128(113123), //	M
    BARCODE128(113321), //	N
    BARCODE128(133121), //	O
    BARCODE128(313121), //	P
    BARCODE128(211331), //	Q
    BARCODE128(231131), //	R
    BARCODE128(213113), //	S
    BARCODE128(213311), //	T
    BARCODE128(213131), //	U
    BARCODE128(311123), //	V
    BARCODE128(311321), //	W
    BARCODE128(331121), //	X
    BARCODE128(312113), //	Y
    BARCODE128(312311), //	Z
    BARCODE128(332111), //	[
    BARCODE128(314111), //	'\'
    
    BARCODE128(221411), //	]
    BARCODE128(431111), //	^
    BARCODE128(111224), //	_
    BARCODE128(111422), //	`
    BARCODE128(121124), //	a
    BARCODE128(121421), //	b
    BARCODE128(141122), //	c
    BARCODE128(141221), //	d
    BARCODE128(112214), //	e
    BARCODE128(112412), //	f
    BARCODE128(122114), //	g
    BARCODE128(122411), //	h
    BARCODE128(142112), //	i
    BARCODE128(142211), //	j
    BARCODE128(241211), //	k
    BARCODE128(221114), //	l
    BARCODE128(413111), //	m
    BARCODE128(241112), //	n
    BARCODE128(134111), //	o
    BARCODE128(111242), //	p
    BARCODE128(121142), //	q
    BARCODE128(121241), //	r
    BARCODE128(114212), //	s
    BARCODE128(124112), //	t
    BARCODE128(124211), //	u
    BARCODE128(411212), //	v
    BARCODE128(421112), //	w
    BARCODE128(421211), //	x
    BARCODE128(212141), //	y
    BARCODE128(214121), //	z
    BARCODE128(412121), //	{
    BARCODE128(111143), //	|
    BARCODE128(111341), //	}
    BARCODE128(131141), //	~
    BARCODE128(114113), //	DEL
    BARCODE128(114311), //	FNC 3
    BARCODE128(411113), //	FNC 2
    BARCODE128(411311), //	Shift A
    BARCODE128(113141), //	Code C
    BARCODE128(114131), //	FNC4
    BARCODE128(311141), //	Code A
    BARCODE128(411131), //	FNC 1
    BARCODE128(211412), //	Start Code A
    BARCODE128(211214), //	Start Code B
    BARCODE128(211232), //	Start Code C
    BARCODE128STOP      // 2331112	Stop
};
static const unsigned char s_bc128Bnum_code_widths[107] =
{
    (2+1+2+2+2+2), //	space
    (2+2+2+1+2+2), //	!
    (2+2+2+2+2+1), //	"
    (1+2+1+2+2+3), //	#
    (1+2+1+3+2+2), //	$
    (1+3+1+2+2+2), //	%
    (1+2+2+2+1+3), //	&
    (1+2+2+3+1+2), //	'
    (1+3+2+2+1+2), //	(
    (2+2+1+2+1+3), //	)
    (2+2+1+3+1+2), //	*
    (2+3+1+2+1+2), //	+
    (1+1+2+2+3+2), //	,
    (1+2+2+1+3+2), //	-
    (1+2+2+2+3+1), //	.
    (1+1+3+2+2+2), //	/
    (1+2+3+1+2+2), //	0
    (1+2+3+2+2+1), //	1
    (2+2+3+2+1+1), //	2
    (2+2+1+1+3+2), //	3
    (2+2+1+2+3+1), //	4
    (2+1+3+2+1+2), //	5
    (2+2+3+1+1+2), //	6
    (3+1+2+1+3+1), //	7
    (3+1+1+2+2+2), //	8
    (3+2+1+1+2+2), //	9
    (3+2+1+2+2+1), //	:
    (3+1+2+2+1+2), //	;
    (3+2+2+1+1+2), //	<
    (3+2+2+2+1+1), //	=
    (2+1+2+1+2+3), //	>
    (2+1+2+3+2+1), //	?
    (2+3+2+1+2+1), //	@
    (1+1+1+3+2+3), //	A
    (1+3+1+1+2+3), //	B
    (1+3+1+3+2+1), //	C
    (1+1+2+3+1+3), //	D
    (1+3+2+1+1+3), //	E
    (1+3+2+3+1+1), //	F
    (2+1+1+3+1+3), //	G
    (2+3+1+1+1+3), //	H
    (2+3+1+3+1+1), //	I
    (1+1+2+1+3+3), //	J
    (1+1+2+3+3+1), //	K
    (1+3+2+1+3+1), //	L
    (1+1+3+1+2+3), //	M
    (1+1+3+3+2+1), //	N
    (1+3+3+1+2+1), //	O
    (3+1+3+1+2+1), //	P
    (2+1+1+3+3+1), //	Q
    (2+3+1+1+3+1), //	R
    (2+1+3+1+1+3), //	S
    (2+1+3+3+1+1), //	T
    (2+1+3+1+3+1), //	U
    (3+1+1+1+2+3), //	V
    (3+1+1+3+2+1), //	W
    (3+3+1+1+2+1), //	X
    (3+1+2+1+1+3), //	Y
    (3+1+2+3+1+1), //	Z
    (3+3+2+1+1+1), //	[
    (3+1+4+1+1+1), //	\
    
    (2+2+1+4+1+1), //	]
    (4+3+1+1+1+1), //	^
    (1+1+1+2+2+4), //	_
    (1+1+1+4+2+2), //	`
    (1+2+1+1+2+4), //	a
    (1+2+1+4+2+1), //	b
    (1+4+1+1+2+2), //	c
    (1+4+1+2+2+1), //	d
    (1+1+2+2+1+4), //	e
    (1+1+2+4+1+2), //	f
    (1+2+2+1+1+4), //	g
    (1+2+2+4+1+1), //	h
    (1+4+2+1+1+2), //	i
    (1+4+2+2+1+1), //	j
    (2+4+1+2+1+1), //	k
    (2+2+1+1+1+4), //	l
    (4+1+3+1+1+1), //	m
    (2+4+1+1+1+2), //	n
    (1+3+4+1+1+1), //	o
    (1+1+1+2+4+2), //	p
    (1+2+1+1+4+2), //	q
    (1+2+1+2+4+1), //	r
    (1+1+4+2+1+2), //	s
    (1+2+4+1+1+2), //	t
    (1+2+4+2+1+1), //	u
    (4+1+1+2+1+2), //	v
    (4+2+1+1+1+2), //	w
    (4+2+1+2+1+1), //	x
    (2+1+2+1+4+1), //	y
    (2+1+4+1+2+1), //	z
    (4+1+2+1+2+1), //	{
    (1+1+1+1+4+3), //	|
    (1+1+1+3+4+1), //	}
    (1+3+1+1+4+1), //	~
    (1+1+4+1+1+3), //	DEL
    (1+1+4+3+1+1), //	FNC 3
    (4+1+1+1+1+3), //	FNC 2
    (4+1+1+3+1+1), //	Shift A
    (1+1+3+1+4+1), //	Code C
    (1+1+4+1+3+1), //	FNC4
    (3+1+1+1+4+1), //	Code A
    (4+1+1+1+3+1), //	FNC 1
    (2+1+1+4+1+2), //	Start Code A
    (2+1+1+2+1+4), //	Start Code B
    (2+1+1+2+3+2), //	Start Code C
    BARCODE128STOPWIDTH      // 2331112	Stop
};
unsigned generateBarcode128B1(const char *input, unsigned short *output, unsigned *width)
{
    unsigned len = 1;
    unsigned short barcode;
    unsigned ctrl_code = BARCODE128STARTBNO;
    unsigned w = 0;
    
    output[0] = BARCODE128STARTB;
    output++;
    w = BARCODE128STOPWIDTH;
    
    while(input[0])
    {
        if(input[0] > 127)
        {
            return 0;
        }
        barcode = s_bc128Bcodes[input[0]];
        w += s_bc128Bcode_widths[input[0]];
        if(barcode == 0)
        {
            return 0;
        }
        switch(input[0])
        {
            case 1: // FUNC1
                ctrl_code += len*102;
                break;
            case 2: // FUNC2
                ctrl_code += len*97;
                break;
            case 3: // FUNC3
                ctrl_code += len*96;
                break;
            case 4: // FUNC4
                ctrl_code += len*100;
                break;
            default:
                ctrl_code += len*(input[0] - 32);
                break;
        }
        output[0] = barcode;
        output++;
        input++;
        len++;
    }
    ctrl_code %= 103;
    
    output[0] = s_bc128Bnum_codes[ctrl_code];
    w += s_bc128Bnum_code_widths[ctrl_code];
    output++;
    len++;
    output[0] = BARCODE128STOP;
    w += BARCODE128STOPWIDTH;
    len++;
    
    if(width)
    {
        *width = w;
    }
    return len;
}