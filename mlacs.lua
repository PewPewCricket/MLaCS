local term = require("term")
local component = require("component")
local data = component.data
local fs = require("filesystem")
local launch = component.getPrimary("launch_pad")
--define variables
local X = nil
local Z = nil
--local yield = nil
local launch_code

--Encryption functions for launch codes (gamma :3):
local function encrypt(info) -- i hate AES encryption, why does everything have to be 128 bit >:(
  local key = string.sub(component.computer.address, 0, 8) .. string.sub(component.data.address, 0, 8) -- generate a new key depending on the computer address
  local IV = string.sub(component.computer.address, 0, 8) .. string.sub(component.filesystem.address, 0, 8) -- generate an IV for additional security
  return data.encrypt(info, key, IV) -- return the encrypted data
end
local function decrypt(info)
  local key = string.sub(component.computer.address, 0, 8) .. string.sub(component.data.address, 0, 8) -- generate the (hopefully) existing key for decryption
  local IV  = string.sub(component.computer.address, 0, 8) .. string.sub(component.filesystem.address, 0, 8)
  return data.decrypt(info, key, IV) -- return the decrypted data
end

-- data checks just in-case
if not component.isAvailable("data") then
  print("A data card tier 2 or better is required, insert the card and then run again.")
  os.exit(-1)
end
if not fs.exists("/etc/Launchcodes.txt") then -- add a default key if none is present
  print("Populating code file for initial startup...")
  local f = io.open("/etc/Launchcodes.txt", "w")
  f:write(encrypt("a1b2c3")) --change this string to any default key you want, sadly can't be an empty string or 0 in a string.
  local f2 = io.open("/etc/checksum.txt", "w")
  f2:write(data.encode64(data.md5(encrypt("a1b2c3"))))
  f:close()
  f2:close()
  os.sleep(3)
  print("File populated, starting program...")
  os.sleep(1)
end
local f = io.open("/etc/Launchcodes.txt", "r")
local f2 = io.open("/etc/checksum.txt", "r")
if not(data.md5(f:read("*l")) == data.decode64(f2:read("*l"))) then
  print("Code checksum invalid, the launch codes have likely been tampered with. This program will not start, the key must be reset manually.")
  f2:close()
  f:close()
  fs.remove("/etc/checksum.txt")
  os.exit(-1)
end
f2:close()
f:close()
--end data checks

--text printing
::start::
local energyLevel = launch.getEnergyStored()
term.clear()
print("\27[32mMissile Launch and Control System v1.3a\27[0m")
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
  local codesFile = io.open("/etc/Launchcodes.txt", "r")
  launch_code = decrypt(codesFile:read("*l"))
  codesFile:close()

  if codesInput == launch_code then
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
    oldCodes = decrypt(codesFile:read("*l"))
    codesFile:close()
    io.write("Input current codes: ")
    local userCodesInput = io.read()
    if userCodesInput == oldCodes then
      term.setCursor(1, 3)
      io.write("Input new codes: ")
      local newCodes = io.read()
      fs.remove("/etc/Launchcodes.txt")
      fs.remove("/etc/checksum.txt")
      codesFile = io.open("/etc/Launchcodes.txt", "w")
      local chksum = io.open("/etc/checksum.txt", "w")
      codesFile:write(encrypt(newCodes))
      codesFile:close()
      codesFile = io.open("/etc/Launchcodes.txt", "r")
      chksum:write(data.encode64(data.md5(codesFile:read("*l"))))
      codesFile:close()
      chksum:close()
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
