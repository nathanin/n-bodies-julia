using Logging
using Random
using DataFrames
using DelimitedFiles
using Images

include("balls.jl")
include("interactions.jl")
include("utilities.jl")
include("world.jl")

ball_names = readdlm("ball-names.txt", String)
n_balls = 2
ball_scale = 12
density = 0.2
ball_spread = 500
world_size = 500
world_bounds = [1, world_size]

initial_velocity_mag = 4
grav_mag = 0.5
gravity = GravSource([world_size/2, world_size/2], grav_mag)
@info gravity

# gx, gy = makeGravityField(gravity, world_size)
# @info "Gravity" gx gy

rng = MersenneTwister(5)
balls = Array{Any}(nothing, n_balls)
world = World(world_bounds, gravity)
@info world

collisions = zeros(Bool, n_balls, n_balls)

for i in 1:n_balls
    # name = ball_names[i]
    name = rand(ball_names)
    x=world_bounds[1]-1
    y=world_bounds[1]-1
    while !(between(x, world_bounds) & between(x, world_bounds) & (sum(collisions)==0))
        x = rand(rng) * ball_spread
        y = rand(rng) * ball_spread
        # r = max(3.0, rand(rng) * ball_scale)
        r = 10
        gx, gy = calcGravity((x,y), gravity)
        vx = randn(rng) * initial_velocity_mag
        vy = randn(rng) * initial_velocity_mag
        velo = Velocity(vx,vy)
        accel = Acceleration(gx,gy)
        balls[i] = Ball(name, x, y, r, velo, accel, (pi*r^2)*density, i)
        if i > 1
            _ = findCollisions(balls[1:i], collisions)
        end
    end
    @info "Created Ball" balls[i]
end

dt = 0.05
# ball_image = zeros(Float64, world_bounds[2], world_bounds[2], 3)
for i in 1:7500
    outf = string("balls/balls",lpad(i,5,"0"),".png")
    moveAllBalls!(balls, world, dt)

    new_collisions = findCollisions(balls, collisions)
    collideAllBalls!(balls, new_collisions)

    if i % 10 == 0
        num_collisions = sum(new_collisions)
        ball_image = zeros(Float64, world_bounds[2], world_bounds[2], 3)
        drawGravity!(ball_image, world.gravity)
        drawBalls!(ball_image, balls, world_bounds, 5)
        # @info "saving ball image" size(ball_image) typeof(ball_image) outf
        #save(outf, colorview(RGB, ball_image))
        save(outf, ball_image)
        @info "Stepped" i outf num_collisions
    end

    # #if abs(randn()) > 2.5
    # if mod(i+1, 2000) == 0
    #     grav_x = min(max(2, rand(rng) * world_size), world_size-2)
    #     grav_y = min(max(2, rand(rng) * world_size), world_size-2)
    #     world.gravity = GravSource([grav_x, grav_y], grav_mag)
    # end
end

@info "Done!"