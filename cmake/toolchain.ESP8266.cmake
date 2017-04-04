set(CMAKE_SYSTEM_NAME ESP8266)
set(CMAKE_SYSTEM_VERSION 1)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/Modules")

if(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
    set(USER_HOME $ENV{HOME})
    set(HOST_EXECUTABLE_PREFIX "")
    set(ESP8266_ESPTOOL_COM_PORT /dev/ttyUSB0 CACHE STRING "COM port to be used by esptool")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
    set(USER_HOME $ENV{USERPROFILE})
    set(HOST_EXECUTABLE_SUFFIX ".exe")
    set(ESP8266_ESPTOOL_COM_PORT COM1 CACHE STRING "COM port to be used by esptool")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
    set(USER_HOME $ENV{HOME})
    set(HOST_EXECUTABLE_PREFIX "")
    set(ESP8266_ESPTOOL_COM_PORT /dev/tty.usbserial CACHE STRING "COM port to be used by esptool")
else()
    message(FATAL_ERROR Unsupported build platform.)
endif()

set(ESP_TOOLCHAIN_DIR /Volumes/ESPToolchain/xtensa-lx106-elf/bin)

file(GLOB_RECURSE ESP8266_XTENSA_C_COMPILERS ${ESP_TOOLCHAIN_DIR}/xtensa-lx106-elf-gcc FOLLOW_SYMLINKS xtensa-lx106-elf-gcc${HOST_EXECUTABLE_SUFFIX})
list(GET ESP8266_XTENSA_C_COMPILERS 0 ESP8266_XTENSA_C_COMPILER)
file(GLOB_RECURSE ESP8266_XTENSA_CXX_COMPILERS ${ESP_TOOLCHAIN_DIR}/xtensa-lx106-elf-gcc FOLLOW_SYMLINKS xtensa-lx106-elf-g++${HOST_EXECUTABLE_SUFFIX})
list(GET ESP8266_XTENSA_CXX_COMPILERS 0 ESP8266_XTENSA_CXX_COMPILER)
file(GLOB_RECURSE ESP8266_XTENSA_SIZES ${ESP_TOOLCHAIN_DIR}/xtensa-lx106-elf-size FOLLOW_SYMLINKS xtensa-lx106-elf-size${HOST_EXECUTABLE_SUFFIX})
list(GET ESP8266_XTENSA_SIZES 0 ESP8266_XTENSA_SIZE)
file(GLOB_RECURSE ESP8266_ESPTOOLS /Volumes/ESPToolchain/esptool FOLLOW_SYMLINKS esptool${HOST_EXECUTABLE_NAME})
list(GET ESP8266_ESPTOOLS 0 ESP8266_ESPTOOL)

message("Using " ${ESP8266_XTENSA_C_COMPILER} " C compiler.")
message("Using " ${ESP8266_XTENSA_CXX_COMPILER} " C++ compiler.")
message("Using " ${ESP8266_ESPTOOL} " esptool binary.")

set(CMAKE_C_COMPILER ${ESP8266_XTENSA_C_COMPILER})
set(CMAKE_CXX_COMPILER ${ESP8266_XTENSA_CXX_COMPILER})

# Optimization flags
set(OPTIMIZATION_FLAGS "-Os -g")

# Flags which control code generation and dependency generation, both for C and C++
set(COMMON_FLAGS "-ffunction-sections -fdata-sections -falign-functions=4 \
                  -mlongcalls \
                  -nostdlib \
                  -mtext-section-literals \
                  -DICACHE_FLASH \
                  -D__ets__")

# Warnings-related flags relevant C
set(COMMON_WARNING_FLAGS "-Wpointer-arith \
                          -Wno-implicit-function-declaration \
                          -Wundef")

set(CMAKE_C_FLAGS "-std=gnu99 \
                   -fno-inline-functions \
                   -pipe \
                   ${OPTIMIZATION_FLAGS} \
                   ${COMMON_FLAGS} \
                   ${COMMON_WARNING_FLAGS}")

set(CMAKE_CXX_FLAGS "-std=gnu++11 \
                     -fno-exceptions \
                     -fno-rtti \
                     -MMD \
                     ${OPTIMIZATION_FLAGS} \
                     ${COMMON_FLAGS}")

set(CMAKE_EXE_LINKER_FLAGS "-nostdlib -Wl,--no-check-sections -Wl,-static -Wl,--gc-sections")

set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> -o <TARGET> -Wl,--start-group <OBJECTS> <LINK_LIBRARIES> -lc -Wl,--end-group")
set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> -o <TARGET> -Wl,--start-group <OBJECTS> <LINK_LIBRARIES> -lc -Wl,--end-group")
