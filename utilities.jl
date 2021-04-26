include("world.jl")

function between(x, vals)
    return (x > vals[1]) & (x < vals[2]) ? true : false
end

## This is supposed to draw a gradient representing gravity but its soo slow
# function drawGravity!(ball_image::Array, gravity::GravSource)
#     maxd = 150
#     color = [199, 29, 26] / 255.
#     c = gravity.epicenter
#     for i in 1:size(ball_image)[1]
#         for j in 1:size(ball_image)[2]
#             d = sqrt((i-c[1])^2 + (j-c[2])^2)
#             ball_image[i,j,:] = color * max(0, (maxd-d)/maxd)^2
#         end
#     end
# end

function drawGravity!(ball_image::Array, gravity::GravSource)
    dotsize = 5
    color = [199, 29, 26] / 255.
    c = gravity.epicenter 
    x1 = max(round(Int, c[1]-dotsize), 1)
    x2 = min(round(Int, c[1]+dotsize), size(ball_image)[1])
    y1 = max(round(Int, c[2]-dotsize), 1)
    y2 = min(round(Int, c[2]+dotsize), size(ball_image)[2])
    ball_image[x1:x2,y1:y2,1] .= color[1]
    ball_image[x1:x2,y1:y2,2] .= color[2]
    ball_image[x1:x2,y1:y2,3] .= color[3]
end
