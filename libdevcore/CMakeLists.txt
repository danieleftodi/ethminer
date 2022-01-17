file(GLOB HEADERS "*.h")
file(GLOB SOURCES "*.cpp")

if(APPLE)
    if(CMAKE_SYSTEM_VERSION MATCHES "19.6.0")
        message(STATUS "[Apple ] Found macOS 10.15.7 Catalina (uname -r: ${CMAKE_SYSTEM_VERSION})")
        set(MACOSX_DEPLOYMENT_TARGET 10.15)
        set(CMAKE_OSX_DEPLOYMENT_TARGET 10.15)
        set(CMAKE_OSX_ARCHITECTURES x86_64)
    elseif(CMAKE_SYSTEM_VERSION MATCHES "20.6.0")
        message(STATUS "[Apple ] Found macOS 11.6.2 Big Sur (uname -r: ${CMAKE_SYSTEM_VERSION})")
        set(MACOSX_DEPLOYMENT_TARGET 11.3)
        set(CMAKE_OSX_DEPLOYMENT_TARGET 11.3)
        #
        # Cross-compile doesn't work right now. 
        # Because of libraries that haven't updated their
        # CMake settings for Universal support: jsoncpp ethash CLI11
        #set(CMAKE_OSX_ARCHITECTURES arm64;x86_64)
        #
        # Use this until packgaes have added support
        set(CMAKE_OSX_ARCHITECTURES ${CMAKE_SYSTEM_PROCESSOR})
    elseif(CMAKE_SYSTEM_VERSION MATCHES "21.2.0")
        message(STATUS "[Apple ] Found macOS 12.1 Monterey (uname -r: ${CMAKE_SYSTEM_VERSION})")
        set(MACOSX_DEPLOYMENT_TARGET 12.1)
        set(CMAKE_OSX_DEPLOYMENT_TARGET 12.1)
        #
        # Cross-compile doesn't work right now. 
        # Because of libraries that haven't updated their
        # CMake settings for Universal support: jsoncpp ethash
        #set(CMAKE_OSX_ARCHITECTURES arm64;x86_64)
        #
        # Use this until packgaes have added support
        set(CMAKE_OSX_ARCHITECTURES ${CMAKE_SYSTEM_PROCESSOR})
    else()
        message(STATUS "[Apple ] Found macOS *** (uname -r: ${CMAKE_SYSTEM_VERSION})")
        set(CMAKE_OSX_ARCHITECTURES ${CMAKE_SYSTEM_PROCESSOR})
    endif()
endif()

find_package(Threads)

add_library(devcore ${SOURCES} ${HEADERS})
target_link_libraries(devcore PUBLIC Boost::boost Boost::system)
target_link_libraries(devcore PRIVATE Threads::Threads)

