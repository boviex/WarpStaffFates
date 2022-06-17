.text
.align 4

.equ map__Cursor__Get, 0x39b8fc
.equ map__Mind__Get, 0x389014
.equ map__Mind__GetUnit, 0x5261fc
.equ map__Mind__GetTargetUnit, 0x5261dc
.equ map__Deploy__Cannon, 0x39d270
.equ map__Deploy__DoubleFillRod, 0x39c654
.equ map__Deploy__FillRod, 0x39d448
.equ map__Panel__Deploy__SetMode, 0x393f10
.equ map__Intermediate__GameInfo__EnableChangeViewer, 0x34cb78
.equ map__Intermediate__GameInfo__Update, 0x34cbd4
.equ map__Intermediate__GameInfo__Set, 0x1bbe38
.equ map__Intermediate__GameInfo__UpdateJobIntro, 0x34cacc
.equ map__Intermediate__GameInfo__DisableJobIntro, 0x34cb6c
.equ map__TerrainInfo__Get, 0x34c4ec
.equ map__TerrainInfo__Show, 0x34ca6c
.equ map__TerrainInfo__Hide, 0x34c9b4
.equ map__Gradation__Get, 0x3a58e0
.equ map__Situation__IsCancelOperation, 0x527f14
.equ map__SequenceHelper__MoveCursor, 0x35e3bc
.equ map__SequenceHelper__DangerTick, 0x35e2cc
.equ map__sound__Se__Decide, 0x398208
.equ map__sound__Se__Cancel, 0x3981d4
.equ map__sound__Se__Failure, 0x398254
.equ ProcInst__Jump, 0x4edfcc
.equ game__graphics__GameCursor__TickFree, 0x3e3324
.equ map__ItemHelper__Rod__GetRescuePosition, 0x34a32c
.equ Item__Get, 0x3d0e90
.equ unit__GetItemEquipped, 0x3d5fb0
.equ unit__Item__GetName, 0x53b368
.equ TerrainCost__GetCostFromUnit, 0x1a6708
.equ map__Image__Unit__GetUnit, 0x526424

.global WarpCursorPrepare
WarpCursorPrepare:
push {r4-r10, lr}
mov r5, r0

bl CheckWarpStaff
cmp r0, #0
bne IsWarpStaff

@TODO: if used staff is not Warp, procinstjump to 0x1f and end. Otherwise, continue.
		mov r0, r5
		pop {r4-r10, lr}
		mov r1, #0x26
		b ProcInst__Jump

IsWarpStaff:
sub sp, #8
bl map__Mind__Get
bl map__Mind__GetUnit
mov r4, r0
bl map__Cursor__Get
vldr.32 s0, [r0, #0x18]
vcvt.s32.f32 s0, s0
vmov r7, s0
bl map__Cursor__Get
vldr.32 s0, [r0, #0x1c]
ldr r10, =0x6d70a8
vcvt.s32.f32 s0, s0
vmov r8, s0

mov r6, #0 @size of cursor
mov r9, #10 @outer range
mov r3, #0 @inner range

ldr r0, =0x6d7364
str r6, [sp, #4]
str r9, [sp, #0]
ldrsb r2, [r4, #0xf5] @ is this the coord?
ldrsb r1, [r4, #0xf4]
ldr r0, [r0]

bl map__Deploy__Cannon
@ bl map__Deploy__FillRod

ldr r0, [r10]
mov r2, #0
mov r1, #0xb @yellow tiles like dv, not ideal but it works
ldr r0, [r0, #4]
bl map__Panel__Deploy__SetMode

bl map__Cursor__Get
ldr r1, [r0, #0x44]
orr r1, #3
str r1, [r0, #0x44]
bl map__Cursor__Get
ldr r1, [r0, #0x44]
orr r1, #8
str r1, [r0, #0x44]
bl map__Cursor__Get
str r6, [r0, #0x30]
mov r2, r8
mov r1, r7
mov r0, r5
@ this is where there would be a bl is valid target and such 'iscannonattack'. I am skipping it
bl map__Cursor__Get
ldr r1, [r0, #0x44]
bic r1, #0x10

str r1, [r0, #0x44]
bl map__Intermediate__GameInfo__EnableChangeViewer
mov r4, #0
strb r4, [r5, #0x4c]
bl map__Mind__Get
bl map__Mind__GetUnit
mov r2, r0
mov r1, r8
mov r0, r7
bl map__Intermediate__GameInfo__Update
mov r2, #0
mov r1, r8
mov r0, r7
bl map__Intermediate__GameInfo__UpdateJobIntro
bl map__TerrainInfo__Get
mov r2, r8
mov r1, r7
bl map__TerrainInfo__Show
bl map__Gradation__Get
strb r4, [r0, #0]

add sp, #8
pop {r4-r10, pc}

.align 4
.pool


.global WarpCursorTick
WarpCursorTick:
push {r4-r10, lr}
mov r4, r0
mov r0, #0
ldrsb r5, [r4, #0x4c]
strb r0, [r4, #0x4c]
ldr r0, =0x6d7ed0
ldr r0, [r0]
bl map__Situation__IsCancelOperation
ldr r8, =0x6d70a8
cmp r0, #0
beq NoCancel
	mov r5, r4
	bl map__Mind__Get
	bl map__Mind__GetUnit
	mov r4, r0
	ldr r0, [r8]
	mov r2, #0
	mov r1, r2
	ldr r0, [r0, #4]
	bl map__Panel__Deploy__SetMode
	ldrsb r2, [r4, #0xf5]
	ldrsb r1, [r4, #0xf4]
	mov r0, r5
	bl map__SequenceHelper__MoveCursor
	bl map__Cursor__Get
	ldr r1, [r0, #0x44]
	bic r1, #0x3
	str r1, [r0, #0x44]
	bl  map__Cursor__Get
	ldr r1, [r0, #0x44]
	bic r1, #0x8
	str r1, [r0, #0x44]
	bl map__Cursor__Get
	ldr r1, [r0, #0x44]
	bic r1, #0x10
	str r1, [r0, #0x44] @do we need to do these one by one? who knows
	bl map__Intermediate__GameInfo__DisableJobIntro
	bl map__sound__Se__Cancel
	bl map__TerrainInfo__Get
	bl map__TerrainInfo__Hide
	mov r0, r4
	bl map__Intermediate__GameInfo__Set
	ldr r0, [r5, #0x34]
	mov r4, r5
	cmp r0, #0
	beq ProcLabel1A
		mov r0, r4
		pop {r4-r10, lr}
		mov r1, #0x14
		b ProcInst__Jump
	ProcLabel1A:
	mov r0, r4
	pop {r4-r10, lr}
	mov r1, #0x1a
	b ProcInst__Jump
NoCancel:
bl map__Cursor__Get
mov r1, #3
bl game__graphics__GameCursor__TickFree
bl map__Cursor__Get
vldr.32 s0,[r0, #0x18]
vcvt.s32.f32 s0, s0
vmov r7, s0
bl map__Cursor__Get
vldr.32 s0,[r0, #0x1c]
vcvt.s32.f32 s0, s0
vmov r6, s0
bl map__Cursor__Get
ldr r0, [r0, #0x44]
tst r0, #0x20
beq NoUnitOnTile
	mov r2, r6
	mov r1, r7
	mov r0, r4
	@ bl IsValidWarpTile @if there is a unit on the tile it's not a valid warp point.
	mov r0, #0
	cmp r0, #0
	beq InvalidTile
		bl map__Cursor__Get
		ldr r1, [r0, #0x44]
		orr r1, #0x10
		b Continue
	InvalidTile:
		bl map__Cursor__Get
		ldr r1, [r0, #0x44]
		bic r1, #0x10
	Continue:
		str r1, [r0, #0x44]
		bl map__Mind__Get
		bl map__Mind__GetUnit
		mov r2, r0
		mov r1, r6
		mov r0, r7
		bl map__Intermediate__GameInfo__Update
		mov r2, #0
		mov r1, r6
		mov r0, r7
		bl map__Intermediate__GameInfo__UpdateJobIntro
		bl map__TerrainInfo__Get
		mov r2, r6
		mov r1, r7
		bl map__TerrainInfo__Show

NoUnitOnTile:
ldr r0, =0x6bd96c
mov r9, #6
ldr r0, [r0]
ldr r0, [r0, #0x14]
tst r0, #1
beq NoAPress
	bl map__Cursor__Get
	vldr.32 s0, [r0, #0x18]
	vcvt.s32.f32 s0, s0
	vmov r6, s0
	bl map__Cursor__Get
	vldr.32 s0, [r0, #0x1c]
	vcvt.s32.f32 s0, s0
	vmov r7, s0
	mov r0, r6
	mov r1, r7
	bl IsValidWarpTile @with x and y in r0 and r1
	cmp r0, #0
	beq InvalidTile2
		ldr r0, [r8]
		mov r2, #0
		mov r1, r2
		ldr r0, [r0, #4]
		bl map__Panel__Deploy__SetMode
		bl map__Cursor__Get
		ldr r1, [r0, #0x44]
		bic r1, #0x3
		str r1, [r0, #0x44]
		bl  map__Cursor__Get
		ldr r1, [r0, #0x44]
		bic r1, #0x8
		str r1, [r0, #0x44]
		bl map__Cursor__Get
		ldr r1, [r0, #0x44]
		bic r1, #0x10
		str r1, [r0, #0x44] @do we need to do these one by one? who knows
		bl map__Intermediate__GameInfo__DisableJobIntro
		bl map__sound__Se__Decide
		bl map__Mind__Get
		bl map__Mind__GetUnit
		mov r5, r0
		bl map__Mind__Get
		mov r1, r0
		ldrb r0, [r5, #0xf4]
		strb r0, [r1, #4]
		bl map__Mind__Get
		ldrb r2, [r5, #0xf5]
		strb r2, [r0, #0x5]
		ldr r0, [r4, #0x34]
		cmp r0, #0
		beq UnknownCondition
			bl map__Mind__Get
			strb r9, [r0, #0x6]
			bl map__Mind__Get
			mov r1, r0
			ldr r0, [r4, #0x34]
			ldrb r0, [r0, #0xc]
			strh r0, [r1, #0xc]
			b Continue2
	InvalidTile2:
	pop {r4-r10, lr}
	b map__sound__Se__Failure
	
	UnknownCondition:
	bl map__Mind__Get
	mov r1, #0x5 @ 0x22 for cannon, this is checked in sequencecannon__create, but why?
	@ setting it to 0x4 which is checked at 0x35d374. Later on down the same function is the skill IUID rescue checked at 35d7fc
	@rescue sets it to 0x5... interesting
	strb r1, [r0, #0x6]
		Continue2:
		bl map__Mind__Get
		strb r6, [r0, #0xa]
		bl map__Mind__Get
		strb r7, [r0, #0xb]
		mov r0, r4
		pop {r4-r10, lr}
		mov r1, #0x26
		b ProcInst__Jump @ends turn
NoAPress:
tst r0, #0x2
beq UnknownPress
	mov r5, r4
	bl map__Mind__Get
    bl  map__Mind__GetUnit   
    mov r4,r0
    ldr r0,[r8,#0x0]
    mov r2,#0x0
    mov r1,r2
    ldr r0,[r0,#0x4]
    bl  map__Panel__Deploy__SetMode 
    ldrsb r2,[r4,#0xf5]
    ldrsb r1,[r4,#0xf4]
    mov r0,r5
    bl  map__SequenceHelper__MoveCursor       
    bl  map__Cursor__Get   
    ldr r1,[r0,#0x44]
    bic r1,r1,#0x3
    str r1,[r0,#0x44]
    bl  map__Cursor__Get      
    ldr r1,[r0,#0x44]
    bic r1,r1,#0x8
    str r1,[r0,#0x44]
    bl  map__Cursor__Get     
    ldr r1,[r0,#0x44]
    bic r1,r1,#0x10
    str r1,[r0,#0x44]
    bl  map__Intermediate__GameInfo__DisableJobIntro   
    bl  map__sound__Se__Cancel 
    bl  map__TerrainInfo__Get  
    bl  map__TerrainInfo__Hide 
    mov r0,r4
    bl  map__Intermediate__GameInfo__Set 
    ldr r0,[r5,#0x34]
    cmp r0,#0x0
    beq ProcLabel1A_2
    mov r0,r5
    pop {r4-r10, lr}
    mov r1,#0x14
    b   ProcInst__Jump       
ProcLabel1A_2:
    mov r0,r5
	pop {r4-r10, lr}
    mov r1,#0x1a
    b   ProcInst__Jump     

UnknownPress:
    bl  map__SequenceHelper__DangerTick   
    cmp r0,#0x0
    bne EndFunction
	    cmp r5,#0x0
	    beq EndFunction
		    mov r0,r4
		    str r9,[r4,#0x48]
			pop {r4-r10, lr}
		    mov r1,#0x27
		    b   ProcInst__Jump   
EndFunction:
pop {r4-r10, pc}

.align 4
.pool

.align 4
IsValidWarpTile:
push {r4-r10, lr}
mov r4, r0 @r4 = x
mov r5, r1 @r5 = y

bl map__Mind__Get
bl map__Mind__GetTargetUnit
mov r6, r0 @target unit in r6
ldr r7, =0x6d73e8 @what is this?
ldr r7, [r7]

add r0, r7, #8
mov r1, r4
mov r2, r5
bl map__Image__Unit__GetUnit
cmp r0, #0
bne False

orr r0, r4, r5, lsl #5 @is this the map coords?
add r1, r7, #8
add r1, #0x400
ldrb r0, [r0, r1]
bl 0x4e0afc @turns it into some kind of struct?
@ldr r1, [r0, #0x18] @no idea what this was for
@tst r1, #0x8
@beq False
ldrb r1, [r0, #0x10]
mov r0, r6
bl TerrainCost__GetCostFromUnit @r0 = unit? r1 = what? terrain index?
cmp r0, #0
blt False

mov r0, #1
pop {r4-r10, pc}

False:
mov r0, #0

pop {r4-r10, pc}


.align 4

CheckWarpStaff: @0077b4e0
push {r4-r10, lr}

ldr r0, =aIID_Warp
bl Item__Get
ldrh r0, [r0, #0x14]
mov r4, r0 @the item ID for warp staff is here now.. i think.


bl map__Mind__Get
mov r5, r0
bl map__Mind__GetUnit
mov r6, r0
bl unit__GetItemEquipped
cmp r0, #0
addne r6, #4 @if unit has an equipped weapon, the staff will be 2nd.
add r6, #0x108 @otherwise it is first.
ldrh r0, [r6] @the top item, or 2nd if weapon equipped
cmp r0, r4

mov r0, #0
moveq r0, #1

pop {r4-r10, pc}

.align 4
.global GetRescuePosWrapper
GetRescuePosWrapper:
push {r4-r10, lr}
@TODO: if not warp staff, do the default behaviour.

@r0 contains stack pointer to write to
@r1 contains stack pointer to write to
mov r7, r0
mov r8, r1
mov r9, r2
mov r10, r3

bl CheckWarpStaff
cmp r0, #0
beq NotWarp

bl map__Cursor__Get
vldr.32 s0,[r0, #0x18]
vcvt.s32.f32 s0, s0
vmov r4, s0
bl map__Cursor__Get
vldr.32 s0,[r0, #0x1c]
vcvt.s32.f32 s0, s0
vmov r5, s0

str r4, [r7]
str r5, [r8]
pop {r4-r10, pc}

NotWarp:
mov r0, r7
mov r1, r8
mov r2, r9
mov r3, r10
pop {r4-r10, lr} @put the params and stack back how we found them
b map__ItemHelper__Rod__GetRescuePosition

aIID_Warp:
.string "IID_Warp"
.align 4
.pool