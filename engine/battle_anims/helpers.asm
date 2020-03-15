ReinitBattleAnimFrameset:
	ld hl, BATTLEANIMSTRUCT_FRAMESET_ID
	add hl, bc
	ld [hl], a
	ld hl, BATTLEANIMSTRUCT_DURATION
	add hl, bc
	ld [hl], 0
	ld hl, BATTLEANIMSTRUCT_FRAME
	add hl, bc
	ld [hl], -1
	ret

GetBattleAnimFrame:
.loop
	ld hl, BATTLEANIMSTRUCT_DURATION
	add hl, bc
	ld a, [hl]
	and a
	jr z, .next_frame
	dec [hl]
	call .GetPointer
	ld a, [hli]
	push af
	jr .okay

.next_frame
	ld hl, BATTLEANIMSTRUCT_FRAME
	add hl, bc
	inc [hl]
	call .GetPointer
	ld a, [hli]
	cp dorestart_command
	jr z, .restart
	cp endanim_command
	jr z, .repeat_last

	push af
	ld a, [hl]
	push hl
	and $3f
	ld hl, BATTLEANIMSTRUCT_DURATION
	add hl, bc
	ld [hl], a
	pop hl
.okay
	ld a, [hl]
	and $c0
	srl a
	ld [wBattleAnimTempAddSubFlags], a
	pop af
	ret

.repeat_last
	xor a
	ld hl, BATTLEANIMSTRUCT_DURATION
	add hl, bc
	ld [hl], a
	ld hl, BATTLEANIMSTRUCT_FRAME
	add hl, bc
	dec [hl]
	dec [hl]
	jr .loop

.restart
	xor a
	ld hl, BATTLEANIMSTRUCT_DURATION
	add hl, bc
	ld [hl], a
	dec a
	ld hl, BATTLEANIMSTRUCT_FRAME
	add hl, bc
	ld [hl], a
	jr .loop


.GetPointer:
	ld hl, BATTLEANIMSTRUCT_FRAMESET_ID
	add hl, bc
	ld e, [hl]
	ld d, 0
	ld hl, BattleAnimFrameData
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, BATTLEANIMSTRUCT_FRAME
	add hl, bc
	ld l, [hl]
	ld h, $0
	add hl, hl
	add hl, de
	ret


GetBattleAnimOAMPointer:
	ld l, a
	ld h, 0
	ld de, BattleAnimOAMData
	add hl, hl
	add hl, hl
	add hl, de
	ret


LoadBattleAnimObj:
	cp ANIM_GFX_POKE_BALL
	call z, .LoadBallPalette
	push hl
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	ld de, AnimObjGFX
	add hl, de
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop de
	push bc
	call DecompressRequest2bpp
	pop bc
	ret

.LoadBallPalette:
	; save the registers to the stack
	push hl
	push af
	; save the current WRAM bank
	ld a, [rSVBK]
	push af
	; switch to the WRAM bank of wCurItem so we can read it
	ld a, BANK(wCurItem)
	ld [rSVBK], a
	; store the current item in b
	ld a, [wCurItem]
	ld b, a
	; seek for the BallColors entry matching the current item
	ld hl, BallColors
.loop
	ld a, [hli]
	cp b ; did we find the current ball?
	jr z, .done
	cp -1 ; did we reach the end of the list?
	jr z, .done
rept 4
	inc hl ; skip over the 4 RGB color bytes to the next entry
endr
	jr .loop
.done
	; switch to the WRAM bank of wOBPals2 so we can write to it
	ld a, BANK(wOBPals2)
	ld [rSVBK], a
	; load the RGB colors into the middle two colors of PAL_BATTLE_OB_RED
	ld de, wOBPals2 palette PAL_BATTLE_OB_RED color 1
rept 4
	ld a, [hli]
	ld [de], a
	inc de
endr
	; apply the updated colors to the palette RAM
	ld a, $1
	ld [hCGBPalUpdate], a
	; restore the current WRAM bank
	pop af
	ld [rSVBK], a
	; restore the registers from the stack
	pop af
	pop hl
	ret

INCLUDE "data/battle_anims/ball_colors.asm"
