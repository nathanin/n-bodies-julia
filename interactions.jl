using Logging
using DataFrames
using Printf
using Random

include("balls.jl")

function checkCollide(a::Ball, b::Ball)
    d = sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
    return d < (a.r + b.r) ? true : false
end

function findCollisions(balls::Array, collisions::Matrix)
    n_balls = length(balls)
    # @info "Finding collisions" n_balls
    new_collisions = zeros(Bool, size(collisions))

    for i in 1:n_balls
        a = balls[i]
        for j in i+1:n_balls
            b = balls[j]
            colliding = checkCollide(a,b)
            new_collisions[i,j] = colliding & !collisions[i,j]
            collisions[i,j] = colliding
        end
    end

    return new_collisions
end

#https://cnx.org/contents/U34hHQg1@1/Two-Body-Collision-Problem
#update the velocity vector of each ball according 
#to two-body perfectly elastic collision
function collideBalls!(a::Ball, b::Ball)
    # @info "Colliding balls" a b 
    m_a = a.mass
    m_b = b.mass
    vi_a = [a.v.x, a.v.y]
    vi_b = [b.v.x, b.v.y]
    dv_a = 2 * (m_b / (m_a+m_b)) * (vi_b - vi_a)
    dv_b = 2 * (m_a / (m_a+m_b)) * (vi_a - vi_b)
    vf_a = vi_a + dv_a
    vf_b = vi_b + dv_b

    a.v.x = vf_a[1]
    a.v.y = vf_a[2]

    b.v.x = vf_b[1]
    b.v.y = vf_b[2]
end

function collideAllBalls!(balls::Array, collisions::Matrix)
    n_balls = length(balls)
    for i in 1:n_balls
        for j in i+1:n_balls
            if collisions[i,j]
                collideBalls!(balls[i], balls[j])
            end
        end
    end
end