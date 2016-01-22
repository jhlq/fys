function volume(r,db,r0=1) #r is distance, db is original volume at r0, r0 is distance from mike to soundsource.
	db+10log(10,(r0/r)^2)
end
