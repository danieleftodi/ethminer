cmake_minimum_required(VERSION 3.5)

include(cmake/cable/bootstrap.cmake)

include(CableBuildInfo)
include(CableBuildType)
include(CableToolchains)
include(HunterGate)

include(defaults/HunterCacheServers)

cable_configure_toolchain(DEFAULT cxx11)

set(HUNTER_CONFIGURATION_TYPES Release CACHE STRING "Build type of Hunter packages")
set(HUNTER_JOBS_NUMBER 6 CACHE STRING "Number of parallel builds used by Hunter")
HunterGate(
    URL "https://github.com/cpp-pm/hunter/archive/v0.23.321.tar.gz"
    SHA1 "5e53cbb0429037ea8e2592bfd92704b8ff3ab492"
    LOCAL
)

project(ethminer)

set(PROJECT_VERSION 0.19.2)

cable_set_build_type(DEFAULT Release CONFIGURATION_TYPES Release RelWithDebInfo)

option(ETHASHCL "Build with OpenCL mining" ON)
option(ETHASHCUDA "Build with CUDA mining" ON)
option(ETHASHCPU "Build with CPU mining (only for development)" OFF)
option(ETHDBUS "Build with D-Bus support" OFF)
option(APICORE "Build with API Server support" ON)
option(BINKERN "Install AMD binary kernels" ON)
option(DEVBUILD "Log developer metrics" OFF)
option(USE_SYS_OPENCL "Build with system OpenCL" OFF)

# propagates CMake configuration options to the compiler
function(configureProject)
    if (ETHASHCL)
        add_definitions(-DETH_ETHASHCL)
    endif()
    if (ETHASHCUDA)
        add_definitions(-DETH_ETHASHCUDA)
    endif()
    if (ETHASHCPU)
        add_definitions(-DETH_ETHASHCPU)
    endif()
    if (ETHDBUS)
        add_definitions(-DETH_DBUS)
    endif()
    if (APICORE)
        add_definitions(-DAPI_CORE)
    endif()
    if (BINKERN)
        add_definitions(-DBIN_KERN)
    endif()
    if (DEVBUILD)
        add_definitions(-DDEV_BUILD)
    endif()
    if (USE_SYS_OPENCL)
        add_definitions(-DUSE_SYS_OPENCL)
    endif()
endfunction()

if(APPLE)
    set(USE_SYS_OPENCL ON)
    message(STATUS "[Apple ] CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}")
    message(STATUS "[Apple ] CMAKE_OSX_SYSROOT: ${CMAKE_OSX_SYSROOT}")
    message(STATUS "[Apple ] MACOSX_DEPLOYMENT_TARGET: ${MACOSX_DEPLOYMENT_TARGET}")
    message(STATUS "[Apple ] CMAKE_OSX_DEPLOYMENT_TARGET: ${CMAKE_OSX_DEPLOYMENT_TARGET}")
    message(STATUS "[Apple ] CMAKE_OSX_ARCHITECTURES ${CMAKE_OSX_ARCHITECTURES}")
    message(STATUS "[Apple ] CMAKE_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR}")
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

hunter_add_package(Boost COMPONENTS system filesystem thread)
find_package(Boost CONFIG REQUIRED COMPONENTS system filesystem thread)

hunter_add_package(jsoncpp)
find_package(jsoncpp CONFIG REQUIRED)

hunter_add_package(ethash)
find_package(ethash CONFIG REQUIRED)

configureProject()

message("----------------------------------------------------------------------------")
message("-- CMake ${CMAKE_VERSION}")
message("-- Build ${CMAKE_BUILD_TYPE} / ${CMAKE_SYSTEM_NAME}")
message("----------------------------------------------------------------- components")
message("-- ETHASHCL         Build OpenCL components                      ${ETHASHCL}")
message("-- ETHASHCUDA       Build CUDA components                        ${ETHASHCUDA}")
message("-- ETHASHCPU        Build CPU components (only for development)  ${ETHASHCPU}")
message("-- ETHDBUS          Build D-Bus components                       ${ETHDBUS}")
message("-- APICORE          Build API Server components                  ${APICORE}")
message("-- BINKERN          Install AMD binary kernels                   ${BINKERN}")
message("-- DEVBUILD         Build with dev logging                       ${DEVBUILD}")
message("-- USE_SYS_OPENCL   Build with system OpenCL                     ${USE_SYS_OPENCL}")
message("----------------------------------------------------------------------------")
message("")

include(EthCompilerSettings)
if(UNIX AND NOT APPLE)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libstdc++")
endif()

cable_add_buildinfo_library(PROJECT_NAME ${PROJECT_NAME})

add_subdirectory(libdevcore)
add_subdirectory(libethcore)
add_subdirectory(libhwmon)
add_subdirectory(libpoolprotocols)

if (ETHASHCL)
    add_subdirectory(libethash-cl)
    if (BINKERN)
        add_subdirectory(libethash-cl/kernels)
    endif()
endif ()
if (ETHASHCUDA)
    add_subdirectory(libethash-cuda)
endif ()
if (ETHASHCPU)
    add_subdirectory(libethash-cpu)
endif ()
if (APICORE)
    add_subdirectory(libapicore)
endif()

add_subdirectory(ethminer)


if(WIN32)
    set(CPACK_GENERATOR ZIP)
else()
    set(CPACK_GENERATOR TGZ)
endif()
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_CHECKSUM SHA256)
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
include(CPack)
