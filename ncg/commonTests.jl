import Base.Test

ex=:x+:y-3
@test expression(addparse(ex))==ex

ex1=simplify(1+:x*2-1)
ex2=push!(2,:x)
@test ex1==ex2

