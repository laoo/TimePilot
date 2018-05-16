
	org dataTitleScreenDlist
	
	dta b($50),b($c7),a(bufScreenTxt),b($70),b($70)
	dta b($45),a(bufScreen0+80),b($85),b($70),b($70),b($70),b($70),b($70),b($47),a(bufScreenTxt+20),b($70),b($70),b($87),b($70),b($70),b($70),b($70),b($70),b($47),a(bufScreenTxt+7*20),b($30),b($7)
	dta b($41),a(dataTitleScreenDlist)
	
	org dataTitleScreenDlist2
	
	dta b($50),b($c7),a(bufScreenTxt),b($70),b($70)
	dta b($45),a(bufScreen0+80),b($85),b($70),b($70),b($c7),a(bufScreenTxt+20),b($70),b($20),b($87),b($70),b($20),b($87),b($70),b($20),b($87),b($70),b($20),b($87),b($70),b($20),b($7)
	dta b($41),a(dataTitleScreenDlist2)
	
fakeDlist
	dta b($f0)
	dta b($41),a(fakeDlist)	