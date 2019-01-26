home = {}

function home.create(collider,radius)
    ourHome={}
    ourHome.radius=radius
    ourHome.shape=collider:circle(150,150,ourHome.radius)
    ourHome.sprite=love.graphics.newImage('graphisme/test.png')
    return ourHome
return home
