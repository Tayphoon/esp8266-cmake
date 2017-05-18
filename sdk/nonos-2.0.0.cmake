if(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
    set(ESP8266_SDK_BASE ${USER_HOME}/git/esp-open-sdk/sdk CACHE PATH "Path to the ESP8266 SDK")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
    set(ESP8266_SDK_BASE ${USER_HOME}/dev/projects/esp-open-sdk CACHE PATH "Path to the ESP8266 SDK")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
    set(ESP8266_SDK_BASE /Volumes/ESPToolchain/sdk/ CACHE PATH "Path to the ESP8266 SDK")
else()
    message(FATAL_ERROR "Unsupported build platforom.")
endif()


if (ESP8266_FLASH_SIZE MATCHES "512K")
    set_target_properties(firmware PROPERTIES
        LINK_FLAGS "-L${ESP8266_SDK_BASE}/ld -Teagle.app.v6.ld"
    )
    set(FW_ADDR_1 0x00000)
    set(FW_ADDR_2 0x40000)
elseif (ESP8266_FLASH_SIZE MATCHES "1M")
    set_target_properties(firmware PROPERTIES
        LINK_FLAGS "-L${ESP8266_SDK_BASE}/ld -Teagle.app.v6.new.1024.app1.ld"
    )
    set(FW_ADDR_1 0x00000)
    set(FW_ADDR_2 0x01010)
elseif (ESP8266_FLASH_SIZE MATCHES "2M")
    set_target_properties(firmware PROPERTIES
            LINK_FLAGS "-L${ESP8266_SDK_BASE}/ld -Teagle.app.v6.new.2048.ld"
            )
    set(FW_ADDR_1 0x00000)
    set(FW_ADDR_2 0x01010)
elseif(ESP8266_FLASH_SIZE MATCHES "4M")
    set_target_properties(firmware PROPERTIES
            LINK_FLAGS "-L${ESP8266_SDK_BASE}/ld -Teagle.app.v6.ld"
            )
    set(FW_ADDR_1 0x00000)
    set(FW_ADDR_2 0x40000)
else()
    message(FATAL_ERROR "Unsupported flash size")
endif()

target_include_directories(ESP8266_SDK INTERFACE
    ${ESP8266_SDK_BASE}/include
    ${ESP8266_SDK_BASE}/include/json
)

find_library(ESP8266_SDK_LIB_AT at ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_CRYPTO crypto ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_ESPNOW espnow ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_JSON json ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_LWIP lwip ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_MAIN main ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_MESH mesh ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_NET80211 net80211 ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_PHY phy ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_PP pp ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_PWM pwm ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_SMARTCONFIG smartconfig ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_SSL ssl ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_WPA wpa ${ESP8266_SDK_BASE}/lib)
find_library(ESP8266_SDK_LIB_WPS wps ${ESP8266_SDK_BASE}/lib)

target_link_libraries(ESP8266_SDK INTERFACE
    gcc
    ${ESP8266_SDK_LIB_AT}
    ${ESP8266_SDK_LIB_CRYPTO}
    ${ESP8266_SDK_LIB_ESPNOW}
    ${ESP8266_SDK_LIB_JSON}
    ${ESP8266_SDK_LIB_LWIP}
    ${ESP8266_SDK_LIB_MAIN}
    ${ESP8266_SDK_LIB_MESH}
    ${ESP8266_SDK_LIB_NET80211}
    ${ESP8266_SDK_LIB_PHY}
    ${ESP8266_SDK_LIB_PP}
    ${ESP8266_SDK_LIB_PWM}
    ${ESP8266_SDK_LIB_SMARTCONFIG}
    ${ESP8266_SDK_LIB_SSL}
    ${ESP8266_SDK_LIB_WPA}
    ${ESP8266_SDK_LIB_WPS}
)

add_custom_target(
    firmware_binary ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_SOURCE_DIR}/firmware
    COMMAND ${ESP8266_XTENSA_SIZE} -A $<TARGET_FILE:firmware>
    COMMAND ${ESP8266_ESPTOOL} -bz ${ESP8266_FLASH_SIZE} -eo $<TARGET_FILE:firmware> -bo ${PROJECT_SOURCE_DIR}/firmware/firmware_${FW_ADDR_1}.bin -bs .text -bs .data -bs .rodata -bc -ec -eo $<TARGET_FILE:firmware> -es .irom0.text ${PROJECT_SOURCE_DIR}/firmware/firmware_${FW_ADDR_2}.bin -ec
    #COMMAND ${ESP8266_ESPTOOL} elf2image -o ${PROJECT_SOURCE_DIR}/firmware/firmware_ $<TARGET_FILE:firmware>
)

get_directory_property(extra_clean_files ADDITIONAL_MAKE_CLEAN_FILES)
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${extra_clean_files};${PROJECT_SOURCE_DIR}/firmware/firmware_${FW_ADDR_1}.bin;${PROJECT_SOURCE_DIR}/firmware/firmware_${FW_ADDR_2}.bin")

add_dependencies(firmware_binary firmware)

add_custom_target(flash COMMAND ${ESP8266_ESPTOOL} -vv -cp ${ESP8266_ESPTOOL_COM_PORT} -cd nodemcu -cb 115200 -ca ${FW_ADDR_1} -cf  ${PROJECT_SOURCE_DIR}/firmware/firmware_${FW_ADDR_1}.bin -ca ${FW_ADDR_2} -cf ${PROJECT_SOURCE_DIR}/firmware/firmware_${FW_ADDR_2}.bin)
#add_custom_target(flash COMMAND ${ESP8266_ESPTOOL} --port ${ESP8266_ESPTOOL_COM_PORT} write_flash ${FW_ADDR_1} ${PROJECT_SOURCE_DIR}/firmware/firmware_${FW_ADDR_1}.bin ${FW_ADDR_2} ${PROJECT_SOURCE_DIR}/firmware/firmware_${FW_ADDR_2}.bin)

add_dependencies(flash firmware_binary)