
;preparations for every rendering phase

.enum prPrepareGenericTypes
cloud1 = 0
cloud2 = 1
cloud3 = 2
asteroid1 = 3
asteroid2 = 4
asteroid3 = 5
enemy =     6
explosion = 7
parachute = 8
bomb = 9
boss = 10
.ende

;Y - object type
.proc prPrepareGeneric
  lda twidth,y
  sta prObjWidth
  lda theight,y
  sta prObjHeight
  lda txloopjmpl,y
  sta prDrawGeneric.xloopJmp+0
  lda txloopjmph,y
  sta prDrawGeneric.xloopJmp+1
  lda txloopexit,y
  sta prDrawGeneric.StandardXLoop.exitResult
  lda txloopfhd,y
  sta prDrawGeneric.StandardXLoop.highFontDeterminant
  ldx tobj,y
  stx prObjId
  lda ebGfxMaskO,x
  sta prGfxMaskOff
  lda ebGfxNextO,x
  sta prGfxNextOff+1
  asl
  sta prGfxNextOff+2
  clc
  adc prGfxNextOff+1
  sta prGfxNextOff+3
  clc
  adc prGfxNextOff+1
  sta prGfxNextOff+4
  rts
  
SXL = prDrawGeneric.StandardXLoop
CXL = prDrawGeneric.Cloud3XLoop
c1w = prPrepareGfxCloud1.cWidth
c2w = prPrepareGfxCloud2.cWidth
c3w = prPrepareGfxCloud3.cWidth
a1w = prPrepareGfxAsteroid1.cWidth
a2w = prPrepareGfxAsteroid2.cWidth
a3w = prPrepareGfxAsteroid3.cWidth
bow = prPrepareGfxBoss.cWidth
c1h = prPrepareGfxCloud1.cHeight
c2h = prPrepareGfxCloud2.cHeight
c3h = prPrepareGfxCloud3.cHeight
a1h = prPrepareGfxAsteroid1.cHeight
a2h = prPrepareGfxAsteroid2.cHeight
a3h = prPrepareGfxAsteroid3.cHeight
boh = prPrepareGfxBoss.cHeight
oc1 = prGfxObj.cloud1
oc2 = prGfxObj.cloud2
oc3 = prGfxObj.cloud3
oen = prGfxObj.enemy
oex = prGfxObj.explosion
opa = prGfxObj.parachute
obm = prGfxObj.bomb
obo = prGfxObj.boss

bossBlink = txloopfhd+prPrepareGenericTypes.boss

twidth      dta b(c1w),     b(c2w),     b(c3w),     b(a1w),     b(a2w),     b(a3w),     b(4),   b(4),   b(4),   b(2),   b(bow)
theight     dta b(c1h),     b(c2h),     b(c3h),     b(a1h),     b(a2h),     b(a3h),     b(16),  b(16),  b(16),  b(8),   b(boh)
txloopjmpl  dta l(SXL),     l(SXL),     l(CXL),     l(SXL),     l(SXL),     l(CXL),     l(SXL), l(SXL), l(SXL), l(SXL), l(SXL)
txloopjmph  dta h(SXL),     h(SXL),     h(CXL),     h(SXL),     h(SXL),     h(CXL),     h(SXL), h(SXL), h(SXL), h(SXL), h(SXL)
txloopexit  dta b(0),       b(0),       b($ff),     b(0),       b(0),       b($ff),     b(1),   b(0),   b(1),   b(1),   b(1)
txloopfhd   dta b($80),     b($80),     b($0),      b($80),     b($80),     b(0),       b(0),   b(0),   b($80), b(0),   b(0)
tobj        dta b(oc1),     b(oc2),     b(oc3),     b(oc1),     b(oc2),     b(oc3),     b(oen), b(oex), b(opa), b(obm), b(obo)
.endp

.proc prepareGfxNextOff

.endp