function Button(x, y, t, tc, bc, tpc, bpc)
    
    local button = {}
    
    button.label = t or "Click Me"
    button.posX = x or 1
    button.posY = y or 1
    button.width = #button.label or 3
    button.height = 1
    button.colorNormal = bc or colors.blue
    button.colorPressed = bpc or colors.red
    button.textColorNormal = tc or colors.white
    button.textColorPressed = tpc or colors.yellow
    button.isPressed = false
    button.justDrawn = true
    button.func = function ()
        print("No function set yet")
    end
    
    --getter method
    function button.get(property)
        return button[property]
    end

    --setter methods
    function button.set(property, value)
        button[property] = value
    end
    
    --changes the state of the button when pressed
    function button.pressed()
        button.isPressed = not button.isPressed
    end
    
    --checks if the button was clicked or not
    function button.clicked(column, row)
        return (column >= button.posX and column < button.posX + button.width and row >= button.posY and row < button.posY + button.height)
    end
    
    --draws the button
    function button.draw(mon)
    --gets the screen size
        local x, y = mon.getSize()
        
        --if no x position specified
        if button.width < #button.label then
            button.width = #button.label
        end

        if button.justDrawn then
            if not button.posX then
                button.posX = math.ceil(x/2) - math.floor(button.width/2)
            else
                button.posX = button.posX - math.floor(button.width/2)
            end
        
            --if no y position specified
            if not button.posY then
                button.posY = math.ceil(y/2)
            end
            
            button.justDrawn = false
        end
        
        --checks if the button has been pressed or not
        if button.isPressed then
            mon.setBackgroundColor(button.colorPressed)
            mon.setTextColor(button.textColorPressed)
        else
            mon.setBackgroundColor(button.colorNormal)
            mon.setTextColor(button.textColorNormal)
        end
        
        --Draw Background
        for i=0, button.height-1, 1 do
            mon.setCursorPos(button.posX, button.posY+i)
            mon.write(string.rep(" ", button.width))
        end
        
        --Draw the Label
        mon.setCursorPos(button.posX+math.ceil((button.width-#button.label)/2), button.posY+math.ceil(button.height/2)-1)
        mon.write(button.label)
    end
    
    --toggles the button on then off again
    function button.toggle(mon)
        button.pressed()
        button.draw(mon)
        sleep(0.2)
        button.pressed()
        button.draw(mon)
    end
    
    return button
end
