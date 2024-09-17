ExterShared = {}
ExterShared.Functions = {}

ExterShared.Functions.Trim = function(str)
   return (str:gsub("^%s*(.-)%s*$", "%1"))
end

ExterShared.Functions.Capitalize = function(str) 
   return string.upper(str:sub(1,1)) .. str:sub(2)
end

ExterShared.Functions.Includes = function(arr, target)
   local includes = false
    
   for _, v in ipairs(arr) do 
      if v == target then 
         includes = true
      end
   end

   return includes
end

ExterShared.Functions.GetFramework = function() 
   local availableFramework = nil

   for k,v in ipairs(ExterShared.Types.Frameworks) do
      if GetResourceState(v.ResourceName) ~= "missing" then 
         availableFramework = v
      end
   end

   if not availableFramework then 
      ExterShared.Functions.Log("^1Could not find a supported framework! Please ensure that framework script name did not got change.^7")
   end

   return availableFramework
end 

ExterShared.Functions.GetDatabase = function() 
   local availableDatabase = nil

   for k,v in ipairs(ExterShared.Types.Databases) do 
      if GetResourceState(v.ResourceName) ~= "missing" then 
         availableDatabase = v
      end
   end

   if not availableDatabase then 
      ExterShared.Functions.Log("^1Could not find a supported database! Please ensure that database script name did not got change.^7")
   end

   return availableDatabase
end 

ExterShared.Functions.Log = function(str) 
   print("^4[exter_core]^7: " .. ExterShared.Functions.Trim(str))
end