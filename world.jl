
struct GravSource
    epicenter::Array # 2-vector: (x,y)-coordinates
    magnitude::Float64
end

mutable struct World
    bounds::Array 
    gravity::GravSource
    # gx::Matrix
    # gy::Matrix
end

function makeGravityField(grav::GravSource, world_size::Int)
    gx = zeros(Float64, (world_size, world_size))
    gy = zeros(Float64, (world_size, world_size))

    #vectorize this
    for i in 1:world_size
        for j in 1:world_size
            x = i - grav.epicenter[1]
            y = j - grav.epicenter[2]
            theta = atan(x/y)
            gx[i,j] = grav.magnitude * sin(theta)
            gy[i,j] = grav.magnitude * cos(theta)
        end
    end
    return gx, gy
end

function calcGravity(coord::Tuple, grav::GravSource)
    x = coord[1] - grav.epicenter[1]
    y = coord[2] - grav.epicenter[2]
    theta = atan(x,y) 
    gx = -grav.magnitude * sin(theta)
    gy = -grav.magnitude * cos(theta)

    return gx, gy
end