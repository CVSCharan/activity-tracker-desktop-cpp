# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "ActivityTracker_autogen"
  "CMakeFiles\\ActivityTracker_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\ActivityTracker_autogen.dir\\ParseCache.txt"
  "CMakeFiles\\tst_ActivityModel_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\tst_ActivityModel_autogen.dir\\ParseCache.txt"
  "tst_ActivityModel_autogen"
  )
endif()
