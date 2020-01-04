.thumb

HAS_BIG_SHIELD_FUNC = (adr+0)
HAS_HOLY_SHIELD_FUNC = (adr+4)
HAS_GOD_SHIELD_FUNC = (adr+8)
HAS_INORI_FUNC = (adr+12)
HAS_NIHIL_FUNC = (adr+16)
SET_SKILLANIME_DEF_FUNC = (adr+20)
HAS_INVINCIBLE_FUNC = (adr+28)

@.org	0802b490 > 00 4A 97 46 XX XX XX 08
@
@
	bl Invincible
	cmp r0, #1
	beq zero

	mov r1, #4
	ldsh r0, [r4, r1]
	cmp r0, #0
	ble zero

	mov r0, r8
	ldrb r0, [r0, #0xB]
		ldr r1, =0x08019108
		mov lr, r1
		.short 0xF800
	cmp r0, #0
	beq end	@壁
	
	bl DistantGuard @遠距離無効
	cmp r0, #0
	bne zero
	
	bl Amulet
	cmp r0, #1
	beq end
	
	mov r1, r10
	cmp r1, #0xDE
	beq end	@必的チェック
	ldr r0, =0x0203a604
	ldr r0, [r0]
	ldr r0, [r0]
	mov r1, #128
	lsl r1, r1, #3
	and r0, r1
	bne end	@トライアングルチェック
	mov r1, #0xDF		@防御用
	mov r10, r1
@無効
	bl HolyShield
	cmp r0, #1
	beq end
	
@致命耐え
	bl Pray
	cmp r0, #1
	beq end
	bl Xeno

@半減
	bl BigShield
	cmp r0, #1
	beq end
	
	bl Deflect
	cmp r0, #1
	beq end
bl Oracle
	b end

zero:
	mov	r0, #0
	strh	r0, [r4, #4]
end:
	ldr r0, =0x0802b49a
	mov pc, r0
	

Invincible:
		push {lr}

		mov r0, r8
		mov r1, #0
		bl hasInvincible
		cmp r0, #0
		beq falseInvincible
@
		mov r1, r7
		add r1, #100
		ldrh r0, [r1]
		cmp r0, #100
		blt jumpInvincible
		mov r0, #99
		strh r0, [r1] @命中99
	jumpInvincible:
		ldr r0, =0x0203a4d0
		ldrh r1, [r0, #0]
		mov r0, #2
		and r0, r1
		cmp r0, #0
		bne falseInvincible @戦闘予測時はスキップ
@
		mov r3, r8
		ldrb r1, [r3, #19]
		ldrh r0, [r4, #4]
		cmp r0, r1
		blt falseInvincible @一撃で死なないなら終了
@
		ldr r3, =0x0203a604
		ldr r3, [r3, #0]
		ldr r2, [r3, #0]
		lsl r1, r2, #13
		lsr r1, r1, #13
		mov r0, #2
		orr r1, r0
		ldr r0, =0xfff80000
		and r0, r2
		orr r0, r1
		str r0, [r3, #0]	@回避

		mov r0, #1
		b endInvincible
	falseInvincible:
		mov r0, #0
	endInvincible:
		pop {pc}

Deflect:
		push {lr}
			ldr r0, =0x0203a4d0
			ldrh r0, [r0]
			mov r1, #0x20
			and r0, r1
			bne falseDeflect @闘技場チェック
		mov r0, r8
			ldr r3, adr+32 @連撃防御
			mov lr, r3
			.short 0xF800
		cmp r0, #0
		beq falseDeflect
		
		mov r0, r8
		ldrb r0, [r0, #11]
			ldr r3, =0x08019108
			mov lr, r3
			.short 0xF800
		ldrb r1, [r0, #0x13] @戦闘前のHP
		mov r0, r8
		ldrb r0, [r0, #0x13] @今のHP
		cmp r0, r1
		bge falseDeflect @HP減少(被攻撃)が無ければ終わり
		
		mov r0, r7
			ldr r1, HAS_NIHIL_FUNC
			mov lr, r1
			.short 0xF800
		cmp r0, #1
		beq falseDeflect	@見切り持ちなら終了
		ldrh r0, [r4, #4]
		asr r0, r0, #1
		strh r0, [r4, #4]
		mov r0, #1
		.short 0xE000
	falseDeflect:
		mov r0, #0
		pop {pc}
	
	
	
	DistantGuard:
		push {lr}
		mov r0, r8
			ldr r1, adr+24 @遠距離無効
			mov lr, r1
			.short 0xF800
		cmp r0, #0
		beq endDistantGuard
		
		ldr r0, =0x0203a4d2
		ldrb r0, [r0] @距離
		cmp r0, #1
		beq endDistantGuard
		
		mov r0, #1
		.short 0xE000
	endDistantGuard:
		mov r0, #0
		pop {pc}
		

BigShield:
	push {lr}
	mov r0, r8
		ldr r1, HAS_BIG_SHIELD_FUNC
		mov lr, r1
		.short 0xF800
	cmp r0, #0
	beq falseShield
	
	mov r0, r7
		ldr r1, HAS_NIHIL_FUNC
		mov lr, r1
		.short 0xF800
	cmp r0, #1
	beq falseShield	@見切り持ちなら終了
	
	mov	r3, r8
	mov	r0, #0x50
	ldrb	r0, [r7, r0]	@魔法判定
	cmp	r0, #7
	beq	falseShield
	cmp	r0, #6
	beq	falseShield
	cmp	r0, #5
	beq	falseShield
	
	ldrb	r0, [r3, #21]	@技
	mov	r1, #0
	bl	random
	cmp	r0, #0
	beq	falseShield
	ldrh	r0, [r4, #4]
	lsr	r0, r0, #1
	strh	r0, [r4, #4]
	
    mov r0, r8
    ldr r1, HAS_BIG_SHIELD_FUNC
    ldr r1, [r1, #12]
        ldr r2, SET_SKILLANIME_DEF_FUNC
        mov lr, r2
        .short 0xF800
	
	mov	r0, #1
	b endShield
falseShield:
	mov	r0, #0
endShield:
	pop	{pc}
	
	
HolyShield:
	push {lr}
	mov r0, r8
		ldr r1, adr+4 @聖盾
		mov lr, r1
		.short 0xF800
	cmp r0, #0
	beq falseHoly
	
	mov r0, r7
		ldr r1, HAS_NIHIL_FUNC
		mov lr, r1
		.short 0xF800
	cmp r0, #1
	beq falseHoly	@見切り持ちなら終了
	
	mov	r3, r8
	mov	r0, #0x50
	ldrb	r0, [r7, r0]	@物理判定
	cmp	r0, #7
	beq	ouiHoly
	cmp	r0, #6
	beq	ouiHoly
	cmp	r0, #5
	beq	ouiHoly
	b falseHoly
ouiHoly:
	ldrb	r0, [r3, #21]	@技
	mov	r1, #0
	bl	random
	cmp	r0, #0
	beq	falseHoly
	ldrh	r0, [r4, #4]
	mov r0, #0
	strh	r0, [r4, #4]
	
    mov r0, r8
    ldr r1, HAS_HOLY_SHIELD_FUNC
    ldr r1, [r1, #12]
        ldr r2, SET_SKILLANIME_DEF_FUNC
        mov lr, r2
        .short 0xF800
	
	mov	r0, #1
	pop	{pc}

falseHoly:
	mov	r0, #0
	pop	{pc}
	
	
Pray:
	push {lr}
	mov r0, r8
		ldr r1, HAS_INORI_FUNC @祈り
		mov lr, r1
		.short 0xF800
	cmp r0, #0
	beq	falsePray
	mov r3, r8
	
    mov r0, #0x13
    ldrb r0, [r3, r0]	@現在HP
    mov r1, #0x12
    ldrb r1, [r3, r1]	@最大HP
    lsl r0, r0, #1
    cmp r0, r1
    blt falsePray
	
	ldrb r1, [r3, #19]
	ldrh r0, [r4, #4]
	cmp r0, r1
	blt falsePray @一撃で死なないなら終了
	
	mov r0, r7
		ldr r1, HAS_NIHIL_FUNC
		mov lr, r1
		.short 0xF800
	cmp r0, #1
	beq falsePray @見切り持ちなら終了

@祈り効果
	mov	r0, r8
	ldrb	r0, [r0, #19]
	sub	r0, #1
	strh	r0, [r4, #4]
	
        mov r0, r8
        ldr r1, HAS_INORI_FUNC
        ldr r1, [r1, #12]
            ldr r2, SET_SKILLANIME_DEF_FUNC
            mov lr, r2
            .short 0xF800
	
	mov	r0, #1
	b endPray
falsePray:
	mov	r0, #0
endPray:
	pop	{pc}


Oracle:
	push	{lr}
	ldr r1, HAS_GOD_SHIELD_FUNC
	mov lr, r1
	mov r0, r8
	.short 0xF800
	cmp r0, #0
	beq	endOracle
	
	mov r0, r7
		ldr r1, HAS_NIHIL_FUNC
		mov lr, r1
		.short 0xF800
	cmp r0, #1
	beq	endOracle	@見切り持ちなら終了
	ldrh	r0, [r4, #4]
	asr	r0, r0, #1
	strh	r0, [r4, #4]
	b	endOracle
endOracle:
	pop	{pc}
	
	
Amulet:
	push {r5, lr}
	mov	r5, #0x1C
loopAmulet:
	add	r5, #2
	cmp	r5, #40
	beq	endAmulet
	mov	r3, r8
	ldrh	r0, [r3, r5]
	cmp	r0, #0
	beq	loopAmulet
		ldr	r1, =0x08017314
		mov	lr, r1
		.short 0xF800
	mov r2, r0
	lsl	r0, r2, #5	@盾パッチの下の下
	bmi	ouiAmulet
	b	loopAmulet
	
ouiAmulet:
	mov	r3, r8
	ldrb	r1, [r3, #19]	@現在HP
@一撃で死ぬか
	ldrh	r0, [r4, #4]	@ダメージ
	cmp	r0, r1
	blt	endAmulet
	lsl	r0, r2, #27	@特殊・売却不可
	bmi	gotElixir
	
	ldrh	r0, [r3, r5]
	mov		r2, #0xFF
	lsl	r2, r2, #8
	tst	r0, r2
	beq	endAmulet	@破損チェック
	mov		r2, #0xFF
	and	r0, r2
	strh	r0, [r3, r5]	@破損処理
gotElixir:
	ldrb	r0, [r3, #19]
	sub	r0, #1
	strh	r0, [r4, #4]
	
        mov r0, r8
        ldr r1, HAS_INORI_FUNC
        ldr r1, [r1, #12]
            ldr r2, SET_SKILLANIME_DEF_FUNC
            mov lr, r2
            .short 0xF800
	
	mov	r0, #1
	pop	{r5, pc}
endAmulet:
	mov	r0, #0
	pop	{r5, pc}

Xeno:
	mov r2, r8
	ldrb r0, [r2, #11]
	ldr r1, =0x0203a5e8 @ゲノ
	ldrb r1, [r1]
	cmp r0, r1
	bne endXeno @不発
	ldrh r0, [r4, #4]
	ldrb r1, [r2, #19]	@現在HP
@一撃で死ぬか
	cmp r0, r1
	blt endXeno
	sub r1, #1
	strh r1, [r4, #4]
endXeno:
	bx lr

hasInvincible:
	ldr	r2, HAS_INVINCIBLE_FUNC
	mov	pc, r2

random:
	ldr	r2, =0x0802a490
	mov	pc, r2
.ltorg
adr:
