function indin(array,item)
	ind=0
	for it in array
		ind+=1
		if it==item
			return ind
		end
	end
	return 0
end
function indsin(array,item)
	ind=Int64[]
	for it in 1:length(array)
		if array[it]==item
			push!(ind,it)
		end
	end
	return ind
end
