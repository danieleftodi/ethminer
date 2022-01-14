file(GLOB HEADERS "*.h")
file(GLOB SOURCES "*.cpp")

if(APPLE)
    if(CMAKE_SYSTEM_VERSION MATCHES "19.6.0")
        message(STATUS "Found macOS 10.15.7 Catalina (uname -r: ${CMAKE_SYSTEM_VERSION})")
        set(CMAKE_OSX_DEPLOYMENT_TARGET 10.15)
        set(CMAKE_OSX_ARCHITECTURES x86_64)
    elseif(CMAKE_SYSTEM_VERSION MATCHES "21.2.0")
        message(STATUS "Found macOS 12.1 Monterey (uname -r: ${CMAKE_SYSTEM_VERSION})")
        set(CMAKE_OSX_DEPLOYMENT_TARGET 12.1)
        set(CMAKE_OSX_ARCHITECTURES arm64;x86_64)
    else()
        message(STATUS "Found macOS *** (uname -r: ${CMAKE_SYSTEM_VERSION})")
        set(CMAKE_OSX_ARCHITECTURES x86_64)
    endif()
endif()

find_package(Threads)

add_library(devcore ${SOURCES} ${HEADERS})
target_link_libraries(devcore PUBLIC Boost::boost Boost::system)
target_link_libraries(devcore PRIVATE Threads::Threads)

