@thumb
	
	add	r0, #0x50
	ldrb	r0, [r0]
	cmp	r0, #3
	beq	kansetsu
	cmp	r0, #5
	beq	kansetsu
	cmp	r0, #6
	beq	kansetsu
	cmp	r0, #7
	beq	kansetsu
	mov	r0, #0
	bx	lr
kansetsu
	mov	r0, #1
	bx	lr	