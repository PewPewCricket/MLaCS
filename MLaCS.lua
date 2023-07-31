local term = require("term")
local color = require("colors")
local component = require("component")
local text = require("text")
local shell = require("shell")
local launch = component.getPrimary("launch_pad")
--define variables
local X = nil
local Z = nil
--local yield = nil

--text printing
::start::
term.clear()
print("\27[32mMissile Launch and Control System v1.0\27[0m")
os.sleep(1)
print(" ")
print(" ")
print(" ")
print("\27[33mPlease Select An Option\27[0m")
print(" ")
print("1: Begin Launch Sequence")
print("2: [Removed]")
print("3: Target Selection")
print("4: Configuration")
print("5: Exit")
print(" ")

--input

local userInput = io.read()
if userInput == "1" then
  -- Launch
  local rightCodes = false
  term.clear()
  io.write("Please input launch codes: ")
  local codes = io.read()
  if codes == "EJK1037PDJ" then
    term.setCursor(1, 3)
    rightCodes = true
  end
  if rightCodes == false then
    term.setCursor(1, 3)
    io.stderr:write("invalid codes")
    term.clear()
    goto start
  end
  os.sleep(0.5)
  print("Authentication: complete")
  if X == nil or Z == nil then
    print("Target selection: failed")
    os.sleep(1)
    goto start
  end
  launch.setCoords(X, Y)
  print("Target selection: complete")
  os.sleep(0.5)
  io.write("Current energy level: ")
  io.write(launch.getEnergyStored())
  term.setCursor(1, 7)
  print("Are you sure you want to launch? (y/n)")
  local finalAuth = io.read()
  if finalAuth == "n" then
    term.setCursor(1, 9)
    print("returning...")
    os.sleep(1)
  elseif finalAuth == "y" then
    term.setCursor(1, 9)
    print("Launching...")
    os.sleep(1)
    launch.launch()
    os.sleep(1)
    goto start
  end
  
  elseif userInput == "2" then
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
    goto start
    
  elseif userInput == "3" then
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
    end
    os.sleep(0.2)
    term.setCursor(1, 5)
    print("Target Selected")
    os.sleep(1)
    goto start
    
  elseif userInput == "4" then
  --config
  print("returning...")
  os.sleep(0.4)
  goto start
  
  elseif userInput == "5" then
  --exit
    term.clear()
    os.exit()
    
  else
    io.stderr:write("invalid input")
    os.sleep(1)
    goto start
    
end
