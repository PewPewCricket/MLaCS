local term = require("term")
local component = require("component")
local data = require("data")
local fs = require("filesystem")
local launch = component.getPrimary("launch_pad")
--define variables
local X = nil
local Z = nil
--local yield = nil

--text printing
::start::
local energyLevel = launch.getEnergyStored()
term.clear()
print("\27[32mMissile Launch and Control System v1.2\27[0m")
os.sleep(1)
print(" ")
print(" ")
print(" ")
print("\27[33mPlease Select An Option\27[0m")
print(" ")
print("1: Begin Launch Sequence")
print("2: Target Selection")
print("3: Configuration")
print("4: Exit")
print(" ")

--input

local userInput = io.read()
if userInput == "1" then
  -- Launch
  local codesCheck = false
  term.clear()
  io.write("Please input launch codes: ")
  local codesInput = io.read()
  
  if codesInput == launchCodes then
    term.setCursor(1, 3)
    codesCheck = true
  end
  
  if codesCheck == false then
    term.setCursor(1, 3)
    io.stderr:write("invalid codes")
    os.sleep(1)
    term.clear()
    goto start
  end
  
  os.sleep(0.5)
  print("Authentication: complete")
  os.sleep(0.5)
  
  if X == nil or Z == nil then
    print("Target selection: failed")
    os.sleep(1)
    goto start
  else
    launch.setCoords(X, Z)
    print("Target selection: complete")
    os.sleep(0.5)
  end
  
  if energyLevel < 100000 then
    io.stderr:write("Energy level: insufficient")
    os.sleep(1)
    goto start
  else
    print("Energy level: sufficient")
    term.setCursor(1, 7)
    print("Are you sure you want to launch? (y/n)")
    local finalAuth = io.read()
  
    if finalAuth == "n" then
      term.setCursor(1, 9)
      print("returning...")
      os.sleep(1)
      goto start
    elseif finalAuth == "y" then
      term.setCursor(1, 9)
      print("Launching...")
      os.sleep(1)
      launch.launch()
      os.sleep(1)
      goto start
    else
      term.setCursor(1, 9)
      io.stderr:write("invalid input")
      goto start
    end
  end
  
  --elseif userInput == "removed" then
  --Yield selection
    --term.clear()
    --print("Please Select Yield (150-957kt)")
    --local syield = io.read()
    --yield = tonumber(syield)
    --if yield == nil then
      --yield = 0
      --io.stderr:write("invalid input")
      --os.sleep(1)
      --goto start
    --end
    --if yield > 957 then
      --yield = 0
      --io.stderr:write("invalid input")
      --os.sleep(1)
    --end
    --goto start
    
elseif userInput == "2" then
  --target select
  term.clear()
  print("Please select x and z position")
  io.write("X: ")
  local  sX = io.read()
  X = tonumber(sX)
  os.sleep(0.2)
  term.setCursor(1, 3)
  io.write("Z: ")
  local sZ = io.read()
  Z = tonumber(sZ)
    
  if X == nil or Z == nil then
    term.setCursor(1, 5)
    io.stderr:write("invalid input")
    os.sleep(1)
    goto start
  else
    os.sleep(0.2)
    term.setCursor(1, 5)
    print("Target Selected")
    os.sleep(1)
    goto start
  end
  
elseif userInput == "3" then
  --config
  ::config::
  term.clear()
  print("Please Select an Option:")
  term.setCursor(1, 3)
  print("1: Change launch codes")
  print("2: Back")
  term.setCursor(1, 6)
  userInputCfg = io.read()
    
  if userInputCfg == "1" then
    term.clear()
    local codesFile = io.open("/etc/Launchcodes.txt", "r")
    oldCodes = codesFile:read("*l")
    codesFile:close()
    io.write("Input current codes: ")
    local userCodesInput = io.read()
    if userCodesInput == oldCodes then
      term.setCursor(1, 3)
      local codesFile = io.open("/etc/Launchcodes.txt", "w")
      io.write("Input new codes: ")
      local newCodes = io.read()
      codesFile:write(newCodes)
      codesFile:close()
      os.sleep(0.5)
      term.setCursor(1, 5)
      print("Codes changed")
      os.sleep(1)
      goto config
    else
      term.setCursor(1, 5)
      io.stderr:write("Invalid codes")
      codesFile:close()
      os.sleep(1)
      goto config
    end
      
  elseif userInputCfg == "2" then
      os.sleep(1)
      goto start
    
  else
      term.setCursor(1, 8)
      io.stderr:write("invalid input")
      os.sleep(1)
      goto config
  end
    
elseif userInput == "4" then
  --exit
  term.clear()
  os.exit()
    
else
  io.stderr:write("invalid input")
  os.sleep(1)
  goto start
    
end
