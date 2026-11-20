#Author: MLE_qwq | Version: v20261120154800

#this function scans whether the line of sight of @e[tag=current_shooter,limit=1] intersects with the hitbox of @s (size of hitbox configurated between lines 66 and 86), along with summoning a marker with tag "predicated_bullet_hit_pos" at the point where the line of sight first intersects with the hitbox. If positive, then the entity @s will be tagged "within_range" :3

#NOTE 0: every value is scaled by 1000 to handle decimals in this implementation
#NOTE 1: this function is 1-to-1 (1 ray vs 1 hitbox). you'll have to handle 1-to-multiple, or rather, multiple-to-multiple, on your own, sry again...
#NOTE 2: the following two commands below does the untagging of "within_range" from @s, and the removal of the "predicated_bullet_hit_pos" marker beforehand, if you dont want them to occur just disable them
    tag @s remove within_range
    kill @e[tag=predicated_bullet_hit_pos]

#learn details at a video in my youtube channel https://www.youtube.com/@MLE_qwq

#scoreboard objective init
    scoreboard objectives add const.1000 dummy
    scoreboard players set #const const.1000 1000
    scoreboard objectives add _ dummy
    scoreboard objectives add game.mechanism.gunshot_scan.shooter_eyes_x dummy
    scoreboard objectives add game.mechanism.gunshot_scan.shooter_eyes_y dummy
    scoreboard objectives add game.mechanism.gunshot_scan.shooter_eyes_z dummy
    scoreboard objectives add game.mechanism.gunshot_scan.target_feet_x dummy
    scoreboard objectives add game.mechanism.gunshot_scan.target_feet_y dummy
    scoreboard objectives add game.mechanism.gunshot_scan.target_feet_z dummy
    scoreboard objectives add game.mechanism.gunshot_scan.shooter_look_dir_x dummy
    scoreboard objectives add game.mechanism.gunshot_scan.shooter_look_dir_y dummy
    scoreboard objectives add game.mechanism.gunshot_scan.shooter_look_dir_z dummy
    scoreboard objectives add game.mechanism.gunshot_scan.x_bound_min dummy
    scoreboard objectives add game.mechanism.gunshot_scan.x_bound_max dummy
    scoreboard objectives add game.mechanism.gunshot_scan.y_bound_min dummy
    scoreboard objectives add game.mechanism.gunshot_scan.y_bound_max dummy
    scoreboard objectives add game.mechanism.gunshot_scan.z_bound_min dummy
    scoreboard objectives add game.mechanism.gunshot_scan.z_bound_max dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_x_0 dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_x_1 dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_y_0 dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_y_1 dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_z_0 dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_z_1 dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_x_min dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_x_max dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_y_min dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_y_max dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_z_min dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_z_max dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_enter dummy
    scoreboard objectives add game.mechanism.gunshot_scan.t_exit dummy
    scoreboard objectives add game.mechanism.gunshot_scan.hit_pos_x dummy
    scoreboard objectives add game.mechanism.gunshot_scan.hit_pos_y dummy
    scoreboard objectives add game.mechanism.gunshot_scan.hit_pos_z dummy


#obtaining coords of eyes of shooter, S
    execute as @e[tag=current_shooter,limit=1] at @s anchored eyes run summon marker ^ ^ ^ {Tags:["shooter_pos_det"]}
    execute store result score #global game.mechanism.gunshot_scan.shooter_eyes_x run data get entity @e[tag=shooter_pos_det,limit=1] Pos[0] 1000
    execute store result score #global game.mechanism.gunshot_scan.shooter_eyes_y run data get entity @e[tag=shooter_pos_det,limit=1] Pos[1] 1000
    execute store result score #global game.mechanism.gunshot_scan.shooter_eyes_z run data get entity @e[tag=shooter_pos_det,limit=1] Pos[2] 1000
    kill @e[tag=shooter_pos_det]

#obtaining coords of feet of target, T
    execute store result score #global game.mechanism.gunshot_scan.target_feet_x run data get entity @s Pos[0] 1000
    execute store result score #global game.mechanism.gunshot_scan.target_feet_y run data get entity @s Pos[1] 1000
    execute store result score #global game.mechanism.gunshot_scan.target_feet_z run data get entity @s Pos[2] 1000

#obtaing shooter looking direction vector, b - everything scaled by 1e3
    #obtaining coords starting from shooter moving 1 block along looking direction
        execute as @e[tag=current_shooter,limit=1] at @s anchored eyes run summon marker ^ ^ ^1 {Tags:["shooter_dir_det"]}
        execute store result score #global game.mechanism.gunshot_scan.shooter_look_dir_x run data get entity @e[tag=shooter_dir_det,limit=1] Pos[0] 1000
        execute store result score #global game.mechanism.gunshot_scan.shooter_look_dir_y run data get entity @e[tag=shooter_dir_det,limit=1] Pos[1] 1000
        execute store result score #global game.mechanism.gunshot_scan.shooter_look_dir_z run data get entity @e[tag=shooter_dir_det,limit=1] Pos[2] 1000
        kill @e[tag=shooter_dir_det]

    #subtracting coords by position of player
        scoreboard players operation #global game.mechanism.gunshot_scan.shooter_look_dir_x -= #global game.mechanism.gunshot_scan.shooter_eyes_x
        scoreboard players operation #global game.mechanism.gunshot_scan.shooter_look_dir_y -= #global game.mechanism.gunshot_scan.shooter_eyes_y
        scoreboard players operation #global game.mechanism.gunshot_scan.shooter_look_dir_z -= #global game.mechanism.gunshot_scan.shooter_eyes_z

#obtaining coord range of bounding box relative to shooter - bounding box: 1.0 * 1.85 * 1.0
    #x_min = (Tx - 0.5) - Sx
        scoreboard players operation #global game.mechanism.gunshot_scan.x_bound_min = #global game.mechanism.gunshot_scan.target_feet_x
        scoreboard players remove #global game.mechanism.gunshot_scan.x_bound_min 500
        scoreboard players operation #global game.mechanism.gunshot_scan.x_bound_min -= #global game.mechanism.gunshot_scan.shooter_eyes_x
    #x_max = (Tx + 0.5) - Sx
        scoreboard players operation #global game.mechanism.gunshot_scan.x_bound_max = #global game.mechanism.gunshot_scan.x_bound_min
        scoreboard players add #global game.mechanism.gunshot_scan.x_bound_max 1000
    #y_min = Ty - Sy
        scoreboard players operation #global game.mechanism.gunshot_scan.y_bound_min = #global game.mechanism.gunshot_scan.target_feet_y
        scoreboard players operation #global game.mechanism.gunshot_scan.y_bound_min -= #global game.mechanism.gunshot_scan.shooter_eyes_y
    #y_max = (Ty + 2) - Sy
        scoreboard players operation #global game.mechanism.gunshot_scan.y_bound_max = #global game.mechanism.gunshot_scan.y_bound_min
        scoreboard players add #global game.mechanism.gunshot_scan.y_bound_max 2000
    #z_min = (Tz - 0.5) - Sz
        scoreboard players operation #global game.mechanism.gunshot_scan.z_bound_min = #global game.mechanism.gunshot_scan.target_feet_z
        scoreboard players remove #global game.mechanism.gunshot_scan.z_bound_min 500
        scoreboard players operation #global game.mechanism.gunshot_scan.z_bound_min -= #global game.mechanism.gunshot_scan.shooter_eyes_z
    #z_max = (Tz + 0.5) - Sz
        scoreboard players operation #global game.mechanism.gunshot_scan.z_bound_max = #global game.mechanism.gunshot_scan.z_bound_min
        scoreboard players add #global game.mechanism.gunshot_scan.z_bound_max 1000

#let P be an arbitrary point along the ray starting from shooter eyes and in the facing direction, hence P = S + bt. If there is an existence of P inside the bounding box, we should be able to find a common value of t in all 3 dimensions, where t>=0.

#obtaining values of t at the points said to be which the ray enters and leaves the bounding box
    #t_x_0 = x_min / v_x
        scoreboard players operation #global game.mechanism.gunshot_scan.t_x_0 = #global game.mechanism.gunshot_scan.x_bound_min
        scoreboard players operation #global game.mechanism.gunshot_scan.t_x_0 *= #const const.1000
        scoreboard players operation #global game.mechanism.gunshot_scan.t_x_0 /= #global game.mechanism.gunshot_scan.shooter_look_dir_x
    #t_x_1 = x_max / v_x
        scoreboard players operation #global game.mechanism.gunshot_scan.t_x_1 = #global game.mechanism.gunshot_scan.x_bound_max
        scoreboard players operation #global game.mechanism.gunshot_scan.t_x_1 *= #const const.1000
        scoreboard players operation #global game.mechanism.gunshot_scan.t_x_1 /= #global game.mechanism.gunshot_scan.shooter_look_dir_x
    #t_y_0 = y_min / v_y
        scoreboard players operation #global game.mechanism.gunshot_scan.t_y_0 = #global game.mechanism.gunshot_scan.y_bound_min
        scoreboard players operation #global game.mechanism.gunshot_scan.t_y_0 *= #const const.1000
        scoreboard players operation #global game.mechanism.gunshot_scan.t_y_0 /= #global game.mechanism.gunshot_scan.shooter_look_dir_y
    #t_y_1 = y_max / v_y
        scoreboard players operation #global game.mechanism.gunshot_scan.t_y_1 = #global game.mechanism.gunshot_scan.y_bound_max
        scoreboard players operation #global game.mechanism.gunshot_scan.t_y_1 *= #const const.1000
        scoreboard players operation #global game.mechanism.gunshot_scan.t_y_1 /= #global game.mechanism.gunshot_scan.shooter_look_dir_y
    #t_z_0 = z_min / v_z
        scoreboard players operation #global game.mechanism.gunshot_scan.t_z_0 = #global game.mechanism.gunshot_scan.z_bound_min
        scoreboard players operation #global game.mechanism.gunshot_scan.t_z_0 *= #const const.1000
        scoreboard players operation #global game.mechanism.gunshot_scan.t_z_0 /= #global game.mechanism.gunshot_scan.shooter_look_dir_z
    #t_z_1 = z_max / v_z
        scoreboard players operation #global game.mechanism.gunshot_scan.t_z_1 = #global game.mechanism.gunshot_scan.z_bound_max
        scoreboard players operation #global game.mechanism.gunshot_scan.t_z_1 *= #const const.1000
        scoreboard players operation #global game.mechanism.gunshot_scan.t_z_1 /= #global game.mechanism.gunshot_scan.shooter_look_dir_z
    #t_x_min = min(t_x_0, t_x_1), repeat for max, y and z
        execute if score #global game.mechanism.gunshot_scan.t_x_0 <= #global game.mechanism.gunshot_scan.t_x_1 run scoreboard players operation #global game.mechanism.gunshot_scan.t_x_min = #global game.mechanism.gunshot_scan.t_x_0
        execute if score #global game.mechanism.gunshot_scan.t_x_0 <= #global game.mechanism.gunshot_scan.t_x_1 run scoreboard players operation #global game.mechanism.gunshot_scan.t_x_max = #global game.mechanism.gunshot_scan.t_x_1
        execute if score #global game.mechanism.gunshot_scan.t_x_0 > #global game.mechanism.gunshot_scan.t_x_1 run scoreboard players operation #global game.mechanism.gunshot_scan.t_x_min = #global game.mechanism.gunshot_scan.t_x_1
        execute if score #global game.mechanism.gunshot_scan.t_x_0 > #global game.mechanism.gunshot_scan.t_x_1 run scoreboard players operation #global game.mechanism.gunshot_scan.t_x_max = #global game.mechanism.gunshot_scan.t_x_0
        
        execute if score #global game.mechanism.gunshot_scan.t_y_0 <= #global game.mechanism.gunshot_scan.t_y_1 run scoreboard players operation #global game.mechanism.gunshot_scan.t_y_min = #global game.mechanism.gunshot_scan.t_y_0
        execute if score #global game.mechanism.gunshot_scan.t_y_0 <= #global game.mechanism.gunshot_scan.t_y_1 run scoreboard players operation #global game.mechanism.gunshot_scan.t_y_max = #global game.mechanism.gunshot_scan.t_y_1
        execute if score #global game.mechanism.gunshot_scan.t_y_0 > #global game.mechanism.gunshot_scan.t_y_1 run scoreboard players operation #global game.mechanism.gunshot_scan.t_y_min = #global game.mechanism.gunshot_scan.t_y_1
        execute if score #global game.mechanism.gunshot_scan.t_y_0 > #global game.mechanism.gunshot_scan.t_y_1 run scoreboard players operation #global game.mechanism.gunshot_scan.t_y_max = #global game.mechanism.gunshot_scan.t_y_0
        
        execute if score #global game.mechanism.gunshot_scan.t_z_0 <= #global game.mechanism.gunshot_scan.t_z_1 run scoreboard players operation #global game.mechanism.gunshot_scan.t_z_min = #global game.mechanism.gunshot_scan.t_z_0
        execute if score #global game.mechanism.gunshot_scan.t_z_0 <= #global game.mechanism.gunshot_scan.t_z_1 run scoreboard players operation #global game.mechanism.gunshot_scan.t_z_max = #global game.mechanism.gunshot_scan.t_z_1
        execute if score #global game.mechanism.gunshot_scan.t_z_0 > #global game.mechanism.gunshot_scan.t_z_1 run scoreboard players operation #global game.mechanism.gunshot_scan.t_z_min = #global game.mechanism.gunshot_scan.t_z_1
        execute if score #global game.mechanism.gunshot_scan.t_z_0 > #global game.mechanism.gunshot_scan.t_z_1 run scoreboard players operation #global game.mechanism.gunshot_scan.t_z_max = #global game.mechanism.gunshot_scan.t_z_0
    #edge cases: a component in direction vector is zero?
        #note: before this, x/y/z_bound_min/max is relative to the shooter, while we now need them to be relative to (0,0,0). hence add the shooter eye coords to them, and then substract afterwards.
        #converting x/y/z_bound_min/max from being relative to the shooter into being relative to (0,0,0)
            scoreboard players operation #global game.mechanism.gunshot_scan.x_bound_min += #global game.mechanism.gunshot_scan.shooter_eyes_x
            scoreboard players operation #global game.mechanism.gunshot_scan.y_bound_min += #global game.mechanism.gunshot_scan.shooter_eyes_y
            scoreboard players operation #global game.mechanism.gunshot_scan.z_bound_min += #global game.mechanism.gunshot_scan.shooter_eyes_z
            scoreboard players operation #global game.mechanism.gunshot_scan.x_bound_max += #global game.mechanism.gunshot_scan.shooter_eyes_x
            scoreboard players operation #global game.mechanism.gunshot_scan.y_bound_max += #global game.mechanism.gunshot_scan.shooter_eyes_y
            scoreboard players operation #global game.mechanism.gunshot_scan.z_bound_max += #global game.mechanism.gunshot_scan.shooter_eyes_z
        #v_x = 0
            execute if score #global game.mechanism.gunshot_scan.shooter_look_dir_x matches 0 run scoreboard players set #global game.mechanism.gunshot_scan.t_x_min 1
            execute if score #global game.mechanism.gunshot_scan.shooter_look_dir_x matches 0 run scoreboard players set #global game.mechanism.gunshot_scan.t_x_max 0
            execute if score #global game.mechanism.gunshot_scan.shooter_look_dir_x matches 0 if score #global game.mechanism.gunshot_scan.shooter_eyes_x >= #global game.mechanism.gunshot_scan.x_bound_min if score #global game.mechanism.gunshot_scan.shooter_eyes_x <= #global game.mechanism.gunshot_scan.x_bound_max run scoreboard players set #global game.mechanism.gunshot_scan.t_x_min -2147483648
            execute if score #global game.mechanism.gunshot_scan.shooter_look_dir_x matches 0 if score #global game.mechanism.gunshot_scan.shooter_eyes_x >= #global game.mechanism.gunshot_scan.x_bound_min if score #global game.mechanism.gunshot_scan.shooter_eyes_x <= #global game.mechanism.gunshot_scan.x_bound_max run scoreboard players set #global game.mechanism.gunshot_scan.t_x_max 2147483647
        #v_y = 0
            execute if score #global game.mechanism.gunshot_scan.shooter_look_dir_y matches 0 run scoreboard players set #global game.mechanism.gunshot_scan.t_y_min 1
            execute if score #global game.mechanism.gunshot_scan.shooter_look_dir_y matches 0 run scoreboard players set #global game.mechanism.gunshot_scan.t_y_max 0
            execute if score #global game.mechanism.gunshot_scan.shooter_look_dir_y matches 0 if score #global game.mechanism.gunshot_scan.shooter_eyes_y >= #global game.mechanism.gunshot_scan.y_bound_min if score #global game.mechanism.gunshot_scan.shooter_eyes_y <= #global game.mechanism.gunshot_scan.y_bound_max run scoreboard players set #global game.mechanism.gunshot_scan.t_y_min -2147483648
            execute if score #global game.mechanism.gunshot_scan.shooter_look_dir_y matches 0 if score #global game.mechanism.gunshot_scan.shooter_eyes_y >= #global game.mechanism.gunshot_scan.y_bound_min if score #global game.mechanism.gunshot_scan.shooter_eyes_y <= #global game.mechanism.gunshot_scan.y_bound_max run scoreboard players set #global game.mechanism.gunshot_scan.t_y_max 2147483647
        #v_z = 0
            execute if score #global game.mechanism.gunshot_scan.shooter_look_dir_z matches 0 run scoreboard players set #global game.mechanism.gunshot_scan.t_z_min 1
            execute if score #global game.mechanism.gunshot_scan.shooter_look_dir_z matches 0 run scoreboard players set #global game.mechanism.gunshot_scan.t_z_max 0
            execute if score #global game.mechanism.gunshot_scan.shooter_look_dir_z matches 0 if score #global game.mechanism.gunshot_scan.shooter_eyes_z >= #global game.mechanism.gunshot_scan.z_bound_min if score #global game.mechanism.gunshot_scan.shooter_eyes_z <= #global game.mechanism.gunshot_scan.z_bound_max run scoreboard players set #global game.mechanism.gunshot_scan.t_z_min -2147483648
            execute if score #global game.mechanism.gunshot_scan.shooter_look_dir_z matches 0 if score #global game.mechanism.gunshot_scan.shooter_eyes_z >= #global game.mechanism.gunshot_scan.z_bound_min if score #global game.mechanism.gunshot_scan.shooter_eyes_z <= #global game.mechanism.gunshot_scan.z_bound_max run scoreboard players set #global game.mechanism.gunshot_scan.t_z_max 2147483647
        #in addition, if eye coords within hitbox in all three dimensions, immediately pass - this is not inside the edge case but is put here because we needed x/y/z_bound_min/max to be relative to (0,0,0)
            execute if score #global game.mechanism.gunshot_scan.shooter_eyes_x >= #global game.mechanism.gunshot_scan.x_bound_min if score #global game.mechanism.gunshot_scan.shooter_eyes_x <= #global game.mechanism.gunshot_scan.x_bound_max if score #global game.mechanism.gunshot_scan.shooter_eyes_y >= #global game.mechanism.gunshot_scan.y_bound_min if score #global game.mechanism.gunshot_scan.shooter_eyes_y <= #global game.mechanism.gunshot_scan.y_bound_max if score #global game.mechanism.gunshot_scan.shooter_eyes_z >= #global game.mechanism.gunshot_scan.z_bound_min if score #global game.mechanism.gunshot_scan.shooter_eyes_z <= #global game.mechanism.gunshot_scan.z_bound_max run tag @s add within_range
        #converting x/y/z_bound_min/max back to being relative to the shooter
            scoreboard players operation #global game.mechanism.gunshot_scan.x_bound_min -= #global game.mechanism.gunshot_scan.shooter_eyes_x
            scoreboard players operation #global game.mechanism.gunshot_scan.y_bound_min -= #global game.mechanism.gunshot_scan.shooter_eyes_y
            scoreboard players operation #global game.mechanism.gunshot_scan.z_bound_min -= #global game.mechanism.gunshot_scan.shooter_eyes_z
            scoreboard players operation #global game.mechanism.gunshot_scan.x_bound_max -= #global game.mechanism.gunshot_scan.shooter_eyes_x
            scoreboard players operation #global game.mechanism.gunshot_scan.y_bound_max -= #global game.mechanism.gunshot_scan.shooter_eyes_y
            scoreboard players operation #global game.mechanism.gunshot_scan.z_bound_max -= #global game.mechanism.gunshot_scan.shooter_eyes_z
    
    #t_enter = max(t_x/y/z_min), t_exit = min(t_x/y/z_max)
        scoreboard players operation #global game.mechanism.gunshot_scan.t_enter = #global game.mechanism.gunshot_scan.t_x_min
        execute if score #global game.mechanism.gunshot_scan.t_y_min > #global game.mechanism.gunshot_scan.t_enter run scoreboard players operation #global game.mechanism.gunshot_scan.t_enter = #global game.mechanism.gunshot_scan.t_y_min
        execute if score #global game.mechanism.gunshot_scan.t_z_min > #global game.mechanism.gunshot_scan.t_enter run scoreboard players operation #global game.mechanism.gunshot_scan.t_enter = #global game.mechanism.gunshot_scan.t_z_min

        scoreboard players operation #global game.mechanism.gunshot_scan.t_exit = #global game.mechanism.gunshot_scan.t_x_max
        execute if score #global game.mechanism.gunshot_scan.t_y_max < #global game.mechanism.gunshot_scan.t_exit run scoreboard players operation #global game.mechanism.gunshot_scan.t_exit = #global game.mechanism.gunshot_scan.t_y_max
        execute if score #global game.mechanism.gunshot_scan.t_z_max < #global game.mechanism.gunshot_scan.t_exit run scoreboard players operation #global game.mechanism.gunshot_scan.t_exit = #global game.mechanism.gunshot_scan.t_z_max

#if t_enter <= t_exit AND t_enter>=0, then there is a solution, the ray passes through the bounding box
    execute if score #global game.mechanism.gunshot_scan.t_enter <= #global game.mechanism.gunshot_scan.t_exit if score #global game.mechanism.gunshot_scan.t_enter matches 0.. run tag @s add within_range

    #calculate bullet hit position: pos = S + bt
        scoreboard players operation #global game.mechanism.gunshot_scan.hit_pos_x = #global game.mechanism.gunshot_scan.t_enter
        scoreboard players operation #global game.mechanism.gunshot_scan.hit_pos_x *= #global game.mechanism.gunshot_scan.shooter_look_dir_x
        scoreboard players operation #global game.mechanism.gunshot_scan.hit_pos_x /= #const const.1000
        scoreboard players operation #global game.mechanism.gunshot_scan.hit_pos_x += #global game.mechanism.gunshot_scan.shooter_eyes_x

        scoreboard players operation #global game.mechanism.gunshot_scan.hit_pos_y = #global game.mechanism.gunshot_scan.t_enter
        scoreboard players operation #global game.mechanism.gunshot_scan.hit_pos_y *= #global game.mechanism.gunshot_scan.shooter_look_dir_y
        scoreboard players operation #global game.mechanism.gunshot_scan.hit_pos_y /= #const const.1000
        scoreboard players operation #global game.mechanism.gunshot_scan.hit_pos_y += #global game.mechanism.gunshot_scan.shooter_eyes_y

        scoreboard players operation #global game.mechanism.gunshot_scan.hit_pos_z = #global game.mechanism.gunshot_scan.t_enter
        scoreboard players operation #global game.mechanism.gunshot_scan.hit_pos_z *= #global game.mechanism.gunshot_scan.shooter_look_dir_z
        scoreboard players operation #global game.mechanism.gunshot_scan.hit_pos_z /= #const const.1000
        scoreboard players operation #global game.mechanism.gunshot_scan.hit_pos_z += #global game.mechanism.gunshot_scan.shooter_eyes_z

    execute if entity @s[tag=within_range] run summon marker ~ ~ ~ {Tags:["predicated_bullet_hit_pos","newbie"],CustomName:"Predicated Bullet Hitting Position"}
    execute store result entity @e[tag=predicated_bullet_hit_pos,tag=newbie,limit=1] Pos[0] double 0.001 run scoreboard players get #global game.mechanism.gunshot_scan.hit_pos_x
    execute store result entity @e[tag=predicated_bullet_hit_pos,tag=newbie,limit=1] Pos[1] double 0.001 run scoreboard players get #global game.mechanism.gunshot_scan.hit_pos_y
    execute store result entity @e[tag=predicated_bullet_hit_pos,tag=newbie,limit=1] Pos[2] double 0.001 run scoreboard players get #global game.mechanism.gunshot_scan.hit_pos_z


    #enable the command below to display particles at the point where line of sight first intersects with hitbox
        #execute as @e[tag=predicated_bullet_hit_pos,tag=newbie] at @s run particle happy_villager

    tag @e[tag=predicated_bullet_hit_pos] remove newbie