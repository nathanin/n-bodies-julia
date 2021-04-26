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
    dvx = ball.a.x*dt
    dvy = ball.a.y*dt
    ball.v.x += dvx
    ball.v.y += dvy

    # Get the current velocity and position step
    dx = ball.v.x*dt
    dy = ball.v.y*dt
    newx = ball.x + dx
    newy = ball.y + dy
    if !(between(newx, world.bounds) & between(newy, world.bounds))
        ball.v.x = -ball.v.x*0.9
        ball.v.y = -ball.v.y*0.9
        dx = ball.v.x*dt
        dy = ball.v.y*dt
        newx = ball.x + dx
        newy = ball.y + dy
        # @warn "Saved ball from falling off the world" ball
    end
    ball.x = newx
    ball.y = newy
    
    # Update acceleration vector
    gx, gy = calcGravity((newx,newy), world.gravity)
    ball.a.x = gx
    ball.a.y = gy

    # @info "Moved ball " ball.name dx dy ball.x ball.y
end

function moveAllBalls!(balls::Array, world::World, dt::Float64=1.0)
    for ball in balls
        moveBall!(ball, world, dt)
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