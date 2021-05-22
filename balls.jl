using Logging
using Random
include("world.jl")
include("utilities.jl")

mutable struct Velocity
    x::Float64
    y::Float64
end

mutable struct Acceleration
    x::Float64
    y::Float64
end

mutable struct Ball
    name::String
    x::Float64
    y::Float64
    r::Float64
    v::Velocity
    a::Acceleration
    mass::Float64
    id::Int64
end

function moveBall!(ball, world::World, dt::Float64=1.0)
    # Update velocity based on acceleration
    vx = ball.v.x + ball.a.x*dt
    vy = ball.v.y + ball.a.y*dt

    # Get the current velocity and position step
    newx = ball.x + vx*dt
    newy = ball.y + vy*dt
    if !(between(newx, world.bounds) & between(newy, world.bounds))
        vx = -vx*0.9
        vy = -vy*0.9
        newx = ball.x + vx*dt
        newy = ball.y + vy*dt
        # @warn "Saved ball from falling off the world" ball
    end
    
    # Update acceleration vector
    gx, gy = calcGravity((newx,newy), world.gravity)
    ball.a.x = gx
    ball.a.y = gy
    ball.v.x = vx
    ball.v.y = vy
    ball.x = newx
    ball.y = newy
end

# We've already set parameters according to t-1. 
# This updates positions for each ball individually
function moveAllBalls!(balls::Array, world::World, dt::Float64=1.0)
    Threads.@threads for i in 1:length(balls)
        moveBall!(balls[i], world, dt)
    end
end

function drawBalls!(ball_image::Array, balls::Array, world_bounds::Array, scale::Int=5)
    # ball_image = zeros(Bool, world_bounds[2], world_bounds[2], 3)
    for ball in balls
        x=floor(Int, ball.x)
        y=floor(Int, ball.y)
        r=floor(Int, ball.r)
        x1=max(ceil(Int, x-r/2), 1)
        x2=min(ceil(Int, x+r/2), world_bounds[2])
        y1=max(ceil(Int, y-r/2), 1)
        y2=min(ceil(Int, y+r/2), world_bounds[2])
        try
            ball_image[x1:x2,y1:y2,:] .= 1
        catch
            @warn "Failed recording ball in image" ball x1 x2 y1 y2
        end
    end
end