function Erev(T,z,Cint,Cext)
	K=1.4*10.0^-23
	ec=1.6*10.0^-19
	er=-K*T/(z*ec)*log(Cint/Cext)
	return er
end
