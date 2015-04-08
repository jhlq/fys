import Base.Test

ex=:x+:y-3
@test expression(addparse(ex))==ex

ex1=simplify(1+:x*2-1)
ex2=push!(2,:x)
@test ex1==ex2

ex1=1-:x+:x*:y
ex2=sumsym(1-:x+:x*:y)
@test ex1==ex2 

@test sumsym(1-:x+:x)==1
@test sumnum(1+:x-1)==:x
