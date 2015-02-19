include("common.jl")

abstract Vec <: Component
type Vec2D <: Vec
	angle
	length
end

v=Vec2D(0,:l1)
w=Vec2D(:θ,:l2)
