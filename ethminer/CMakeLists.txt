cmake_policy(SET CMP0015 NEW)

aux_source_directory(. SRC_LIST)

include_directories(BEFORE ..)

set(EXECUTABLE ethminer)

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

file(GLOB HEADERS "*.h")

add_executable(${EXECUTABLE} ${SRC_LIST} ${HEADERS})
if(MSVC)
	target_sources(${EXECUTABLE} PRIVATE ethminer.rc)
endif()

hunter_add_package(CLI11)
find_package(CLI11 CONFIG REQUIRED)

target_link_libraries(ethminer PRIVATE ethcore poolprotocols devcore ethminer-buildinfo CLI11::CLI11 Boost::system Boost::thread)

if(ETHDBUS)
	find_package(PkgConfig)
	set( ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:/usr/lib/x86_64-linux-gnu/pkgconfig" )
	pkg_check_modules(DBUS dbus-1)
	include_directories(${DBUS_INCLUDE_DIRS})
	link_directories(${DBUS_LIBRARY_DIRS})
	target_link_libraries(ethminer PRIVATE ${DBUS_LIBRARIES})
endif()

if(APICORE)
	target_link_libraries(ethminer PRIVATE apicore)
endif()

include(GNUInstallDirs)
install(TARGETS ethminer DESTINATION ${CMAKE_INSTALL_BINDIR})
if(MSVC)
    install(FILES $<TARGET_PDB_FILE:ethminer> DESTINATION ${CMAKE_INSTALL_BINDIR} OPTIONAL)
endif()
