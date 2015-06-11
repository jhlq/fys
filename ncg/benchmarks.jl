function f1(ex)
   ap=addparse(ex)
   for term in ap
       for fac in term
           print(fac)
       end
       print(:+)
   end
end
function f2(ex)
   for term in ex
       for fac in term
           print(fac)
       end
       print(:+)
   end
end
ex=componify((:a+:b)^5)
@time f1(ex)
@time f2(ex)

