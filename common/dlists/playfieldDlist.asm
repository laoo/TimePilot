
	org dataPlayfieldDlist
	dta b($50),b($c7),a(bufScreenTxt)
	dta b($45)
adrBufScreen0 equ *+1
	dta a(bufScreen0),b($5),b($85),b($5),b($5),b($85),b($5),b($5),b($85),b($5),b($5)
	dta b($85),b($10)
	dta b($4d),a(bufProgressBar),b($d),b($d),b($d),b($d),b($d),b($d),b($d)
	dta b($41),a(dataPlayfieldDlist)
	
	org dataPlayfieldDlist2		; titleScreen transition
	dta b($50),b($45)
	dta a(bufScreen0)
	dta b($5),b($5),b($5),b($5),b($5),b($5),b($5),b($5),b($5),b($5),b($5),b($5),b($5),b($10)
	dta b($41),a(dataPlayfieldDlist2)
	
