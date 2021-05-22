using Logging
using Random
using DataFrames
using DelimitedFiles
using Images
using LinearAlgebra

include("balls.jl")
include("interactions.jl")
include("utilities.jl")
include("world.jl")

ball_names = readdlm("ball-names.txt", String)
n_balls = 25
ball_scale = 5
density = 0.2
ball_spread = 256
world_size = 256
world_bounds = [1, world_size]

initial_velocity_mag = 3
grav_mag = 0.01
gravity = GravSource([world_size/2, world_size/2], grav_mag)
@info gravity

rng = MersenneTwister(777)
balls = Array{Any}(nothing, n_balls)
world = World(world_bounds, gravity)
@info world

collisions = zeros(Bool, n_balls, n_balls)

for i in 1:n_balls
    # name = ball_names[i]
    name = rand(ball_names)
    x=world_bounds[1]-1
    y=world_bounds[1]-1
    # Start without any colliding balls.
    while !(between(x, world_bounds) & between(x, world_bounds) & (sum(collisions)==0))
        x = rand(rng) * ball_spread
        y = rand(rng) * ball_spread

        r = max(2.0, rand(rng) * ball_scale)
        # r = 5
        gx, gy = calcGravity((x,y), gravity)
        accel = Acceleration(gx,gy)

        # vx = randn(rng) * initial_velocity_mag
        # vy = randn(rng) * initial_velocity_mag
        # velo = Velocity(vx,vy)

        ## Set initial velocity orthogonal to gravity vector
        v = nullspace(reshape([gx,gy], (1,2))) * initial_velocity_mag
        velo = Velocity(v[1],v[2])

        balls[i] = Ball(name, x, y, r, velo, accel, (pi*r^2)*density, i)

        if i > 1
            _, _ = findCollisions!(balls[1:i], collisions)
        end
    end
    # @info "Created Ball" balls[i]
end

@info "Done creating balls"
dt = 0.1
# ball_image = zeros(Float64, world_bounds[2], world_bounds[2], 3)
for i in 1:10000
    outf = string("balls/balls",lpad(i,5,"0"),".png")

    new_collisions, _ = findCollisions!(balls, collisions)
    collideAllBalls!(balls, new_collisions)

    moveAllBalls!(balls, world, dt)

    if i % 5 == 0
        num_collisions = sum(new_collisions)
        ball_image = zeros(Float64, world_bounds[2], world_bounds[2], 3)
        drawGravity!(ball_image, world.gravity)
        drawBalls!(ball_image, balls, world_bounds, 5)
        # @info "saving ball image" size(ball_image) typeof(ball_image) outf
        #save(outf, colorview(RGB, ball_image))
        save(outf, ball_image)
        # @info "Stepped" i outf num_collisions
    end

    #if abs(randn()) > 2.5
    if mod(i+1, 5000) == 0
        grav_x = min(max(2, rand(rng) * world_size), world_size-2)
        grav_y = min(max(2, rand(rng) * world_size), world_size-2)
        world.gravity = GravSource([grav_x, grav_y], grav_mag)
        @info "Updated gravity source" grav_x grav_y
    end
end

@info "Done!"